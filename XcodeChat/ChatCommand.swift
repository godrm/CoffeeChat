//
//  ChatCommand.swift
//  XcodeChat
//
//  Created by Jung Kim on 2022/11/05.
//

import Foundation
import XcodeKit
import Network

class ChatCommand: NSObject, XCSourceEditorCommand {
    var connection : NWConnection?

    override init() {
        self.connection = NWConnection.init(host: .init(stringLiteral: "127.0.0.1"), port: .init(integerLiteral: 12022), using: .udp)
        connection?.start(queue: DispatchQueue.init(label: "kr.letswift.xcode"))
        connection?.stateUpdateHandler = {newState in
            switch newState {
            case .ready:
                break
            default:
                break
            }
        }
    }
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let selection = invocation.buffer.selections.firstObject as! XCSourceTextRange
        var selectionLines = [String]()
        for (index, line) in invocation.buffer.lines.enumerated() {
            if selection.start.line <= index && index < selection.end.line {
                selectionLines.append(line as? String ?? "")
            }
        }
        let selections = selectionLines.joined(separator: "")

        let cachePath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.kr.letswift.letchat")?.path
        var fileURL = URL.init(fileURLWithPath: cachePath!)
        fileURL.appendPathComponent("code.txt")
        try? selections.write(toFile: fileURL.path, atomically: true, encoding: .utf8)
        self.connection?.send(content: "{ \"app\":\"Xcode\", \"code\" : \"\(fileURL.path)\" }".data(using: .utf8), completion: NWConnection.SendCompletion.contentProcessed({ error in }))

        completionHandler(nil)
    }
}
