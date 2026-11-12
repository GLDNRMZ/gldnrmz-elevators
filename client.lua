local Config = require 'config'

local INTERACT_KEY = 38 -- E
local MENU_ID = 'gldnrmz_elevator_menu'
local COLLISION_TIMEOUT = 5000

local Bridge = Config.TextUI == 'bridge' and exports.community_bridge:Bridge() or nil

local insidePoints = {} -- every floor point the player is standing in
local activePoint       -- the one that owns the prompt and the E key
local promptText        -- text currently on screen, nil when hidden
local busy = false      -- a menu request or trip is in progress

-- Prompt -------------------------------------------------------------------

local function hidePrompt()
    if not promptText then return end

    if Config.TextUI == 'arp_ui' then
        -- Pass the text so only our entry is removed; Hide() alone clears every script's prompt.
        pcall(function() exports.arp_ui:Hide(promptText) end)
    elseif Config.TextUI == 'ox_lib' then
        lib.hideTextUI()
    elseif Bridge and Bridge.HelpText then
        pcall(Bridge.HelpText.HideHelpText)
    end

    promptText = nil
end

local function showPrompt(text)
    if promptText == text then return end
    hidePrompt()

    if Config.TextUI == 'arp_ui' then
        pcall(function() exports.arp_ui:Show('E', text) end)
    elseif Config.TextUI == 'ox_lib' then
        lib.showTextUI(('[E] %s'):format(text))
    elseif Bridge and Bridge.HelpText then
        pcall(Bridge.HelpText.ShowHelpText, ('[E] %s'):format(text), 'left')
    end

    promptText = text
end

-- Helpers ------------------------------------------------------------------

-- Other scripts (e.g. gldnrmz-phas inside its haunted house) set this local state to hide our prompts.
local function suppressed()
    return LocalPlayer.state.hideInteractions == true
end

local function canInteract()
    local ped = cache.ped
    return not busy
        and not suppressed()
        and not cache.vehicle
        and not IsEntityDead(ped)
        and not IsPedCuffed(ped)
        and not IsPedRagdoll(ped)
end

local function notify(message)
    lib.notify({ description = message, type = 'error' })
end

local function fetchAccess(point)
    return lib.callback.await('gldnrmz-elevators:server:getAccess', false, point.elevatorId, point.floorIndex)
end

-- Ask the server whether this floor is usable and show or hide the prompt.
local function refreshPoint(point)
    if suppressed() then return hidePrompt() end
    CreateThread(function()
        local access = fetchAccess(point)
        if activePoint ~= point then return end -- player walked off while we waited
        if suppressed() then return hidePrompt() end

        point.hasAccess = access ~= nil
        if point.hasAccess then
            showPrompt(point.floor.prompt or Config.Text.prompt)
        else
            hidePrompt()
        end
    end)
end

-- Teleport -----------------------------------------------------------------

local function teleport(floor)
    local ped = cache.ped
    local coords = floor.coords

    DoScreenFadeOut(500)
    local fadeDeadline = GetGameTimer() + 1500
    while not IsScreenFadedOut() and GetGameTimer() < fadeDeadline do Wait(0) end

    local started = GetGameTimer()
    FreezeEntityPosition(ped, true)
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(ped, floor.heading or 0.0)

    -- Wait for the ground to load so players don't fall through interiors.
    local collisionDeadline = GetGameTimer() + COLLISION_TIMEOUT
    while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < collisionDeadline do
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        Wait(0)
    end

    local remaining = Config.WaitTime - (GetGameTimer() - started)
    if remaining > 0 then Wait(remaining) end

    FreezeEntityPosition(ped, false)
    DoScreenFadeIn(500)
end

local function travel(point, toIndex)
    if busy then return end
    busy = true

    local allowed = lib.callback.await('gldnrmz-elevators:server:travel', false,
        point.elevatorId, point.floorIndex, toIndex)

    if allowed then
        hidePrompt()
        teleport(Config.Elevators[point.elevatorId][toIndex])
    else
        notify(Config.Text.denied)
    end

    busy = false
end

-- Menu ---------------------------------------------------------------------

local function openMenu(point)
    busy = true
    local access = fetchAccess(point)
    busy = false

    if not access then
        point.hasAccess = false
        hidePrompt()
        notify(Config.Text.unavailable)
        return
    end

    local options = {}

    for index, floor in ipairs(Config.Elevators[point.elevatorId]) do
        local isCurrent = index == point.floorIndex
        local allowed = access[index]

        if allowed or Config.ShowLockedFloors then
            local level, label = floor.level or ('Floor %d'):format(index), floor.label
            local title, description = level, label
            if floor.menuFormat == 'labelTop' and label and label ~= '' then
                title, description = label, level
            end

            options[#options + 1] = {
                title = title,
                description = description ~= '' and description or nil,
                icon = isCurrent and 'location-dot' or (allowed and 'elevator' or 'lock'),
                disabled = isCurrent or not allowed,
                onSelect = function() travel(point, index) end,
            }
        end
    end

    lib.registerContext({
        id = MENU_ID,
        title = Config.Text.menuTitle,
        options = options,
    })
    lib.showContext(MENU_ID)
end

-- Points -------------------------------------------------------------------

local function onEnter(self)
    insidePoints[self] = true
    activePoint = self
    refreshPoint(self)
end

local function onExit(self)
    insidePoints[self] = nil
    if activePoint ~= self then return end

    activePoint = next(insidePoints)
    if activePoint then
        refreshPoint(activePoint)
    else
        hidePrompt()
        if lib.getOpenContextMenu() == MENU_ID then lib.hideContext(false) end
    end
end

local function nearby(self)
    if activePoint ~= self or not self.hasAccess then return end
    if IsControlJustReleased(0, INTERACT_KEY) and canInteract() then
        CreateThread(function() openMenu(self) end)
    end
end

for elevatorId, floors in pairs(Config.Elevators) do
    for floorIndex, floor in ipairs(floors) do
        if type(floor.coords) == 'vector3' then
            lib.points.new({
                coords = floor.coords,
                distance = floor.radius or Config.DefaultRadius,
                elevatorId = elevatorId,
                floorIndex = floorIndex,
                floor = floor,
                onEnter = onEnter,
                onExit = onExit,
                nearby = nearby,
            })
        end
    end
end

-- Hide or bring back the prompt the moment another script toggles hideInteractions.
AddStateBagChangeHandler('hideInteractions', ('player:%s'):format(cache.serverId), function(_, _, value)
    if value then
        hidePrompt()
        if lib.getOpenContextMenu() == MENU_ID then lib.hideContext(false) end
    elseif activePoint then
        SetTimeout(0, function()
            if activePoint and not suppressed() then refreshPoint(activePoint) end
        end)
    end
end)

-- Never leave the player frozen, blacked out, or with a stuck prompt on restart.
AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    hidePrompt()
    if busy then
        FreezeEntityPosition(cache.ped, false)
        DoScreenFadeIn(0)
    end
end)
