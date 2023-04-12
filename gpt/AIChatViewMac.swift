//
//  AIChatViewMac.swift
//  gpt
//
//  Created by 顾艳华 on 2023/3/27.
//

import SwiftUI
import CoreData
import Foundation

struct AIChatViewMac: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Chat.createdDate, ascending: true)],
            animation: .default)
    private var chats: FetchedResults<Chat>
    
    
    @State private var isAddPresented: Bool = false
    @State private var isPromptPresented: Bool = false
    @ObservedObject var chatModel: AIChatViewModel
    @State private var selectedChat: String?
    
    private var addButton: some View {
        Button(action: {
            isAddPresented = true
        }) {
            Label("Set OpenAI Key", systemImage: "key.viewfinder")
        }
    }
    
    private var promptButton: some View {
        Button(action: {
            isPromptPresented = true
        }) {
            Label("Prompt Manager", systemImage: "key.viewfinder")
        }
    }
    
    var body: some View {
        NavigationSplitView {
            
            List ( chats.map{$0.id!},id: \.self, selection: $selectedChat) { item in
                
                Text(chats.filter{$0.id! == item}.first!.last ?? "untitled chat")
                    
//                    .onDelete(perform: deleteItems)
                }
            .onAppear{
                let chats = try! viewContext.fetch(NSFetchRequest(entityName: "Chat")) as! [Chat]
                if !chats.isEmpty {
                    selectedChat = chats.first!.id
                }
            }
               
            Button{
                newChat()
            } label:{
                Text("New Chat")
            }
            .padding()
            
//            Button{
//                _debug(viewContext: viewContext)
//            } label: {
//                Text("debug")
//            }
//
        } detail: {
            VStack{
                HStack{
                    Spacer()
                    Menu {
                        addButton
                        promptButton
                       Button("Quit") {
                           exit(0)
                       }
                   } label: {
                       Image(systemName: "gearshape")
                   }
                   .menuStyle(.borderlessButton)
                      .menuIndicator(.hidden)
                      .fixedSize()
                      .padding()
                }
                if let selectedChat = selectedChat {
                    AIChatViewWithoutNav(chatId: selectedChat, chatModel: chatModel)
                } else {
                    Text("Please select a chat")
                }
            }
        }
        .sheet(isPresented: $isAddPresented, content: {
            TokenSettingView(isAddPresented: $isAddPresented, chatModel: chatModel)
        })
        .sheet(isPresented: $isPromptPresented, content: {
            PromptManagerView()
        })

        .frame(width: 800,height: 800)
        
//        .navigationViewStyle(.columns)
     
    }
    

    private func newChat() {
        _newChat(viewContext: viewContext, chatModel: chatModel)
    }

//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
}

//struct AIChatViewMac_Previews: PreviewProvider {
//    static var previews: some View {
//        AIChatViewMac()
//    }
//}
