bindings
========

Bindings for Objective-C

The Bindings extension on NSObject provide a mechanism to bind the
property of one object to the property of another's through KVO.

Usage
--------

Import the header for the Bindings extension:
```objective-c
#import "bindings/NSObject+Binding.h"
```

Basics
---------

The Bindings extension provides the following methods to all NSObjects:

    - (void)bindProperty:(NSString *)observingKeyPath
              toObserved:(NSObject *)observed
             withKeyPath:(NSString *)observedKeyPath;

    - (void)unbindProperty:(NSString *)keyPath;
    - (void)unbindAll;

If you want an object's property to always be equal to another object's property you can bind it using the `-bindProperty:toObservered:withKeyPath:` method. This automatically sets up the necessary observers and removes the observer if the source object or destination object is destroyed.
```objective-c
[destinationObject bindProperty:@"stringProperty" toObserved:sourceObject withKeyPath:@"stringProperty"];
```

You can also manually remove a binding by calling the `-unbindProperty:` or `-unbindAll` methods.
If you want to stop the binding do the following:
```objective-c
[destinationObject unbindProperty:@"stringProperty"];
```

Transforming Values
---------

Sometimes you may want to bind a property to the property of a different type. For example, you might want to bind a date property to a string property.

To do this, create a setter on the destination object that takes the source objects property types, convert the object, and then set it on the real property. For example:

```objective-c
- (void)setDate:(NSDate *)date {
    self.dateString = date.description;
}
```

In the example above you would bind to the "date" key path.

See the spec file for more example usage: specs/BindingSpec.mm

For a description of the implementation please see my [blog post](http://drewag.me/posts/objective-c-bindings?source=github) about it.
