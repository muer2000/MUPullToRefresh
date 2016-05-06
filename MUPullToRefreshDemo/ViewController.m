//
//  ViewController.m
//  MUPullToRefreshDemo
//
//  Created by Muer on 16/5/4.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+MURefresh.h"

static NSString * const kBasicCellIdentifier = @"BasicCellIdentifier";

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    __weak typeof(self) wSelf = self;
    [self.tableView mu_addPullToRefreshWithActionHandler:^(UIScrollView *sender) {
        [wSelf fetchItemsWithContinuous:NO completionHandler:^(BOOL success, NSUInteger count) {
            if (success) {
                [(UITableView *)sender reloadData];
            }
            [sender mu_endRefreshing];
        }];
    }];

    [self.tableView mu_addInfiniteScrollingWithActionHandler:^(UIScrollView *sender) {
        [wSelf fetchItemsWithContinuous:YES completionHandler:^(BOOL success, NSUInteger count) {
            if (success) {
                [(UITableView *)sender reloadData];
                [sender mu_endLoadingWithNoMoreData:count == 0];
            }
            else {
                [sender mu_endLoading];
            }
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)items {
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}

- (void)fetchItemsWithContinuous:(BOOL)continuous completionHandler:(void (^)(BOOL success, NSUInteger count))completionHandler {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!continuous) {
            [self.items removeAllObjects];
        }
        NSInteger oldCount = self.items.count;
        NSInteger newCount = oldCount > 100 ? 0 : 20;
        for (int i = 0; i < newCount; i++) {
            [self.items addObject:@(i + 1 + oldCount)];
        }
        if (completionHandler) {
            completionHandler(YES, newCount);
        }
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBasicCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self.items[indexPath.row] stringValue];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"contentInset.Top:%f contentOffset.Y:%f", tableView.contentInset.top, tableView.contentOffset.y);
}
@end
