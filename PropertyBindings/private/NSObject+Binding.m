//
//  NSObject+Binding.m
//
//  Created by Andrew J Wagner on 2/10/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import "NSObject+Binding.h"

#import "Binding.h"
#import "BindingPropertyLink.h"
#import "BindingManager.h"

@interface NSObject (BindingPrivateMethods)

- (NSMutableDictionary *)bindingObservers;
- (void)removeAllBindingReferences;

@end


@implementation NSObject (Binding)

const NSString *bindingObserversKey = @"BindingObservers";

- (void)bindProperty:(NSString *)observingKeyPath
          toObserved:(NSObject *)observed
         withKeyPath:(NSString *)observedKeyPath
{
    if (observed && observedKeyPath) {
        BindingPropertyLink *binding = [[BindingPropertyLink alloc]
            initWithObserved:observed
            atKeyPath:observedKeyPath
            toDestination:self
            atKeyPath:observingKeyPath];
        [[BindingManager sharedInstance] setBinding:binding];
        [binding release];
    }
}

- (void)unbindProperty:(NSString *)keyPath {
    [[BindingManager sharedInstance] removeBindingsAssociatedWithObjects:self keyPath:keyPath];
}

- (void)unbindAll {
    [[BindingManager sharedInstance] removeAllBindingsAssociatedWithObject:self];
}

@end
