//
//  RemoveAllAssociatedBindingsClassAttacher.h
//  PropertyBindings
//
//  Created by Andrew J Wagner on 5/3/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RemoveAllAssociatedBindingsClassAttacher : NSObject

+ (void)attachRemoveAllAssociatedBindingsToDeallocOfObject:(id)object;

@end
