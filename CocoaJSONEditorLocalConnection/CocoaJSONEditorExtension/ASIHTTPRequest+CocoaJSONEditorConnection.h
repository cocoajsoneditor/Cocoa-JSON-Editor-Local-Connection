//
//  ASIHTTPRequest+CocoaJSONEditorConnection.h
//  CocoaJSONEditorLocalConnection
//
//  Created by Jan Kubny on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ASIHTTPRequest.h"

@interface ASIHTTPRequest (CocoaJSONEditorConnection)
#ifdef DEBUG
+ (void) startClient;
+ (void) stopClient;

- (void) startAsynchronousWithCocoaJSONEditor:(NSString *)localConnectionID;
#endif
@end
