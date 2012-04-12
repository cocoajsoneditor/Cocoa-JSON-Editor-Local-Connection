//
//  ViewController.m
//  CocoaJSONEditorLocalConnection
//
//  Created by Jan Kubny on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSGetResponseByIdVC.h"
#import "ASIHTTPRequest.h"
#import "ASIHTTPRequest+CocoaJSONEditorConnection.h"

#define LOCAL 1
#define USING_BLOCKS 1

@interface JSGetResponseByIdVC ()
- (void) visualizeJSON:(NSString *)jsonString;
@end

@implementation JSGetResponseByIdVC
@synthesize responseTextView;
@synthesize connectionIdTextField;
@synthesize fetchButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Fetch By ID";
    [connectionIdTextField becomeFirstResponder];

    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setFetchButton:nil];
    [self setConnectionIdTextField:nil];
    [self setResponseTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (IBAction) request:(id)sender
{
    NSString *urlString = @"http://www.panoramio.com/map/get_panoramas.php?set=public&from=0&to=20&minx=-180&miny=-90&maxx=180&maxy=90&size=medium&mapfilter=true";
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
   
    if (USING_BLOCKS)
    {
        [request setCompletionBlock:^{
            [self visualizeJSON:request.responseString];
         }];
        
        [request setFailedBlock:^{
            NSLog(@"FAILED");
        }];
    }
    else
    {
        [request setDelegate:self];
    }    
    
    if (LOCAL) 
    {
        [request startAsynchronousWithCocoaJSONEditor:connectionIdTextField.text];
    }
    else
    {
        [request startAsynchronous];
    }       
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    [self visualizeJSON:request.responseString];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    //NSError *error = [request error];
}



- (void) visualizeJSON:(NSString *)jsonString
{
    responseTextView.text = jsonString;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc {
    [fetchButton release];
    [connectionIdTextField release];
    [responseTextView release];
    [super dealloc];
}
@end
