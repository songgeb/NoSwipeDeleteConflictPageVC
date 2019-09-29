//
//  ViewController.swift
//  NoSwipeDeleteConflictPageViewController
//
//  Created by songgeb on 2019/9/28.
//  Copyright © 2019 Songgeb. All rights reserved.
//

import UIKit

protocol NoSwipeDeleteConflictPageVCDelegate: AnyObject {
  
  /// 手势左右滑动触发vc切换时执行该回调
  /// - Parameter vc: 当前pagevc
  /// - Parameter vc: 切换到的目的UIViewController
    func pageViewController(
      _ vc: NoSwipeDeleteConflictPageViewController,
      didChangeTo dest: UIViewController)
}

protocol NoSwipeDeleteConflictPageVCDataSource: AnyObject {
  
  /// 获取`viewControllerBefore`之前的`UIViewController`
  /// - Parameter vc: PageViewController
  /// - Parameter viewControllerBefore:
  func pageViewController(
    _ vc: NoSwipeDeleteConflictPageViewController,
    viewControllerBefore viewController: UIViewController) -> UIViewController?
  
  /// 获取`viewControllerAfter`之后的`UIViewController`
  /// - Parameter vc: PageViewController
  /// - Parameter viewControllerAfter:
  func pageViewController(
    _ vc: NoSwipeDeleteConflictPageViewController,
    viewControllerAfter viewController: UIViewController) -> UIViewController?
}

/// `horizontal scrolling page viewcontroller`，模拟`UIPageViewController`效果，但可以支持`UITableView`的swipe delete手势
class NoSwipeDeleteConflictPageViewController: UIViewController {
  
  // MARK: - public property
  var isLeftBounceOn = true
  var isRightBounceOn = true
  
  weak var delegate: NoSwipeDeleteConflictPageVCDelegate?
  weak var dataSource: NoSwipeDeleteConflictPageVCDataSource?
  
  // MARK: - private property
  private enum Position {
    case pre, current, next
  }
  private var displayViewController: UIViewController?
  private var displayView: UIView? {
    return displayViewController?.view
  }
  private var preDisplayViewController: UIViewController?
  
  private enum InsertionType {
    case none
    // true: 表示向右边插入view, false: 表示向左边插入view
    case insert(UIViewController, Bool)
  }
  
  /// 一次移动过程中是否有view插入
  private var insertStatus = InsertionType.none
  
  private lazy var scrollView: UIScrollView = {
      let scrollView = UIScrollView()
      scrollView.showsVerticalScrollIndicator = false
      scrollView.showsHorizontalScrollIndicator = false
      // 此处自己实现了一个类似scrollView panGestureRecognizer的手势，是因为自己实现的手势会更方便和其他手势协作，如为了实现消息页tableview左滑删除和左右滑动页面切换同时work的效果。
      scrollView.isScrollEnabled = false
      scrollView.panGestureRecognizer.isEnabled = false
      let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
      pan.delegate = self
      scrollView.addGestureRecognizer(pan)
      return scrollView
  }()
  private var previousX: CGFloat = -1
  private var isAppear = false
    
  // MARK: - public function
  func setViewController(_ vc: UIViewController) {
    preDisplayViewController = displayViewController
    displayViewController = vc
    // 两种情况
    // pagevc还未展示，直接添加到
    // pagevc已经展示，执行该方法替换或展示新vc的view
      // 当有旧view时，类似右滑插入新view
      // 当没有旧view时，直接展示
    if isAppear {
      if preDisplayViewController != nil {
        if preDisplayViewController == displayViewController { return }
        insert(vc, pre: false)
        vc.beginAppearanceTransition(true, animated: true)
        scroll(to: true, completion: {
          vc.endAppearanceTransition()
        })
      } else {
        vc.beginAppearanceTransition(true, animated: false)
        addViewAndDisplayIfNeed()
        vc.endAppearanceTransition()
      }
    }
  }
  
  private func addViewAndDisplayIfNeed() {
    guard let displayView = displayView else { return }
    scrollView.addSubview(displayView)
    displayView.frame = CGRect(
      x: scrollView.bounds.width,
      y: 0,
      width: scrollView.bounds.width,
      height: scrollView.bounds.height)
    
    scrollView.contentOffset = CGPoint(
      x: scrollView.bounds.width,
      y: scrollView.contentOffset.y)
  }
  
