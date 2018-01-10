//
//  SpotlightHelper.m
//  AlfrescoApp
//
//  Created by Fabian Mistoiu on 09/01/2018.
//  Copyright © 2018 Alfresco. All rights reserved.
//

#import "SpotlightHelper.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import "UserAccount.h"
#import "FavouriteManager.h"
#import "AccountManager.h"
#import "AlfrescoNode+Sync.h"
#import "AlfrescoDocument+CSSearchableAttributes.h"


@implementation SpotlightHelper

+ (instancetype)sharedHelper {
	static SpotlightHelper *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[SpotlightHelper alloc] init];
	});
	return instance;
}

- (void)removeItemsForAccount:(UserAccount *)account {
	NSLog(@"!!!  %@", account.accountIdentifier);
	
	[CSSearchableIndex.defaultSearchableIndex deleteSearchableItemsWithDomainIdentifiers:@[account.accountIdentifier] completionHandler:^(NSError * _Nullable error) {
		
	}];
}

- (void)indexFavoritesWithSession:(id<AlfrescoSession>) session {
	
	AlfrescoListingContext *listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:100];
	[[FavouriteManager sharedManager] topLevelFavoriteNodesWithSession:session
																filter:@"all"
														listingContext:listingContext
													   completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error)
	{
		if (!error) {
			NSMutableArray *items = [NSMutableArray new];
			UserAccount *account = [AccountManager sharedManager].selectedAccount;
			for (AlfrescoDocument *favDoc in pagingResult.objects){
				if ([favDoc isKindOfClass:[AlfrescoDocument class]]) {
				   CSSearchableItem *item = [[CSSearchableItem alloc] initWithUniqueIdentifier:favDoc.syncIdentifier
																			  domainIdentifier:account.accountIdentifier attributeSet:favDoc.itemAttributeSet];
					[items addObject:item];
				}
			}
			[CSSearchableIndex.defaultSearchableIndex indexSearchableItems:items completionHandler:^(NSError * _Nullable error) {
				
			}];
		}
	}];
}



@end

