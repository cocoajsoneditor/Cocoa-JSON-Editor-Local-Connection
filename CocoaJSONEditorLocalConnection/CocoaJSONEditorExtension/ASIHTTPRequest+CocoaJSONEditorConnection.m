//
//  ASIHTTPRequest+CocoaJSONEditorConnection.m
//  CocoaJSONEditorLocalConnection
//
//  Created by Jan Kubny on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ASIHTTPRequest+CocoaJSONEditorConnection.h"
#import "JSCocoaJSONEditorLocalConnectionManager.h"

@implementation ASIHTTPRequest (CocoaJSONEditorConnection)
+ (void) startClient
{
    [[JSCocoaJSONEditorLocalConnectionManager sharedInstance] toggleClient:nil];
}
+ (void) stopClient
{
    [[JSCocoaJSONEditorLocalConnectionManager sharedInstance] toggleClient:nil];
}
- (void) startAsynchronousWithCocoaJSONEditor:(NSString *)localConnectionID 
{
    [[JSCocoaJSONEditorLocalConnectionManager sharedInstance] requestResponseForID:localConnectionID delegate:self userInfo:nil cacheResponse:YES timeOutInterval:3];
}

-(void) localConnectionManagerDidReceivedResponse:(id)response forRequestId:(NSString *)requestId
{
    if ([response isKindOfClass:[NSString class]])
    {
        NSMutableData *data = [[NSMutableData alloc] initWithData:[(NSString *)response dataUsingEncoding:NSUTF8StringEncoding]];
        self.rawResponseData = data;
        [data release];
    }
    
    [self requestFinished];    
}
-(void) localConnectionManagerDidFailedForRequestId:(NSString *)requestId
{
    //[self reportFailure];
    if (delegate && [delegate respondsToSelector:didFailSelector]) {
		[delegate performSelector:didFailSelector withObject:self];
	}
    
#if NS_BLOCKS_AVAILABLE
    if(failureBlock){
        failureBlock();
    }
#endif
    
	if (queue && [queue respondsToSelector:@selector(requestFailed:)]) {
		[queue performSelector:@selector(requestFailed:) withObject:self];
	}
}

@end
