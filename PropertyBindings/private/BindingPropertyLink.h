//
//  BindingPropertyLink.h
//  PropertyBindings
//
//  Created by Andrew J Wagner on 5/2/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import "Binding.h"

@interface BindingPropertyLink : Binding

@property (nonatomic, assign, readonly) id destinationObject;
@property (nonatomic, assign, readonly) NSString *destinationKeyPath;

- (id)initWithObserved:(id)observed
             atKeyPath:(NSString *)observedKeyPath
         toDestination:(id)destionation
             atKeyPath:(NSString *)destinationKeyPath;

@end
