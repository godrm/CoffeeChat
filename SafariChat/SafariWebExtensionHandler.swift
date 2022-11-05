//
//  SafariWebExtensionHandler.swift
//  SafariChat
//
//  Created by Jung Kim on 2022/11/05.
//

import SafariServices
import os.log
import Network

let SFExtensionMessageKey = "message"

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    var connection : NWConnection?

    override init() {
        super.init()
        self.connection = NWConnection.init(host: .init(stringLiteral: "127.0.0.1"), port: .init(integerLiteral: 12022), using: .udp)
        connection?.start(queue: DispatchQueue.init(label: "sender.safarichat"))
        connection?.stateUpdateHandler = {newState in
            switch newState {
            case .ready:
                os_log(.default, "extension connection ready.")
            default:
                break
            }
        }
    }

    func beginRequest(with context: NSExtensionContext) {
        let item = context.inputItems[0] as! NSExtensionItem
        let message = item.userInfo?[SFExtensionMessageKey] as! NSDictionary
        let body = message["body"] as! String
        let location = message["location"] as! String
        
        let cachePath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.kr.letswift.letchat")?.path
        var fileURL = URL.init(fileURLWithPath: cachePath!)
        fileURL.appendPathComponent("body.txt")
        try? body.write(toFile: fileURL.path, atomically: true, encoding: .utf8)
        
        os_log(.default, "Received message from browser.runtime.sendNativeMessage: len=%{public}@, %{public}@", fileURL.path as! CVarArg)
        self.connection?.send(content: "{ \"app\":\"Safari\", \"location\" : \"\(location)\", \"file\" : \"\(fileURL.path)\" }".data(using: .utf8), completion: NWConnection.SendCompletion.contentProcessed({ error in }))
        
        let response = NSExtensionItem()
        response.userInfo = [ SFExtensionMessageKey: [ "Response to": location ] ]
        
        context.completeRequest(returningItems: [response], completionHandler: nil)
    }

}
