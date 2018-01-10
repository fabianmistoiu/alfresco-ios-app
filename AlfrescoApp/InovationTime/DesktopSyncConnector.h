//
//  DesktopSyncConnector.h
//  AlfrescoApp
//
//  Created by Fabian Mistoiu on 10/01/2018.
//  Copyright © 2018 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DesktopSyncConnector : NSObject

+ (instancetype)sharedConnector;

- (void)syncFolderToDesktop:(AlfrescoFolder *)folder session:(id<AlfrescoSession>)session;

@end
