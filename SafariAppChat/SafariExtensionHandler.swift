//
//  SafariExtensionHandler.swift
//  SafariAppChat
//
//  Created by JK on 2022/11/24.
//

import SafariServices
import os.log
import Network

class SafariExtensionHandler: SFSafariExtensionHandler {
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
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
        page.getPropertiesWithCompletionHandler { properties in
            NSLog("The extension received a message (\(messageName)) from a script injected into (\(String(describing: properties?.url))) with userInfo (\(userInfo ?? [:]))")
        }
    }

    override func toolbarItemClicked(in window: SFSafariWindow) {
        // This method will be called when your toolbar item is clicked.
        NSLog("The extension's toolbar item was clicked")
        
        self.connection?.send(content: "{ \"app\":\"SafariApp\", \"location\" : \"https://letswift.kr\", \"file\" : \"\" }".data(using: .utf8), completion: NWConnection.SendCompletion.contentProcessed({ error in }))
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }

}
