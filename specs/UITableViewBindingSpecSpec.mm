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
    __block SourceObjectWithArray *secondSource = nil;

    beforeEach(^{
        tableView = [[UITableView alloc] init];
//        mockTableView = [OCMockObject partialMockForObject:tableView];
        sourceObject = [SourceObjectWithArray new];
        sourceObject.arrayProperty = [NSMutableArray array];
       
        secondSource = [SourceObjectWithArray new];
        secondSource.arrayProperty = [NSMutableArray array];
    });

    afterEach(^{
        [tableView release];
        [sourceObject release];
        [secondSource release];
    });

    describe(@"observations", ^{
        it(@"should insert a single row when adding an object to the array", ^{
            [tableView
                bindToObserved:sourceObject
                withArrayKeyPath:@"arrayProperty"
                cellCreationBlock:^UITableViewCell *(id object) {
                    return [[UITableViewCell new] autorelease];
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
                    return [[UITableViewCell new] autorelease];
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
                    return [[UITableViewCell new] autorelease];
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
                    return [[UITableViewCell new] autorelease];
                }];
            
            sourceObject.arrayProperty = [NSMutableArray arrayWithObject:@"Object1"];

            expect(^{ [mockTableView verify]; }).to_not(raise_exception());
        });

        it(@"should do nothing after being unbound", ^{
            [tableView
                bindToObserved:sourceObject
                withArrayKeyPath:@"arrayProperty"
                cellCreationBlock:^UITableViewCell *(id object) {
                    return [[UITableViewCell new] autorelease];
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

        it(@"should report 2 sections in the table when bound twice", ^{
            [tableView
                bindToObserved:sourceObject
                withArrayKeyPath:@"arrayProperty"
                cellCreationBlock:^UITableViewCell *(id object) {
                    return nil;
                }
                forSection:0
                withSectionTitle:nil
           ];

           [tableView
                bindToObserved:sourceObject
                withArrayKeyPath:@"arrayProperty"
                cellCreationBlock:^UITableViewCell *(id object) {
                    return nil;
                }
                forSection:1
                withSectionTitle:nil
            ];

            expect([tableView.dataSource numberOfSectionsInTableView:tableView]).to(equal(2));
        });

        it(@"should return the section title names", ^{
            [tableView
                bindToObserved:sourceObject
                withArrayKeyPath:@"arrayProperty"
                cellCreationBlock:^UITableViewCell *(id object) {
                    return nil;
                }
                forSection:0
                withSectionTitle:@"section 1"
           ];

           [tableView
                bindToObserved:sourceObject
                withArrayKeyPath:@"arrayProperty"
                cellCreationBlock:^UITableViewCell *(id object) {
                    return nil;
                }
                forSection:1
                withSectionTitle:@"section 2"
            ];

            expect([tableView.dataSource tableView:tableView titleForHeaderInSection:0]).to(equal(@"section 1"));
            expect([tableView.dataSource tableView:tableView titleForHeaderInSection:1]).to(equal(@"section 2"));
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
            [secondSource.arrayProperty addObject:@"Object2"];

            __block UITableViewCell *cell = nil;
            cell = [[UITableViewCell alloc] init];
            cell.textLabel.text = @"cell1";

            __block UITableViewCell *cell2 = nil;
            cell2 = [[UITableViewCell alloc] init];
            cell2.textLabel.text = @"cell1";

            [tableView
                bindToObserved:sourceObject
                withArrayKeyPath:@"arrayProperty"
                cellCreationBlock:^UITableViewCell *(NSString *object) {
                    expect(object).to(equal(@"Object1"));
                    return cell;
                }
                forSection:0
                withSectionTitle:nil
            ];

            [tableView
                bindToObserved:secondSource
                withArrayKeyPath:@"arrayProperty"
                cellCreationBlock:^UITableViewCell *(NSString *object) {
                    expect(object).to(equal(@"Object2"));
                    return cell2;
                }
                forSection:1
                withSectionTitle:nil
            ];

            NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
            expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:path]).to(be_same_instance_as(cell));

            path = [NSIndexPath indexPathForRow:0 inSection:1];
            expect([tableView.dataSource tableView:tableView cellForRowAtIndexPath:path]).to(be_same_instance_as(cell2));
        });

        it(@"should call the commit editing style callback", ^{
            NSIndexPath *expectedIndexPath1 = [NSIndexPath indexPathForRow:1 inSection:0];
            NSIndexPath *expectedIndexPath2 = [NSIndexPath indexPathForRow:2 inSection:1];

            __block BOOL callback1Called = NO;
            __block BOOL callback2Called = NO;
            [tableView bindToObserved:sourceObject withArrayKeyPath:@"arrayProperty" cellCreationBlock:nil commitEditingStyleBlock:^(UITableViewCellEditingStyle style, NSIndexPath *indexPath) {
                    callback1Called = YES;
                    expect(style).to(equal(UITableViewCellEditingStyleInsert));
                    expect(indexPath).to(be_same_instance_as(expectedIndexPath1));
                }
                forSection:0
                withSectionTitle:nil
            ];

            [tableView bindToObserved:sourceObject withArrayKeyPath:@"arrayProperty" cellCreationBlock:nil commitEditingStyleBlock:^(UITableViewCellEditingStyle style, NSIndexPath *indexPath) {
                    callback2Called = YES;
                    expect(style).to(equal(UITableViewCellEditingStyleDelete));
                    expect(indexPath).to(be_same_instance_as(expectedIndexPath2));
                }
                forSection:1
                withSectionTitle:nil
            ];

            [tableView.dataSource
                tableView:nil
                commitEditingStyle:UITableViewCellEditingStyleInsert
                forRowAtIndexPath:expectedIndexPath1
            ];
            expect(callback1Called).to(equal(YES));

            [tableView.dataSource
                tableView:nil
                commitEditingStyle:UITableViewCellEditingStyleDelete
                forRowAtIndexPath:expectedIndexPath2
            ];
            expect(callback2Called).to(equal(YES));
        });
    });
});

SPEC_END
