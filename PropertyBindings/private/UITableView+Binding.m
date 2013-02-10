//
//  UITableView+Binding.m
//  bindings
//
//  Created by Andrew J Wagner on 2/6/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import "BindingToManyObserver.h"
#import <objc/runtime.h>
#import "NSObject+Binding.h"

@interface UITableView (TableviewBindingPrivateMethods)

- (NSMutableDictionary *)bindingObservers;

@end

@implementation UITableView (Binding)

NSString *tableViewBindingObserverProperty = @"TableViewBindingObserver";

- (void)bindToObserved:(NSObject *)observed
      withArrayKeyPath:(NSString *)observedKeyPath
     cellCreationBlock:(UITableViewCellCreationBlock)creationBlock
{
    [self unbind];

    if (observed) {
        BindingToManyObserver *bindingObserver = [BindingToManyObserver
            newWithTableView:self
            keyPath:tableViewBindingObserverProperty
            observed:observed
            arrayKeyPath:observedKeyPath
            cellCreationBlock:creationBlock];
        [[self bindingObservers] setObject:bindingObserver forKey:tableViewBindingObserverProperty];
        [bindingObserver release];
    }
}

- (void)unbind {
    [self unbindProperty:tableViewBindingObserverProperty];
}

@end
