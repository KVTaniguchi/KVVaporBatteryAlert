

import FluentProvider
import VaporAPNS
import Foundation

struct KVBatteryAlertKeys {
    struct BatteryUpdate {
        static let batteryLevel = "batteryLevel"
        static let deviceType = "deviceType"
        static let deviceId = "deviceID"
        static let desiredCharge = "desiredCharge"
    }
}

enum KVDeviceType: Int {
    case iPhone5c
    case iPhone5s
    case iPhoneSE
    case iPhone6
    case iPhone6Plus
    case iPhone6S
    case iPhone6SPlus
    
    case iPhone7
    case iPhone7Plus
    
    case iPhone8
    case iPhone8Plus
    
    case iPhoneX
    
    case unsupported
}

// this class has
// - a timer
// - a battery level it is init'd with
// - a device type
// - a calculator for how long it will take for the device to charge
// - when the timer is up, send a silent notif to wake up the app
// - app, when it gets a PN `req to check` level, will check its batt level
// - if the app is full, either do a local PN to wake up device or (ugh) send back to app to req a PN
// -

final class BatteryUpdate: Model {
    let storage = Storage()
    
    let batteryLevel: Double
    let deviceType: Int
    let deviceId: String
    let desiredCharge: Double
    private var timer: Timer?
    
    init(batteryLevel: Double, deviceType: Int, deviceId: String, desiredCharge: Double) {
        self.batteryLevel = batteryLevel
        self.deviceType = deviceType
        self.deviceId = deviceId
        self.desiredCharge = desiredCharge
        
        let chargeToFill = 100.0 - batteryLevel
        let numberSecondToFillCharge = 90.0 * chargeToFill
        
        timer = Timer(timeInterval: numberSecondToFillCharge, target: self, selector: #selector(sendPush) , userInfo: nil, repeats: false)
        timer?.fire()
    }
    
    init(row: Row) throws {
        batteryLevel = try row.get(KVBatteryAlertKeys.BatteryUpdate.batteryLevel)
        deviceType = try row.get(KVBatteryAlertKeys.BatteryUpdate.deviceType)
        deviceId = try row.get(KVBatteryAlertKeys.BatteryUpdate.deviceId)
        desiredCharge = try row.get(KVBatteryAlertKeys.BatteryUpdate.desiredCharge)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(KVBatteryAlertKeys.BatteryUpdate.batteryLevel, batteryLevel)
        try row.set(KVBatteryAlertKeys.BatteryUpdate.deviceType, deviceType)
        try row.set(KVBatteryAlertKeys.BatteryUpdate.deviceId, deviceId)
        try row.set(KVBatteryAlertKeys.BatteryUpdate.desiredCharge, desiredCharge)
        return row
    }
    
    @objc func sendPush() {
        timer?.invalidate()
        do {
            let options = try! Options(topic: "com.taniguchi.BatteryFullAlert", teamId: "<your team identifier>", keyId: "<your key id>", keyPath: "/path/to/your/APNSAuthKey.p8")
            let vaporAPNS = try VaporAPNS(options: options)
            
            let payload = Payload.contentAvailable
            payload.bodyLocKey = "kvVaporBattery_check_batt"
            
            let pushMessage = ApplePushMessage(topic: "nl.logicbit.TestApp", priority: .immediately, payload: payload, sandbox: true)
            let result = vaporAPNS.send(pushMessage, to: "488681b8e30e6722012aeb88f485c823b9be15c42e6cc8db1550a8f1abb590d7")
            switch result {
            case .success(let apnsId,let deviceToken, let serviceStatus):
                print("success")
                print(apnsId)
                print(deviceToken)
                print(serviceStatus.rawValue)
            case .error(let apnsId, let deviceToken, let error):
                print(error)
                print(apnsId)
                print(deviceToken)
            case .networkError(let error):
                print(error)
            }
            
        }
        catch {
            print(error)
        }
    }
}

extension BatteryUpdate: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { (builder) in
            builder.id()
            builder.double(KVBatteryAlertKeys.BatteryUpdate.batteryLevel)
            builder.int(KVBatteryAlertKeys.BatteryUpdate.deviceType)
            builder.string(KVBatteryAlertKeys.BatteryUpdate.deviceId)
            builder.double(KVBatteryAlertKeys.BatteryUpdate.desiredCharge)
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
                      deviceId: json.get(KVBatteryAlertKeys.BatteryUpdate.deviceId),
                      desiredCharge: json.get(KVBatteryAlertKeys.BatteryUpdate.desiredCharge))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set(KVBatteryAlertKeys.BatteryUpdate.batteryLevel, batteryLevel)
        try json.set(KVBatteryAlertKeys.BatteryUpdate.deviceType, deviceType)
        try json.set(KVBatteryAlertKeys.BatteryUpdate.deviceId, deviceId)
        try json.set(KVBatteryAlertKeys.BatteryUpdate.desiredCharge, desiredCharge)
        return json
    }
}

extension BatteryUpdate: ResponseRepresentable {}
