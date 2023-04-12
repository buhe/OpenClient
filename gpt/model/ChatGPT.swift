//
//  ChatGPT.swift
//  iChatGPT
//
//  Created by HTC on 2022/12/8.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import Foundation
import Combine
import OpenAI

class Chatbot {
	var userAvatarUrl = "https://pic46.photophoto.cn/20180327/0005018543576948_b.jpg"
    var openAIKey = ""
    var openAI:OpenAI
    var answer = ""
	
    init(openAIKey:String) {
        self.openAIKey = openAIKey
        self.openAI = OpenAI(apiToken: self.openAIKey)
	}
	
    func getUserAvatar() -> String {
        userAvatarUrl
    }


    func getChatGPTAnswer(prompts: [AIChat], completion: @escaping (String, Int) -> Void) {
        if openAIKey.isEmpty {
            DispatchQueue.main.async {
                completion("**Key**", 0)
            }
        } else {
            var messages: [OpenAI.Chat] = []
            for i in 0..<prompts.count {
                if i == prompts.count - 1 {
                    messages.append(.init(role: "user", content: prompts[i].issue))
                    break
                }
                let answer = prompts[i].answer!
                if !answer.isEmpty {
                    messages.append(.init(role: "assistant", content: answer))
                    messages.append(.init(role: "user", content: prompts[i].issue))
                }
            }
            print("req prompt: \(messages)")
            let query = OpenAI.ChatQuery(model: .gpt3_5Turbo, messages: messages, temperature: 0.8, max_tokens: 4000)
            openAI.chats(query: query) { data in
                do {
                    let res = try data.get().choices[0].message.content
                    let tokens = try data.get().usage.total_tokens
                    DispatchQueue.main.async {
                        completion(res, tokens)
                    }
                } catch {
                    print(error)
                    DispatchQueue.main.async {
                        let e = error as? OpenAI.ChatError
                        if e != nil {
                            completion(e!.error.message, 0)
                        } else {
                            completion("", 0)
                        }
                    }
                }
            }
        }
    }
}
