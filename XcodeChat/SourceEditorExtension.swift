//
//  SourceEditorExtension.swift
//  XcodeChat
//
//  Created by Jung Kim on 2022/11/05.
//

import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    
    func extensionDidFinishLaunching() {
    }
    
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        let namespace = Bundle(for: type(of: self)).bundleIdentifier!
        let snapshotMarker = SnapshotCommand.className()
        let chatMarker = ChatCommand.className()
        return [[.identifierKey: namespace + snapshotMarker,
                 .classNameKey: snapshotMarker,
                 .nameKey: NSLocalizedString("Xshot",
                 comment: "Snapshot for Swift code")],
                [.identifierKey: namespace + chatMarker,
                 .classNameKey: chatMarker,
                 .nameKey: NSLocalizedString("Chat",
                 comment: "Send the code to chat")]]
    }
}
