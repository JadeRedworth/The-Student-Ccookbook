//
//  LogoutViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 21/05/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit
import FirebaseAuth

class LogoutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleLogout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleLogout() {
        try! FIRAuth.auth()!.signOut()
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        present(vc!, animated: true, completion: nil)
    }
}
