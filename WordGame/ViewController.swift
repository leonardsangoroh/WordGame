//
//  ViewController.swift
//  WordGame
//
//  Created by Lee Sangoroh on 02/11/2023.
//

import UIKit

class ViewController: UITableViewController {
    
    //arrays for holding data
    var allWords = [String]()
    var usedWords = [String]()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        //left button
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(restart))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: ".txt") {
            
            if let startWords = try? String(contentsOf:startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
    }
    
    @objc func restart () {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    func startGame() {
        loadPreviousState()
        tableView.reloadData()
    }
    
    //number of rows on the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    //what each row should look like
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //make cell reusable
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer(){
        
        ///Creating a UIAlertController
        ///addTextField() adds an editable test input field to the UIAlertController
        let ac = UIAlertController(title: "Submit", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        /// The in keyword is important: everything before that describes the closure; everything after that is the closure.
        /// So action in means that it accepts one parameter in, of type UIAlertAction............................That declares self (the current view controller) and ac (our UIAlertController) to be captured as weak references inside the closure.
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
            ///safely unwraps the array of TextFields
            guard let answer = ac?.textFields?[0].text else {return}
            ///Inside the closure we need to reference methods on our view controller using self so that we’re clearly acknowledging the possibility of a strong reference cycle.
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        saveStatus()
        present(ac, animated: true)
    }
    
    
    func submit (_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        guard isTitle(word: lowerAnswer) else {
            
           return showErrorMessage(title: "No Way!", message: "You can't just repeat the word")

        }
        guard isLong(word: lowerAnswer) else {
            
           return showErrorMessage(title: "Word too short", message: "Make it longer")
            
        }
        guard isPossible(word: lowerAnswer) else {
            
            guard let title = title?.lowercased() else {return}
            return showErrorMessage(title: "Word not Possible", message: "You can't spell that word from \(title)")
        }
        guard isOriginal(word: lowerAnswer) else {
            
            return showErrorMessage(title: "Word used already", message: "Be more original!")

        }
        guard isReal(word: lowerAnswer) else {
            
            return showErrorMessage(title: "Word not recognised", message: "You can't just make them")

        }
        
        usedWords.insert(answer, at:0)
                            
        ///insert row into table view
        let indexPath = IndexPath(row: 0, section: 0)
        /// the with parameter lets you specify how the row should be animated in. Whenever you're adding and removing things from a table, the .automatic value means "do whatever is the standard system animation for this change." In this case, it means "slide the new row in from the top."
        tableView.insertRows(at: [indexPath], with: .automatic)
        return
    }
    
    func showErrorMessage(title: String, message: String) {
           let errorTitle = title
           let errorMessage = message

           let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
           ac.addAction(UIAlertAction(title: "OK", style: .default))
           present(ac, animated: true)
     }

    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else {return false}
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                ///remove letter from tempWord if found
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }

    func isOriginal(word: String) -> Bool {
        ///.contains is method that checks whether the arrays it's called on contains the value specified in the parameter
        /// ! - while in front of a variable or constant, it means 'not', when at the end, it means 'force unwrap'
        return !usedWords.contains(word)
    }

    func isReal(word: String) -> Bool {
        ///UITextChecker - an iOS class designed to spot spelling errors
        ///Create instance and put it into the checker constant
        let checker = UITextChecker()
        //type used to store a string range
        let range = NSRange(location: 0, length: word.utf16.count)
        
//        if word.count <= 3 {
//            return false
//        }
        
        /// - Parameters:
        ///        - in: the string to be checked
        ///        - range: range to scan
        ///        - startingAt: selects a point in a range where the text checker should start scanning
        ///        - wrap: set whether the UITextChecker should start at the beginning of the range if no misspelled word were found starting from parameter three
        ///        - language: language to check with
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isLong(word:String) -> Bool{
        if word.count <= 3 {
            return false
        }
        return true
    }

    func isTitle(word:String) -> Bool {
        if word != title {
            return true
        }
        return false
    }
    
    func saveStatus() {
        let defaults = UserDefaults.standard
        
        let arrayOfUsedWords = usedWords
        defaults.set(arrayOfUsedWords, forKey: "savedUsedWords")
        
        let saveTitle = title
        defaults.set(saveTitle, forKey: "savedTitle")
        
        print("status saved")
    }
    
    func loadPreviousState(){
        let defaults = UserDefaults.standard
        
        if let savedArray = defaults.object(forKey: "savedUsedWords") as? [String] {
            usedWords = savedArray
        }
        
        title = defaults.string(forKey: "savedTitle")
    }
}

