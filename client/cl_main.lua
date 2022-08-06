local Mercy, LoggedIn = Config.CoreExport, false
local CurrentStorageId = nil

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Citizen.SetTimeout(1250, function() 
        Mercy.Functions.TriggerCallback('mc-storage/server/get-config', function(ConfigData)
           Config = ConfigData
        end)
        Citizen.Wait(250)
        TriggerServerEvent('mc-storage/server/setup-containers')
        Citizen.Wait(450)
        LoggedIn = true
    end)
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    LoggedIn = false
end)

-- [ Code ] --

-- [ Threads ] --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn then
            local NearStorage = false
            for k, v in pairs(Config.StorageContainers) do
                local Distance = #(GetEntityCoords(PlayerPedId()) - vector3(v['Coords']['X'], v['Coords']['Y'], v['Coords']['Z']))
                print(Distance)
                if Distance <= 3.5 and IsAuthorized(v['Owner'], v['KeyHolders']) then
                    NearStorage = true
                    DrawMarker(2, v['Coords']['X'], v['Coords']['Y'], v['Coords']['Z'], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.1, 0.05, 242, 148, 41, 255, false, false, false, 1, false, false, false)
                    DrawText3D(v['Coords']['X'], v['Coords']['Y'], v['Coords']['Z'] + 0.15, '~g~E~s~ - Storage ('..v['SName']..')')
                    if IsControlJustReleased(0, 38) then
                        CurrentStorageId = v['SName']
                        OpenKeyPad()
                    end
                end
            end
            if not NearStorage then
                Citizen.Wait(450)
            end
        else
            Citizen.Wait(450)
        end
    end
end)


-- [ Functions ] --

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

function IsAuthorized(CitizenId, KeyHolders)
    local Retval = false
    if Mercy.Functions.GetPlayerData().citizenid == CitizenId then
        Retval = true
    end
    return Retval
end

function OpenKeyPad()
    SendNUIMessage({
        action = "open"
    })
    SetNuiFocus(true, true)    
end

local function OpenStorage(StorageId)
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "storage_"..StorageId, {
        maxweight = Config.MaxStashWeight,
        slots = Config.StashSlots,
    })
    TriggerEvent("inventory:client:SetCurrentStash", "storage_"..StorageId)
end

local function IsRealEstate()
    local Retval = false
    if Mercy.Functions.GetPlayerData().job.name == Config.EstateJob then
      Retval = true
    end
    return Retval
end

-- RegisterCommand('keypad', function(source, args, RawCommand)
--     OpenKeyPad()
-- end)

-- [ NUI Callbacks ] --

RegisterNUICallback("CheckPincode", function(data, cb)
    Mercy.Functions.TriggerCallback('mc-storage/server/check-pincode', function(AcceptedPincode)
        if AcceptedPincode then
            OpenStorage(CurrentStorageId)
        else
            Mercy.Functions.Notify('You have entered a wrong pincode..', 'error')
        end
    end, tonumber(data.pincode), CurrentStorageId)
end)

RegisterNUICallback("Close", function(data, cb)
    SetNuiFocus(false, false)
end)

-- [ Events ] --

RegisterNetEvent('mc-storage/client/create-storage', function(PinCode, TPlayer)
    if IsRealEstate() then
        local PlayerCoords = GetEntityCoords(PlayerPedId())
        local PlayerHeading = GetEntityHeading(PlayerPedId())
        local CoordsTable = {['X'] = PlayerCoords.x, ['Y'] = PlayerCoords.y, ['Z'] = PlayerCoords.z, ['H'] = PlayerHeading}
        TriggerServerEvent('mc-storage/server/add-new-storage', CoordsTable, PinCode, TPlayer)
    else
        Mercy.Functions.Notify('And what are you doing exactly?', 'error')
    end
end)

RegisterNetEvent("mc-storage/client/update-config", function(ContainerData)
    Config.StorageContainers = ContainerData
end)