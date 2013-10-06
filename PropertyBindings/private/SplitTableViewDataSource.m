//
//  SplitTableViewDataSource.m
//  PropertyBindings
//
//  Created by Andrew J Wagner on 10/4/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import "SplitTableViewDataSource.h"

@interface SplitTableViewDataSource ()

@property (nonatomic, strong) NSMutableDictionary *delegates;

@end

@implementation SplitTableViewDataSource

- (id)init {
    self = [super init];
    if (self) {
        self.delegates = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setDelegate:(id<UITableViewDataSource>)delegate forSection:(NSUInteger)section {
    [self.delegates setObject:[NSValue valueWithNonretainedObject:delegate] forKey:@(section)];
}

- (void)clearDelegate:(id<UITableViewDataSource>)delegate forSection:(NSUInteger)section {
    if ([self.delegates[@(section)] nonretainedObjectValue] == delegate) {
        [self.delegates removeObjectForKey:@(section)];
    }
}

- (id<UITableViewDataSource>)delegateForSection:(NSInteger)section {
    return [self.delegates[@(section)] nonretainedObjectValue];
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id<UITableViewDataSource> delegate = [self delegateForSection:section];
    if (delegate && [delegate respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
        return [delegate tableView:tableView titleForHeaderInSection:section];
    }
    else {
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionCount = 0;
    for (NSNumber *section in self.delegates.allKeys) {
        if ([section integerValue] + 1 > sectionCount) {
            sectionCount = [section integerValue] + 1;
        }
    }
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<UITableViewDataSource> delegate = [self delegateForSection:section];
    if (delegate && [delegate respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
        return [delegate tableView:tableView numberOfRowsInSection:section];
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<UITableViewDataSource> delegate = [self delegateForSection:indexPath.section];
    if (delegate && [delegate respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]) {
        return [delegate tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    id<UITableViewDataSource> delegate = [self delegateForSection:indexPath.section];
    if (delegate && [delegate respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
        [delegate tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    id<UITableViewDataSource> delegate = [self delegateForSection:indexPath.section];
    if (delegate && [delegate respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]) {
        return [delegate tableView:tableView canEditRowAtIndexPath:indexPath];
    }
    return NO;
}

@end
