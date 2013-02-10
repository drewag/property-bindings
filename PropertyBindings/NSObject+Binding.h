//
//  NSObject+Binding.h
//
//  Created by Andrew J Wagner on 2/10/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (Binding)

- (void)bindProperty:(NSString *)observingKeyPath
          toObserved:(NSObject *)observed
         withKeyPath:(NSString *)observedKeyPath;

- (void)unbindProperty:(NSString *)keyPath;
- (void)unbindAll;

@end
