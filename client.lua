-- Client Script (client.lua)

-- Ensure QBCore is initialized
local QBCore = exports['qb-core']:GetCoreObject()

-- Helper function to check if a value exists in a table
local function tableContains(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

local function canAccessFloor(floor)
    local PlayerData = QBCore.Functions.GetPlayerData()

    -- Check for Citizen ID
    if floor.citizenIDs and #floor.citizenIDs > 0 then
        if not tableContains(floor.citizenIDs, PlayerData.citizenid) then
            return false -- Deny access if the player's Citizen ID is not allowed
        end
    end

    -- Check for jobs
    if floor.jobs then
        local hasJob = false
        for job, grade in pairs(floor.jobs) do
            if PlayerData.job and PlayerData.job.name == job and PlayerData.job.grade.level >= grade then
                hasJob = true
                break
            end
        end
        if not hasJob then
            return false -- Deny access if no matching job is found
        end
    end

    -- Check for items
    if floor.items then
        local hasItem = false
        for _, item in ipairs(floor.items) do
            if QBCore.Functions.HasItem(item) then
                hasItem = true
                break
            end
        end
        if not hasItem then
            return false -- Deny access if no required item is found
        end
    end

    -- Check for both jobs and items
    if floor.jobAndItem then
        local hasJob = false
        local hasItem = false

        if floor.jobs then
            for job, grade in pairs(floor.jobs) do
                if PlayerData.job and PlayerData.job.name == job and PlayerData.job.grade.level >= grade then
                    hasJob = true
                end
            end
        end

        if floor.items then
            for _, item in ipairs(floor.items) do
                if QBCore.Functions.HasItem(item) then
                    hasItem = true
                end
            end
        end

        if not (hasJob and hasItem) then
            return false -- Deny access if both job and item requirements are not met
        end
    end

    return true -- Allow access if all configured checks pass
end


local function openElevatorMenu(elevator)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local options = {}

    for _, floor in ipairs(elevator) do
        local distance = #(playerCoords - floor.coords)
        local radius = floor.radius or (Config and Config.DefaultRadius) or 1.0
        local isCurrentFloor = distance < radius

        -- Determine menu title and description based on configuration
        local title, description
        if floor.menuFormat == "labelTop" then
            title = floor.label or "Unknown"
            description = (floor.level or "Unknown")
        else -- Default: floorTop
            title = (floor.level or "Unknown")
            description = floor.label or "Unknown"
        end

        table.insert(options, {
            title = title,
            description = description,
            event = not isCurrentFloor and "elevator:teleport" or nil, -- Disable event if on current floor
            args = floor,
            disabled = isCurrentFloor -- Gray out the current floor
        })
    end

    lib.registerContext({
        id = 'elevator_menu',
        title = 'Elevator Menu',
        options = options,
    })

    lib.showContext('elevator_menu')
end


RegisterNetEvent('elevator:teleport', function(floor)
    DoScreenFadeOut(500)
    Wait(500)

    Wait(Config.WaitTime) -- Configurable wait time

    SetEntityCoords(PlayerPedId(), floor.coords)
    SetEntityHeading(PlayerPedId(), floor.heading)

    Wait(500)
    DoScreenFadeIn(500)
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local isNearElevator = false

        for name, elevator in pairs(Config.Elevators) do
            for _, floor in ipairs(elevator) do
                local distance = #(playerCoords - floor.coords)
                local radius = floor.radius or (Config and Config.DefaultRadius) or 1.0

                if distance < radius and canAccessFloor(floor) then
                    isNearElevator = true
                    sleep = 0
                    
                    if not shownText then
                        local text = floor.prompt or "Use Elevator"
                        exports['arp_ui']:Show('E', text)
                        shownText = true
                    end

                    if IsControlJustReleased(0, 38) then
                        openElevatorMenu(elevator)
                    end
                end
            end
        end

        if not isNearElevator and shownText then
            exports['arp_ui']:Hide()
            shownText = false
        end

        Citizen.Wait(sleep)
    end
end)

local PlayerData = {}
local shellObj
local coords = vec3(675.14, 1330.34, 58.09)
local returnCoords = nil

-- Cache player data and listen for updates
CreateThread(function()
    while not QBCore.Functions.GetPlayerData().job do
        Wait(100)
    end
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    PlayerData.job = job
end)

-- Job check function
local function isRealEstateJob()
    return PlayerData and PlayerData.job and PlayerData.job.name == "realestate"
end

-- Shell spawner
function SpawnShells(model)
    local x, y, z = table.unpack(coords)
    shellObj = CreateObject(GetHashKey(model), x, y, z, false, true, true)
    SetEntityRotation(shellObj, 0, 0, 0, 0, true)
    SetEntityAsMissionEntity(shellObj, true, true)
    FreezeEntityPosition(shellObj, true)
end

-- /spawnshell command
RegisterCommand("spawnshell", function(src, args, raw)
    if not isRealEstateJob() then
        print("^1[Error]^0 You do not have permission to use this command.")
        return
    end

    if shellObj then DeleteObject(shellObj) end

    local model = args[1]
    if not model then
        print("^1[Error]^0 You must specify a model.")
        return
    end

    returnCoords = GetEntityCoords(PlayerPedId())
    SpawnShells(model)

    local x, y, z = table.unpack(coords)
    SetEntityCoords(PlayerPedId(), x, y, z + 1, false, false, false, false)
end, false)

-- /removeshell command
RegisterCommand("removeshell", function()
    if not isRealEstateJob() then
        print("^1[Error]^0 You do not have permission to use this command.")
        return
    end

    if shellObj then
        DeleteObject(shellObj)
        shellObj = nil
    end
end, false)

-- /offset command
RegisterCommand("offset", function()
    if not isRealEstateJob() then
        print("^1[Error]^0 You do not have permission to use this command.")
        return
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)

    local offset = vector3(
        playerCoords.x - coords.x,
        playerCoords.y - coords.y,
        playerCoords.z - coords.z
    )

    local result = string.format("vec4(%.2f, %.2f, %.2f, %.2f)", offset.x, offset.y, offset.z, playerHeading)
    print("^2[Offset]^0 " .. result)
    lib.setClipboard(result)
    QBCore.Functions.Notify("Offset copied to clipboard!", "success")

    if shellObj then
        DeleteObject(shellObj)
        shellObj = nil
    end

    if returnCoords then
        SetEntityCoords(playerPed, returnCoords.x, returnCoords.y, returnCoords.z, false, false, false, false)
        returnCoords = nil
    end
end, false)

-- Clean up if resource stops
AddEventHandler("onClientResourceStop", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    if shellObj then DeleteObject(shellObj) end
end)
