//
//  MUPullToRefreshView.m
//  MUPullToRefresh
//
//  Created by Muer on 15/4/23.
//  Copyright (c) 2015年 Muer. All rights reserved.
//

#import "MUPullToRefreshView.h"
#import "NSBundle+MURefresh.h"

typedef NS_ENUM(NSInteger, ADPullToRefreshState) {
    ADPullToRefreshStateHidden,
    ADPullToRefreshStatePullingDown,
    ADPullToRefreshStateOveredThreshold,
    ADPullToRefreshStateRefreshing
};

static const CGFloat kAnimateWithDuration = 0.3;

static const CGFloat kTitleWidth = 200.0;
static const CGFloat kTitleHeight = 21.0;

static NSString * const kContentOffsetKeyPath = @"contentOffset";

@interface NSDate (MUPullToRefresh)

- (NSString *)muptr_formatString;

@end

@interface MUPullToRefreshView ()

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL dragging;
@property (nonatomic, assign) ADPullToRefreshState state;


@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, readonly) NSString *lastUpdateFormattedString;

@property (nonatomic, assign) UIEdgeInsets originalContentInset;

@end

@implementation MUPullToRefreshView

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.threshold = -frame.size.height; // -50;
        self.state = ADPullToRefreshStateHidden;
        self.dragging = NO;
        self.backgroundColor = [UIColor clearColor];
        
        [self createArrowViews];
    }
    return self;
}

#pragma mark - Arrow Style

- (void)createArrowViews
{
    self.lastUpdateTime = nil;
    NSBundle *bundle = [NSBundle muRefreshBundle];
    UIImage *arrowImage = [UIImage imageWithContentsOfFile:[[bundle bundlePath] stringByAppendingPathComponent:@"MU_PullToRefreshArrow.png"]];
    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 5, arrowImage.size.width, arrowImage.size.height)];
    arrowImageView.image = arrowImage;
    [self addSubview:arrowImageView];
    self.arrowImageView = arrowImageView;
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.frame = CGRectMake(35, 20, 20, 20);
    activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self addSubview:activityIndicatorView];
    self.activityIndicatorView = activityIndicatorView;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 7, kTitleWidth, kTitleHeight)];
    titleLabel.text = MURefreshLocalizedString(@"Pull to refresh", nil);
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 30, kTitleWidth, kTitleHeight)];
    timeLabel.text = [NSString stringWithFormat:MURefreshLocalizedString(@"Last Updated: %@", nil), @"--"];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textColor = [UIColor grayColor];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    timeLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:timeLabel];
    self.timeLabel = timeLabel;
}

- (void)updateArrowStyle
{
    switch(_state) {
        case ADPullToRefreshStateHidden: {
            self.activityIndicatorView.hidden = YES;
            [self.activityIndicatorView stopAnimating];
            self.arrowImageView.hidden = NO;
            
            self.lastUpdateTime = [NSDate date];
            self.timeLabel.text = [NSString stringWithFormat:MURefreshLocalizedString(@"Last Updated: %@", nil), [self.lastUpdateTime muptr_formatString]];
            self.arrowImageView.transform = CGAffineTransformMakeRotation(0);
        }
            break;
        case ADPullToRefreshStatePullingDown: {
            self.titleLabel.text = MURefreshLocalizedString(@"Pull to refresh", nil);
            [UIView animateWithDuration:0.2 animations:^{
                self.arrowImageView.transform = CGAffineTransformMakeRotation(0);
            }];
        }
            break;
        case ADPullToRefreshStateOveredThreshold: {
            self.titleLabel.text = MURefreshLocalizedString(@"Release to refresh", nil);
            [UIView animateWithDuration:0.2 animations:^{
                self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
            }];
        }
            break;
        default: {
            self.activityIndicatorView.hidden = NO;
            [self.activityIndicatorView startAnimating];
            self.titleLabel.text = MURefreshLocalizedString(@"Loading...", nil);
            self.arrowImageView.hidden = YES;
        }
            break;
    }
}


#pragma mark - override

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.frame = CGRectMake((self.frame.size.width - kTitleWidth) / 2.0, 7, kTitleWidth, kTitleHeight);
    self.timeLabel.frame = CGRectMake((self.frame.size.width - kTitleWidth) / 2.0, 30, kTitleWidth, kTitleHeight);
}

