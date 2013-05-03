//
//  Binding.m
//  PropertyBindings
//
//  Created by Andrew J Wagner on 5/2/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import "Binding.h"

#import "RemoveAllAssociatedBindingsClassAttacher.h"

@interface Binding ()

@property (nonatomic, assign, readwrite) id observedObject;
@property (nonatomic, assign, readwrite) NSString *observedKeyPath;

@end

@implementation Binding

- (id)initWithObserved:(id)observed atKeyPath:(NSString *)keyPath {
    self = [super init];
    if (self) {
        self.observedObject = observed;
        self.observedKeyPath = keyPath;
    }
    return self;
}

- (BOOL)isAssociatedWithObjects:(id)object keyPath:(NSString *)keyPath {
    if (!keyPath) {
        return self.observedObject == object;
    }

    return self.observedObject == object && [self.observedKeyPath isEqualToString:keyPath];
}

- (void)didUnbind {
}

- (void)confirmBinding {
    [RemoveAllAssociatedBindingsClassAttacher
        attachRemoveAllAssociatedBindingsToDeallocOfObject:self.observedObject];
}

- (void)activateWithChange:(NSDictionary *)change {
    @throw [NSException
        exceptionWithName:@"Unimplimented Method"
        reason:@"You must use a subclass that overrides thie method"
        userInfo:nil];
}

- (BOOL)shouldRemoveExistingBinding:(Binding *)binding {
    @throw [NSException
        exceptionWithName:@"Unimplimented Method"
        reason:@"You must use a subclass that overrides thie method"
        userInfo:nil];
}

@end
