//
//  BindingPropertyLink.m
//  PropertyBindings
//
//  Created by Andrew J Wagner on 5/2/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import "BindingPropertyLink.h"

#import "RemoveAllAssociatedBindingsClassAttacher.h"

@interface BindingPropertyLink ()

@property (nonatomic, assign, readwrite) id destinationObject;
@property (nonatomic, assign, readwrite) NSString *destinationKeyPath;

@end

@implementation BindingPropertyLink

- (id)initWithObserved:(id)observed
             atKeyPath:(NSString *)observedKeyPath
         toDestination:(id)destionation
             atKeyPath:(NSString *)destinationKeyPath
{
    self = [super initWithObserved:observed atKeyPath:observedKeyPath];
    if (self) {
        self.destinationObject = destionation;
        self.destinationKeyPath = destinationKeyPath;
    }
    return self;
}

- (void)confirmBinding {
    [super confirmBinding];

    [RemoveAllAssociatedBindingsClassAttacher
        attachRemoveAllAssociatedBindingsToDeallocOfObject:self.destinationObject];
}

- (BOOL)isAssociatedWithObjects:(id)object keyPath:(NSString *)keyPath {
    if ([super isAssociatedWithObjects:object keyPath:keyPath]) {
        return YES;
    }

    if (!keyPath) {
        return self.destinationObject == object;
    }

    return self.destinationObject == object && [self.destinationKeyPath isEqualToString:keyPath];
}

- (void)activateWithChange:(NSDictionary *)change {
    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
    if (newValue == [NSNull null]) {
        newValue = nil;
    }
    [self.destinationObject setValue:newValue forKey:self.destinationKeyPath];
}

- (BOOL)shouldRemoveExistingBinding:(BindingPropertyLink *)binding {
    if (![[binding class] isSubclassOfClass:[BindingPropertyLink class]]) {
        return NO;
    }

    return binding.destinationObject == self.destinationObject
        && [binding.destinationKeyPath isEqualToString:self.destinationKeyPath];
}

@end
