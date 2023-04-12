//
//  ChatInputView.swift
//  iChatGPT
//
//  Created by HTC on 2022/12/8.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import SwiftUI

struct ChatInputView: View {
    let chatId: String
    @FocusState private var keyFocused: Bool
    @Binding var searchText: String
    @ObservedObject var chatModel: AIChatViewModel
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            ZStack(alignment: .leading){
                Rectangle()
                #if os(macOS)
                    .foregroundColor(Color(NSColor.gray))
                #else
                    .foregroundColor(Color(UIColor.tertiarySystemGroupedBackground))
                #endif
                    .cornerRadius(10)
                    .frame(height: 40)
                HStack {
                    PromptListView(chatId: chatId, chatModel: chatModel)
//                    Image(systemName: "message.and.waveform")
//                        .foregroundColor(.gray)
//                        .padding(.leading, 8)
//                        .padding(.trailing, 5)
                
                    TextField("Ask me anything..", text: $searchText, onEditingChanged: changedSearch)
                        .onSubmit {
                            fetchSearch()
                        }
                        .textFieldStyle(.plain)
                        .padding(.trailing, 8)
                        .submitLabel(.send)
                        .onAppear{
                            keyFocused = true
                        }.focused($keyFocused)
                    
                    if searchText.count > 0 {
                        Button(action: clearSearch) {
                            Image(systemName: "multiply.circle.fill")
                        }
                        .padding(.trailing, 8)
                        .foregroundColor(.gray)
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
//            if isEditing {
//                Button(action: cancelSearch) {
//                    Image(systemName: "keyboard.chevron.compact.down")
//                }
//                .buttonStyle(PlainButtonStyle())
//            }
        }
        .padding(.bottom, 10)
    }
    
    func changedSearch(isEditing: Bool) {
        self.isEditing = isEditing
    }
    
    func fetchSearch() {
        guard !searchText.isEmpty else {
            return
        }
        chatModel.getChatResponse(id: chatId, prompt: searchText)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            clearSearch()
        }
    }
    
    func clearSearch() {
        searchText = ""
    }
    
//    func cancelSearch() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
}
