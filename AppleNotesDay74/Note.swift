//
//  Note.swift
//  AppleNotesDay74
//
//  Created by Samat on 17.08.2020.
//  Copyright © 2020 somfish. All rights reserved.
//

import UIKit

class Note: NSObject, Codable {
    var title: String
    var subtitle: String
    var body: String
    
    init(body: String) {
        let arr = body.components(separatedBy: "\n")
        self.title = arr[0]
        self.subtitle = arr.count > 1 ? arr[1] : ""
        self.body = body
    }
}
