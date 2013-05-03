//
//  RemoveAllAssociatedBindingsClassAttacher.m
//  PropertyBindings
//
//  Created by Andrew J Wagner on 5/3/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import "RemoveAllAssociatedBindingsClassAttacher.h"

#import <objc/runtime.h>
#import <pthread.h>

#import "BindingManager.h"

@interface RemoveAllAssociatedBindingsClassAttacher ()

+ (void)patchKVOObjectClass:(Class)objectClass;
+ (void)createSubclassForObject:(id)object;
+ (BOOL)classAlreadyModified:(Class)class;

- (BOOL)willRemoveAssociatedBindings;
- (void)deallocWithRemoveAllAssociatedBindings;

@end

@implementation RemoveAllAssociatedBindingsClassAttacher

static NSArray *ClassMethodNames(Class c) {
    NSMutableArray *array = [NSMutableArray array];
    
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList(c, &methodCount);
    unsigned int i;
    for(i = 0; i < methodCount; i++)
        [array addObject: NSStringFromSelector(method_getName(methodList[i]))];
    free(methodList);
    
    return array;
}

static void PrintDescription(NSString *name, id obj) {
    NSString *str = [NSString stringWithFormat:
        @"%@: %@\n\tNSObject class %s\n\tlibobjc class %s\n\tNSObject superclass: %@\n\tlibobjc superclass: %@\n\timplements methods <%@>",
        name,
        obj,
        class_getName([obj class]),
        class_getName(object_getClass(obj)),
        class_getSuperclass([obj class]),
        class_getSuperclass(object_getClass(obj)),
        [ClassMethodNames(object_getClass(obj)) componentsJoinedByString:@", "]];
    printf("%s\n", [str UTF8String]);
}

+ (void)attachRemoveAllAssociatedBindingsToDeallocOfObject:(id)object {
    Class objectClass = object_getClass(object);

    if ([self classAlreadyModified:objectClass]) {
        return;
    }

    if (objectClass != [object class]) {
        [self patchKVOObjectClass:objectClass];
    }
    else {
        [self createSubclassForObject:object];
    }
}

- (BOOL)willRemoveAssociatedBindings {
    return YES;
}

#pragma mark - Locking

static pthread_mutex_t gMutex;

static void WhileLocked(void (^block)(void)) {
    pthread_mutex_lock(&gMutex);
    block();
    pthread_mutex_unlock(&gMutex);
}

#pragma mark - Swizzle Methods

- (void)deallocWithRemoveAllAssociatedBindings {
    [[BindingManager sharedInstance] removeAllBindingsAssociatedWithObject:self];

    [super dealloc];
}

static void KVOSubclassRelease(id self, SEL _cmd) {
    IMP originalRelease = class_getMethodImplementation(object_getClass(self), @selector(PropertyBindings_KVO_original_release));
    WhileLocked(^{
        ((void (*)(id, SEL))originalRelease)(self, _cmd);
    });
}

static void KVOSubclassDealloc(id self, SEL _cmd) {
//    PrintDescription(@"In Dealloc", self);
    [[BindingManager sharedInstance] removeAllBindingsAssociatedWithObject:self];
    
    Class class = object_getClass(self);
    if ([RemoveAllAssociatedBindingsClassAttacher classAlreadyModified:class]) {
        IMP originalDealloc = class_getMethodImplementation(class, @selector(PropertyBindings_KVO_original_dealloc));
        ((void (*)(id, SEL))originalDealloc)(self, _cmd);
    }
    else {
        // The object has been returned to the original object so it is dealloc will
        // be back to the original implementation instead of this one
        [self dealloc];
    }
}

static void KVOSubclassRemoveObserverForKeyPath(id self, SEL _cmd, id observer, NSString *keyPath) {
    WhileLocked(^{
        IMP originalIMP = class_getMethodImplementation(object_getClass(self), @selector(PropertyBindings_KVO_original_removeObserver:forKeyPath:));
        ((void (*)(id, SEL, id, NSString *))originalIMP)(self, _cmd, observer, keyPath);
    });
}

