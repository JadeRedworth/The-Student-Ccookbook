//
//  UserReviewsTableViewCell.swift
//  student_cookbook
//
//  Created by Jade Redworth on 12/05/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit

class UserReviewsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelRecipeName: UILabel!
    @IBOutlet weak var labelReview: UILabel!
    @IBOutlet weak var labelStar: UILabel!
    @IBOutlet weak var photoViewRecipe: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
