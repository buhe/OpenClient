//
//  gptApp.swift
//  gpt
//
//  Created by 顾艳华 on 2023/3/26.
//

import SwiftUI
#if os(macOS)
import HotKey
import MenuBarExtraAccess
#endif
@main
struct gptApp: App {
    @State var menuDisplay = false
    let persistenceController = PersistenceController.shared
    #if os(macOS)
    let hotKey = HotKey(key: .e, modifiers: [.option])
    private var menu: some Scene {
        let m = MenuBarExtra {
            AIChatViewMac(chatModel: AIChatViewModel(viewContext: persistenceController.container.viewContext))
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        } label: {
            Label("ChatGPT", image: "menu_bar_icon")
        }
        .menuBarExtraStyle(.window)
        .menuBarExtraAccess(isPresented: $menuDisplay)
        hotKey.keyDownHandler = {
            menuDisplay.toggle()
        }
        return m
    }
    #endif
    var body: some Scene {
        #if os(macOS)
        menu
        #else
        WindowGroup {
            AIChatView(chatModel: AIChatViewModel(viewContext: persistenceController.container.viewContext))
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        #endif
    }
 
}
