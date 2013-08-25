#import "NSObject+Binding.h"
#import <objc/runtime.h>
#import <OCMock/OCMock.h>
#import "BindingManager.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface BindingManager (BindingSpecAccess)

@property (nonatomic, strong) NSMutableArray *bindings;

@end

@interface SourceObject : UIView

@property (nonatomic) NSInteger numberProperty;
@property (strong, nonatomic) NSString *stringProperty;
@property (strong, nonatomic) NSArray *arrayProperty;

@end


@implementation SourceObject

- (void)dealloc {
    [_stringProperty release];
    [_arrayProperty release];

    [super dealloc];
}

@end


@interface DestinationObject : NSObject

@property (nonatomic) NSInteger numberProperty;
@property (strong, nonatomic) NSString *stringProperty;
@property (strong, nonatomic) NSString *stringProperty2;
@property (strong, nonatomic) NSArray *arrayProperty;

@end


@implementation DestinationObject

- (void)dealloc {
    [_stringProperty release];
    [_stringProperty2 release];
    [_arrayProperty release];

    [super dealloc];
}

@end

@interface BindToSelfOnInitObject : NSObject

@property (strong, nonatomic) NSString *stringProperty;
@property (strong, nonatomic) NSString *stringProperty2;

@end

@implementation BindToSelfOnInitObject

- (id)init {
    self = [super init];
    if (self) {
        [self bindProperty:@"stringProperty2" toObserved:self withKeyPath:@"stringProperty"];
    }
    return self;
}

- (void)dealloc {
    [_stringProperty release];
    [_stringProperty2 release];

    [super dealloc];
}

@end

SPEC_BEGIN(BindingSpec)

