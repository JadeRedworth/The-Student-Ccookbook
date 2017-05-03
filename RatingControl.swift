//
//  RatingControl.swift
//  student_cookbook
//
//  Created by Jade Redworth on 23/03/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    //MARK: Properties
    private var ratingButtons = [UIButton]()
    var rating = 0 {
        didSet {
            updateButtonSelectionStates()
        }
    }
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupRatingButtons()
        }
    }
    
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupRatingButtons()
        }
    }
    
    //MARK: Initialization
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setupRatingButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupRatingButtons()
    }
    
    //MARK: Private Methods
    private func setupRatingButtons(){
        
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        // Load Button Images
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named:"emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named:"highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        for _ in 0..<starCount {
            
            let ratingButton = UIButton()
            
            // Set the button images
            ratingButton.setImage(emptyStar, for: .normal)
            ratingButton.setImage(filledStar, for: .selected)
            ratingButton.setImage(highlightedStar, for: .highlighted)
            ratingButton.setImage(highlightedStar, for: [.highlighted, .selected])
            
            ratingButton.translatesAutoresizingMaskIntoConstraints = false
            ratingButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
            ratingButton.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
            
            ratingButton.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(button:)), for: .touchUpInside)
            
            addArrangedSubview(ratingButton)
            
            ratingButtons.append(ratingButton)
        }
        updateButtonSelectionStates()
    }
    
    //MARK: Button Actions
    func ratingButtonTapped(button: UIButton) {

        guard let index = ratingButtons.index(of: button) else {
            fatalError("The button, \(button), is not in the ratingButtons array: \(ratingButtons)")
        }
        
        let selectedRating = index + 1
        
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    private func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            // If the index of a button is less than the rating, that button should be selected.
            button.isSelected = index < rating
        }
    }
}
