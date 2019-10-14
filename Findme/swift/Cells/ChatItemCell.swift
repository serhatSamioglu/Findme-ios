//
//  ChatItemCell.swift
//  Findme
//
//  Created by Serhat Şamioğlu on 27.09.2019.
//  Copyright © 2019 Serhat Şamioğlu. All rights reserved.
//

import UIKit

class ChatItemCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64,y: textLabel!.frame.origin.y-2,width: textLabel!.frame.width,height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64,y: detailTextLabel!.frame.origin.y+2,width: detailTextLabel!.frame.width,height: detailTextLabel!.frame.height)
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        //label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let unreadMessages: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 7
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    
        addSubview(profileImageView)
        addSubview(timeLabel)
        addSubview(unreadMessages)
        //need x,y,width,height anchors for profileImageView
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        //need x,y,width,height anchors for timeLabel
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: textLabel!.centerYAnchor).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
        //need x,y,width,height anchors for unreadedMessage
        unreadMessages.rightAnchor.constraint(equalTo: timeLabel.centerXAnchor).isActive = true
        unreadMessages.centerYAnchor.constraint(equalTo: detailTextLabel!.centerYAnchor).isActive = true
        //unreadMessages.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        unreadMessages.widthAnchor.constraint(equalToConstant: 14).isActive = true
        unreadMessages.heightAnchor.constraint(equalToConstant: 14).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
