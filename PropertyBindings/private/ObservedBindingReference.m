//
//  ObservedBindingReference.m
//
//  Created by Andrew J Wagner on 2/10/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import "ObservedBindingReference.h"
#import "BindingObserver.h"
#import "NSObject+Binding.h"

@interface ObservedBindingReference ()

- (void)unbindPropertyFromObserving;

@end


@implementation ObservedBindingReference

+ (id)newWithBindingObserver:(BindingObserver *)bindingObserver {
    return [[self alloc] initWithBindingObserver:bindingObserver];
}

- (id)initWithBindingObserver:(BindingObserver *)bindingObserver {
    self = [super init];
    if (self) {
        self.bindingObserver = bindingObserver;
    }
    return self;
}

- (id)autorelease {
    [NSException
        raise:@"Forbidden Function"
        format:@"Do not autorelease binding connections as the timing of their deallocation and the other associated objects is crucial."];
    return self;
}

- (void)dealloc {
    [self unbindPropertyFromObserving];

    [super dealloc];
}

#pragma mark - Private Methods

- (void)unbindPropertyFromObserving {
    self.bindingObserver.observedBindingReference = nil;
    [self.bindingObserver.observing unbindProperty:self.bindingObserver.observingKeyPath];
}

@end
