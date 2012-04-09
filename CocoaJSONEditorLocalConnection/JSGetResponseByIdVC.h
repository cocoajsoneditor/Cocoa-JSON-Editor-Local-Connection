//
//  ViewController.h
//  CocoaJSONEditorLocalConnection
//
//  Created by Jan Kubny on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JSGetResponseByIdVC : UIViewController

@property (retain, nonatomic) IBOutlet UITextView *responseTextView;
@property (retain, nonatomic) IBOutlet UITextField *connectionIdTextField;
@property (retain, nonatomic) IBOutlet UIButton *fetchButton;

- (IBAction) request:(id)sender;
@end
