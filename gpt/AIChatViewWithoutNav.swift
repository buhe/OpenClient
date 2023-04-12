//
//  AIChatView.swift
//  iChatGPT
//
//  Created by HTC on 2022/12/8.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import SwiftUI
import MarkdownText

struct AIChatViewWithoutNav: View {
    @Environment(\.managedObjectContext) private var viewContext
//    let preToken = 0.000002
    let chatId: String

    @State private var searchText = ""

    @ObservedObject var chatModel: AIChatViewModel
    
    var body: some View {
            Group {
                List {
                    ForEach(chatModel.contents[chatId] ?? [], id: \.datetime) { item in
                        Section(header: Text(item.datetime)) {
                            VStack(alignment: .leading) {
                                HStack(alignment: .top) {
                                    AvatarImageView(url: item.userAvatarUrl)
                                    MarkdownText(item.issue)
                                        .padding(.top, 3)
                                }
                                Divider()
                                HStack(alignment: .top) {
                                    Image("menu_bar_icon")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .cornerRadius(5)
                                        .padding(.trailing, 10)
                                    if item.isResponse {
                                        MarkdownText(item.answer ?? "")
                                            .padding(.top, 3)
                                    } else {
                                        ProgressView()
                                        #if os(macOS)
                                            .scaleEffect(x: 0.5, y: 0.5, anchor: .center)
                                        #endif
                                            .padding(.top, 3)
                                    }
                                }
                                .padding([.top, .bottom], 3)
                            }.contextMenu {
                                ChatContextMenu(searchText: $searchText, chatModel: chatModel, item: item)
                            }
                        }
                    }
                }
                Spacer()
                let isWait = (chatModel.contents[chatId] ?? []).filter({ $0.isResponse == false })
//                let price = Double(chatModel.tokens) * preToken
                HStack {
//                    Text("\(chatModel.count) Talk")
//                    Text("\(chatModel.tokens) Token")
//                    Text("Avg \(chatModel.count != 0 ? chatModel.tokens / chatModel.count : 0) ")
//                    Text("Cost \(price) $")
                    Button{
                        chatModel.clear(id: chatId)
                    } label: {
                        Text("Delete all")
                    }
                    .disabled(isWait.count > 0)
                }
                .font(.caption)
                .padding()
                ChatInputView(chatId: chatId, searchText: $searchText, chatModel: chatModel)
                    .padding([.leading, .trailing], 12)
            }
            .markdownHeadingStyle(.custom)
            .markdownQuoteStyle(.custom)
            .markdownCodeStyle(.custom)
            .markdownInlineCodeStyle(.custom)
            .markdownOrderedListBulletStyle(.custom)
            .markdownUnorderedListBulletStyle(.custom)
            .markdownImageStyle(.custom)

            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image("menu_bar_icon").resizable()
                            .frame(width: 25, height: 25)
                        Text("AI Bot").font(.headline)
                    }
                }
            }
    }
    

}

struct AvatarImageView: View {
    let url: String
    
    var body: some View {
        Group {
            ImageLoaderView(urlString: url) {
                Color(.white)
            } image: { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
            }
        }
        .cornerRadius(5)
        .frame(width: 25, height: 25)
        .padding(.trailing, 10)
    }
}

//struct AIChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        AIChatView()
//    }
//}
