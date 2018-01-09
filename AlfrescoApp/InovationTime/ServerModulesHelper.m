//
//  ServerModulesHelper.m
//  AlfrescoApp
//
//  Created by Fabian Mistoiu on 09/01/2018.
//  Copyright © 2018 Alfresco. All rights reserved.
//

#import "ServerModulesHelper.h"

@interface ServerModulesHelper ()

@property(nonatomic) BOOL isRMInstalled;

@end

@implementation ServerModulesHelper

+ (instancetype)sharedHelper {
	static ServerModulesHelper *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[ServerModulesHelper alloc] init];
	});
	return instance;
}


- (instancetype)init {
	self = [super init];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionRefreshed:) name:kAlfrescoSessionRefreshedNotification object:nil];
	}
	return self;
}

- (void) setSession:(id<AlfrescoSession>)session {
	_isRMInstalled = false;
	
	NSString *requestString = @"/api/discovery";
	NSURL *url = [NSURL URLWithString:[[session.baseUrl absoluteString] stringByAppendingPathComponent:requestString]];
	
	AlfrescoRequest *request = [[AlfrescoRequest alloc] init];
	[session.networkProvider executeRequestWithURL:url
												session:session
											requestBody:nil
												 method:@"GET"
										alfrescoRequest:request
										completionBlock:^(NSData *data, NSError *error) {
											NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
											NSDictionary *jsonObject=[NSJSONSerialization
																	  JSONObjectWithData:data
																	  options:NSJSONReadingMutableLeaves
																	  error:nil];
											
											NSArray *modules = jsonObject[@"entry"][@"repository"][@"modules"];
											for (NSDictionary *module in modules) {
												if ([module[@"id"] isEqualToString:@"org_alfresco_module_rm"]) {
													_isRMInstalled = true;
													break;
												}
											}
										}];
}


- (void)sessionRefreshed:(NSNotification *)notification
{
	[self setSession:notification.object];
}


@end
