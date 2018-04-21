

import FluentProvider

struct KVBatteryAlertKeys {
    struct BatteryUpdate {
        static let batteryLevel = "batteryLevel"
        static let deviceType = "deviceType"
        static let deviceId = "deviceID"
    }
}

final class BatteryUpdate: Model {
    let storage = Storage()
    
    let batteryLevel: Double
    let deviceType: String
    let deviceId: String
    
    init(batteryLevel: Double, deviceType: String, deviceId: String) {
        self.batteryLevel = batteryLevel
        self.deviceType = deviceType
        self.deviceId = deviceId
    }
    
    init(row: Row) throws {
        batteryLevel = try row.get(KVBatteryAlertKeys.BatteryUpdate.batteryLevel)
        deviceType = try row.get(KVBatteryAlertKeys.BatteryUpdate.deviceType)
        deviceId = try row.get(KVBatteryAlertKeys.BatteryUpdate.deviceId)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(KVBatteryAlertKeys.BatteryUpdate.batteryLevel, batteryLevel)
        try row.set(KVBatteryAlertKeys.BatteryUpdate.deviceType, deviceType)
        try row.set(KVBatteryAlertKeys.BatteryUpdate.deviceId, deviceId)
        return row
    }
}

extension BatteryUpdate: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { (builder) in
            builder.id()
            builder.double(KVBatteryAlertKeys.BatteryUpdate.batteryLevel)
            builder.string(KVBatteryAlertKeys.BatteryUpdate.deviceType)
            builder.string(KVBatteryAlertKeys.BatteryUpdate.deviceId)
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension BatteryUpdate: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(batteryLevel: json.get(KVBatteryAlertKeys.BatteryUpdate.batteryLevel),
                      deviceType: json.get(KVBatteryAlertKeys.BatteryUpdate.deviceType),
                      deviceId: json.get(KVBatteryAlertKeys.BatteryUpdate.deviceId))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set(KVBatteryAlertKeys.BatteryUpdate.batteryLevel, batteryLevel)
        try json.set(KVBatteryAlertKeys.BatteryUpdate.deviceType, deviceType)
        try json.set(KVBatteryAlertKeys.BatteryUpdate.deviceId, deviceId)
        return json
    }
}

extension BatteryUpdate: ResponseRepresentable {}
