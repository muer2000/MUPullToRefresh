//
//  MUInfiniteScrollingView.h
//  MUPullToRefresh
//
//  Created by Muer on 15/4/23.
//  Copyright (c) 2015年 Muer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MUInfiniteScrollingView : UIView

- (void)beginLoading;
- (void)endLoading;

- (BOOL)isLoading;

@property (nonatomic, assign) CGFloat threshold;
@property (nonatomic, assign) BOOL isNoMoreData;

@property (nonatomic, copy) void (^actionHandler)(UIScrollView *sender);

@end
