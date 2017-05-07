//
//  AdminRecipeTableViewCell.swift
//  student_cookbook
//
//  Created by Jade Redworth on 03/05/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit

class AdminRecipeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageViewRecipe: UIImageView!
    @IBOutlet weak var labelRecipeName: UILabel!
    @IBOutlet weak var labelAddedBy: UILabel!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        labelRecipeName?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        labelAddedBy?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
        
        imageViewRecipe.setCircleSize()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "AdminRecipeTableViewCell")
        
        addSubview(imageViewRecipe)
        
        imageViewRecipe.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        imageViewRecipe.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageViewRecipe.widthAnchor.constraint(equalToConstant: 48).isActive = true
        imageViewRecipe.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    
        // Configure the view for the selected state
    }
}