static void KVOSubclassRemoveObserverForKeyPathContext(id self, SEL _cmd, id observer, NSString *keyPath, void *context) {
    WhileLocked(^{
        IMP originalIMP = class_getMethodImplementation(object_getClass(self), @selector(PropertyBindings_KVO_original_removeObserver:forKeyPath:context:));
        ((void (*)(id, SEL, id, NSString *, void *))originalIMP)(self, _cmd, observer, keyPath, context);
    });
}

#pragma mark - Private Methods

+ (BOOL)classAlreadyModified:(Class)class {
    return class_getInstanceMethod(class, @selector(__willRemoveAssociatedBindings));
}

+ (void)addRemoveMethodToClass:(Class)class {
    Method willRemoveMethod = class_getInstanceMethod([self class], @selector(willRemoveAssociatedBindings));
    class_addMethod(
        class,
        @selector(__willRemoveAssociatedBindings),
        method_getImplementation(willRemoveMethod),
        method_getTypeEncoding(willRemoveMethod)
    );
}

+ (void)patchKVOObjectClass:(Class)objectClass {
//    PrintDescription(@"Before", object);

    Method removeObserverForKeyPath = class_getInstanceMethod(objectClass, @selector(removeObserver:forKeyPath:));
    Method removeObserverForKeyPathContext = class_getInstanceMethod(objectClass, @selector(removeObserver:forKeyPath:context:));
    Method release = class_getInstanceMethod(objectClass, @selector(release));
    Method dealloc = class_getInstanceMethod(objectClass, @selector(dealloc));

    class_addMethod(
        objectClass,
        @selector(PropertyBindings_KVO_original_removeObserver:forKeyPath:),
        method_getImplementation(removeObserverForKeyPath),
        method_getTypeEncoding(removeObserverForKeyPath)
    );
    class_addMethod(
        objectClass,
        @selector(PropertyBindings_KVO_original_removeObserver:forKeyPath:context:),
        method_getImplementation(removeObserverForKeyPathContext),
        method_getTypeEncoding(removeObserverForKeyPathContext)
    );
    class_addMethod(
        objectClass,
        @selector(PropertyBindings_KVO_original_release),
        method_getImplementation(release),
        method_getTypeEncoding(release)
    );
    class_addMethod(
        objectClass,
        @selector(PropertyBindings_KVO_original_dealloc),
        method_getImplementation(dealloc),
        method_getTypeEncoding(dealloc)
    );

    class_replaceMethod(
        objectClass,
        @selector(removeObserver:forKeyPath:),
        (IMP)KVOSubclassRemoveObserverForKeyPath,
        method_getTypeEncoding(removeObserverForKeyPath)
    );
    class_replaceMethod(
        objectClass,
        @selector(removeObserver:forKeyPath:context:),
        (IMP)KVOSubclassRemoveObserverForKeyPathContext,
        method_getTypeEncoding(removeObserverForKeyPathContext)
    );
    class_replaceMethod(
        objectClass,
        @selector(release),
        (IMP)KVOSubclassRelease,
        method_getTypeEncoding(release)
    );
    class_replaceMethod(
        objectClass,
        @selector(dealloc),
        (IMP)KVOSubclassDealloc,
        method_getTypeEncoding(dealloc)
    );

    [self addRemoveMethodToClass:objectClass];

//    PrintDescription(@"After", object);
}

+ (void)createSubclassForObject:(id)object {
//    PrintDescription(@"Before", object);

    Class objectClass = object_getClass(object);
    NSString *objectClassString = NSStringFromClass(objectClass);
    NSString *subclassName = [NSString stringWithFormat:@"RemoveAllAssociatedBindings_%@", objectClassString];

    Class subclass = objc_getClass([subclassName UTF8String]);
    if (!subclass) {
        subclass = objc_allocateClassPair(objectClass, [subclassName UTF8String], 0);
        if (subclass) {
            Method dealloc = class_getInstanceMethod(self, @selector(deallocWithRemoveAllAssociatedBindings));
            class_addMethod(subclass, @selector(dealloc), method_getImplementation(dealloc), method_getTypeEncoding(dealloc));
            [self addRemoveMethodToClass:subclass];
            objc_registerClassPair(subclass);
        }
    }

    if (!!subclass) {
        object_setClass(object, subclass);
    }
//    PrintDescription(@"After", object);
}

@end
