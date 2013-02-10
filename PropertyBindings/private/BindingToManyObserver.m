//
//  BindingArrayObserver.m
//  bindings
//
//  Created by Andrew J Wagner on 2/7/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import "BindingToManyObserver.h"

@interface BindingToManyObserver ()

- (UITableView *)tableView;
- (NSArray *)sourceArray;

@property (nonatomic, copy) UITableViewCellCreationBlock cellCreationBlock;

@end

@implementation BindingToManyObserver

+ (id)newWithTableView:(UITableView *)tableView
               keyPath:(NSString *)observingKeyPath
              observed:(NSObject *)observed
          arrayKeyPath:(NSString *)observedKeyPath
     cellCreationBlock:(UITableViewCellCreationBlock)creationBlock
{
    return [[self alloc]
        initWithTableView:tableView
        keyPath:observingKeyPath
        observed:observed
        arrayKeyPath:observedKeyPath
        cellCreationBlock:creationBlock];
}

- (id)initWithTableView:(UITableView *)tableView
                keyPath:(NSString *)observingKeyPath
               observed:(NSObject *)observed
           arrayKeyPath:(NSString *)observedKeyPath
     cellCreationBlock:(UITableViewCellCreationBlock)creationBlock
{
   self = [super
        initWithObserving:tableView
        keyPath:observingKeyPath
        observed:observed
        keyPath:observedKeyPath];
    if (self) {
        tableView.dataSource = self;
        self.cellCreationBlock = creationBlock;
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSNumber *kind = [change objectForKey:NSKeyValueChangeKindKey];
    if ([kind integerValue] == NSKeyValueChangeSetting) {
        [self.tableView reloadData];
    }
    else {
        NSIndexSet *indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
        NSMutableArray *indexArray = [NSMutableArray array];
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            [indexArray addObject:indexPath];
        }];
        [self.tableView beginUpdates];
        switch([kind integerValue]) {
            case NSKeyValueChangeInsertion:
                [self.tableView
                    insertRowsAtIndexPaths:indexArray
                    withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSKeyValueChangeRemoval:
                [self.tableView
                    deleteRowsAtIndexPaths:indexArray
                    withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSKeyValueChangeReplacement:
                [self.tableView
                    reloadRowsAtIndexPaths:indexArray
                    withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
        }
        [self.tableView endUpdates];
    }
}

- (void)unbind {
    self.tableView.dataSource = nil;
    [super unbind];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self sourceArray].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellCreationBlock([self sourceArray][indexPath.row]);
}

#pragma mark - Private Methods

- (UITableView *)tableView {
    return (UITableView *)self.observing;
}

- (NSArray *)sourceArray {
    return (NSArray *)[self.observed valueForKey:self.observedKeyPath];
}

@end
