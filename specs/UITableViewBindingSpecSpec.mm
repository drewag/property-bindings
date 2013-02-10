#import "UITableView+Binding.h"

#import <OCMock/OCMock.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface SourceObjectWithArray : NSObject

@property (strong, nonatomic) NSMutableArray *arrayProperty;

@end

@implementation SourceObjectWithArray

- (void)dealloc {
    [_arrayProperty release];

    [super dealloc];
}

@end

SPEC_BEGIN(UITableViewBindingSpecSpec)

describe(@"UITableViewBindingSpec", ^{
    __block UITableView *tableView = nil;
    __block id mockTableView = nil;
    __block SourceObjectWithArray *sourceObject = nil;

    beforeEach(^{
        tableView = [[UITableView alloc] init];
        mockTableView = [OCMockObject partialMockForObject:tableView];
        sourceObject = [SourceObjectWithArray new];
        sourceObject.arrayProperty = [NSMutableArray array];
    });

    afterEach(^{
        [tableView release];
        [sourceObject release];
    });

    describe(@"observations", ^{
        it(@"should insert a single row when adding an object to the array", ^{
            [tableView
                bindToObserved:sourceObject
                withArrayKeyPath:@"arrayProperty"
                cellCreationBlock:^UITableViewCell *(id object) {
                    return nil;
                }];

            [[mockTableView expect] beginUpdates];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [[mockTableView expect]
                insertRowsAtIndexPaths:@[indexPath]
                withRowAnimation:UITableViewRowAnimationAutomatic];
            [[mockTableView expect] endUpdates];

            [[sourceObject mutableArrayValueForKey:@"arrayProperty"] addObject:@"Object1"];

            expect(^{ [mockTableView verify]; }).to_not(raise_exception());
        });

        it(@"should remove a single row when removing an object from the array", ^{
            [sourceObject.arrayProperty addObject:@"Object1"];
            [sourceObject.arrayProperty addObject:@"Object2"];
            [sourceObject.arrayProperty addObject:@"Object3"];

            [tableView
                bindToObserved:sourceObject
                withArrayKeyPath:@"arrayProperty"
                cellCreationBlock:^UITableViewCell *(id object) {
                    return nil;
                }];

            [[mockTableView expect] beginUpdates];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            [[mockTableView expect]
                deleteRowsAtIndexPaths:@[indexPath]
                withRowAnimation:UITableViewRowAnimationAutomatic];
            [[mockTableView expect] endUpdates];

            [[sourceObject mutableArrayValueForKey:@"arrayProperty"] removeObject:@"Object2"];

            expect(^{ [mockTableView verify]; }).to_not(raise_exception());
        });
        
        it(@"should update a single row when removing an object from the array", ^{
            [sourceObject.arrayProperty addObject:@"Object1"];
            [sourceObject.arrayProperty addObject:@"Object2"];
            [sourceObject.arrayProperty addObject:@"Object3"];

            [tableView
                bindToObserved:sourceObject
                withArrayKeyPath:@"arrayProperty"
                cellCreationBlock:^UITableViewCell *(id object) {
                    return nil;
                }];

            [[mockTableView expect] beginUpdates];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            [[mockTableView expect]
                reloadRowsAtIndexPaths:@[indexPath]
                withRowAnimation:UITableViewRowAnimationAutomatic];
            [[mockTableView expect] endUpdates];

            [[sourceObject mutableArrayValueForKey:@"arrayProperty"]
                replaceObjectAtIndex:1
                withObject:@"Object4"];

            expect(^{ [mockTableView verify]; }).to_not(raise_exception());
        });

        it(@"should reload the table if the entire array is reassigned", ^{
            [[mockTableView expect] reloadData];

            [tableView
                bindToObserved:sourceObject
                withArrayKeyPath:@"arrayProperty"
                cellCreationBlock:^UITableViewCell *(id object) {
                    return nil;
                }];
            
            sourceObject.arrayProperty = [NSMutableArray arrayWithObject:@"Object1"];

            expect(^{ [mockTableView verify]; }).to_not(raise_exception());
        });

        it(@"should do nothing after being unbound", ^{
            [tableView
                bindToObserved:sourceObject
                withArrayKeyPath:@"arrayProperty"
                cellCreationBlock:^UITableViewCell *(id object) {
                    return nil;
                }];

            [[mockTableView reject] reloadData];

            [tableView unbind];

            expect(^{
                sourceObject.arrayProperty = [NSMutableArray arrayWithObject:@"Object1"];
            }).to_not(raise_exception());
        });
    });

    describe(@"UITableViewDataSource", ^{
        it(@"should report 1 section in the table", ^{
            [tableView
                bindToObserved:sourceObject
                withArrayKeyPath:@"arrayProperty"
                cellCreationBlock:^UITableViewCell *(id object) {
                    return nil;
                }];

            expect([tableView.dataSource numberOfSectionsInTableView:tableView]).to(equal(1));
        });

        it(@"should report the number of rows according to the number of objects in the array", ^{
            [sourceObject.arrayProperty addObject:@"Object1"];
            [sourceObject.arrayProperty addObject:@"Object2"];
            [sourceObject.arrayProperty addObject:@"Object3"];

            [tableView
                bindToObserved:sourceObject
                withArrayKeyPath:@"arrayProperty"
                cellCreationBlock:^UITableViewCell *(id object) {
                    return nil;
                }];

            expect([tableView.dataSource tableView:tableView numberOfRowsInSection:0]).to(equal(3));
        });

        it(@"should use the given block to create cells", ^{
            [sourceObject.arrayProperty addObject:@"Object1"];

            __block UITableViewCell *cell = nil;
            cell = [[UITableViewCell alloc] init];

            [tableView
                bindToObserved:sourceObject
                withArrayKeyPath:@"arrayProperty"
                cellCreationBlock:^UITableViewCell *(NSString *object) {
                    expect(object).to(equal(@"Object1"));
                    return cell;
                }];

            NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
            expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:path]).to(be_same_instance_as(cell));
        });
    });
});

SPEC_END
