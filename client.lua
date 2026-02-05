-- Client Script (client.lua)

local Bridge = exports['community_bridge']:Bridge()
local Framework = Bridge and Bridge.Framework or nil
local Inventory = Bridge and Bridge.Inventory or nil
local HelpText = Bridge and Bridge.HelpText or nil

local shownText = false

-- Helper function to check if a value exists in a table
local function tableContains(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

local function ShowTextUI(text)
    if Config.TextUI == 'arp_ui' then
        return exports['arp_ui']:Show('E', text)
    end
    if HelpText and HelpText.ShowHelpText then
        return HelpText.ShowHelpText(text, 'left')
    end
    if Bridge and Bridge.Notify and Bridge.Notify.ShowHelpText then
        return Bridge.Notify.ShowHelpText(text, 'left')
    end
end

local function HideTextUI()
    if Config.TextUI == 'arp_ui' then
        return exports['arp_ui']:Hide()
    end
    if HelpText and HelpText.HideHelpText then
        return HelpText.HideHelpText()
    end
    if Bridge and Bridge.Notify and Bridge.Notify.HideHelpText then
        return Bridge.Notify.HideHelpText()
    end
end

local function getPlayerIdentifier()
    if Framework and Framework.GetPlayerIdentifier then
        return Framework.GetPlayerIdentifier()
    end
end

local function getPlayerJobData()
    if Framework and Framework.GetPlayerJobData then
        return Framework.GetPlayerJobData()
    end
    return {}
end

local function playerHasItem(item)
    if Inventory and Inventory.HasItem then
        return Inventory.HasItem(item)
    end
    if Framework and Framework.HasItem then
        return Framework.HasItem(item)
    end
    return false
end

local function canAccessFloor(floor)
    local playerIdentifier = getPlayerIdentifier()
    local jobData = getPlayerJobData()

    -- Check for Citizen ID
    if floor.citizenIDs and #floor.citizenIDs > 0 then
        if not playerIdentifier or not tableContains(floor.citizenIDs, playerIdentifier) then
            return false -- Deny access if the player's Citizen ID is not allowed
        end
    end

    -- Check for jobs
    if floor.jobs then
        local hasJob = false
        for job, grade in pairs(floor.jobs) do
            if jobData.jobName == job and (jobData.gradeRank or 0) >= grade then
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
            if playerHasItem(item) then
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
                if jobData.jobName == job and (jobData.gradeRank or 0) >= grade then
                    hasJob = true
                end
            end
        end

        if floor.items then
            for _, item in ipairs(floor.items) do
                if playerHasItem(item) then
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

CreateThread(function()
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
                        if Config.TextUI == 'arp_ui' then
                            ShowTextUI(text)
                        else
                            ShowTextUI("[E] " .. text)
                        end
                        shownText = true
                    end

                    if IsControlJustReleased(0, 38) then
                        openElevatorMenu(elevator)
                    end
                end
            end
        end

        if not isNearElevator and shownText then
            HideTextUI()
            shownText = false
        end

        Wait(sleep)
    end
end)
