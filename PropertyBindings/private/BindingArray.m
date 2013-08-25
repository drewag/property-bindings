//
//  BindingArray.m
//  PropertyBindings
//
//  Created by Andrew J Wagner on 8/25/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import "BindingArray.h"

@implementation BindingArray

- (void)activateWithChange:(NSDictionary *)change {
    NSNumber *kind = [change objectForKey:NSKeyValueChangeKindKey];
    if ([kind integerValue] == NSKeyValueChangeSetting) {
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        [self.destinationObject setValue:newValue forKey:self.destinationKeyPath];
    }
    else {
        id newValue = [self.observedObject valueForKey:self.observedKeyPath];
        [self.destinationObject setValue:newValue forKey:self.destinationKeyPath];
    }
}

@end
