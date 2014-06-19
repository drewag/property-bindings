//
//  UITableView+Binding.m
//  bindings
//
//  Created by Andrew J Wagner on 2/6/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import "UITableView+Binding.h"
#import "NSObject+Binding.h"

#import "BindingTableView.h"
#import "BindingManager.h"

#import "SplitTableViewDataSource.h"

@implementation UITableView (Binding)

NSString *tableViewBindingObserverProperty = @"TableViewBindingObserver";

- (void)bindToObserved:(NSObject *)observed
      withArrayKeyPath:(NSString *)observedKeyPath
     cellCreationBlock:(UITableViewCellCreationBlock)creationBlock
 {
    return [self
        bindToObserved:observed
        withArrayKeyPath:observedKeyPath
        cellCreationBlock:creationBlock
        topCellCreationBlock:nil
    ];
 }

- (void)bindToObserved:(NSObject *)observed
      withArrayKeyPath:(NSString *)observedKeyPath
     cellCreationBlock:(UITableViewCellCreationBlock)creationBlock
  topCellCreationBlock:(UITableViewTopCellCreationBlock)topCreationBlock
{
    return [self
        bindToObserved:observed
        withArrayKeyPath:observedKeyPath
        cellCreationBlock:creationBlock
        topCellCreationBlock:topCreationBlock
        commitEditingStyleBlock:nil
    ];
}

- (void)bindToObserved:(NSObject *)observed
      withArrayKeyPath:(NSString *)observedKeyPath
     cellCreationBlock:(UITableViewCellCreationBlock)creationBlock
  topCellCreationBlock:(UITableViewTopCellCreationBlock)topCreationBlock
            forSection:(NSInteger)section
      withSectionTitle:(NSString *)sectionTitle
{
    return [self
        bindToObserved:observed
        withArrayKeyPath:observedKeyPath
        cellCreationBlock:creationBlock
        topCellCreationBlock:topCreationBlock
        commitEditingStyleBlock:nil
        forSection:section
        withSectionTitle:sectionTitle
    ];
}

- (void)bindToObserved:(NSObject *)observed
      withArrayKeyPath:(NSString *)observedKeyPath
     cellCreationBlock:(UITableViewCellCreationBlock)creationBlock
  topCellCreationBlock:(UITableViewTopCellCreationBlock)topCreationBlock
commitEditingStyleBlock:(UITableViewCommitEditingStyleBlock)editingBlock
{
    return [self
        bindToObserved:observed
        withArrayKeyPath:observedKeyPath
        cellCreationBlock:creationBlock
        topCellCreationBlock:topCreationBlock
        commitEditingStyleBlock:editingBlock
        forSection:0
        withSectionTitle:nil
    ];
}

- (void)bindToObserved:(NSObject *)observed
      withArrayKeyPath:(NSString *)observedKeyPath
     cellCreationBlock:(UITableViewCellCreationBlock)creationBlock
  topCellCreationBlock:(UITableViewTopCellCreationBlock)topCreationBlock
commitEditingStyleBlock:(UITableViewCommitEditingStyleBlock)editingBlock
            forSection:(NSInteger)section
      withSectionTitle:(NSString *)sectionTitle
{
    if (observed && observedKeyPath) {
        BindingTableView *binding = [[BindingTableView alloc]
            initWithObserved:observed
            atKeyPath:observedKeyPath
            withTableView:self
            cellCreationBlock:creationBlock
            topCellCreationBlock:topCreationBlock
            commitEditingStyleBlock:editingBlock
            forSection:section
            withSectionTitle:sectionTitle
        ];
        [[BindingManager sharedInstance] setBinding:binding];
        [binding release];
    }
 }

- (void)unbindSection:(NSUInteger)section animated:(BOOL)animated
{
    if (self.dataSource && [self.dataSource isKindOfClass:[SplitTableViewDataSource class]]) {
        BOOL deleted = [(SplitTableViewDataSource *)self.dataSource clearDelegateForSection:section];
        if (deleted) {
            [self deleteSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)unbind {
    [self unbindProperty:tableViewBindingObserverProperty];
}

@end
