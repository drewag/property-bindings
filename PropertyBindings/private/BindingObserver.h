//
//  Binding.h
//
//  Created by Andrew J Wagner on 2/10/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ObservedBindingReference;

extern const NSString *bindingReferencesKey;

@interface BindingObserver : NSObject

@property (nonatomic, assign, readonly) NSObject *observing;
@property (nonatomic, assign, readonly) NSString *observingKeyPath;
@property (nonatomic, assign, readonly) NSObject *observed;
@property (nonatomic, assign, readonly) NSString *observedKeyPath;
@property (nonatomic, assign) ObservedBindingReference *observedBindingReference;

+ (id)newWithObserving:(NSObject *)observing
               keyPath:(NSString *)observingKeyPath
              observed:(NSObject *)observed
               keyPath:(NSString *)observedKeyPath;

- (id)initWithObserving:(NSObject *)observing
                keyPath:(NSString *)observingKeyPath
               observed:(NSObject *)observed
                keyPath:(NSString *)observedKeyPath;

- (void)unbind;

@end
