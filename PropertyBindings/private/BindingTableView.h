//
//  BindingTableView.h
//  PropertyBindings
//
//  Created by Andrew J Wagner on 5/3/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import "Binding.h"
#import "UITableView+Binding.h"

#import <UIKit/UIKit.h>

@interface BindingTableView : Binding<UITableViewDataSource>

- (id)initWithObserved:(id)observed
             atKeyPath:(NSString *)keyPath
         withTableView:(UITableView *)tableView
     cellCreationBlock:(UITableViewCellCreationBlock)creationBlock
commitEditingStyleBlock:(UITableViewCommitEditingStyleBlock)editingBlock
            forSection:(NSInteger)section;

@end
