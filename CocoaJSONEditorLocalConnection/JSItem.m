//
//  JSItem.m
//  CocoaJSONEditorLocalConnection
//
//  Created by Jan Kubny on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSItem.h"

@implementation JSItem

@synthesize urlString;
@synthesize title;
@synthesize detailText;

- (void)dealloc
{
    self.urlString = nil;
    self.title = nil;
    self.detailText = nil;
    
    [super dealloc];
}

@end
