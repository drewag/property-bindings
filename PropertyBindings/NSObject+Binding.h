//
//  NSObject+Binding.h
//
//  Created by Andrew J Wagner on 2/10/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPropertyBindingsMismatchedTypeException @"Mismatched Type"

@interface NSObject (Binding)

- (void)bindProperty:(NSString *)observingKeyPath
          toObserved:(NSObject *)observed
         withKeyPath:(NSString *)observedKeyPath;

- (void)bindArrayProperty:(NSString *)observingKeyPath
               toObserved:(NSObject *)observed
              withKeyPath:(NSString *)observedKeyPath;

- (void)unbindProperty:(NSString *)keyPath;
- (void)unbindAll;

- (void)bindBlock:(void(^)(id newValue))block toProperty:(NSString *)property;

@end
