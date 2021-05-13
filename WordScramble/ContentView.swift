//
//  ContentView.swift
//  WordScramble
//
//  Created by Kristoffer Eriksson on 2021-02-04.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var scoreCount = 0
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
    
    var body: some View {
    
        NavigationView{
            VStack{
                TextField("Enter your word:", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                
                //Geo challenge 2 & 3
                
                List(usedWords, id: \.self){ word in
                    GeometryReader { geo in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                                //.foregroundColor(colors[usedWords.lastIndex(of: word)! % 7])
                                .foregroundColor(Color(
                                    red: Double(geo.frame(in: .global).midY / geo.frame(in: .global).maxY),
                                    green: 0.5,
                                    blue: Double((geo.frame(in: .global).midY / geo.size.height) / 20) - 1)
                                )
                            Text("\(word)")
                        }
                        .offset(x: geo.frame(in: .global).minY > 600 ? CGFloat( usedWords.lastIndex(of: word)! * 4) : 0, y: 0)
                        //testing
                        .onTapGesture {
                            print(Double(geo.frame(in: .global).midY / geo.frame(in: .global).maxY))
                            print((geo.frame(in: .global).midY / geo.size.height) / 10)
                        }
                        
                        .accessibilityElement(children: .ignore)
                        .accessibility(label: Text("\(word), \(word.count) letters"))
                    }
                }
                
                Text("Score: \(scoreCount)")
            }
            .navigationBarTitle(rootWord)
            .navigationBarItems(leading:
                Button(action: startGame){
                    Text("Start")
                }
            )
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError, content: {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("ok")))
            })
        }
    }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isStartWord(word: answer) else {
            wordError(title: "Word is questionword", message: "dont use the word we are looking for")
            return
        }
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "Check your spelling")
            return
        }
        guard isRealWord(word: answer) else {
            wordError(title: "Word doesnt exist", message: "that is not a real word")
            return
        }
        
        usedWords.insert(answer, at: 0)
        scoreCount += answer.count
        newWord = ""
    }
    
    func startGame(){
        
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordURL){
                
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "pickleboy"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle")
    }
    
    func isStartWord(word: String) -> Bool {
        if word == rootWord{
            return false
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isRealWord(word: String) -> Bool {
        
        if word.count < 3 {
            return false
        }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
