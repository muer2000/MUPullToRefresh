//
//  NSBundle+MURefresh.h
//  MUPullToRefresh
//
//  Created by Muer on 16/5/5.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MURefreshLocalizedString(key, comment) \
        NSLocalizedStringFromTableInBundle((key), @"MUPullToRefresh", [NSBundle muRefreshBundle], (comment))

@interface NSBundle (MURefresh)

+ (NSBundle *)muRefreshBundle;

@end
