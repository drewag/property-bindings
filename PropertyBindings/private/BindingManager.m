//
//  BindingManager.m
//  PropertyBindings
//
//  Created by Andrew J Wagner on 5/2/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import "BindingManager.h"

#import "Binding.h"

@interface BindingManager ()

@property (nonatomic, strong) NSMutableArray *bindings;

@end

@implementation BindingManager

+ (id)sharedInstance {
    static BindingManager *singleton = nil;

    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        singleton = [BindingManager new];
    });

    return singleton;
}

- (id)init {
    self = [super init];
    if (self) {
        self.bindings = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    [_bindings release];

    [super dealloc];
}

- (void)setBinding:(Binding *)binding {
    NSUInteger index = [self.bindings indexOfObjectPassingTest:^BOOL(Binding* existingBinding, NSUInteger idx, BOOL *stop) {
        BOOL shouldRemove = [binding shouldRemoveExistingBinding:existingBinding];
        if (shouldRemove) {
            [existingBinding.observedObject
                removeObserver:self
                forKeyPath:existingBinding.observedKeyPath
                context:existingBinding];
            [existingBinding didUnbind];
        }
        return shouldRemove;
    }];
    @synchronized(self.bindings) {
        if (index != NSNotFound) {
            [self.bindings removeObjectAtIndex:index];
        }
        [self.bindings addObject:binding];
    }

    [binding.observedObject
        addObserver:self
        forKeyPath:binding.observedKeyPath
        options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial
        context:binding];

    [binding confirmBinding];
}

- (void)removeAllBindings {
    @synchronized(self.bindings) {
        for (Binding *binding in self.bindings) {
            [binding.observedObject
                removeObserver:self
                 forKeyPath:binding.observedKeyPath
                 context:binding];
            [binding didUnbind];
        }
        [self.bindings removeAllObjects];
    }
}

- (void)removeAllBindingsAssociatedWithObject:(id)object {
    [self removeBindingsAssociatedWithObjects:object keyPath:nil];
}

- (void)removeBindingsAssociatedWithObjects:(id)object keyPath:(NSString *)keyPath {
    @synchronized(self.bindings) {
        NSIndexSet *toBeRemoved = [self.bindings indexesOfObjectsPassingTest:^BOOL(Binding *binding, NSUInteger idx, BOOL *stop) {
            BOOL isAssociated = [binding isAssociatedWithObjects:object keyPath:keyPath];
            if (isAssociated)  {
                @try {
                    [binding.observedObject
                        removeObserver:self
                        forKeyPath:binding.observedKeyPath
                        context:binding];
                }
                @catch (NSException *exception) {
                    NSLog(@"Failed to Remove Observer: %@", exception);
                }
                [binding didUnbind];
            }
            return isAssociated;
        }];

        [self.bindings removeObjectsAtIndexes:toBeRemoved];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    Binding *binding = (Binding *)context;
    [binding activateWithChange:change];
}

@end
