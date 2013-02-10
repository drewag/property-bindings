//
//  BindingArrayObserver.h
//  bindings
//
//  Created by Andrew J Wagner on 2/7/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import "BindingObserver.h"
#import <UIKit/UIKit.h>
#import "UITableView+Binding.h"

@interface BindingArrayObserver : BindingObserver<UITableViewDataSource>

+ (id)newWithTableView:(UITableView *)tableView
               keyPath:(NSString *)observingKeyPath
              observed:(NSObject *)observed
          arrayKeyPath:(NSString *)observedKeyPath
     cellCreationBlock:(UITableViewCellCreationBlock)creationBlock;

- (id)initWithTableView:(UITableView *)tableView
               keyPath:(NSString *)observingKeyPath
              observed:(NSObject *)observed
          arrayKeyPath:(NSString *)observedKeyPath
     cellCreationBlock:(UITableViewCellCreationBlock)creationBlock;

@end
