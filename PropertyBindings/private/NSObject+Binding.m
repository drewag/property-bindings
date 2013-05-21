//
//  NSObject+Binding.m
//
//  Created by Andrew J Wagner on 2/10/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import "NSObject+Binding.h"

#import "Binding.h"
#import "BindingPropertyLink.h"
#import "BindingBlock.h"
#import "BindingManager.h"

@implementation NSObject (Binding)

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

- (void)bindBlock:(void(^)(id newValue))block toProperty:(NSString *)property {
    if (property && block) {
        BindingBlock *binding = [[BindingBlock alloc]
            initWithObserved:self
            atKeyPath:property
            toBlock:block];
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
