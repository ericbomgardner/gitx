//
//  PBRefMenuItem.m
//  GitX
//
//  Created by Pieter de Bie on 01-11-08.
//  Copyright 2008 Pieter de Bie. All rights reserved.
//

#import "PBRefMenuItem.h"
#import "PBGitRepository.h"
#import "PBGitRevSpecifier.h"

@implementation PBRefMenuItem
@synthesize refishs;

+ (PBRefMenuItem *) itemWithTitle:(NSString *)title action:(SEL)selector enabled:(BOOL)isEnabled
{
	if (!isEnabled)
		selector = nil;

	PBRefMenuItem *item = [[PBRefMenuItem alloc] initWithTitle:title action:selector keyEquivalent:@""];
	[item setEnabled:isEnabled];
	return item;
}


+ (PBRefMenuItem *) separatorItem
{
	PBRefMenuItem *item = (PBRefMenuItem *)[super separatorItem];
	return item;
}


+ (NSArray<NSMenuItem *> *) defaultMenuItemsForStashRef:(PBGitRef *)ref inRepository:(PBGitRepository *)repo target:(id)target
{
    NSMutableArray *items = [NSMutableArray array];
	NSString *targetRefName = [ref shortName];
    BOOL isCleanWorkingCopy = YES;
    
    // pop
    NSString *stashPopTitle = [NSString stringWithFormat:@"Pop %@", targetRefName];
    [items addObject:[PBRefMenuItem itemWithTitle:stashPopTitle action:@selector(stashPop:) enabled:isCleanWorkingCopy]];
    
    // apply
    NSString *stashApplyTitle = @"Apply";
    [items addObject:[PBRefMenuItem itemWithTitle:stashApplyTitle action:@selector(stashApply:) enabled:YES]];
    
    // view diff
    NSString *stashDiffTitle = @"View Diff";
    [items addObject:[PBRefMenuItem itemWithTitle:stashDiffTitle action:@selector(stashViewDiff:) enabled:YES]];

    [items addObject:[PBRefMenuItem separatorItem]];

    // drop
    NSString *stashDropTitle = @"Drop";
    [items addObject:[PBRefMenuItem itemWithTitle:stashDropTitle action:@selector(stashDrop:) enabled:YES]];
    
	for (PBRefMenuItem *item in items) {
		item.target = target;
		item.refishs = @[ref];
	}
    
	return items;
}


+ (NSArray<NSMenuItem *> *) defaultMenuItemsForRef:(PBGitRef *)ref inRepository:(PBGitRepository *)repo target:(id)target
{
	if (!ref || !repo || !target) {
		return nil;
	}
	
    if ([ref isStash]) {
        return [self defaultMenuItemsForStashRef:ref inRepository:repo target:target];
    }

	NSString *refName = [ref shortName];

	PBGitRef *headRef = [[repo headRef] ref];
	NSString *headRefName = [headRef shortName];
	BOOL isHead = [ref isEqualToRef:headRef];
	BOOL isOnHeadBranch = isHead ? YES : [repo isRefOnHeadBranch:ref];
	BOOL isDetachedHead = (isHead && [headRefName isEqualToString:@"HEAD"]);

	NSString *remoteName = [ref remoteName];
	if (!remoteName && [ref isBranch]) {
		remoteName = [[repo remoteRefForBranch:ref error:NULL] remoteName];
	}
	BOOL hasRemote = (remoteName ? YES : NO);
	BOOL isRemote = ([ref isRemote] && ![ref isRemoteBranch]);

	NSMutableArray *items = [NSMutableArray array];
	if (!isRemote) {
		// checkout ref
		NSString *checkoutTitle = [@"Checkout " stringByAppendingString:refName];
		[items addObject:[PBRefMenuItem itemWithTitle:checkoutTitle action:@selector(checkout:) enabled:!isHead]];
		[items addObject:[PBRefMenuItem separatorItem]];

		// Diff
		NSString *diffTitle = [NSString stringWithFormat:@"Diff with %@", headRefName];
		[items addObject:[PBRefMenuItem itemWithTitle:diffTitle action:@selector(diffWithHEAD:) enabled:!isHead]];
		[items addObject:[PBRefMenuItem separatorItem]];
	}

	// delete ref
	[items addObject:[PBRefMenuItem separatorItem]];
	{
		BOOL isStash = [[ref ref] hasPrefix:@"refs/stash"];
		NSString *deleteTitle = [NSString stringWithFormat:@"Delete %@…", refName];
		if ([ref isRemote]) {
			deleteTitle = [NSString stringWithFormat:@"Remove %@…", refName];
		}
		BOOL deleteEnabled = !(isDetachedHead || isHead || isStash);
		PBRefMenuItem *deleteItem = [PBRefMenuItem itemWithTitle:deleteTitle action:@selector(showDeleteRefSheet:) enabled:deleteEnabled];
		[items addObject:deleteItem];
	}

	for (PBRefMenuItem *item in items) {
		item.target = target;
		item.refishs = @[ref];
	}

	return items;
}


+ (NSArray<NSMenuItem *> *) defaultMenuItemsForCommits:(NSArray<PBGitCommit *> *)commits target:(id)target
{
	NSMutableArray *items = [NSMutableArray array];
	
	BOOL isSingleCommitSelection = commits.count == 1;
	PBGitCommit *firstCommit = commits.firstObject;
	
	NSString *headBranchName = [[[firstCommit.repository headRef] ref] shortName];
	BOOL isOnHeadBranch = [firstCommit isOnHeadBranch];
	BOOL isHead = [firstCommit.OID isEqual:firstCommit.repository.headOID];
	
	[items addObject:[PBRefMenuItem itemWithTitle:@"Copy SHA" action:@selector(copySHA:) enabled:YES]];
	[items addObject:[PBRefMenuItem itemWithTitle:@"Copy short SHA" action:@selector(copyShortSHA:) enabled:YES]];

	if (isSingleCommitSelection) {
		NSString *diffTitle = [NSString stringWithFormat:@"Diff with %@", headBranchName];
		[items addObject:[PBRefMenuItem itemWithTitle:diffTitle action:@selector(diffWithHEAD:) enabled:!isHead]];
		[items addObject:[PBRefMenuItem separatorItem]];
	}
	
	for (PBRefMenuItem *item in items) {
		item.target = target;
		item.refishs = commits;
	}

	return items;
}


@end
