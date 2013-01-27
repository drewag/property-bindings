//
//  NSObject+Binding.h
//

#import <Foundation/Foundation.h>


@interface NSObject (Binding)

- (void)bindProperty:(NSString *)observingKeyPath
          toObserved:(NSObject *)observed
         withKeyPath:(NSString *)observedKeyPath;

- (void)unbindProperty:(NSString *)keyPath;
- (void)unbindAll;

@end
