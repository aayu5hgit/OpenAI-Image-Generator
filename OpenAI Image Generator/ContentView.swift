//
//  ContentView.swift
//  OpenAI Image Generator
//
//  Created by Aayush Talreja on 15/12/22.
//

import OpenAIKit
import SwiftUI
import SimpleToast


final class ViewModel: ObservableObject{
    private var openai: OpenAI?
    
    final func setup(){
        openai = OpenAI(Configuration(
            organization: "Personal",
//            apiKey: "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"))
    apiKey: "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"))
    }
    
    func generateImage(prompt: String) async -> UIImage?{
        guard let openai = openai else{
            return nil
        }
        
        do{
            let params = ImageParameters(prompt: prompt,
                                         resolution: .medium,
                                         responseFormat: .base64Json)
            let result = try await openai.createImage(parameters: params)
            let data = result.data[0].image
            let image = try openai.decodeBase64Image(data)
            return image
        } catch{
            print(String(describing: error))
            return nil
        }
    }
}

struct ContentView: View {
    @State private var showingAlert = false
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var image: UIImage?
    var body: some View {
        
        NavigationView {
            
            VStack {
                Spacer()
                if let image = image{
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaledToFit()
                        .frame(width: 320, height: 320)
                    
                } else{
                    Text("Image will appear here!")
                    
                }
                Spacer()
                
                TextField("Type Prompt here", text: $text)
                    .padding()
                Button("Generate"){
                    showingAlert = true
                    if !text.trimmingCharacters(in: .whitespaces).isEmpty{
                        Task{
                            
                            let result = await viewModel.generateImage(prompt: text)
                            if result == nil {
                                print("Failed to get Image...")
                            }
                            self.image = result
                            
                               
//                            HStack{
//                                Text("Fetching...").bold()
//                            }
//                            .padding(20)
//                            .background(Color.gray.opacity(0.7))
//                            .foregroundColor(Color.white)
//                            .cornerRadius(10)
//
                        }
                    }
                }
                .alert("Fetching can take few seconds...", isPresented: $showingAlert) {
                           Button("Ok", role: .cancel) { }
                       }
            }
            
            .navigationTitle("OPEN-AI + DALLE-E")
            .onAppear{
                viewModel.setup()
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
