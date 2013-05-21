//
//  BindingBlock.m
//  PropertyBindings
//
//  Created by Andrew Wagner on 5/21/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import "BindingBlock.h"

@interface BindingBlock ()

@property (nonatomic, copy) void(^block)(id newValue);

@end

@implementation BindingBlock

- (id)initWithObserved:(id)observed atKeyPath:(NSString *)keyPath toBlock:(void(^)(id newValue))block {
    if (!block) { return nil; }

    self = [super initWithObserved:observed atKeyPath:keyPath];
    if (self) {
        self.block = block;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"BLOCK -> %@.%@", self.observedObject, self.observedKeyPath];
}

- (void)activateWithChange:(NSDictionary *)change {
    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
    if (newValue == [NSNull null]) {
        newValue = nil;
    }

    self.block(newValue);
}

- (BOOL)shouldRemoveExistingBinding:(Binding *)binding {
    return NO;
}

@end
