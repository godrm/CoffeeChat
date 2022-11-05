//
//  SourceEditorCommand.swift
//  XcodeChat
//
//  Created by Jung Kim on 2022/11/05.
//

import Cocoa
import XcodeKit
import Splash

class SnapshotCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let selection = invocation.buffer.selections.firstObject as! XCSourceTextRange
        var selectionLines = [String]()
        for (index, line) in invocation.buffer.lines.enumerated() {
            if selection.start.line <= index && index < selection.end.line {
                selectionLines.append(line as? String ?? "")
            }
        }
        let selections = selectionLines.joined(separator: "")
        let systemTheme = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        let options = ImageGenerator.Options(code: selections,
                                             outputURL: URL(fileURLWithPath: ""), padding: 10, font: Font(size: 14))
        let image = ImageGenerator.buildImage(options: options, isLight: (systemTheme == "Light"))
        let board = NSPasteboard.general
        board.clearContents()
        board.writeObjects([image])

        completionHandler(nil)
    }
}
