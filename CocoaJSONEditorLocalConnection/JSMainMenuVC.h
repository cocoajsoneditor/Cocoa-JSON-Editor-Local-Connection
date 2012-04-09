//
//  JSMainMenuVC.h
//  CocoaJSONEditorLocalConnection
//
//  Created by Jan Kubny on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JSMainMenuVC : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@end
