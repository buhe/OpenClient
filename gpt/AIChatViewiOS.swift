//
//  AIChatView.swift
//  gpt
//
//  Created by 顾艳华 on 2023/3/27.
//

import SwiftUI

struct AIChatView: View {
    @State private var isAddPresented: Bool = false
    @State private var isChatListPresented: Bool = false
    @State private var isPromptPresented: Bool = false
    @State var chatId: String = ""
    @ObservedObject var chatModel: AIChatViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Chat.createdDate, ascending: true)],
            animation: .default)
    private var chats: FetchedResults<Chat>
    
    var body: some View {
        NavigationView {
            VStack{
                AIChatViewWithoutNav(chatId: chatId, chatModel: chatModel)
                    .navigationBarTitleDisplayMode(.inline)
                    .environment(\.managedObjectContext, viewContext)
                    .navigationBarItems(trailing:
                    HStack {
                        addButton
                        promptManagerButton
                    })
                    .navigationBarItems(leading:
                    HStack {
                        addNewChatButton
                    })
                    .sheet(isPresented: $isChatListPresented, content: {
                        ChatListView(close: {id in
                            isChatListPresented = false
                            print("select chat: \(id)")
                            self.chatId  = id
                            
                        })
                        .environment(\.managedObjectContext, viewContext)
                    })
                    .sheet(isPresented: $isAddPresented, content: {
                        TokenSettingView(isAddPresented: $isAddPresented, chatModel: chatModel)
                    })
                    .sheet(isPresented: $isPromptPresented, content: {
                        PromptManageriOSView()
                    })
                    .onAppear{
                        chatId = !chats.isEmpty ? chats.first!.id! : ""
                    }
                listButton
            }
        }
        
        .navigationViewStyle(.stack)
    }
    private var promptManagerButton: some View {
        Button(action: {
            isPromptPresented = true
        }) {
            HStack {
                Image(systemName: "square.text.square")
            }
        }
    }
    private var listButton: some View {
        Button(action: {
            isChatListPresented = true
        }) {
            HStack {
                Image(systemName: "list.dash")
            }
        }
    }
    
    private var addButton: some View {
        Button(action: {
            isAddPresented = true
        }) {
            HStack {
                Image(systemName: "key.viewfinder")
            }
        }
    }
    
    private var addNewChatButton: some View {
        Button(action: {
            newChat()
        }) {
            HStack {
                Image(systemName: "plus")
            }
        }
    }
    
    private func newChat() {
        _newChat(viewContext: viewContext, chatModel: chatModel)
    }
   
}
//
//struct AIChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        AIChatView()
//    }
//}
