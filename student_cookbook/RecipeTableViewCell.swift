//
//  RecipeTableViewCell.swift
//  student_cookbook
//
//  Created by Jade Redworth on 28/03/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var labelRecipeName: UILabel!
    @IBOutlet weak var labelRecipeAddedBy: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
