//
//  Binding.m
//
//  Created by Andrew J Wagner on 2/10/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import "BindingObserver.h"
#import "NSObject+Binding.h"
#import <objc/runtime.h>
#import "ObservedBindingReference.h"


@interface BindingObserver ()

@property (nonatomic, assign, readwrite) NSObject *observing;
@property (nonatomic, assign, readwrite) NSString *observingKeyPath;
@property (nonatomic, assign, readwrite) NSObject *observed;
@property (nonatomic, assign, readwrite) NSString *observedKeyPath;

- (void)startObserving;
- (void)stopObserving;
- (void)addReferenceToObserved;
- (void)removeReferenceFromObserved;

@end


@implementation BindingObserver

const NSString *bindingReferencesKey = @"BindingReferences";

+ (id)newWithObserving:(NSObject *)observing
               keyPath:(NSString *)observingKeyPath
              observed:(NSObject *)observed
               keyPath:(NSString *)observedKeyPath;
{
    return [[self alloc]
        initWithObserving:observing
        keyPath:observingKeyPath
        observed:observed
        keyPath:observedKeyPath];
}

- (id)initWithObserving:(NSObject *)observing
                keyPath:(NSString *)observingKeyPath
               observed:(NSObject *)observed
                keyPath:(NSString *)observedKeyPath;
{
    self = [super init];
    if (self) {
        self.observing = observing;
        self.observingKeyPath = observingKeyPath;
        self.observed = observed;
        self.observedKeyPath = observedKeyPath;

        [self startObserving];
        [self addReferenceToObserved];
    }
    return self;
}

- (id)autorelease {
    [NSException
        raise:@"Forbidden Function"
        format:@"Do not autorelease bindings as the timing of their deallocation and the other associated objects is crucial."];
    return self;
}

- (void)dealloc {
    [self unbind];
    [_observed release];

    [super dealloc];
}

- (void)unbind {
    [self stopObserving];
    [self removeReferenceFromObserved];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
    if (newValue == [NSNull null]) {
        newValue = nil;
    }
    [self.observing setValue:newValue forKey:self.observingKeyPath];
}

#pragma mark - Private Methods

- (void)startObserving {
    [self.observed
        addObserver:self
        forKeyPath:self.observedKeyPath
        options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial
        context:nil];
}

- (void)stopObserving {
    [self.observed removeObserver:self forKeyPath:self.observedKeyPath];
    self.observed = nil;
}

- (void)addReferenceToObserved {
    NSMutableArray *bindingReferences = objc_getAssociatedObject(self.observed, &bindingReferencesKey);
    if (!bindingReferences) {
        bindingReferences = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self.observed, &bindingReferencesKey, bindingReferences, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [bindingReferences release];
    }

    ObservedBindingReference *observedBindingReference = [ObservedBindingReference newWithBindingObserver:self];
    self.observedBindingReference = observedBindingReference;
    [bindingReferences addObject:observedBindingReference];

    [observedBindingReference release];
}

- (void)removeReferenceFromObserved {
    self.observedBindingReference.bindingObserver = nil;
    self.observedBindingReference = nil;
}

@end
