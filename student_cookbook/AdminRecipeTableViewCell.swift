//
//  AdminRecipeTableViewCell.swift
//  student_cookbook
//
//  Created by Jade Redworth on 03/05/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit

class AdminRecipeTableViewCell: UITableViewCell {

    @IBOutlet weak var labelRecipeName: UILabel!
    @IBOutlet weak var labelAddedBy: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
