//
//  PlaceholderViewController.swift
//  NoSwipeDeleteConflictPageVC
//
//  Created by songgeb on 2019/9/28.
//  Copyright © 2019 Songgeb. All rights reserved.
//

import UIKit

extension UIColor {
  static public func randomColor() -> UIColor {
      let r = Float(arc4random_uniform(255)) / 255
      let g = Float(arc4random_uniform(255)) / 255
      let b = Float(arc4random_uniform(255)) / 255
      
      return UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1)
  }
}

class PlaceholderViewController: UIViewController {

  deinit {
    print("deinit->\(self)")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("viewdidload->\(self)")
      
    view.backgroundColor = UIColor.randomColor()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print("viewwillappear->\(self)")
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    print("viewDidAppear->\(self)")
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    print("viewwilldisappear->\(self)")
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    print("viewdiddisappear->\(self)")
  }

}
