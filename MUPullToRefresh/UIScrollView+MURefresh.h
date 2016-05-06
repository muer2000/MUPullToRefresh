//
//  UIScrollView+MURefresh.h
//  MUPullToRefresh
//
//  Created by Muer on 15/4/23.
//  Copyright (c) 2015年 Muer. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const MUPullToRefreshViewHeight;
extern CGFloat const MUInfiniteScrollingViewHeight;

@interface UIScrollView (MURefresh)

- (void)mu_addPullToRefreshWithActionHandler:(void (^)(UIScrollView *sender))actionHandler;
- (void)mu_addInfiniteScrollingWithActionHandler:(void (^)(UIScrollView *sender))actionHandler;

- (void)mu_beginRefreshing;
- (void)mu_beginRefreshingWithAnimated:(BOOL)animated;
- (void)mu_endRefreshing;

- (void)mu_beginLoading;
- (void)mu_endLoading;
- (void)mu_endLoadingWithNoMoreData:(BOOL)isNoMoreData;

@end
