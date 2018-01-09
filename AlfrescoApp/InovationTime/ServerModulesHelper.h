//
//  ServerModulesHelper.h
//  AlfrescoApp
//
//  Created by Fabian Mistoiu on 09/01/2018.
//  Copyright © 2018 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerModulesHelper : NSObject

+ (instancetype)sharedHelper;

- (void) setSession:(id<AlfrescoSession>)session;

@property(nonatomic, readonly) BOOL isRMInstalled;

@end
