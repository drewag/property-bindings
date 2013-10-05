//
//  UITableView+Binding.h
//  bindings
//
//  Created by Andrew J Wagner on 2/6/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (Binding)

typedef UITableViewCell *(^UITableViewCellCreationBlock)(id object);
typedef void(^UITableViewCommitEditingStyleBlock)(UITableViewCellEditingStyle style, NSIndexPath *indexPath);
- (void)bindToObserved:(NSObject *)observed
      withArrayKeyPath:(NSString *)observedKeyPath
     cellCreationBlock:(UITableViewCellCreationBlock)creationBlock;

- (void)bindToObserved:(NSObject *)observed
      withArrayKeyPath:(NSString *)observedKeyPath
     cellCreationBlock:(UITableViewCellCreationBlock)creationBlock
            forSection:(NSInteger)section;

- (void)bindToObserved:(NSObject *)observed
      withArrayKeyPath:(NSString *)observedKeyPath
     cellCreationBlock:(UITableViewCellCreationBlock)creationBlock
commitEditingStyleBlock:(UITableViewCommitEditingStyleBlock)editingBlock;

- (void)bindToObserved:(NSObject *)observed
      withArrayKeyPath:(NSString *)observedKeyPath
     cellCreationBlock:(UITableViewCellCreationBlock)creationBlock
commitEditingStyleBlock:(UITableViewCommitEditingStyleBlock)editingBlock
             forSection:(NSInteger)section;

- (void)unbind;

@end
