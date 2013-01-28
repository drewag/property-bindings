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

When you would like to ensure that an objects property is always the same as another objects do the following:
```objective-c
[destinationObject bindProperty:@"stringProperty" toObserved:sourceObject withKeyPath:@"stringProperty"];
```

If you want to stop the binding do the following:
```objective-c
[destinationObject unbindProperty:@"stringProperty"];
```

See the spec file for more example usage: specs/BindingSpec.mm
