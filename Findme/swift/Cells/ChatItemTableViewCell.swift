//
//  ChatItemTableViewCell.swift
//  Findme
//
//  Created by Serhat Şamioğlu on 25.09.2019.
//  Copyright © 2019 Serhat Şamioğlu. All rights reserved.
//

import UIKit

class ChatItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var lastMessageTime: UILabel!
    @IBOutlet weak var undreadedMessage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
