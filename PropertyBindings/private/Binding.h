//
//  Binding.h
//  PropertyBindings
//
//  Created by Andrew J Wagner on 5/2/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Binding : NSObject

@property (nonatomic, assign, readonly) id observedObject;
@property (nonatomic, assign, readonly) NSString *observedKeyPath;

- (id)initWithObserved:(id)observed atKeyPath:(NSString *)keyPath;

- (void)activateWithChange:(NSDictionary *)change;
- (BOOL)shouldRemoveExistingBinding:(Binding *)binding;
- (BOOL)isAssociatedWithObjects:(id)object keyPath:(NSString *)keyPath;

- (void)confirmBinding;
- (void)didUnbind;

@end
