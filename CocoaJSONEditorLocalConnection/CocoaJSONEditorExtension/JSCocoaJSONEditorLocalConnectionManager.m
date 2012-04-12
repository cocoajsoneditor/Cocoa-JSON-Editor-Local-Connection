//
//  JSCocoaJSONEditorLocalConnectionManager.m
//  CocoaJSONEditorLocalConnection
//
//  Created by Jan Kubny on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSCocoaJSONEditorLocalConnectionManager.h"

// UserInfor Transferred Dictionary TimeStamp Key
#define kCocoaJSONEditorUserInfoTimeStampKey @"localConnectionTimestamp"
#define kCocoaJSONEditorUserInfoCacheKey @"localConnectionCache"

#define kLocalConnectionManagerDelegateKey @"delegate"
#define kLocalConnectionManagerRequestIdKey @"requestId"
#define kLocalConnectionManagerUserInfoKey @"userInfo"


@interface JSCocoaJSONEditorLocalConnectionManager ()
- (void) temporarySavedResponseOrFail:(NSString *)requestId;
- (void) sendRequestWithDictionaryToCocoaJSONEditor:(NSDictionary *)requestDictionary;

- (void) cacheResponse:(NSString *)jsonString andRequestId:(NSString *)requestId;
- (NSString *) cachedResponseForId:(NSString *)requestId;

@end

@implementation JSCocoaJSONEditorLocalConnectionManager

static JSCocoaJSONEditorLocalConnectionManager *sharedInstance = nil;

#pragma mark -
#pragma mark SINGLETON
#pragma mark -

+ (JSCocoaJSONEditorLocalConnectionManager *)sharedInstance
{
    if (!sharedInstance) 
    {
        sharedInstance = [[JSCocoaJSONEditorLocalConnectionManager alloc] init];
    }
    
    return sharedInstance;
}

#pragma mark -
#pragma mark MEMORY MANAGEMENT
#pragma mark -

- (void)dealloc
{
    [runningRequests release];
    [scheduledRequests release];
    [super dealloc];
}

#pragma mark -
#pragma mark INIT
#pragma mark -

- (id)init
{
    self = [super init];
    if (self) 
    {
        
    }
    return self;
}

#pragma mark -
#pragma mark START CLIENT
#pragma mark -


-(IBAction) toggleClient:(id)sender 
{
    if (!clientStub) {
        clientStub = [[ThoMoClientStub alloc] initWithProtocolIdentifier:kCOCOA_JSON_EDITOR_PROTOCOL_ID];
        [clientStub setDelegate:self];
        [clientStub start];
    }
    else
    {
        [clientStub stop];
        [clientStub setDelegate:nil];
        [clientStub release];
        clientStub = nil;
    }    
}

#pragma mark -
#pragma mark REQUEST QUEUE
#pragma mark -


