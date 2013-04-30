//
//  NSObject+Binding.m
//
//  Created by Andrew J Wagner on 2/10/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import "NSObject+Binding.h"
#import <objc/runtime.h>
#import "BindingObserver.h"
#import "ObservedBindingReference.h"


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
    NSMutableDictionary *bindingObservers = objc_getAssociatedObject(self, &bindingObserversKey);

    for (NSString *keyPath in bindingObservers.allKeys) {
            [self unbindProperty:keyPath];
    }
}

#pragma mark - Dealloc decoration

+ (void)load {
    [self decorateDeallocWithUnbindAll];
}

+ (void)decorateDeallocWithUnbindAll {
    @autoreleasepool {
        Method dealloc = class_getInstanceMethod([NSObject class], @selector(dealloc));
        Method deallocWithUnbindAll = class_getInstanceMethod([NSObject class], @selector(deallocWithUnbindAll));

        method_exchangeImplementations(dealloc, deallocWithUnbindAll);
    }
}

- (void)deallocWithUnbindAll {
    [self unbindAll];
    [self removeAllBindingReferences];

    [self deallocWithUnbindAll];
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

- (void)removeAllBindingReferences {
    objc_setAssociatedObject(self, &bindingReferencesKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