- (void)setState:(ADPullToRefreshState)state
{
    if (_state != state) {
        _state = state;
        [self updateArrowStyle];
    }
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
    }
    if ([newSuperview isKindOfClass:[UIScrollView class]]) {
        self.frame = CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height);
        [newSuperview addObserver:self forKeyPath:kContentOffsetKeyPath options:NSKeyValueObservingOptionNew context:NULL];
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
        
        [self scrollViewDidScroll:scrollView];
    }
}

- (BOOL)isRefreshing
{
    return (self.state == ADPullToRefreshStateRefreshing);
}


#pragma mark - Refresh

- (void)beginRefreshing
{
    [self beginRefreshingWithAnimated:YES];
}

- (void)beginRefreshingWithAnimated:(BOOL)animated
{
    self.state = ADPullToRefreshStateRefreshing;
    UIEdgeInsets newContentInset = self.scrollView.contentInset;
    newContentInset.top -= self.threshold;
    [UIView animateWithDuration:animated ? kAnimateWithDuration : 0 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.scrollView.contentInset = newContentInset;
        self.scrollView.contentOffset = CGPointMake(0, -newContentInset.top);
    } completion:^(BOOL finished) {
        if (self.actionHandler) {
            self.actionHandler(self.scrollView);
        }
    }];
}

- (void)endRefreshing
{
    UIEdgeInsets newContentInset = self.scrollView.contentInset;
    newContentInset.top = self.originalContentInset.top;
    if (self.scrollView.contentOffset.y < 0) {
        [UIView animateWithDuration:kAnimateWithDuration delay:0.0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.scrollView.contentInset = newContentInset;
        } completion:^(BOOL finished) {
        }];
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.originalContentInset.top) animated:YES];
    }
    else {
        self.scrollView.contentInset = newContentInset;
    }
    
    self.state = ADPullToRefreshStateHidden;
}


#pragma mark - UIScrollViewDelegate (Detected by observing value changes)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.state == ADPullToRefreshStateRefreshing) {
        return;
    }
    
    self.originalContentInset = scrollView.contentInset;
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat offsetThreshold = self.threshold - self.originalContentInset.top;
    
    if (offsetY < offsetThreshold) {
        self.state = ADPullToRefreshStateOveredThreshold;
    }
    else if (offsetY < -self.originalContentInset.top) {
        self.state = ADPullToRefreshStatePullingDown;
    }
    else {
        self.state = ADPullToRefreshStateHidden;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.state == ADPullToRefreshStateOveredThreshold) {
        [self beginRefreshing];
    }
}

@end

#define CURRENT_CALENDAR [NSCalendar currentCalendar]
#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)

@implementation NSDate (MUPullToRefresh)

- (NSString *)muptr_formatString
{
    NSDate *today = [NSDate date];
    NSDateComponents *dc1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    NSDateComponents *dc2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:today];
    // equal date
    if (dc1.year == dc2.year && dc1.month == dc2.month && dc1.day == dc2.day) {
        NSTimeInterval timeInterval = [today timeIntervalSinceDate:self];
        if (timeInterval > 0) {
            if (timeInterval < 60) {
                return MURefreshLocalizedString(@"Just now", nil);
            }
            if (timeInterval < 3600) {
                return [NSString stringWithFormat:MURefreshLocalizedString(@"%@ mins ago", nil), @((int)(timeInterval / 60))];
            }
        }

        NSString *s = [self muptr_stringWithFormat:@"HH:mm"];
        return s;
    }
    
    if (dc1.year == dc2.year) {
        return [self muptr_stringWithFormat:@"MM-dd"];
    }

    return [self muptr_stringWithFormat:@"yyyy-MM-dd"];
}

- (NSString *)muptr_stringWithFormat:(NSString *)format {
    NSDateFormatter *outputFormatter = [NSDate muptr_sharedDateFormatter];
    [outputFormatter setDateFormat:format];
    NSString *timestamp_str = [outputFormatter stringFromDate:self];
    return timestamp_str;
}

+ (NSDateFormatter *)muptr_sharedDateFormatter
{
    static NSDateFormatter *sharedDateFormatterInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDateFormatterInstance = [[NSDateFormatter alloc] init];
    });
    return sharedDateFormatterInstance;
}

@end