- (void) requestResponseForID:(NSString *)theID 
                     delegate:(NSObject *)delegate
                     userInfo:(NSMutableDictionary *)userInfo
                cacheResponse:(BOOL)cacheResponse
              timeOutInterval:(NSTimeInterval)timeOut
{
    BOOL isValidPayload = YES;
    
    if (!theID || ![theID isKindOfClass:[NSString class]]) {
        isValidPayload = NO;
    }

    if (!delegate || ![delegate isKindOfClass:[NSObject class]]) {
        isValidPayload = NO;
    }
        
    if (!isValidPayload)
    {
        LocalConnectionManagerLog(@"LocalConnectionManagerLog: INVALID PAYLOAD");
        return;    
    }
    
    
    if (!clientStub) {
        [self toggleClient:nil];
    }
    if (!delegates) {
        delegates = [[NSMutableDictionary alloc] init];
    }
    
    if (!runningRequests) {
        runningRequests = [[NSMutableSet alloc] initWithCapacity:kMAXIMUM_CONCURRENT_REQUESTS];
    }
    
    // SCHEDULE REQUEST
    if ([runningRequests count] == kMAXIMUM_CONCURRENT_REQUESTS )
    {
        if (!scheduledRequests) {
            scheduledRequests = [[NSMutableSet alloc] init];
        }
        
        NSDate *timeStampDate = [NSDate date];
        NSNumber *timeStamp = [NSNumber numberWithLongLong:[timeStampDate timeIntervalSince1970]];  
        
        NSMutableDictionary *userInfoDictionary = nil;
        
        if (userInfo)
        {
            userInfoDictionary = userInfo;
        }
        else
        {
            userInfoDictionary = [NSMutableDictionary dictionary];                   
        }
        
        [userInfoDictionary setObject:timeStamp forKey:kCocoaJSONEditorUserInfoTimeStampKey];  
        if (cacheResponse) {
            [userInfoDictionary setObject:[NSNumber numberWithBool:YES] forKey:kCocoaJSONEditorUserInfoCacheKey];
        }

        
        
        NSDictionary *requestRefference = [NSDictionary dictionaryWithObjectsAndKeys:
                                           delegate,kLocalConnectionManagerDelegateKey,
                                           theID,kLocalConnectionManagerRequestIdKey,
                                           userInfoDictionary,kLocalConnectionManagerUserInfoKey,nil];        
        
        [delegates setObject:requestRefference forKey:timeStamp];
        [scheduledRequests addObject:timeStamp];        
    }
    else // RUN REQUEST
    {
        NSDate *timeStampDate = [NSDate date];
        NSNumber *timeStamp = [NSNumber numberWithLongLong:[timeStampDate timeIntervalSince1970]];  
        
        NSMutableDictionary *userInfoDictionary = nil;
        
        if (userInfo)
        {
            userInfoDictionary = userInfo;
        }
        else
        {
            userInfoDictionary = [NSMutableDictionary dictionary];                   
        }
        
        [userInfoDictionary setObject:timeStamp forKey:kCocoaJSONEditorUserInfoTimeStampKey];  
        if (cacheResponse) {
            [userInfoDictionary setObject:[NSNumber numberWithBool:YES] forKey:kCocoaJSONEditorUserInfoCacheKey];
        }
        
        
        NSDictionary *requestRefference = [NSDictionary dictionaryWithObjectsAndKeys:
                                           delegate,kLocalConnectionManagerDelegateKey,
                                           theID,kLocalConnectionManagerRequestIdKey,
                                           userInfoDictionary,kLocalConnectionManagerUserInfoKey,nil];        
        
        [delegates setObject:requestRefference forKey:timeStamp];
        [runningRequests addObject:timeStamp];
        
        NSDictionary *requestDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           theID,kCOCOA_JSON_EDITOR_REQUESTID_KEY,
                                           userInfoDictionary,kCOCOA_JSON_EDITOR_USER_INFO,nil];
        
        [NSTimer scheduledTimerWithTimeInterval:timeOut target:self selector:@selector(temporarySavedResponseOrFail:)  userInfo:timeStamp repeats:NO];
        
        [self sendRequestWithDictionaryToCocoaJSONEditor:requestDictionary];        
    }    
}

- (void) sendRequestWithDictionaryToCocoaJSONEditor:(NSDictionary *)requestDictionary
{
    [clientStub sendToAllServers:requestDictionary]; 
}

#pragma mark -
#pragma mark RESPONSE HANDLING
#pragma mark -


- (void) temporarySavedResponseOrFail:(NSTimer *)theTimer
{
    NSNumber *timeStamp = [theTimer userInfo];
    
    if (![runningRequests containsObject:timeStamp]) {
        return;
    }
    
    NSDictionary *requestLocalDictionary = [delegates objectForKey:timeStamp];    
    NSObject *delegate = [requestLocalDictionary objectForKey:kLocalConnectionManagerDelegateKey];
    NSString *originalRequestId = [requestLocalDictionary objectForKey:kLocalConnectionManagerRequestIdKey];    
    
    // GET SAVED TEMPORARY RESPONSE AND SUCCESS
    
    NSString *responseString = [self cachedResponseForId:originalRequestId];
    if (responseString) {
        if([delegate respondsToSelector:@selector(localConnectionManagerDidReceivedResponse:forRequestId:)])
        {
            [(NSObject <JSCocoaJSONEditorLocalConnectionManagerDelegate>*)delegate localConnectionManagerDidReceivedResponse:responseString forRequestId:originalRequestId];
        }
        
        // Cleaning
        [runningRequests removeObject:timeStamp];
        [delegates removeObjectForKey:timeStamp];
        
        return;

    }
    
    if([delegate respondsToSelector:@selector(localConnectionManagerDidFailedForRequestId:)])
    {
        [(NSObject <JSCocoaJSONEditorLocalConnectionManagerDelegate>*)delegate localConnectionManagerDidFailedForRequestId:originalRequestId];
    }
    
    // Cleaning
    [runningRequests removeObject:timeStamp];
    [delegates removeObjectForKey:timeStamp];    
}

