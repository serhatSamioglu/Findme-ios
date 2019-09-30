//
//  Message.swift
//  Findme
//
//  Created by Serhat Şamioğlu on 12.09.2019.
//  Copyright © 2019 Serhat Şamioğlu. All rights reserved.
//

import Foundation//UIKİT ile Foundation farkına bak

class Message: NSObject {
    var message : String?
    var sender : String?
    var date : String?
    var type : String?
    
    func tempCons(_ message :String, _ sender :String, _ date :String, _ type :String){
        self.message = message
        self.sender = sender
        self.date = date
        self.type = type
    }
    
    func toDictionary() -> Any {
        return ["message":message, "sender":sender, "date":date, "type":type] as Any
    }
}
