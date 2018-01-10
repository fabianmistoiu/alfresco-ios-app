//
//  SpotlightHelper.h
//  AlfrescoApp
//
//  Created by Fabian Mistoiu on 09/01/2018.
//  Copyright © 2018 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpotlightHelper : NSObject

+ (instancetype)sharedHelper;

- (void)removeItemsForAccount:(UserAccount *)account;

- (void)indexFavoritesWithSession:(id<AlfrescoSession>) session;

@end
