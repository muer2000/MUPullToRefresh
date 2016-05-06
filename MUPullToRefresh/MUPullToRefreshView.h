//
//  MUPullToRefreshView.h
//  MUPullToRefresh
//
//  Created by Muer on 15/4/23.
//  Copyright (c) 2015年 Muer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MUPullToRefreshView : UIView

- (void)beginRefreshing;
- (void)beginRefreshingWithAnimated:(BOOL)animated;

- (void)endRefreshing;

- (BOOL)isRefreshing;

@property (nonatomic, assign) CGFloat threshold;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong) NSDate *lastUpdateTime;
@property (nonatomic, copy) void (^actionHandler)(UIScrollView *sender);

@end
