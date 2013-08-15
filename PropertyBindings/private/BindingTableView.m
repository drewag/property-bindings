//
//  BindingTableView.m
//  PropertyBindings
//
//  Created by Andrew J Wagner on 5/3/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import "BindingTableView.h"

#import "RemoveAllAssociatedBindingsClassAttacher.h"

@interface BindingTableView ()

@property (nonatomic, assign) UITableView *tableView;
@property (nonatomic, copy) UITableViewCellCreationBlock cellCreationBlock;
@property (nonatomic, copy) UITableViewCommitEditingStyleBlock commitEditingStyleBlock;

- (NSArray *)sourceArray;

@end

@implementation BindingTableView

- (id)initWithObserved:(id)observed
             atKeyPath:(NSString *)keyPath
         withTableView:(UITableView *)tableView
     cellCreationBlock:(UITableViewCellCreationBlock)creationBlock
commitEditingStyleBlock:(UITableViewCommitEditingStyleBlock)editingBlock
{
    self = [super initWithObserved:observed atKeyPath:keyPath];
    if (self) {
        self.tableView = tableView;
        self.tableView.dataSource = self;
        self.cellCreationBlock = creationBlock;
        self.commitEditingStyleBlock = editingBlock;
    }
    return self;
}

- (void)dealloc {
    [_cellCreationBlock release];
    [_commitEditingStyleBlock release];

    [super dealloc];
}

- (void)activateWithChange:(NSDictionary *)change {
    NSNumber *kind = [change objectForKey:NSKeyValueChangeKindKey];
    if ([kind integerValue] == NSKeyValueChangeSetting) {
        [self.tableView reloadData];
    }
    else {
        NSIndexSet *indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
        NSMutableArray *indexArray = [NSMutableArray array];
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            [indexArray addObject:indexPath];
        }];
        [self.tableView beginUpdates];
        switch([kind integerValue]) {
            case NSKeyValueChangeInsertion:
                [self.tableView
                    insertRowsAtIndexPaths:indexArray
                    withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSKeyValueChangeRemoval:
                [self.tableView
                    deleteRowsAtIndexPaths:indexArray
                    withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSKeyValueChangeReplacement:
                [self.tableView
                    reloadRowsAtIndexPaths:indexArray
                    withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
        }
        [self.tableView endUpdates];
    }
}

- (void)confirmBinding {
    [super confirmBinding];

    [RemoveAllAssociatedBindingsClassAttacher
        attachRemoveAllAssociatedBindingsToDeallocOfObject:self.tableView];
}

- (BOOL)shouldRemoveExistingBinding:(BindingTableView *)binding {
    if (![[binding class] isSubclassOfClass:[BindingTableView class]]) {
        return NO;
    }

    return binding.tableView == self.tableView;
}

- (BOOL)isAssociatedWithObjects:(id)object keyPath:(NSString *)keyPath {
    if ([super isAssociatedWithObjects:object keyPath:keyPath]) {
        return YES;
    }

    return self.tableView == object;
}

- (void)didUnbind {
    [super didUnbind];

    self.tableView.dataSource = nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self sourceArray].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellCreationBlock([self sourceArray][indexPath.row]);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.commitEditingStyleBlock) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    self.commitEditingStyleBlock(editingStyle, indexPath);
}

#pragma mark - Private Methods

- (NSArray *)sourceArray {
    return (NSArray *)[self.observedObject valueForKey:self.observedKeyPath];
}

@end
