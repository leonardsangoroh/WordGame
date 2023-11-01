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
    
    func startGame() {
        /// Set View controller title to be a random word in the array (the word the player has to find)
        title = allWords.randomElement()
        /// Removes all values from the usedWords array
        usedWords.removeAll(keepingCapacity: true)
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
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit (_ answer: String) {
        
    }


}

