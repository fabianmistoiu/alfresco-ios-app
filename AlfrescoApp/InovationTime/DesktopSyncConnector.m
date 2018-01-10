//
//  DesktopSyncConnector.m
//  AlfrescoApp
//
//  Created by Fabian Mistoiu on 10/01/2018.
//  Copyright © 2018 Alfresco. All rights reserved.
//

#import "DesktopSyncConnector.h"
#import "CustomFolderService.h"


static NSString * const kJSONMimeType = @"application/json";
static NSString * const kSearchResultsIndexFileName = @"sync.json";

@interface DesktopSyncConnector ()

@property (nonatomic, strong) NSMutableArray 				*syncTargets;
@property (nonatomic, strong) NSMutableSet 					*syncTargetIDs;
@property (nonatomic, strong) id<AlfrescoSession>           session;
@property (nonatomic, strong) CustomFolderService           *customFolderService;
@property (nonatomic, strong) AlfrescoDocumentFolderService *documentService;

@end

@implementation DesktopSyncConnector

+ (instancetype)sharedConnector {
	static DesktopSyncConnector *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[DesktopSyncConnector alloc] init];
	});
	return instance;
}

- (void)syncFolderToDesktop:(AlfrescoFolder *)folder session:(id<AlfrescoSession>)session {
	_syncTargets = [NSMutableArray new];
	_syncTargetIDs = [NSMutableSet new];
	
	if (![_syncTargetIDs containsObject:folder.identifier]) {
		[_syncTargetIDs addObject:folder.identifier];
		[_syncTargets addObject:@{@"nodeid": folder.identifier,
								  @"title": folder.name
								  }];
	}
	
	self.session = session;
	[self saveSyncTargetsInMyFiles];
}


- (void)saveSyncTargetsInMyFiles
{
	self.customFolderService = [[CustomFolderService alloc] initWithSession:self.session];
	
	__weak typeof(self) weakSelf = self;
	[self.customFolderService retrieveMyFilesFolderWithCompletionBlock:^(AlfrescoFolder *folder, NSError *error) {
		if(folder)
		{
			__strong typeof(self) strongSelf = weakSelf;
			
			strongSelf.documentService = [[AlfrescoDocumentFolderService alloc] initWithSession:strongSelf.session];
			[strongSelf.documentService retrieveChildrenInFolder:folder completionBlock:^(NSArray *array, NSError *error) {
				if(!error)
				{
					AlfrescoDocument *searchIndexDoc = nil;
					for(AlfrescoNode *node in array)
					{
						if(([node.name isEqualToString:kSearchResultsIndexFileName]) && node.isDocument)
						{
							searchIndexDoc = (AlfrescoDocument *)node;
						}
					}
					
					if(searchIndexDoc)
					{
						// should update the index file
						[weakSelf.documentService retrieveContentOfDocument:searchIndexDoc completionBlock:^(AlfrescoContentFile *contentFile, NSError *error) {
							if(!error)
							{
								[weakSelf appendSearchIndexDataEntriesFromURL:contentFile.fileUrl];
								[weakSelf.documentService updateContentOfDocument:searchIndexDoc
																	  contentFile:[self contentFileFromTargets] completionBlock:^(AlfrescoDocument *document, NSError *error) {
									if(error)
									{
										AlfrescoLogError(@"Failed to upload search results index with error: %@", error);
									}
								} progressBlock:nil];
							}
						} progressBlock:nil];
					}
					else
					{
						[weakSelf.documentService createDocumentWithName:kSearchResultsIndexFileName
														  inParentFolder:folder
															 contentFile:[self contentFileFromTargets]
															  properties:nil
														 completionBlock:^(AlfrescoDocument *document, NSError *error) {
															 if(error)
															 {
																 AlfrescoLogError(@"Failed to upload search results index with error: %@", error);
															 }
														 } progressBlock:nil];
					}
				}
			}];
		}
	}];
}

- (void)appendSearchIndexDataEntriesFromURL:(NSURL *)fileURL
{
	if (fileURL)
	{
		NSString *jsonString = [[NSString alloc] initWithContentsOfURL:fileURL
															  encoding:NSUTF8StringEncoding
																 error:nil];
		NSDictionary *existingSearchIndexDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
																				options:NSJSONReadingMutableContainers
																				  error:nil];
		
		NSMutableArray *existingEntriesArr = existingSearchIndexDict[@"syncTargets"];
		
		
		[self appendTargets:existingEntriesArr];
	}
	else
	{
		AlfrescoLogError(@"Search index cannot be found");
	}
}

- (AlfrescoContentFile *)contentFileFromTargets
{
	NSError *error = nil;
	NSData *jsonData = [NSJSONSerialization
						dataWithJSONObject:@{@"syncTargets": _syncTargets }
						options:NSJSONWritingPrettyPrinted error:&error];
	AlfrescoContentFile *contentFile = [[AlfrescoContentFile alloc] initWithData:jsonData mimeType:kJSONMimeType];
	return contentFile;
}

- (void)appendTargets:(NSArray *)targets {
	for (NSDictionary *newTarget in targets) {
		if (![_syncTargetIDs containsObject:newTarget[@"nodeid"]]) {
			[_syncTargetIDs addObject:newTarget[@"nodeid"]];
			[_syncTargets addObject:newTarget];
		}
	}
}

- (NSString *)normalizedNodeIdentifierForIdentifierString:(NSString *)identifierString
{
	NSUInteger indexOfVersionSeparator = [identifierString rangeOfString:@";"].location;
	return [identifierString substringToIndex:indexOfVersionSeparator];
}


@end
