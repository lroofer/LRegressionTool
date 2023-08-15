//
//  SaveDirectory.swift
//  LRegressionTool
//
//  Created by Егор Колобаев on 14.08.2023.
//

import SwiftUI

struct SaveDirectory: View {
    @ObservedObject var storage: Storage
    var body: some View {
        HStack {
            Button {
                let panel = NSSavePanel()
                panel.nameFieldLabel = "Output file"
                panel.nameFieldStringValue = "proj.csv"
                if panel.runModal() == .OK {
                    storage.saveDirectory = panel.url
                    var s = "Id,Target\n"
                    for i in 0..<storage.ids!.count {
                        s += "\(storage.ids![i]),\(storage.predictions![i])\n"
                    }
                    do {
                        try s.write(to: panel.url!, atomically: true, encoding: String.Encoding.utf8)
                    } catch {
                        fatalError("Cannot write!")
                    }
                }
                
            } label: {
                Label("Download", systemImage: "arrow.down.app")
            
            }
        }
    }
}

struct SaveDirectory_Previews: PreviewProvider {
    static var previews: some View {
        SaveDirectory(storage: Storage())
    }
}
