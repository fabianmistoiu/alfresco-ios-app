//
//  AlfrescoDocument+CSSearchableAttributes.m
//  AlfrescoApp
//
//  Created by Fabian Mistoiu on 09/01/2018.
//  Copyright © 2018 Alfresco. All rights reserved.
//

#import "AlfrescoDocument+CSSearchableAttributes.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation AlfrescoDocument(CSSearchableAttributes)


- (CSSearchableItemAttributeSet *)itemAttributeSet {
	CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(__bridge NSString *) kUTTypeData];
	attributeSet.title = self.name;
	attributeSet.contentDescription = self.summary;
	attributeSet.creator = self.createdBy;
	attributeSet.contentCreationDate = self.createdAt;
	attributeSet.contentModificationDate = self.modifiedAt;
	return attributeSet;
	
}


@end
