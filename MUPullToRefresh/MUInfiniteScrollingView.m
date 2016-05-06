//
//  MUInfiniteScrollingView.m
//  MUPullToRefresh
//
//  Created by Muer on 15/4/23.
//  Copyright (c) 2015年 Muer. All rights reserved.
//

#import "MUInfiniteScrollingView.h"
#import "NSBundle+MURefresh.h"

typedef NS_ENUM(NSInteger, ADInfiniteScrollingState) {
    ADInfiniteScrollingStateStopped,
    ADInfiniteScrollingStateTriggered,
    ADInfiniteScrollingStateLoading
};

static NSString * const kContentOffsetKeyPath = @"contentOffset";
static NSString * const kContentSizeKeyPath = @"contentSize";

@interface MUInfiniteScrollingView()

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL dragging;
@property (nonatomic, assign) BOOL isEndDragging;
@property (nonatomic, assign) ADInfiniteScrollingState state;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UIButton *titleButton;

@end


@implementation MUInfiniteScrollingView

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.threshold = -frame.size.height * 2;
        self.state = ADInfiniteScrollingStateStopped;
        self.dragging = NO;
        self.isEndDragging = YES;
        self.backgroundColor = [UIColor clearColor];
        
        [self createCustomView];
    }
    return self;
}

#pragma mark - Loading

- (void)beginLoading
{
    self.state = ADInfiniteScrollingStateLoading;
    if (self.actionHandler) {
        self.actionHandler(self.scrollView);
    }
}

- (void)endLoading
{
    self.state = ADInfiniteScrollingStateStopped;
}


#pragma mark - override

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setState:(ADInfiniteScrollingState)state
{
    _state = state;
    [self updateAactivityView];
    [self updateTitle];
}

- (BOOL)isLoading
{
    return (self.state == ADInfiniteScrollingStateLoading);
}


#pragma mark - Custom View

- (void)createCustomView
{
    if (!self.titleButton) {
        self.titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.titleButton.frame = self.bounds;
        self.titleButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self setButtonTitle:MURefreshLocalizedString(@"More...", nil)];
        self.titleButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.titleButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.titleButton addTarget:self action:@selector(titleButtonClick) forControlEvents:UIControlEventTouchUpInside];
        self.titleButton.hidden = YES;
        [self addSubview:self.titleButton];
    }

    if (!self.activityView) {
        self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(50, 10, 20, 20)];
        self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        self.activityView.hidden = YES;
        [self addSubview:self.activityView];
    }
}

- (void)titleButtonClick
{
    [self beginLoading];
}

- (void)setIsNoMoreData:(BOOL)isNoMoreData
{
    _isNoMoreData = isNoMoreData;
    [self updateTitle];
}

- (void)setButtonTitle:(NSString *)title
{
    [self.titleButton setTitle:title forState:UIControlStateNormal];
    [self.titleButton setTitle:title forState:UIControlStateDisabled];
}

- (void)updateTitle
{
    if (_isNoMoreData) {
        [self setButtonTitle:MURefreshLocalizedString(@"The end", nil)];
        self.titleButton.enabled = NO;
    }
    else {
        if (_state == ADInfiniteScrollingStateLoading) {
            self.titleButton.enabled = NO;
            [self setButtonTitle:MURefreshLocalizedString(@"Loading...", nil)];
        }
        else {
            [self setButtonTitle:MURefreshLocalizedString(@"More...", nil)];
            self.titleButton.enabled = YES;
        }
    }
}

- (void)updateAactivityView
{
    if (_state == ADInfiniteScrollingStateLoading) {
        self.activityView.hidden = NO;
        [self.activityView startAnimating];
    }
    else {
        self.activityView.hidden = YES;
        [self.activityView stopAnimating];
    }
}


#pragma mark - Frame

- (void)updateFrameWithScrollViewContent
{
    CGRect tRect = self.frame;
    tRect.origin.y = MAX(self.scrollView.contentSize.height, self.scrollView.frame.size.height);
    self.frame = tRect;
    
    self.titleButton.hidden = self.scrollView.contentSize.height < self.scrollView.frame.size.height;
}


#pragma mark - UIScrollView

- (UIScrollView *)scrollView
{
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        return (UIScrollView *)self.superview;
    }
    return nil;
}


#pragma mark - Observer

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        [self.superview removeObserver:self forKeyPath:kContentOffsetKeyPath];
        [self.superview removeObserver:self forKeyPath:kContentSizeKeyPath];
    }
    if ([newSuperview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)newSuperview;
        self.frame = CGRectMake(0, MAX(scrollView.contentSize.height, scrollView.frame.size.height),
                                  scrollView.bounds.size.width, self.frame.size.height);

        UIEdgeInsets insets = scrollView.contentInset;
        insets.bottom = scrollView.contentInset.bottom + self.frame.size.height;
        scrollView.contentInset = insets;

        [newSuperview addObserver:self forKeyPath:kContentOffsetKeyPath options:NSKeyValueObservingOptionNew context:NULL];
        [newSuperview addObserver:self forKeyPath:kContentSizeKeyPath options:NSKeyValueObservingOptionNew context:NULL];
    }
    [super willMoveToSuperview:newSuperview];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == nil) {
        return;
    }
    if ([keyPath isEqualToString:kContentOffsetKeyPath]) {
        UIScrollView *scrollView = (UIScrollView *)object;
        if (self.dragging != scrollView.dragging) {
            if (!scrollView.dragging) {
                [self scrollViewDidEndDragging:scrollView willDecelerate:NO];
            }
            self.dragging = scrollView.dragging;
        }
        [self scrollViewDidScroll:object];
    }
    else if([keyPath isEqualToString:kContentSizeKeyPath]) {
        [self updateFrameWithScrollViewContent];
    }
}


#pragma mark - UIScrollViewDelegate (Detected by observing value changes)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(![scrollView isDragging]) {
        return;
    }
    if (self.state == ADInfiniteScrollingStateLoading || self.isNoMoreData) {
        return;
    }
    CGFloat contentHeight = self.scrollView.contentSize.height;
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    UIEdgeInsets contentInset = scrollView.contentInset;
    CGFloat scrollViewHeight = scrollView.frame.size.height;
    if (contentInset.top + contentHeight < scrollViewHeight) {
        return;
    }
    if (self.isEndDragging && contentOffsetY > contentHeight - scrollViewHeight + contentInset.bottom + self.threshold) {
        self.isEndDragging = NO;
        [self beginLoading];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.isEndDragging = YES;
}

@end
