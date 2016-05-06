//
//  NSBundle+MURefresh.m
//  MUPullToRefresh
//
//  Created by Muer on 16/5/5.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "NSBundle+MURefresh.h"
#import "MUPullToRefreshView.h"

@implementation NSBundle (MURefresh)

+ (NSBundle *)muRefreshBundle
{
    NSString *bundlePath = [[NSBundle bundleForClass:[MUPullToRefreshView class]] pathForResource:@"MUPullToRefresh" ofType:@"bundle"];
    return [NSBundle bundleWithPath:bundlePath];
}

@end
