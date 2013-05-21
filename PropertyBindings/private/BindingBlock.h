//
//  BindingBlock.h
//  PropertyBindings
//
//  Created by Andrew Wagner on 5/21/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import "Binding.h"

@interface BindingBlock : Binding

- (id)initWithObserved:(id)observed atKeyPath:(NSString *)keyPath toBlock:(void(^)(id newValue))block;

@end
