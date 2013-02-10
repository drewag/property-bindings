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
- (void)bindToObserved:(NSObject *)observed
      withArrayKeyPath:(NSString *)observedKeyPath
     cellCreationBlock:(UITableViewCellCreationBlock)creationBlock;

- (void)unbind;

@end
