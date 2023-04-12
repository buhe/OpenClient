//
//  ChatListView.swift
//  gpt
//
//  Created by 顾艳华 on 2023/4/1.
//

import SwiftUI

struct ChatListView: View {
//    let chatId: String 
//    @Binding var searchText: String
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Chat.createdDate, ascending: true)],
            animation: .default)
    private var chats: FetchedResults<Chat>
    
    let close: (_ chatId: String) -> Void
    
//        let items = Array(1...10)
        let columns: [GridItem] = Array(repeating: .init(.adaptive(minimum: 120)), count: 2)
        
        var body: some View {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(chats.map{$0.id!},id: \.self) { item in
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(.white)
                                .shadow(radius: 1)
//                            Text(item)
                            Button{
                                close(item)
                            } label: {
                                Text(chats.filter{$0.id! == item}.first!.last!)
                                    .padding()
                            }
                                
            
                        }
                        .frame(width: 160, height: 80)
                    }
                }
                .padding()
            }
        }
    }

//struct ChatListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatListView()
//    }
//}
