//
//  BindingTableView.m
//  PropertyBindings
//
//  Created by Andrew J Wagner on 5/3/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import "BindingTableView.h"

#import "RemoveAllAssociatedBindingsClassAttacher.h"
#import "SplitTableViewDataSource.h"

@interface BindingTableView ()

@property (nonatomic) NSInteger section;
@property (nonatomic, strong) NSString *sectionTitle;
@property (nonatomic, assign) UITableView *tableView;
@property (nonatomic, copy) UITableViewCellCreationBlock cellCreationBlock;
@property (nonatomic, copy) UITableViewTopCellCreationBlock topCellCreationBlock;
@property (nonatomic, copy) UITableViewCommitEditingStyleBlock commitEditingStyleBlock;
@property (nonatomic, strong) SplitTableViewDataSource *splitDataSource;

- (NSArray *)sourceArray;

@end

@implementation BindingTableView

- (id)initWithObserved:(id)observed
             atKeyPath:(NSString *)keyPath
         withTableView:(UITableView *)tableView
     cellCreationBlock:(UITableViewCellCreationBlock)creationBlock
  topCellCreationBlock:(UITableViewTopCellCreationBlock)topCreationBlock
commitEditingStyleBlock:(UITableViewCommitEditingStyleBlock)editingBlock
            forSection:(NSInteger)section
      withSectionTitle:(NSString *)sectionTitle
{
    self = [super initWithObserved:observed atKeyPath:keyPath];
    if (self) {
        self.tableView = tableView;
        self.section = section;
        self.sectionTitle = sectionTitle;
        if (self.tableView.dataSource
            && [self.tableView.dataSource isKindOfClass:[SplitTableViewDataSource class]])
        {
            self.splitDataSource = (SplitTableViewDataSource *)self.tableView.dataSource;
        }
        else {
            SplitTableViewDataSource *dataSource = [SplitTableViewDataSource new];
            self.splitDataSource = dataSource;
            [dataSource release];
            self.tableView.dataSource = self.splitDataSource;
        }
        [self.splitDataSource setDelegate:self forSection:section];

        self.cellCreationBlock = creationBlock;
        self.topCellCreationBlock = topCreationBlock;
        self.commitEditingStyleBlock = editingBlock;
    }
    return self;
}

- (void)dealloc {
    [_cellCreationBlock release];
    [_commitEditingStyleBlock release];
    [_topCellCreationBlock release];
    [_sectionTitle release];
    [_splitDataSource release];

    [super dealloc];
}

- (void)activateWithChange:(NSDictionary *)change {
    NSNumber *kind = [change objectForKey:NSKeyValueChangeKindKey];
    if ([kind integerValue] == NSKeyValueChangeSetting) {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:self.section] withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        NSIndexSet *indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
        NSMutableArray *indexArray = [NSMutableArray array];
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            if (self.topCellCreationBlock) {
                idx++;
            }
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:self.section];
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

    return binding.tableView == self.tableView && binding.section == self.section;
}

- (BOOL)isAssociatedWithObjects:(id)object keyPath:(NSString *)keyPath {
    if ([super isAssociatedWithObjects:object keyPath:keyPath]) {
        return YES;
    }

    return self.tableView == object;
}

- (void)didUnbind {
    [super didUnbind];

    if ([self.tableView.dataSource isKindOfClass:[SplitTableViewDataSource class]]) {
        [(SplitTableViewDataSource *)self.tableView.dataSource clearDelegate:self forSection:self.section];
    }
    else if (self.tableView.dataSource == self) {
        self.tableView.dataSource = nil;
    }
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionTitle;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count = [self sourceArray].count;
    if (self.topCellCreationBlock) {
        count++;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.topCellCreationBlock) {
        if (indexPath.row == 0) {
            return self.topCellCreationBlock();
        }
        else {
            return self.cellCreationBlock([self sourceArray][indexPath.row - 1]);
        }
    }
    return self.cellCreationBlock([self sourceArray][indexPath.row]);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.commitEditingStyleBlock) {
        if (self.topCellCreationBlock) {
            return indexPath.row != 0;
        }
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.commitEditingStyleBlock) {
        if (self.topCellCreationBlock) {
            indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        }
        self.commitEditingStyleBlock(editingStyle, indexPath);
    }
}

#pragma mark - Private Methods

- (NSArray *)sourceArray {
    return (NSArray *)[self.observedObject valueForKey:self.observedKeyPath];
}

@end
