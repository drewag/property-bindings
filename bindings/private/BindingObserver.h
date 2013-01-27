//
//  Binding.h
//

#import <Foundation/Foundation.h>

@class ObservedBindingReference;

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
