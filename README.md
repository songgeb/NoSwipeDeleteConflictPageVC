## Feature

- UITableView的swipe delete和UIPageViewController的左滑手势不冲突
- 同一时间仅支持展示（持有）一个Child VC
- Child VC生命周期调用时机和原生UIPageViewController一致

![](https://raw.githubusercontent.com/songgeb/NoSwipeDeleteConflictPageVC/master/demo.gif)

## How to use

使用方法和原生UIPageViewController类似

- 提供一个public方法`func setViewController(_ vc: UIViewController)`，用于设置初始vc或动态设置要展示的vc
- 实现`NoSwipeDeleteConflictPageVCDataSource`协议，返回每个页面要展示的vc