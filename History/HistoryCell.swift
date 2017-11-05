//
//  HistoryCell.swift
//  Assignment4
//
//  Created by Can Wang on 31/10/17.
//  Copyright © 2017 Can Wang. All rights reserved.
//

import UIKit

// history cell
class HistoryCell: UITableViewCell {

    @IBOutlet weak var illuminationLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var moistureLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
