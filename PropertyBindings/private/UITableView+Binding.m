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
        commitEditingStyleBlock:nil
    ];
}

- (void)bindToObserved:(NSObject *)observed
      withArrayKeyPath:(NSString *)observedKeyPath
     cellCreationBlock:(UITableViewCellCreationBlock)creationBlock
            forSection:(NSInteger)section
{
    return [self
        bindToObserved:observed
        withArrayKeyPath:observedKeyPath
        cellCreationBlock:creationBlock
        commitEditingStyleBlock:nil
        forSection:section
    ];
}

- (void)bindToObserved:(NSObject *)observed
      withArrayKeyPath:(NSString *)observedKeyPath
     cellCreationBlock:(UITableViewCellCreationBlock)creationBlock
commitEditingStyleBlock:(UITableViewCommitEditingStyleBlock)editingBlock
{
    return [self
        bindToObserved:observed
        withArrayKeyPath:observedKeyPath
        cellCreationBlock:creationBlock
        commitEditingStyleBlock:editingBlock
        forSection:0
    ];
}

- (void)bindToObserved:(NSObject *)observed
      withArrayKeyPath:(NSString *)observedKeyPath
     cellCreationBlock:(UITableViewCellCreationBlock)creationBlock
commitEditingStyleBlock:(UITableViewCommitEditingStyleBlock)editingBlock
             forSection:(NSInteger)section
{
    if (observed && observedKeyPath) {
        BindingTableView *binding = [[BindingTableView alloc]
            initWithObserved:observed
            atKeyPath:observedKeyPath
            withTableView:self
            cellCreationBlock:creationBlock
            commitEditingStyleBlock:editingBlock
            forSection:section];
        [[BindingManager sharedInstance] setBinding:binding];
        [binding release];
    }
 }

- (void)unbind {
    [self unbindProperty:tableViewBindingObserverProperty];
}

@end
