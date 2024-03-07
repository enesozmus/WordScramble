//
//  ContentView.swift
//  WordScramble
//
//  Created by enesozmus on 7.03.2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var _usedWords = [String]()
    @State private var _rootWord = ""
    @State private var _newWord = ""
    
    @State private var _errorTitle = ""
    @State private var _errorMessage = ""
    @State private var _showingError = false
    
    // challange 3
    @State private var _score = 0
    let _wordLengthValues = [
        8 : 2000,
        7 : 1000,
        6 : 600,
        5 : 500,
        4 : 400,
        3 : 300
    ]
    
    
    var body: some View {
        NavigationStack {
            
            
            List {

                
                Section {
                    TextField("Enter your word", text: $_newWord)
                        .textInputAutocapitalization(.never)
                    // challange 3
                    HStack {
                        Text("Your current score is:")
                        Spacer()
                        Text("\(_score)")
                    }
                }
                
                
                Section {
                    ForEach(_usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                            // challange 3
                            Spacer()
                            Text("+\(_wordLengthValues[word.count] ?? 0)")
                        }
                    }
                }
                
                
            }
            .navigationTitle(_rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(_errorTitle, isPresented: $_showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(_errorMessage)
            }
            // challange 2
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("New word") {
                        startGame()
                    }
                }
            }
            
            
        }
    }
    
    
    // Functions
    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = _newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // exit if the remaining string is empty
        guard answer.count > 0 else { return }
        
        // challange 1
        guard tooShort(word: answer) else {
            wordError(title: "Word must be at least 3 letters", message: "Sorry, that word is too short!")
            return
        }
        // challange 1
        guard isRootWord(word: answer) else {
            wordError(title: "You can't use the root word itself", message: "Sorry, that word is the same as the root word!")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(_rootWord)'!")
            return
        }
        
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        
        withAnimation {
            _usedWords.insert(answer, at: 0)
        }
        // Challange 3
        //_score += 100
        _score += _wordLengthValues[answer.count] ?? 0
        _newWord = ""
    }
    // Function
    func startGame() {
        // 0. Reset the used words and score (challange 3)
        _usedWords.removeAll()
        _score = 0
        
        // 1. Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")
                // 4. Pick one random word, or use "silkworm" as a sensible default
                _rootWord = allWords.randomElement() ?? "silkworm"
                // If we are here everything has worked, so we can exit
                return
            }
        }
        // If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }
    // Function
    func isOriginal(word: String) -> Bool {
        !_usedWords.contains(word)
    }
    // Function
    func wordError(title: String, message: String) {
        _errorTitle = title
        _errorMessage = message
        _showingError = true
    }
    // Function
    func isPossible(word: String) -> Bool {
        var tempWord = _rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    // Function
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word,
                                                            range: range,
                                                            startingAt: 0,
                                                            wrap: false,
                                                            language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    // Challange 1
    func tooShort(word: String) -> Bool {
        
        if word.count <= 2 {
            return false
        }
        return true
    }
    // Challange 1
    func isRootWord(word: String) -> Bool {
        
        if word == _rootWord {
            return false
        }
        return true
    }
}

#Preview {
    ContentView()
}