describe(@"Binding", ^{
    __block SourceObject *sourceObject = nil;
    __block DestinationObject *destinationObject = nil;

    beforeEach(^{
        sourceObject = [SourceObject new];
        destinationObject = [DestinationObject new];
    });

    afterEach(^{
        [sourceObject release];
        [destinationObject release];
    });

    describe(@"-bindProperty:toObserved:withKeyPath:", ^{
        it(@"should change the destination object's property to the source object's property when first bound", ^{
            sourceObject.stringProperty = @"Some String";
            [destinationObject bindProperty:@"stringProperty" toObserved:sourceObject withKeyPath:@"stringProperty"];
            expect(destinationObject.stringProperty).to(equal(@"Some String"));
        });

        it(@"should change the destination object's property when the source object's property changes", ^{
            [destinationObject bindProperty:@"stringProperty" toObserved:sourceObject withKeyPath:@"stringProperty"];

            sourceObject.stringProperty = @"Test String";
            expect(destinationObject.stringProperty).to(equal(@"Test String"));
        });

        it(@"should not change the source object's property when the destinations object's property changes", ^{
            [destinationObject bindProperty:@"stringProperty" toObserved:sourceObject withKeyPath:@"stringProperty"];

            destinationObject.stringProperty = @"Test String";
            expect(sourceObject.stringProperty).to(be_nil());
        });

        it(@"should override the previous property's binding", ^{
            SourceObject *secondSourceObject = [SourceObject new];
            sourceObject.stringProperty = @"Original Value";
            secondSourceObject.stringProperty = @"Second Original Value";

            [destinationObject bindProperty:@"stringProperty" toObserved:sourceObject withKeyPath:@"stringProperty"];
            [destinationObject bindProperty:@"stringProperty" toObserved:secondSourceObject withKeyPath:@"stringProperty"];

            sourceObject.stringProperty = @"Test String";
            expect(destinationObject.stringProperty).to(equal(@"Second Original Value"));

            secondSourceObject.stringProperty = @"Second Test String";
            expect(destinationObject.stringProperty).to(equal(@"Second Test String"));

            [secondSourceObject release];
        });

        it(@"should cancel the binding if the source object is deallocated", ^{
            SourceObject *otherSourceObject = [SourceObject new];
            [destinationObject bindProperty:@"stringProperty" toObserved:otherSourceObject withKeyPath:@"stringProperty"];

            expect([[BindingManager sharedInstance] bindings].count).to(equal(1));

            expect(otherSourceObject.retainCount).to(equal(1));
            [otherSourceObject release];

            expect([[BindingManager sharedInstance] bindings].count).to(equal(0));
        });

        it(@"should cancel the binding if the destination object is deallocated", ^{
            SourceObject *otherSourceObject = [SourceObject new];
            [destinationObject bindProperty:@"stringProperty" toObserved:otherSourceObject withKeyPath:@"stringProperty"];

            expect([[BindingManager sharedInstance] bindings].count).to(equal(1));

            expect(destinationObject.retainCount).to(equal(1));
            [destinationObject release];
            destinationObject = nil;

            expect([[BindingManager sharedInstance] bindings].count).to(equal(0));
        });

        it(@"should cancel the binding only once if the destination object that is bounds twice is deallocated", ^{
            SourceObject *otherSourceObject = [SourceObject new];
            [destinationObject bindProperty:@"stringProperty" toObserved:otherSourceObject withKeyPath:@"stringProperty"];
            [destinationObject bindProperty:@"stringProperty2" toObserved:otherSourceObject withKeyPath:@"stringProperty"];

            expect([[BindingManager sharedInstance] bindings].count).to(equal(2));

            id mockBindingManager = [OCMockObject partialMockForObject:[BindingManager sharedInstance]];

            [[mockBindingManager expect] removeAllBindingsAssociatedWithObject:[OCMArg any]];
            [[mockBindingManager reject] removeAllBindingsAssociatedWithObject:[OCMArg any]];

            expect(destinationObject.retainCount).to(equal(1));
            expect(^{
                [destinationObject release];
            }).to_not(raise_exception());

            destinationObject = nil;

            expect(^{ [mockBindingManager verify]; }).to_not(raise_exception());
        });

        it(@"should handle nil values", ^{
            sourceObject.stringProperty = nil;
            [destinationObject bindProperty:@"stringProperty" toObserved:sourceObject withKeyPath:@"stringProperty"];
            expect(destinationObject.stringProperty).to(be_nil());
        });

        it(@"should be able to bind two properties of the same object", ^{
            [destinationObject bindProperty:@"stringProperty2" toObserved:destinationObject withKeyPath:@"stringProperty"];
            destinationObject.stringProperty = @"Hello";
            expect(destinationObject.stringProperty2).to(equal(@"Hello"));
        });

        it(@"should work with view controllers", ^{
            sourceObject = [SourceObject new];
            UIViewController *controller1 = [UIViewController new];
            expect(controller1.view).to_not(be_nil());
            [controller1.view addSubview:sourceObject];
            [controller1 bindProperty:@"title" toObserved:sourceObject withKeyPath:@"stringProperty"];
            sourceObject.stringProperty = @"My Title";
            expect(controller1.title).to(equal(@"My Title"));;
            [controller1 release];
            [sourceObject release];

            sourceObject = [SourceObject new];
            UIViewController *controller2 = [UIViewController new];
            expect(controller2.view).to_not(be_nil());
            [controller2.view addSubview:sourceObject];
            [controller2 bindProperty:@"title" toObserved:sourceObject withKeyPath:@"stringProperty"];
            sourceObject.stringProperty = @"My Title";
            expect(controller2.title).to(equal(@"My Title"));;
            [controller2 release];
            [sourceObject release];

            sourceObject = [SourceObject new];
            UIViewController *controller3 = [UIViewController new];
            expect(controller3.view).to_not(be_nil());
            [controller3.view addSubview:sourceObject];
            [controller3 bindProperty:@"title" toObserved:sourceObject withKeyPath:@"stringProperty"];
            sourceObject.stringProperty = @"My Title";
            expect(controller3.title).to(equal(@"My Title"));;
            [controller3 release];
            [sourceObject release];
        });

        it(@"should work when binding in initialization", ^{
            BindToSelfOnInitObject *object = [BindToSelfOnInitObject new];
            object.stringProperty = @"A String";object.stringProperty = @"A String";object.stringProperty = @"A String";
            expect(object.stringProperty2).to(equal(@"A String"));
        });
    });

    describe(@"-bindArrayProperty:toObserved:withKeyPath:", ^{
        it(@"should change the destination object's array to the source object's array when first bound", ^{
            sourceObject.arrayProperty = @[@"Some String"];
            [destinationObject bindArrayProperty:@"arrayProperty" toObserved:sourceObject withKeyPath:@"arrayProperty"];
            expect(destinationObject.arrayProperty).to(equal(@[@"Some String"]));
        });

        it(@"should change the destination object's array to the source object's array when reseting entire array", ^{
            sourceObject.arrayProperty = @[@"Some String"];
            [destinationObject bindArrayProperty:@"arrayProperty" toObserved:sourceObject withKeyPath:@"arrayProperty"];

            sourceObject.arrayProperty = @[@"something else", @"another"];
            expect(destinationObject.arrayProperty).to(equal(@[@"something else", @"another"]));
        });

        it(@"should change the destination object's array to the source object's array when modifying the array", ^{
            sourceObject.arrayProperty = @[@"Some String"];
            [destinationObject bindArrayProperty:@"arrayProperty" toObserved:sourceObject withKeyPath:@"arrayProperty"];

            [[sourceObject mutableArrayValueForKey:@"arrayProperty"] addObject:@"another"];
            expect(destinationObject.arrayProperty).to(equal(@[@"Some String", @"another"]));
        });
    });

    describe(@"-bindBlock:ToProperty:", ^{
        it(@"should call the block with the new property", ^{
            __block id capturedValue = @"Before";
            
            [sourceObject bindBlock:^(id newValue) {
                capturedValue = newValue;
            } toProperty:@"stringProperty"];

            expect(capturedValue).to(be_nil());
            sourceObject.stringProperty = @"A test string";
            expect(capturedValue).to(equal(@"A test string"));

            [sourceObject unbindProperty:@"stringProperty"];
            sourceObject.stringProperty = @"Other";
            expect(capturedValue).to(equal(@"A test string"));
        });

        it(@"should handle number properties", ^{
            __block NSInteger capturedNumber = 10;
            
            [sourceObject bindBlock:^(id newValue) {
                capturedNumber = [newValue integerValue];
            } toProperty:@"numberProperty"];

            expect(capturedNumber).to(equal(0));
            sourceObject.numberProperty = 7;
            expect(capturedNumber).to(equal(7));
        });

        it(@"should handle nil values", ^{
            __block id capturedValue = nil;
            sourceObject.stringProperty = @"Before";
            
            [sourceObject bindBlock:^(id newValue) {
                capturedValue = newValue;
            } toProperty:@"stringProperty"];

            expect(capturedValue).to(equal(@"Before"));
            sourceObject.stringProperty = nil;
            expect(capturedValue).to(be_nil());
        });
    });

    describe(@"-unbindProperty:", ^{
        it(@"should stop updating destination object based on source object", ^{
            sourceObject.stringProperty = @"Original String";

            [destinationObject bindProperty:@"stringProperty" toObserved:sourceObject withKeyPath:@"stringProperty"];
            [destinationObject unbindProperty:@"stringProperty"];

            sourceObject.stringProperty = @"Test String";
            expect(destinationObject.stringProperty).to(equal(@"Original String"));
        });

        it(@"should stop calling the block based on source object", ^{
            __block id capturedValue = @"Before";
            
            [sourceObject bindBlock:^(id newValue) {
                capturedValue = newValue;
            } toProperty:@"stringProperty"];
            [sourceObject unbindProperty:@"stringProperty"];

            sourceObject.stringProperty = @"new";
            expect(capturedValue).to(be_nil());
        });
    });

    describe(@"-unbindAll", ^{
        it(@"should stop updating all destination object properties", ^{
            sourceObject.stringProperty = @"Original String";
            sourceObject.numberProperty = 27;

            [destinationObject bindProperty:@"stringProperty" toObserved:sourceObject withKeyPath:@"stringProperty"];
            [destinationObject bindProperty:@"numberProperty" toObserved:sourceObject withKeyPath:@"numberProperty"];
            [destinationObject unbindAll];

            sourceObject.stringProperty = @"Test String";
            sourceObject.numberProperty = 5;
            expect(destinationObject.stringProperty).to(equal(@"Original String"));
            expect(destinationObject.numberProperty).to(equal(27));
        });
    });
});

SPEC_END