  /// `scrollView`中插入vc的view
  /// - Parameter vc: 新插入的视图vc
  /// - Parameter pre: 是否向左边插入view
  private func insert(_ vc: UIViewController, pre: Bool = true) {
    if vc.view.superview == scrollView { return }
    scrollView.addSubview(vc.view)
    if pre {
      vc.view.frame = CGRect(x: 0, y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
    } else {
      vc.view.frame = CGRect(x: scrollView.bounds.width * 2, y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
    }
  }
  
  /// 滚动到右边/左边的视图
  /// - Parameter next: true表示向右边插入视图, false表示向左边插入视图
  /// - Parameter completion: 动画结束回调
  private func scroll(to next: Bool, completion: (() -> Void)?) {
    let scrollOffsetY = scrollView.contentOffset.y
    let scrollViewWidth = scrollView.bounds.width
    UIView.animate(
      withDuration: 0.3,
      animations: {
        let offsetX: CGFloat
        if next {
          offsetX = scrollViewWidth * 2
        } else {
          offsetX = scrollViewWidth
        }
        self.scrollView.contentOffset = CGPoint(x: offsetX, y: scrollOffsetY)
      },
      completion: { (finished) in
        self.afterScrolling()
        completion?()
    })
  }
  
  /// 滚动到新的视图后，清除上一个视图，将新视图移动到scrollView中间，始终保持新的视图在scrollView中间位置
  private func afterScrolling() {
    guard let displayVC = displayViewController else { return }
    // 删除上一个
    preDisplayViewController?.view.removeFromSuperview()
    preDisplayViewController = nil
    // 将新的view添加到中间
    displayVC.view.frame = CGRect(
      x: self.scrollView.bounds.width,
      y: 0,
      width: self.scrollView.bounds.width,
      height: self.scrollView.bounds.height)
    // 非动画移动contentOffset到中间
    self.scrollView.contentOffset = CGPoint(
      x: scrollView.bounds.width,
      y: scrollView.contentOffset.y)
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    if #available(iOS 11, *) {
      scrollView.contentInsetAdjustmentBehavior = .never
    } else {
      automaticallyAdjustsScrollViewInsets = false
    }
        
    view.addSubview(scrollView)
    scrollView.frame = view.bounds
    scrollView.contentSize = CGSize(
      width: scrollView.bounds.width * 3,
      height: scrollView.bounds.height)
    
    addViewAndDisplayIfNeed()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    displayViewController?.beginAppearanceTransition(true, animated: animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    displayViewController?.beginAppearanceTransition(false, animated: animated)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    isAppear = true
    displayViewController?.endAppearanceTransition()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    isAppear = false
    displayViewController?.endAppearanceTransition()
  }
  
  override var shouldAutomaticallyForwardAppearanceMethods: Bool {
    return false
  }
}

// MARK: - Handle Pan Gesture Recognizer
extension NoSwipeDeleteConflictPageViewController {
  
  private var contentOffset: CGPoint {
      return scrollView.contentOffset
  }
  
  @objc private func pan(_ gesture: UIPanGestureRecognizer) {
    guard let displayVC = displayViewController
    else { return }
    let velocity = gesture.velocity(in: gesture.view).x
    let point = gesture.location(in: nil)
    let x = point.x
    
    func scrollToBoundsAfterGesture() {
      scrollToBounds(velocity: velocity) { [weak self] (position) in
        guard let self = self else { return }
        switch (position, self.insertStatus) {
        case (.next, .insert(let vc, true)), (.pre, .insert(let vc, false)):
          self.preDisplayViewController = self.displayViewController
          self.displayViewController = vc
          vc.endAppearanceTransition()
          displayVC.endAppearanceTransition()
          
          self.delegate?.pageViewController(self, didChangeTo: vc)
        case (.current, .insert(let vc, _)):
          self.preDisplayViewController = vc
          vc.beginAppearanceTransition(false, animated: true)
          vc.endAppearanceTransition()
          
          displayVC.beginAppearanceTransition(true, animated: true)
          displayVC.endAppearanceTransition()
          
          self.delegate?.pageViewController(self, didChangeTo: displayVC)
        default:
          break
        }
        self.afterScrolling()
        self.insertStatus = .none
      }
    }
    
    switch gesture.state {
    case .began:
      previousX = x
    case .changed:
      let contentOffsetX = scrollView.contentOffset.x
      if velocity >= 0 && contentOffsetX < scrollView.bounds.width {
        // 右滑
        switch insertStatus {
        case .none:
          if let preVC = dataSource?.pageViewController(self, viewControllerBefore: displayVC) {
            insert(preVC, pre: true)
            insertStatus = .insert(preVC, false)
            preVC.beginAppearanceTransition(true, animated: true)
            displayVC.beginAppearanceTransition(false, animated: true)
          }
        case .insert(let vc, let isNext):
          break
        }
      }
      
      if velocity < 0 && contentOffsetX > scrollView.bounds.width {
        // 左滑
        switch insertStatus {
        case .none:
          if let nextVC = dataSource?.pageViewController(self, viewControllerAfter: displayVC) {
            insert(nextVC, pre: false)
            insertStatus = .insert(nextVC, true)
            nextVC.beginAppearanceTransition(true, animated: true)
            displayVC.beginAppearanceTransition(false, animated: true)
          }
        case .insert(let vc, let isNext):
          break
        }
      }
      let interval = previousX - x
      
      func adjustOffsetWithResistance() {
        let delta = abs(scrollView.bounds.width - contentOffsetX)
        let small = (2 / delta) * interval
        scrollView.contentOffset = CGPoint(x: contentOffset.x + small, y: contentOffset.y)
      }
      // 计算实时的contentOffset
      // 1. 正常情况下直接加interval就好
      // 2. 当左右没有新的vc要插入时，应模拟scrollView的bounce效果，给拖拽添加阻力
      if contentOffsetX < scrollView.bounds.width, velocity > 0 {
        // 右滑
        switch insertStatus {
        case .insert(_, let isNext):
          if isNext {
            adjustOffsetWithResistance()
          } else {
            scrollView.contentOffset = CGPoint(x: contentOffset.x + interval, y: contentOffset.y)
          }
        case .none:
          adjustOffsetWithResistance()
        }
      } else if contentOffsetX > scrollView.bounds.width, velocity < 0 {
        // 左滑
        switch insertStatus {
        case .insert(_, let isNext):
          if !isNext {
            adjustOffsetWithResistance()
          } else {
            scrollView.contentOffset = CGPoint(x: contentOffset.x + interval, y: contentOffset.y)
          }
        case .none:
          adjustOffsetWithResistance()
        }
      } else {
        scrollView.contentOffset = CGPoint(x: contentOffset.x + interval, y: contentOffset.y)
      }
      
      previousX = x
    case .ended:
      scrollToBoundsAfterGesture()
      previousX = x
    case .cancelled:
      scrollToBoundsAfterGesture()
    default:
      scrollToBoundsAfterGesture()
    }
  }
  
  /// pan松手后，根据速度和当前`scrollView.contentOffset`位置，自动将`scrollView`移动到合适位置
  /// - Parameter velocity: 速度
  /// - Parameter completion:
  private func scrollToBounds(velocity: CGFloat = 0, completion: ((Position) -> Void)?) {
    let offsetX = scrollView.contentOffset.x
    var destOffsetX: CGFloat = 0
    let scrollViewWidth = scrollView.bounds.width
    var position: Position = .current
    
    func defaultAction() {
      if offsetX <= 0.5 * scrollViewWidth {
        destOffsetX = 0
        position = .pre
      } else if offsetX <= 1.5 * scrollViewWidth {
        destOffsetX = scrollViewWidth
        position = .current
      } else {
        destOffsetX = 2 * scrollViewWidth
        position = .next
      }
    }
    
    switch insertStatus {
    case .insert(_, let isNext):
      if abs(velocity) > 300 {
        if velocity > 0, !isNext {
          // 右滑
          destOffsetX = 0
          position = .pre
        } else if velocity < 0, isNext {
          // 左滑
          destOffsetX = 2 * scrollViewWidth
          position = .next
        } else {
          defaultAction()
        }
      } else {
        defaultAction()
      }
    case .none:
      defaultAction()
    }
    
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      options: [.allowUserInteraction],
      animations: {
        self.scrollView.contentOffset = CGPoint(x: destOffsetX, y: self.contentOffset.y)
      },
      completion: { (finished)in
        if finished { completion?( position ) }
    })
  }
}

// MARK: - GestureRecognizer Delegate
extension NoSwipeDeleteConflictPageViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let panner = gestureRecognizer as? UIPanGestureRecognizer else {
      fatalError("")
    }
    
    guard let vc = displayViewController,
          let source = dataSource
    else {
      return false
    }
    
    // 用于处理左右边缘取消bounce效果，比如右边缘取消bounce效果，这样tableviewcell的左滑删除操作可以work
    if !isRightBounceOn,
       source.pageViewController(self, viewControllerAfter: vc) == nil,
       panner.velocity(in: panner.view).x < 0 {
      return false
    }
    
    if !isLeftBounceOn,
       source.pageViewController(self, viewControllerBefore: vc) == nil,
       panner.velocity(in: panner.view).x > 0 {
      return false
    }
    return true
  }
  
  private func findTableViewRecursively(_ view: UIView) -> UITableView? {
    if let tableView = view as? UITableView {
      return tableView
    } else {
      for subView in view.subviews {
        if let dest = findTableViewRecursively(subView) {
            return dest
        }
      }
    }
    return nil
  }
}
