//
//  ObservedBindingReference.h
//
//  Created by Andrew J Wagner on 2/10/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BindingObserver;


@interface ObservedBindingReference : NSObject

@property (assign, nonatomic) BindingObserver *bindingObserver;

+ (id)newWithBindingObserver:(BindingObserver *)bindingObserver;
- (id)initWithBindingObserver:(BindingObserver *)bindingObserver;

@end