-(void) handleResponseFromCocoaJSONEditor:(NSDictionary *)responseDictionary
{
    // Transferred Dictionary
    NSString *originalRequestId = [responseDictionary objectForKey:kCOCOA_JSON_EDITOR_REQUESTID_KEY];
    NSString *response = [responseDictionary objectForKey:KCOCOA_JSON_EDITOR_RESPONSE_KEY];
    NSMutableDictionary *userInfo = [responseDictionary objectForKey:kCOCOA_JSON_EDITOR_USER_INFO];
    
    NSNumber *timeStamp = [userInfo objectForKey:kCocoaJSONEditorUserInfoTimeStampKey];    
    BOOL cacheResponse = [[userInfo objectForKey:kCocoaJSONEditorUserInfoCacheKey] boolValue];
    
    // SAVE RESPONSE TO TEMPORARY FOLDER
    if (cacheResponse) {
        [self cacheResponse:response andRequestId:originalRequestId];
    }
       
    // Getting the timestamp from the transferred object to identify our delegate.
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(temporarySavedResponseOrFail:) object:timeStamp];
    
    NSDictionary *requestLocalDictionary = [delegates objectForKey:timeStamp];
    
    NSObject *delegate = [requestLocalDictionary objectForKey:kLocalConnectionManagerDelegateKey]; 
    if([delegate respondsToSelector:@selector(localConnectionManagerDidReceivedResponse:forRequestId:)])
    {
        [(NSObject <JSCocoaJSONEditorLocalConnectionManagerDelegate>*)delegate localConnectionManagerDidReceivedResponse:response forRequestId:originalRequestId];
    }
        
    // Cleaning
    
    [runningRequests removeObject:timeStamp];
    [delegates removeObjectForKey:timeStamp];
}

#pragma mark -
#pragma mark ThoMoClientDelegateProtocol
#pragma mark -

-(void)client:(ThoMoClientStub *)theClient didReceiveData:(id)theData fromServer:(NSString *)aServerIdString;
{
    NSDictionary *responseFromCocoaJSONEditor = (NSDictionary *)theData;
    if ([responseFromCocoaJSONEditor isKindOfClass:[NSDictionary class]])
    {
        [self handleResponseFromCocoaJSONEditor:responseFromCocoaJSONEditor];
    }   
}
- (void)client:(ThoMoClientStub *)theClient didConnectToServer:(NSString *)aServerIdString
{
    LocalConnectionManagerLog(@"%@",aServerIdString);
}
- (void)client:(ThoMoClientStub *)theClient didDisconnectFromServer:(NSString *)aServerIdString errorMessage:(NSString *)errorMessage
{
    LocalConnectionManagerLog(@"%@",aServerIdString);
}
- (void)netServiceProblemEncountered:(NSString *)errorMessage onClient:(ThoMoClientStub *)theClient
{
    LocalConnectionManagerLog(@"%@",errorMessage);
}
- (void)clientDidShutDown:(ThoMoClientStub *)theClient
{
    LocalConnectionManagerLog(@"%@",[theClient description]);
}

#pragma mark -
#pragma mark CACHE RESPONSES
#pragma mark -

- (void) cacheResponse:(NSString *)jsonString andRequestId:(NSString *)requestId
{
    NSString *tempDirectoryPath = NSTemporaryDirectory();
    NSString *folderName = @"/JSCocoaJSONEditorCache/";
    
    
    NSString *tempFolder = [tempDirectoryPath stringByAppendingPathComponent:folderName];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    BOOL isDirectory;
    BOOL success = YES;
    
    if (![fm fileExistsAtPath:tempFolder isDirectory:&isDirectory])
    {
         success = [fm createDirectoryAtPath:tempFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (success)
    {
        NSString *fileName = [NSString stringWithFormat:@"%@.json",requestId];
        NSString *filePath = [tempFolder stringByAppendingPathComponent:fileName];
        
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        if (data)
        {
           [data writeToFile:filePath atomically:YES];
        }

    }    
}

- (NSString *) cachedResponseForId:(NSString *)requestId
{
    NSString *tempDirectoryPath = NSTemporaryDirectory();
    NSString *folderName = @"/JSCocoaJSONEditorCache/";
    
    
    NSString *tempFolder = [tempDirectoryPath stringByAppendingPathComponent:folderName];
    
    NSString *fileName = [NSString stringWithFormat:@"%@.json",requestId];
    NSString *filePath = [tempFolder stringByAppendingPathComponent:fileName];

    
    NSString *string = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    if (string) {
        return string;
    }
    
    return nil;

}

- (void) cleanCachedResponses
{
    NSFileManager *fm = [NSFileManager defaultManager];    
    NSString *tempDirectoryPath = NSTemporaryDirectory();
    NSString *folderName = @"/JSCocoaJSONEditorCache/";
    
    
    NSString *tempFolder = [tempDirectoryPath stringByAppendingPathComponent:folderName];
    NSError *error = nil;
    
    [fm removeItemAtPath:tempFolder error:&error];
    if (error)
    {
        LocalConnectionManagerLog(@"%@",[error localizedDescription]);
    }
}

@end
