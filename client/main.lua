local CurrentRequestId = 0
local ServerCallbacks = {}

RegisterNetEvent('Tgiann:Client:TriggerCallback')
AddEventHandler('Tgiann:Client:TriggerCallback', function(requestId, ...)
	if ServerCallbacks[requestId] ~= nil then
		ServerCallbacks[requestId](...)
		ServerCallbacks[requestId] = nil
	end
end)

function TriggerCallback(name, cb, ...)
	ServerCallbacks[CurrentRequestId] = cb
	TriggerServerEvent("Tgiann:Server:TriggerCallback", name, CurrentRequestId, ...)
	
	if CurrentRequestId < 65535 then
		CurrentRequestId = CurrentRequestId + 1
	else
		CurrentRequestId = 0
	end
end

-- carModel: Vehicle hash or model name
-- coords ex: {x=123.0, y=123.0, z=123.0, h=250.0}
-- isnetworked: false or true
-- exports["tgiann-vehiclespawner"]:SpawnVehicle("kuruma", function(veh) SetPedIntoVehicle(PlayerPedId(), veh, -1) end, {x=123.0, y=123.0, z=123.0, h=250.0}, true)
function SpawnVehicle(carModel, cb, coords, isnetworked)
	Citizen.CreateThread(function()
		local model = (type(carModel) == "number" and carModel or GetHashKey(carModel))
		if not IsModelValid(model) then return end
		RequestModel(model)
		while not HasModelLoaded(model) do Citizen.Wait(1) end

		if coords == nil then
            local playerPed = PlayerPedId()
			local playerCoords = GetEntityCoords(playerPed) -- get the position of the local player ped
			coords = {x=playerCoords.x, y=playerCoords.y, z=playerCoords.z, h=GetEntityHeading(playerPed)}
		end
		
		local vehicle = nil
		if isnetworked then
			TriggerCallback("Tgiann:SpawnCar", function(spawned_car)
				vehicle = NetworkGetEntityFromNetworkId(spawned_car)
				SetNetworkIdExistsOnAllMachines(spawned_car, true)
				SetNetworkIdCanMigrate(spawned_car, true)
				setVehicleData(vehicle, coords)
			end, model, coords)
		else
			vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, coords.h, false, false)
			setVehicleData(vehicle, coords)
		end

		SetModelAsNoLongerNeeded(model)

		if cb then 
			while vehicle == nil do Citizen.Wait(0) end
			cb(vehicle)
		end
	end)
end

function setVehicleData(vehicle, coords)
	SetVehRadioStation(vehicle, "OFF")
	SetVehicleHasBeenOwnedByPlayer(vehicle, true)
	SetEntityAsMissionEntity(vehicle, true, false)
	SetVehicleNeedsToBeHotwired(vehicle, false)
	RequestCollisionAtCoord(coords.x, coords.y, coords.z)
	local timeout = 0
	while not HasCollisionLoadedAroundEntity(vehicle) and timeout < 2000 do -- we can get stuck here if any of the axies are "invalid"
		Citizen.Wait(0)
		timeout = timeout + 1
	end
end

RegisterCommand("sv", function(source, args) -- Test Command
	if args[1] then -- args1: vehicle model name
		SpawnVehicle(args[1], function(vehicle)
			SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
		end, nil, true)
	end
end)