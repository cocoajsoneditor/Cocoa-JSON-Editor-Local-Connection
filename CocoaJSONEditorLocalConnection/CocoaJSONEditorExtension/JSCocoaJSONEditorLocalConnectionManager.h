//
//  JSCocoaJSONEditorLocalConnectionManager.h
//  CocoaJSONEditorLocalConnection
//
//  Created by Jan Kubny on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <ThoMoNetworking/ThoMoNetworking.h>

#pragma mark -
#pragma mark Logging
#pragma mark -

//LocalConnectionManagerLog

#define LocalConnectionManagerLog_Enabled

#ifdef LocalConnectionManagerLog_Enabled
#define LocalConnectionManagerLog(s, ...)				NSLog(s, ## __VA_ARGS__)
#else
#define LocalConnectionManagerLog(s, ...)
#endif


#pragma mark -
#pragma mark Exchange Dictionary and Server Protocol
#pragma mark -


// ThoMoNetworking protocol id. Cocoa JSON Editor uses fixed ID
#define kCOCOA_JSON_EDITOR_PROTOCOL_ID @"jsoneditor"

// ThoMoNetworking exchange dictionary. Cocoa JSON Editor will send back to clients an 
// NSDictionary with 2 object keys. Original Request ID that the client send, and the respective response from 
// Cocoa JSON Editor.

// NSString
#define kCOCOA_JSON_EDITOR_REQUESTID_KEY @"requestId"
// id
#define KCOCOA_JSON_EDITOR_RESPONSE_KEY @"response"
// User Info
#define kCOCOA_JSON_EDITOR_USER_INFO @"userInfo"

#define kMAXIMUM_CONCURRENT_REQUESTS 4
#define kFAILING_THRESHOLD_SECONDS 4.0


#pragma mark -
#pragma mark ConnectionManagerProtocol
#pragma mark -


@protocol JSCocoaJSONEditorLocalConnectionManagerDelegate <NSObject>

-(void) localConnectionManagerDidReceivedResponse:(id)response forRequestId:(NSString *)requestId;
-(void) localConnectionManagerDidFailedForRequestId:(NSString *)requestId;

@end

#pragma mark -
#pragma mark Interface
#pragma mark -


@interface JSCocoaJSONEditorLocalConnectionManager : NSObject <ThoMoClientDelegateProtocol>
{
    ThoMoClientStub	*clientStub;
    
    NSMutableSet *runningRequests;
    NSMutableSet *scheduledRequests;
    NSMutableDictionary *delegates;
}

+ (JSCocoaJSONEditorLocalConnectionManager *)sharedInstance;


- (IBAction) toggleClient:(id)sender;
- (void) requestResponseForID:(NSString *)theID 
                     delegate:(NSObject *)delegate
                     userInfo:(NSMutableDictionary *)userInfo
                cacheResponse:(BOOL)cacheResponse
              timeOutInterval:(NSTimeInterval)timeOut;

- (void) cleanCachedResponses;

@end
