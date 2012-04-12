//
//  JSItem.h
//  CocoaJSONEditorLocalConnection
//
//  Created by Jan Kubny on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSItem : NSObject

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detailText;

@end
