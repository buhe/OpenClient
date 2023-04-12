
import Foundation
import OpenAI
import CoreData
import SwiftyJSON
import SwiftUI

let ChatGPTOpenAIKey = "ChatGPTOpenAIKey"

// MARK: - Welcome1
struct AIChat: Codable {
    let id: String
    let datetime: String
    var issue: String
    var answer: String?
    var isResponse: Bool = false
    var userAvatarUrl: String
    var botAvatarUrl: String = "https://www.freelogovectors.net/wp-content/uploads/2023/01/chatgpt-logo-freelogovectors.net_.png"
}


//@MainActor
class AIChatViewModel: ObservableObject {
    
    var isRefreshSession: Bool = false
    @Published var contents: [String: [AIChat]] = [:]
    @Published var prompts: [String: String] = [:]
    @AppStorage(wrappedValue: 0, "tokens") var tokens: Int
    @AppStorage(wrappedValue: 0, "count") var count: Int
    @AppStorage(wrappedValue: true, "first") var first: Bool
    var viewContext: NSManagedObjectContext
    private var bot: Chatbot?
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        
        loadChatbot()
        loadFromDB()
        if first {
            addNoPrompt()
            addDefaultPrompt()
            first = false
        }
    }
    func addDefaultPrompt() {
        let defaultPromptsName = ["翻译", "编程", "百科"]
        let defaultPrompts = ["请翻译成英文", "生成 python 代码实现", "这是什么意思"]
        for i in 0..<defaultPrompts.count {
            let np = Prompt(context: viewContext)
            np.id = UUID().uuidString
            np.name = defaultPromptsName[i]
            np.text = defaultPrompts[i]
        }
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    func addNoPrompt() {
        let np = Prompt(context: viewContext)
        np.id = "Unselected"
        np.name = "Unselected"
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    func clear(id: String){
        contents[id]!.removeAll()
        let cs: [AIChat] = []
        // TODO: insert DB
        let json = JSON(cs)
        if let rawString = json.rawString() {
          //Do something you want
//                print(rawString)
            self.updateChat(id: id, contents: rawString, last: "New Chat")
        } else {
            print("json.rawString is nil")
        }
        
    }
    
    func loadFromDB() {
        let userAvatarUrl = self.bot?.getUserAvatar() ?? ""
        var chats = try! viewContext.fetch(NSFetchRequest(entityName: "Chat")) as! [Chat]
        if chats.isEmpty {
            print("init chat list..")
            let newItem = Chat(context: viewContext)
            newItem.id = UUID().uuidString
            let cs: [AIChat] = []
            let json = JSON(cs)
            if let rawString = json.rawString() {
                newItem.contents = rawString
                newItem.last = "New Chat"
                newItem.createdDate = Date()
            } else {
                print("json.rawString is nil")
            }

            do {
                try viewContext.save()
                chats.append(newItem)
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
        var fromDB: [String: [AIChat]] = [:]
        var aiChats: [AIChat]
        for chat in chats {
            if chat.contents != nil {
                aiChats = []
                if let data = chat.contents!.data(using: .utf8) {
                    if let json = try? JSON(data: data) {
                        for item in json.arrayValue {
                            let ai = AIChat(id: chat.id!, datetime: item["datetime"].stringValue, issue: item["issue"].stringValue, answer: item["answer"].stringValue, isResponse: true, userAvatarUrl: userAvatarUrl)
                            aiChats.append(ai)
                            
                        }
                    }
                }
            } else {
                aiChats = []
            }
            fromDB[chat.id!] = aiChats
            if chat.promptId != nil {
                self.prompts[chat.id!] = chat.promptId!
            }
        }
        print("fromDB \(fromDB)")
        self.contents = fromDB
    }
    
    func updateChat(id: String, contents: String, last: String) {
        print("update \(id)")
        let fetchRequest: NSFetchRequest<Chat> = Chat.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            let results = try viewContext.fetch(fetchRequest)
            if let chat = results.first {
                chat.contents = contents // Update the age property
                chat.last = last
                try viewContext.save() // Save the changes
            }
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }
    
    func getChatResponse(id: String, prompt: String){
        if isRefreshSession {
            loadChatbot()
        }
        let index = contents[id]!.count
        let userAvatarUrl = self.bot?.getUserAvatar() ?? ""
        var promptStr = ""
        if prompts[id] != nil {
            let promptId = prompts[id]!
            print("find prompt \(promptId)")
            let fetchRequest: NSFetchRequest<Prompt> = Prompt.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", promptId)
            do {
                let results = try viewContext.fetch(fetchRequest)
                if let prompt = results.first {
                    promptStr = prompt.text ?? ""
                }
            } catch let error as NSError {
                print("Fetch error: \(error) description: \(error.userInfo)")
            }
        }
        var chat = AIChat(id: id, datetime: Date().currentDateString(), issue: promptStr + " " + prompt, userAvatarUrl: userAvatarUrl)
        if contents[id] == nil {
            contents[id] = []
        }
        contents[id]!.append(chat)
        self.bot?.getChatGPTAnswer(prompts: contents[id]!){answer, tokens in
            if answer == "**Key**" {
                chat.isResponse = true
                chat.answer = "请设置 Open AI 的密钥"
                self.contents[id]![index] = chat
                return
            }
            self.tokens = self.tokens + tokens
            if tokens > 0 {
                self.count = self.count + 1
            }
            let content = answer
            chat.answer = content
            chat.isResponse = true
                
            self.contents[id]![index] = chat
            let cs = self.contents[id]!.map{
                ["issue": $0.issue, "answer": $0.answer, "datetime": $0.datetime]
            }
            // insert DB
            let json = JSON(cs)
            if let rawString = json.rawString() {
                self.updateChat(id: id, contents: rawString, last: content)
            } else {
                print("json.rawString is nil")
            }

        }
    }
    
    func loadChatbot() {
        isRefreshSession = false
        let chatGPTOpenAIKey = UserDefaults.standard.string(forKey: ChatGPTOpenAIKey) ?? ""
        bot = Chatbot( openAIKey: chatGPTOpenAIKey)
    }
}
