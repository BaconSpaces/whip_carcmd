# WHIP vehicle commands

A small FiveM resource for WHIP (`whip_core`). It provides two admin commands:

- `/car [vehicle_model]` — spawn a temporary vehicle, receive its WHIP key, and be placed in the driver's seat.
- `/dv` — delete the vehicle you are driving, or the closest vehicle within 5 metres if you are on foot.

## Install

1. Put the `whip_car_command` folder in your server's resources directory.
2. Add this to `server.cfg` after `ensure whip_core`:

   ```cfg
   ensure whip_car_command
   ```

3. Grant access to the `group.admin` ACE group:

   ```cfg
   add_ace group.admin command.car allow
   add_ace group.admin command.dv allow
   ```

4. Restart the resource/server.

## Usage

```text
/car sultan
/dv
```

Both commands explicitly check their FiveM ACE permissions on the server. Only members of `group.admin` receive those permissions through the configuration above. WHIP's `SpawnTempVehicle` is used with `forSource = source` and `giveKey = true`, so WHIP issues the spawned vehicle key to the invoking admin. Spawned vehicles are temporary, not owned/saved vehicles.

`/dv` asks the client to identify the vehicle, then the server validates the network entity, vehicle type, admin permission, and distance (within 8 metres) before deleting it.
