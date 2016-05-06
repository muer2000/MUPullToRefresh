//
//  UIScrollView+MURefresh.m
//  MUPullToRefresh
//
//  Created by Muer on 15/4/23.
//  Copyright (c) 2015年 Muer. All rights reserved.
//

#import "UIScrollView+MURefresh.h"
#import <objc/runtime.h>
#import "MUPullToRefreshView.h"
#import "MUInfiniteScrollingView.h"

CGFloat const MUPullToRefreshViewHeight = 52;
CGFloat const MUInfiniteScrollingViewHeight = 40;

static char MUPullToRefreshViewKey;
static char MUInfiniteScrollingViewKey;

@interface UIScrollView()

@property (nonatomic, readonly) MUPullToRefreshView *pullToRefreshView;
@property (nonatomic, readonly) MUInfiniteScrollingView *infiniteScrollingView;

@end

@implementation UIScrollView (MURefresh)

- (void)mu_addPullToRefreshWithActionHandler:(void (^)(UIScrollView *sender))actionHandler
{
    if (!self.pullToRefreshView) {
        MUPullToRefreshView *refreshView = [[MUPullToRefreshView alloc] initWithFrame:CGRectMake(0, -MUPullToRefreshViewHeight, self.bounds.size.width, MUPullToRefreshViewHeight)];
        refreshView.actionHandler = ^(UIScrollView *scrollView){
            if (self.infiniteScrollingView) {
                self.infiniteScrollingView.isNoMoreData = NO;
            }
            if (actionHandler) {
                actionHandler(scrollView);
            }
        };
        [self addSubview:refreshView];
        
        self.pullToRefreshView = refreshView;
    }
}

- (void)mu_addInfiniteScrollingWithActionHandler:(void (^)(UIScrollView *sender))actionHandler
{
    if (!self.infiniteScrollingView) {
        CGRect tRect = CGRectMake(0, MAX(self.contentSize.height, self.frame.size.height),
                                  self.bounds.size.width, MUInfiniteScrollingViewHeight);
        MUInfiniteScrollingView *infiniteScrollingView = [[MUInfiniteScrollingView alloc] initWithFrame:tRect];
        infiniteScrollingView.actionHandler = actionHandler;
        [self addSubview:infiniteScrollingView];
        
        self.infiniteScrollingView = infiniteScrollingView;
    }
}


#pragma mark - Pull to refresh

- (void)mu_beginRefreshing
{
    [self mu_beginRefreshingWithAnimated:YES];
}

- (void)mu_beginRefreshingWithAnimated:(BOOL)animated
{
    if (self.infiniteScrollingView) {
        self.infiniteScrollingView.isNoMoreData = NO;
    }
    [self.pullToRefreshView beginRefreshingWithAnimated:animated];
}

- (void)mu_endRefreshing
{
    if ([self.pullToRefreshView isRefreshing]) {
        [self.pullToRefreshView endRefreshing];
    }
}


#pragma mark - Infinite scrolling

- (void)mu_beginLoading
{
    [self.infiniteScrollingView beginLoading];
}

- (void)mu_endLoading
{
    [self mu_endLoadingWithNoMoreData:NO];
}

- (void)mu_endLoadingWithNoMoreData:(BOOL)isNoMoreData
{
    self.infiniteScrollingView.isNoMoreData = isNoMoreData;
    if ([self.infiniteScrollingView isLoading]) {
        [self.infiniteScrollingView endLoading];
    }
}


#pragma mark - Property Associative

- (void)setPullToRefreshView:(UIView *)pullToRefreshView
{
    objc_setAssociatedObject(self, &MUPullToRefreshViewKey, pullToRefreshView, OBJC_ASSOCIATION_ASSIGN);
}

- (MUPullToRefreshView *)pullToRefreshView
{
    return objc_getAssociatedObject(self, &MUPullToRefreshViewKey);
}

- (void)setInfiniteScrollingView:(UIView *)infiniteScrollingView
{
    objc_setAssociatedObject(self, &MUInfiniteScrollingViewKey, infiniteScrollingView, OBJC_ASSOCIATION_ASSIGN);
}

- (MUInfiniteScrollingView *)infiniteScrollingView
{
    return objc_getAssociatedObject(self, &MUInfiniteScrollingViewKey);
}

@end
