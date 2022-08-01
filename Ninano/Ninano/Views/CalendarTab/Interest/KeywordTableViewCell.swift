//
//  KeywordTableViewCell.swift
//  Ninano
//
//  Created by KYUBO A. SHIM on 2022/07/15.
//

import UIKit

final class KeywordTableViewCell: UITableViewCell {

    @IBOutlet weak var keywordDate: UILabel!
    @IBOutlet weak var keywordTitle: UILabel!
    @IBOutlet weak var keywordImage: UIImageView!
    @IBOutlet weak var keywordBackgroundCell: UIView!
    
    @IBAction func keywordToDetail(_ sender: UIButton) {
        print("hello?")
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}
