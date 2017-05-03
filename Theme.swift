//
//  Theme.swift
//  student_cookbook
//
//  Created by Jade Redworth on 30/04/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit

let SelectedThemeKey = "SelectedTheme"

enum Theme {
    case `default`, reverse
    
    var primaryColor: UIColor {
        switch self {
        case .default: return UIColor().HexToColor(hexString: "#339966", alpha: 1.0)
        case .reverse: return UIColor.white
        }
    }
    
    var primaryText: UIColor {
        switch self {
        case .default: return UIColor.white
        case .reverse: return UIColor.black
        }
    }
}

struct ThemeManager {
    
    static func applyTheme(theme: Theme) {
        
        UINavigationBar.apply(theme: theme)
        UIButton.apply(theme: theme)
        UIToolbar.appearance().tintColor = theme.primaryColor
    }
}

extension UIButton {
    
    static func apply(theme: Theme) {
        UIButton.appearance().backgroundColor = theme.primaryColor
        UIButton.appearance().tintColor = theme.primaryText
    }
    
    func apply(theme: Theme) {
        self.backgroundColor = theme.primaryColor
        self.tintColor = theme.primaryText
    }
}

extension UINavigationBar {
    
    static func apply(theme: Theme) {
        
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = theme.primaryColor
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().clipsToBounds = false
        
        UINavigationBar.appearance().backgroundColor = theme.primaryColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
    }
}


