//
//  PromptManagerView.swift
//  gpt
//
//  Created by 顾艳华 on 2023/4/3.
//

import SwiftUI
import CoreData

struct PromptManagerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var name = ""
    @State var content = ""
    @State private var selectedPrompt: String?
    @State var updated = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Prompt.createdDate, ascending: true)],
            animation: .default)
    private var prompts: FetchedResults<Prompt>
    
    private var updateButton: some View {
        Button(action: {
            print("update prompt \(selectedPrompt!)")
            let fetchRequest: NSFetchRequest<Prompt> = Prompt.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", self.selectedPrompt!)
            do {
                let results = try viewContext.fetch(fetchRequest)
                if let prompt = results.first {
                    prompt.name = name
                    prompt.text = content
                    try viewContext.save() // Save the changes
                    updated = false
                }
            } catch let error as NSError {
                print("Fetch error: \(error) description: \(error.userInfo)")
            }
        }) {
            Text("Update")
        }
        .disabled(!updated)
    }
    private var addButton: some View {
        Button(action: {
            let id = UUID().uuidString
            let newItem = Prompt(context: viewContext)
            newItem.name = "New Prompt"
            newItem.id = id
            newItem.createdDate = Date()
            newItem.text = content

            do {
                try viewContext.save()
                selectedPrompt = id
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }) {
            Text("Create")
        }
        .padding()
    }
    
    var body: some View {
        NavigationSplitView {
            
            List ( prompts.filter{$0.id! != "Unselected"}.map{$0.id!},id: \.self, selection: $selectedPrompt) { item in
                HStack{
                    Text(prompts.filter{$0.id! == item}.first!.name!)
                    Spacer()
                    Button {
                        print("delete prompt \(item)")
                        let fetchRequest: NSFetchRequest<Prompt> = Prompt.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "id == %@", item)
                        do {
                            let results = try viewContext.fetch(fetchRequest)
                            if let prompt = results.first {
                                viewContext.delete(prompt)
                                try viewContext.save() // Save the changes
                                name = ""
                                content = ""
                            }
                        } catch let error as NSError {
                            print("Fetch error: \(error) description: \(error.userInfo)")
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
   
            }
            
            addButton
//
        } detail: {
            VStack{
             
                if let selectedPrompt = selectedPrompt {
                    Form{
                        TextField("Prompt Name", text: $name)
                            .disableAutocorrection(true)
                            .onChange(of: name){
                                _ in updated = true
                            }
                        TextField("Prompt Content", text: $content)
                            .disableAutocorrection(true)
                            .onChange(of: content){
                                _ in updated = true
                            }
                        updateButton
                    }
                    .padding()
                    .onAppear {
                        let prompt = prompts.filter{$0.id! == selectedPrompt}.first
                        if prompt != nil {
                            name = prompt!.name!
                            content = prompt!.text!
                        }
                    }
                    .onChange(of: self.selectedPrompt){
                        p in
                        let prompt = prompts.filter{$0.id! == p}.first
                        if prompt != nil {
                            name = prompt!.name!
                            content = prompt!.text!
                        }
                    }
                } else {
                    Text("Please select a prompt or create.")
                }
            }
        }
        .frame(width: 400,height: 600)
   
    }
}

struct PromptManagerView_Previews: PreviewProvider {
    static var previews: some View {
        PromptManagerView()
    }
}
