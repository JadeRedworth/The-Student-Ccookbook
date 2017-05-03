//
//  AdminTableViewCell.swift
//  student_cookbook
//
//  Created by Jade Redworth on 25/03/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit

class AdminTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewRecipe: UIImageView!
    @IBOutlet weak var labelRecipeName: UILabel!
    @IBOutlet weak var labelAddedBy: UILabel!
    @IBOutlet weak var labelDateAdded: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
