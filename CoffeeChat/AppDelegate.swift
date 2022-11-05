//
//  AppDelegate.swift
//  CoffeeChat
//
//  Created by Jung Kim on 2022/11/05.
//

import Cocoa
import Network
import UserNotifications

struct Command : Decodable {
    let app : String
    let location : String?
    let file : String?
    let code : String?
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var listener : NWListener?
    let networkQueue = DispatchQueue.init(label: "kr.letswift.coffeechat")

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NotificationManager.registNotification()
        configureNetwork()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func configureNetwork() {
        let parameters = NWParameters.udp
        parameters.acceptLocalOnly = true
        parameters.allowLocalEndpointReuse = true
        self.listener = try? NWListener.init(using: parameters, on: .init(integerLiteral: 12022))
        listener?.stateUpdateHandler = {(newState) in
            switch newState {
            case .ready:
                print("listen ready")
            default:
                break
            }
        }
        listener?.newConnectionHandler = {(newConnection) in
            newConnection.stateUpdateHandler = {newState in
                switch newState {
                case .ready:
                    newConnection.receive(minimumIncompleteLength: 10, maximumLength: 1024) { data, context, isContinue, error in
                        guard let receive = try? JSONDecoder().decode(Command.self, from: data!) else { return }
                        switch receive.app {
                        case "Safari":
                            DispatchQueue.main.async {
                                NotificationManager.sendNotification(with: "👻 Safari Chat")
                            }
                        case "Xcode":
                            DispatchQueue.main.async {
                                NotificationManager.sendNotification(with: "🤖 Xcode Chat")
                            }
                        default:
                            break
                        }
                    }
                default:
                    break
                }
            }
            newConnection.start(queue: self.networkQueue)
        }
        listener?.start(queue: networkQueue)
    }
}

enum NotificationManager {
    static func sendNotification(with ment: String) {
        let uuidString = UUID().uuidString
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "LetSwift CoffeeChat"
        content.body = "\(ment)"
        let request = UNNotificationRequest(identifier: uuidString,
                    content: content, trigger: trigger)
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
           if error != nil { }
        }
    }
    
    static func registNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print(error)
            }
            print("user notification", granted)
        }
    }
}
