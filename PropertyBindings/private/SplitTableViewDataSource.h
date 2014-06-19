//
//  SplitTableViewDataSource.h
//  PropertyBindings
//
//  Created by Andrew J Wagner on 10/4/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplitTableViewDataSource : NSObject<UITableViewDataSource>

- (id<UITableViewDataSource>)delegateForSection:(NSInteger)section;

- (void)setDelegate:(id<UITableViewDataSource>)delegate forSection:(NSUInteger)section;
- (void)clearDelegate:(id<UITableViewDataSource>)delegate forSection:(NSUInteger)section;
- (BOOL)clearDelegateForSection:(NSUInteger)section;

@end
