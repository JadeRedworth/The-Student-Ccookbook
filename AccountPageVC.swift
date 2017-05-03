//
//  AccountPageVC.swift
//  student_cookbook
//
//  Created by Jade Redworth on 01/05/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import Foundation
import UIKit

class AccountPageVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    lazy var VCarray: [UIViewController] = {
        return[self.VCInstance(name: "UserAccountVC"),
               self.VCInstance(name: "SearchUserAccountsVC")]
    }()
    
    private func VCInstance(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        if let userDetailsVC = VCarray.first {
            setViewControllers([userDetailsVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = VCarray.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return VCarray.last
        }
        
        guard VCarray.count > previousIndex else {
            return nil
        }
        
        return VCarray[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = VCarray.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < VCarray.count else {
            return VCarray.first
        }
        
        guard VCarray.count > nextIndex else {
            return nil
        }
        
        return VCarray[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return VCarray.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstVC = viewControllers?.first, let firstVCIndex = VCarray.index(of: firstVC) else {
            return 0
        }
        
        return firstVCIndex
    }
    
}
