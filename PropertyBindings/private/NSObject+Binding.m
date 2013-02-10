//
//  NSObject+Binding.m
//
//  Created by Andrew J Wagner on 2/10/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import "NSObject+Binding.h"
#import <objc/runtime.h>
#import "BindingObserver.h"


@interface NSObject (BindingPrivateMethods)

- (NSMutableDictionary *)bindingObservers;

@end


@implementation NSObject (Binding)

const NSString *bindingObserversKey = @"BindingObservers";

- (void)bindProperty:(NSString *)observingKeyPath
          toObserved:(NSObject *)observed
         withKeyPath:(NSString *)observedKeyPath
{
    [self unbindProperty:observingKeyPath];

    if (observed) {
        BindingObserver *bindingObserver = [BindingObserver
            newWithObserving:self
            keyPath:observingKeyPath
            observed:observed
            keyPath:observedKeyPath
        ];
        [[self bindingObservers] setObject:bindingObserver forKey:observingKeyPath];
        [bindingObserver release];
    }
}

- (void)unbindProperty:(NSString *)keyPath {
    NSMutableDictionary *bindingObservers = [self bindingObservers];

    [[bindingObservers objectForKey:keyPath] unbind];
    [bindingObservers removeObjectForKey:keyPath];
}

- (void)unbindAll {
    NSMutableDictionary *bindingObservers = [[self bindingObservers] copy];

    for( NSString *keyPath in bindingObservers) {
        [self unbindProperty:keyPath];
    }

    [bindingObservers release];
}

#pragma mark - Private Methods

- (NSMutableDictionary *)bindingObservers {
    NSMutableDictionary *bindingObservers = objc_getAssociatedObject(self, &bindingObserversKey);

    if (!bindingObservers) {
        bindingObservers = [NSMutableDictionary new];
        objc_setAssociatedObject(self, &bindingObserversKey, bindingObservers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [bindingObservers release];
    }

    return bindingObservers;
}

@end
