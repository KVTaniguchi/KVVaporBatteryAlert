import Vapor

extension Droplet {
    func setupRoutes() throws {
        let batteryUpdateController = BatteryUpdateController()
        batteryUpdateController.addRoutes(to: self)
    }
}

