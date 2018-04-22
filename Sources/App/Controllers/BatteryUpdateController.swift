

import Vapor
import FluentProvider

// url
// ..../api/batteryUpdate/create
// with a payload

struct BatteryUpdateController {
    func addRoutes(to drop: Droplet) {
        let batteryUpdateGroup = drop.grouped("api", "batteryUpdate")
        batteryUpdateGroup.post("create", handler: createBatteryUpdate)
    }
    
    func createBatteryUpdate(_ req: Request) throws -> ResponseRepresentable {
        guard let json = req.json else {
            throw Abort.badRequest
        }
        
        let batteryUpdate = try BatteryUpdate(json: json)
        try batteryUpdate.save()
        return batteryUpdate
    }
}
