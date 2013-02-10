//
//  ObservedBindingReference.h
//

#import <Foundation/Foundation.h>

@class BindingObserver;


@interface ObservedBindingReference : NSObject

@property (assign, nonatomic) BindingObserver *bindingObserver;

+ (id)newWithBindingObserver:(BindingObserver *)bindingObserver;
- (id)initWithBindingObserver:(BindingObserver *)bindingObserver;

@end
