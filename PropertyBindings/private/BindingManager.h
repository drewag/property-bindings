//
//  BindingManager.h
//  PropertyBindings
//
//  Created by Andrew J Wagner on 5/2/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Binding;

@interface BindingManager : NSObject

+ (id)sharedInstance;

- (void)setBinding:(Binding *)binding;
- (void)removeAllBindingsAssociatedWithObject:(id)object;
- (void)removeBindingsAssociatedWithObjects:(id)object keyPath:(NSString *)keyPath;

@end
