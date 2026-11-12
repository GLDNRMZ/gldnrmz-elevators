local Config = require 'config'
local Bridge = exports.community_bridge:Bridge()
local Framework = Bridge and Bridge.Framework
local Inventory = Bridge and Bridge.Inventory

local RESOURCE = GetCurrentResourceName()
local DISTANCE_TOLERANCE = 2.0 -- server-side coords lag slightly behind the client
local TRAVEL_COOLDOWN = 1500   -- ms between trips per player

local lastTrip = {}

-- Bridge functions are cross-resource funcrefs (callable tables), so check for nil and pcall.
local function bridgeCall(fn, ...)
    if fn == nil then return nil end
    local ok, result = pcall(fn, ...)
    if not ok then
        lib.print.error(('community_bridge call failed: %s'):format(result))
        return nil
    end
    return result
end

local function isEmpty(tbl)
    return type(tbl) ~= 'table' or next(tbl) == nil
end

local function getFloor(elevatorId, floorIndex)
    if type(elevatorId) ~= 'string' or math.type(floorIndex) ~= 'integer' then return end
    local floors = Config.Elevators[elevatorId]
    return floors and floors[floorIndex]
end

local function isNearFloor(src, floor)
    local ped = GetPlayerPed(src)
    if ped == 0 then return false end
    local radius = floor.radius or Config.DefaultRadius
    return #(GetEntityCoords(ped) - floor.coords) <= radius + DISTANCE_TOLERANCE
end

-- Holds player data for one request so each floor check reuses it
-- instead of asking the framework again.
local function newContext(src)
    return { src = src, items = {} }
end

local function getJob(ctx)
    if ctx.job == nil then
        ctx.job = bridgeCall(Framework and Framework.GetPlayerJobData, ctx.src) or {}
    end
    return ctx.job
end

local function getIdentifier(ctx)
    if ctx.identifier == nil then
        ctx.identifier = bridgeCall(Framework and Framework.GetPlayerIdentifier, ctx.src) or false
    end
    return ctx.identifier
end

local function hasItem(ctx, item)
    local cached = ctx.items[item]
    if cached ~= nil then return cached end

    local result = bridgeCall(Inventory and Inventory.HasItem, ctx.src, item)
    if result == nil then
        result = bridgeCall(Framework and Framework.HasItem, ctx.src, item)
    end
    result = result == true
    ctx.items[item] = result
    return result
end

local function hasJob(ctx, jobs)
    local job = getJob(ctx)
    local minGrade = job.jobName and jobs[job.jobName]
    return minGrade ~= nil and (job.gradeRank or 0) >= minGrade
end

local function hasAnyItem(ctx, items)
    for _, item in ipairs(items) do
        if hasItem(ctx, item) then return true end
    end
    return false
end

local function canAccess(ctx, floor)
    if not isEmpty(floor.citizenIDs) then
        local identifier = getIdentifier(ctx)
        if not identifier or not lib.table.contains(floor.citizenIDs, identifier) then
            return false
        end
    end

    local jobRule = not isEmpty(floor.jobs)
    local itemRule = not isEmpty(floor.items)

    if jobRule and itemRule then
        if floor.jobAndItem then
            return hasJob(ctx, floor.jobs) and hasAnyItem(ctx, floor.items)
        end
        return hasJob(ctx, floor.jobs) or hasAnyItem(ctx, floor.items)
    elseif jobRule then
        return hasJob(ctx, floor.jobs)
    elseif itemRule then
        return hasAnyItem(ctx, floor.items)
    end

    return true
end

-- Returns a per-floor list of booleans (true = reachable), or nil if the
-- player can't use the elevator from where they're standing.
lib.callback.register('gldnrmz-elevators:server:getAccess', function(src, elevatorId, floorIndex)
    local floor = getFloor(elevatorId, floorIndex)
    if not floor or not isNearFloor(src, floor) then return end

    local ctx = newContext(src)
    if not canAccess(ctx, floor) then return end

    local access = {}
    for i, target in ipairs(Config.Elevators[elevatorId]) do
        access[i] = i == floorIndex or canAccess(ctx, target)
    end
    return access
end)

lib.callback.register('gldnrmz-elevators:server:travel', function(src, elevatorId, fromIndex, toIndex)
    local now = GetGameTimer()
    if lastTrip[src] and now - lastTrip[src] < TRAVEL_COOLDOWN then return false end

    local from = getFloor(elevatorId, fromIndex)
    local to = getFloor(elevatorId, toIndex)
    if not from or not to or fromIndex == toIndex then return false end
    if not isNearFloor(src, from) then return false end

    local ctx = newContext(src)
    if not canAccess(ctx, from) or not canAccess(ctx, to) then return false end

    lastTrip[src] = now

    if Config.Debug then
        lib.print.info(('%s (%d) used %s: %s -> %s'):format(
            GetPlayerName(src), src, elevatorId,
            from.level or fromIndex, to.level or toIndex))
    end

    return true
end)

AddEventHandler('playerDropped', function()
    lastTrip[source] = nil
end)

-- Catch config mistakes at startup instead of in game.
local function validateConfig()
    local all = {}

    for elevatorId, floors in pairs(Config.Elevators) do
        if type(floors) ~= 'table' or #floors < 2 then
            lib.print.warn(('Elevator "%s" needs at least two floors.'):format(elevatorId))
        else
            for i, floor in ipairs(floors) do
                if type(floor.coords) ~= 'vector3' then
                    lib.print.warn(('Elevator "%s" floor %d has no valid vector3 coords.'):format(elevatorId, i))
                else
                    all[#all + 1] = { id = elevatorId, index = i, floor = floor }
                end
            end
        end
    end

    -- Overlapping floors from different elevators fight over the same prompt.
    for a = 1, #all do
        for b = a + 1, #all do
            local fa, fb = all[a], all[b]
            if fa.id ~= fb.id then
                local reach = math.max(fa.floor.radius or Config.DefaultRadius, fb.floor.radius or Config.DefaultRadius)
                if #(fa.floor.coords - fb.floor.coords) < reach then
                    lib.print.warn(('"%s" floor %d overlaps "%s" floor %d.'):format(fa.id, fa.index, fb.id, fb.index))
                end
            end
        end
    end
end

local function parseVersion(version)
    local parts = {}
    for n in tostring(version):gmatch('%d+') do parts[#parts + 1] = tonumber(n) end
    return parts
end

local function isNewer(remote, current)
    local r, c = parseVersion(remote), parseVersion(current)
    for i = 1, math.max(#r, #c) do
        local a, b = r[i] or 0, c[i] or 0
        if a ~= b then return a > b end
    end
    return false
end

local function checkVersion()
    local current = GetResourceMetadata(RESOURCE, 'version', 0)
    local url = ('https://raw.githubusercontent.com/GLDNRMZ/%s/main/version.txt'):format(RESOURCE)

    PerformHttpRequest(url, function(status, body)
        if status ~= 200 or not body then
            print(('^3[GLDNRMZ] Unable to check version for %s^0'):format(RESOURCE))
            return
        end

        local latest = body:gsub('%s', '')
        if isNewer(latest, current) then
            print(('^1[GLDNRMZ] %s is out of date! Latest: %s | Current: %s^0'):format(RESOURCE, latest, current))
        else
            print(('^2[GLDNRMZ] %s is up to date! (%s)^0'):format(RESOURCE, current))
        end
    end, 'GET')
end

CreateThread(function()
    validateConfig()
    if Config.VersionCheck then checkVersion() end
end)
