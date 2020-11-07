local ServerCallbacks = {}

RegisterServerEvent("Tgiann:Server:TriggerCallback")
AddEventHandler('Tgiann:Server:TriggerCallback', function(name, requestId, ...)
	local src = source
	TriggerCallback(name, requestId, src, function(...)
		TriggerClientEvent("Tgiann:Client:TriggerCallback", src, requestId, ...)
	end, ...)
end)

function CreateCallback(name, cb)
	ServerCallbacks[name] = cb
end

function TriggerCallback(name, requestId, source, cb, ...)
	if ServerCallbacks[name] ~= nil then
		ServerCallbacks[name](source, cb, ...)
	end
end

CreateCallback("Tgiann:SpawnCar", function(source, cb, model, coords)
	local spawned_car = CreateVehicle(model, coords.x, coords.y, coords.z, coords.h, true, true)
	local osTime = os.time()
	while not DoesEntityExist(spawned_car) do 
		Citizen.Wait(0) 
		if os.time() > osTime + 5 then break end
	end
    cb(NetworkGetNetworkIdFromEntity(spawned_car))
end)