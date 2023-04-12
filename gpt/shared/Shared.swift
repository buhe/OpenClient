//
//  Shared.swift
//  gpt
//
//  Created by 顾艳华 on 2023/4/1.
//

import Foundation
import SwiftUI
import CoreData

func _newChat(viewContext: NSManagedObjectContext, chatModel: AIChatViewModel){
    withAnimation {
        let newItem = Chat(context: viewContext)
        newItem.id = UUID().uuidString
        newItem.last = "New Chat"
        newItem.createdDate = Date()

        do {
            try viewContext.save()
            chatModel.contents[newItem.id!] = []
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

func _debug(viewContext: NSManagedObjectContext) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chat")
    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    do {
        try viewContext.execute(batchDeleteRequest)
        try viewContext.save()
    } catch {
    }
}
