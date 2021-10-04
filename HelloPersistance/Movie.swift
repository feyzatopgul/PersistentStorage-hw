//
//  Books.swift
//  HelloPersistance
//
//  Created by fyz on 7/6/18.
//  Copyright © 2018 Feyza Topgul. All rights reserved.
//

import Foundation

class Movie {
    
    var id: Int
    var name: String?
    var rate: Int
    
    init(id: Int, name: String?, rate: Int){
        self.id = id
        self.name = name
        self.rate = rate
    }
}
