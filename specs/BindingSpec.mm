#import "NSObject+Binding.h"
#import <objc/runtime.h>
#import "BindingManager.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface BindingManager (BindingSpecAccess)

@property (nonatomic, strong) NSMutableArray *bindings;

@end

@interface SourceObject : NSObject

@property (nonatomic) NSInteger numberProperty;
@property (strong, nonatomic) NSString *stringProperty;

@end


@implementation SourceObject

- (void)dealloc {
    [_stringProperty release];

    [super dealloc];
}

@end


@interface DestinationObject : NSObject

@property (nonatomic) NSInteger numberProperty;
@property (strong, nonatomic) NSString *stringProperty;

@end


@implementation DestinationObject

- (void)dealloc {
    [_stringProperty release];

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

        it(@"should handle nil values", ^{
            sourceObject.stringProperty = nil;
            [destinationObject bindProperty:@"stringProperty" toObserved:sourceObject withKeyPath:@"stringProperty"];
            expect(destinationObject.stringProperty).to(be_nil());
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
