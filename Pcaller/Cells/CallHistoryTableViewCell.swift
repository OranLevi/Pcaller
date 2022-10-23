//
//  CallHistoryTableViewCell.swift
//  Pcaller
//
//  Created by Oran Levi on 22/10/2022.
//

import UIKit

class CallHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var firstAndLastNameLabel: UILabel!
    @IBOutlet weak var telePhone: UILabel!
    @IBOutlet weak var timeDateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
