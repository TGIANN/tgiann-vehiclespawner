# tgiann-vehiclespawner

**Requirements**
This resource requires OneSync to be enabled on the server!

**Usage**  
-carModel: Vehicle hash or model name  
-coords ex: {x=123.0, y=123.0, z=123.0, h=250.0}  
-isnetworked: false or true  

```
exports["tgiann-vehiclespawner"]:SpawnVehicle(carModel, function(veh)
     SetPedIntoVehicle(PlayerPedId(), veh, -1) 
end, coords, isnetworked)
```
