//
//  AlfrescoDocument+CSSearchableAttributes.h
//  AlfrescoApp
//
//  Created by Fabian Mistoiu on 09/01/2018.
//  Copyright © 2018 Alfresco. All rights reserved.
//
#import <CoreSpotlight/CoreSpotlight.h>

@interface AlfrescoDocument (CSSearchableAttributes)

- (CSSearchableItemAttributeSet *)itemAttributeSet;

@end
