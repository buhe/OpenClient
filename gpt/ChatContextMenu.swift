//
//  ChatContextMenu.swift
//  iChatGPT
//
//  Created by HTC on 2022/12/8.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import SwiftUI

struct ChatContextMenu: View {
    
    @Binding var searchText: String
    @StateObject var chatModel: AIChatViewModel
    let item: AIChat
//
    var body: some View {
        VStack {
            CreateMenuItem(text: "Ask again", imgName: "arrow.up.message") {
                chatModel.getChatResponse(id: item.id, prompt: item.issue)
            }
            CreateMenuItem(text: "Copy the issues", imgName: "doc.on.doc") {
                item.issue.copyToClipboard()
            }

            CreateMenuItem(text: "Copy the answer", imgName: "doc.on.doc") {
                item.answer!.copyToClipboard()
            }
            .disabled(item.answer == nil)

            CreateMenuItem(text: "Copy the issues and answers", imgName: "doc.on.doc.fill") {
                "\(item.issue)\n-----------\n\(item.answer ?? "")".copyToClipboard()
            }
            .disabled(item.answer == nil)

            CreateMenuItem(text: "Copy the issues into the input", imgName: "keyboard.badge.ellipsis") {
                searchText = item.issue
            }

            // remove item
            let isWait = chatModel.contents[item.id]!.filter({ $0.isResponse == false })
            CreateMenuItem(text: "Delete the issue", imgName: "trash", isDestructive: true) {
                if let index = chatModel.contents[item.id]!.firstIndex(where: { $0.datetime == item.datetime })
                {
                    chatModel.contents[item.id]!.remove(at: index)
                }
            }.disabled(isWait.count > 0)
            

            CreateMenuItem(text: "Delete all", imgName: "trash", isDestructive: true) {
                chatModel.clear(id: item.id)
            }.disabled(isWait.count > 0)
        }
    }

    func CreateMenuItem(text: LocalizedStringKey, imgName: String, isDestructive: Bool = false, onAction: (() -> Void)?) -> some View {
            return Button {
                onAction?()
            } label: {
                Label(text, systemImage: imgName)
            }
    }
}
