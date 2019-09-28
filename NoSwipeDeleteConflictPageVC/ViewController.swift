//
//  ViewController.swift
//  NoSwipeDeleteConflictPageVC
//
//  Created by songgeb on 2019/9/28.
//  Copyright © 2019 Songgeb. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  private let pageVC = NoSwipeDeleteConflictPageViewController()
  
  lazy private var vcs: [UIViewController] = {
    var vcs: [UIViewController] = []
    for index in 0..<3 {
      let vc = PlaceholderViewController()
      vcs.append(vc)
    }
    return vcs
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    let tableVC = ATableViewController(
      nibName: "ATableViewController",
      bundle: nil)
    vcs.append(tableVC)
    
    pageVC.dataSource = self
    pageVC.delegate = self
    pageVC.isRightBounceOn = false
    pageVC.setViewController(vcs[0])
    
    addChild(pageVC)
    view.addSubview(pageVC.view)
    pageVC.view.frame = view.bounds
    pageVC.didMove(toParent: self)
  }
}

extension ViewController: NoSwipeDeleteConflictPageVCDataSource {
  func pageViewController(_ vc: NoSwipeDeleteConflictPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    let vcIndex = vcs.firstIndex(of: viewController)
    guard let currentIndex = vcIndex else {
        return nil
    }
    
    let previousIndex = currentIndex - 1
    if !(0..<vcs.count).contains(previousIndex) {
        return nil
    }
    
    return vcs[previousIndex]
  }
  
  func pageViewController(_ vc: NoSwipeDeleteConflictPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    let vcIndex = vcs.firstIndex(of: viewController)
    guard let currentIndex = vcIndex else {
        return nil
    }
    
    let nextIndex = currentIndex + 1
    if !(0..<vcs.count).contains(nextIndex) {
        return nil
    }
    
    return vcs[nextIndex]
  }
}

extension ViewController: NoSwipeDeleteConflictPageVCDelegate {
  func pageViewController(_ vc: NoSwipeDeleteConflictPageViewController, didChangeTo dest: UIViewController) {
  }
}

