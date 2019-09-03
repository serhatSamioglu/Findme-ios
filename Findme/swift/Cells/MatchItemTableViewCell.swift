//
//  MatchItemTableViewCell.swift
//  Findme
//
//  Created by Serhat Şamioğlu on 31.08.2019.
//  Copyright © 2019 Serhat Şamioğlu. All rights reserved.
//

import UIKit

class MatchItemTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var matchRatio: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
