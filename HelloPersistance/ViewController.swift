//
//  ViewController.swift
//  HelloPersistance
//
//  Created by fyz on 7/6/18.
//  Copyright © 2018 Feyza Topgul. All rights reserved.
//

import UIKit
import SQLite3

class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    var db: OpaquePointer?
    var movieList = [Movie]()

    @IBOutlet weak var movieNameField: UITextField!
    @IBOutlet weak var movieRateField: UITextField!
    @IBOutlet weak var moviesTableView: UITableView!
    
    @IBAction func saveButton(_ sender: Any) {
        let name = movieNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let rate = movieRateField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if(name?.isEmpty)!{
            movieNameField.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        if(rate?.isEmpty)!{
            movieRateField.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        var stmt: OpaquePointer?
        
        let queryString = "INSERT INTO Movies (name, rate) VALUES (?,?)"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 1, name, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(stmt, 2, (rate! as NSString).intValue) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        
        movieNameField.text=""
        movieRateField.text=""
        
        readValues()
        
        print("Movie saved successfully")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "movieCell")
        let movie: Movie
        movie = movieList[indexPath.row]
        cell.textLabel?.text = movie.name
        return cell
    }
    
    
    func readValues(){
        movieList.removeAll()
        
        let queryString = "SELECT * FROM Movies"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let rate = sqlite3_column_int(stmt, 2)
            
            movieList.append(Movie(id: Int(id), name: String(describing: name), rate: Int(rate)))
        }
        
        self.moviesTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("MoviesDatabase.sqlite")
        
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Movies (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, rate INTEGER)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        readValues()
    }
}
