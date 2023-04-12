//
//  PromptListView.swift
//  gpt
//
//  Created by 顾艳华 on 2023/4/3.
//

import SwiftUI
import CoreData

struct PromptListView: View {
    @State private var selectedColor = "Unselected"
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Prompt.createdDate, ascending: true)],
            animation: .default)
    private var prompts: FetchedResults<Prompt>
    let chatId: String
    @ObservedObject var chatModel: AIChatViewModel
//    @State var data: [String] = []
    
    func updateChat(id: String, promptId: String) {
        print("update prompt \(promptId) for \(id)")
        let fetchRequest: NSFetchRequest<Chat> = Chat.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            let results = try viewContext.fetch(fetchRequest)
            if let chat = results.first {
                chat.promptId = promptId
                try viewContext.save() // Save the changes
            }
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }
    var body: some View {
        HStack {
            Picker("", selection: $selectedColor) {
                ForEach(prompts.map {$0.id!}, id: \.self) { p in
                    Text(prompts.filter{$0.id! == p}.first?.name ?? p)
                }
            }
            .onChange(of: selectedColor){
                i in
                if i != chatModel.prompts[chatId] {
                    chatModel.prompts[chatId] = i
                    self.updateChat(id: chatId, promptId: i)
                }
            }
            .onChange(of: chatId){
                c in
//                print("chat on appear")
                if chatModel.prompts[c] != nil {
                    selectedColor = chatModel.prompts[c]!
                } else {
                    selectedColor = "Unselected"
                }
            }
            .onAppear{
//                print("on appear")
//                data = prompts.map {$0.id!}
//                data.append("Unselected")
                if chatModel.prompts[chatId] != nil {
                    selectedColor = chatModel.prompts[chatId]!
                }
            }
            .pickerStyle(DefaultPickerStyle())
            .frame(width: 140)
//            .scaleEffect(CGSize(width: 1.8, height: 1.8))
//            .padding(.horizontal, 20)
        }
        
    }
}

//struct PromptListView_Previews: PreviewProvider {
//    static var previews: some View {
//        PromptListView()
//    }
//}

