//
//  TokenSettingView.swift
//  iChatGPT
//
//  Created by HTC on 2022/12/8.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import SwiftUI

struct TokenSettingView: View {
    
    @Binding var isAddPresented: Bool
    @StateObject var chatModel: AIChatViewModel
    @State private var OpenAIKey: String = ""
    @State private var kError: String = ""
    
    func lastOpenAIKey() -> String?{
        
        guard let inputString = UserDefaults.standard.string(forKey: ChatGPTOpenAIKey) else { return nil }
        
        let firstThree = inputString.prefix(3)
        let lastThree = inputString.suffix(3)
        let middle = String(repeating: "*", count: inputString.count - 6)
        let outputString = "\(firstThree)\(middle)\(lastThree)"
        
        return outputString
    }
    
    
    var body: some View {
        Form {
            if let lastOpenAIKey = lastOpenAIKey() {
                Section("Last OpenAI Key") {
                    Text("\(lastOpenAIKey)")
                }
                #if os(macOS)
                .padding(.bottom)
                #endif
            }
            Section("Set OpenAI Key") {
                TextField("", text: $OpenAIKey)
                    .submitLabel(.done)
            }
            #if os(macOS)
            .padding(.bottom)
            #endif
            Button(action: {
                guard !OpenAIKey.isEmpty else{
                    kError = "OpenAI Key not empty."
                    return
                }
                
                UserDefaults.standard.set(OpenAIKey, forKey: ChatGPTOpenAIKey)
                isAddPresented = false
                chatModel.isRefreshSession = true
            }) {
                Text("Save")
            }
        }
        #if os(macOS)
        .padding()
        #endif
    }
}


