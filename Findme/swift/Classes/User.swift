//
//  User.swift
//  Findme
//
//  Created by Serhat Şamioğlu on 27.08.2019.
//  Copyright © 2019 Serhat Şamioğlu. All rights reserved.
//

import Foundation

class User{
    var INITIAL_EMPTY_VALUE: String = ""
    var id: String
    var userEmail: String
    var password: String
    var userName: String
    var answers: String
    var imageUrl: String
    var location: String
    var birthday: String
    var bio: String
    var idOfChatUser: String
    var examPassed: Bool
    var online: Bool
    var messagesPrivacy: Bool
    var minMatchRaito: Int

    init(_ id: String,_ userEmail: String,_ password: String,_ userName: String){
        self.id = id;
        self.userEmail = userEmail;
        self.password = password;
        self.userName = userName;
        self.examPassed=false;
        self.online=false;
        self.answers="00000-0000-000";
        self.imageUrl = INITIAL_EMPTY_VALUE;
        self.minMatchRaito = 50;
        self.location = INITIAL_EMPTY_VALUE;
        self.birthday = INITIAL_EMPTY_VALUE;
        self.bio = INITIAL_EMPTY_VALUE;
        self.messagesPrivacy=false;//false mean is everybody can send message you
        self.idOfChatUser=INITIAL_EMPTY_VALUE;
    }
    /*override init(){
        super.init()
    }*/
    func toDictionary() -> Any {
        return ["id":id, "userEmail":userEmail, "password":password, "userName":userName, "examPassed":examPassed, "online":online,
                "answers":answers, "imageUrl":imageUrl, "minMatchRaito":minMatchRaito, "location":location, "birthday":birthday, "bio":bio,
            "messagesPrivacy":messagesPrivacy, "idOfChatUser":idOfChatUser, ] as Any
    }
}
