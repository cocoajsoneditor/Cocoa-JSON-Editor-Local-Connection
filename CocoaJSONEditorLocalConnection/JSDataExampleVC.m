//
//  JSDataExample.m
//  CocoaJSONEditorLocalConnection
//
//  Created by Jan Kubny on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSDataExampleVC.h"
#import "ASIHTTPRequest.h"
#import "ASIHTTPRequest+CocoaJSONEditorConnection.h"

#import "JSItem.h"
#import "JSDataExampleCell.h"

#define LOCALREQUEST 1
#define localRequestID @"MyAPI_getList"

@interface JSDataExampleVC ()

-(void) processResponse:(NSData *)response;

@property (nonatomic, retain) NSArray *results;


@end

@implementation JSDataExampleVC
@synthesize tableView;

@synthesize results;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.results = [NSArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)] autorelease];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc 
{
    [tableView release];
    [results release];
    [super dealloc];
}


#pragma mark -
#pragma mark UITableViewDelegate, UITableViewDataSource
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.results count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSItem *item = [self.results objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"JSDataExampleCell";
    JSDataExampleCell *cell = (JSDataExampleCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = (JSDataExampleCell *)[[[NSBundle mainBundle] loadNibNamed:@"JSDataExampleCell" owner:nil options:nil] objectAtIndex:0];
    }
    
    // Configure the cell...
    [cell.titleLabel setText:item.title];
    [cell.detailLabel setText:item.detailText];
    [cell loadImage:[NSURL URLWithString:item.urlString]];           
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
}

#pragma mark -
#pragma mark Request (Quickly Processing)
#pragma mark -

- (IBAction) refresh:(id)sender
{
    NSString *urlString = @"http://www.cocoajsoneditor.com/api/getList.php";
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [request setCompletionBlock:^{
        [self processResponse:request.responseData];
    }];
    
    [request setFailedBlock:^{
        NSLog(@"FAILED");
    }];
    
    if (LOCALREQUEST) 
    {
        [request startAsynchronousWithCocoaJSONEditor:localRequestID];
    }
    else
    {
        [request startAsynchronous];
    }       
}

- (void) processResponse:(NSData *)response
{
    NSError *parsingError = nil;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:&parsingError];
    if (parsingError) {
        NSLog(@"%@",[parsingError localizedDescription]);
    }    
    
    NSArray *itemsArray = [responseDic objectForKey:@"items"];
    
    NSMutableArray *newResponseArray = [NSMutableArray array];
    
    for (NSDictionary *itemDic in itemsArray)
    {
        JSItem *item = [[JSItem alloc] init];
        item.urlString = [itemDic objectForKey:@"url"];
        item.title = [itemDic objectForKey:@"titleText"];
        item.detailText = [itemDic objectForKey:@"detailText"];
        
        [newResponseArray addObject:item]; 
        [item release];
    }
    
    self.results = [NSArray arrayWithArray:newResponseArray]; 
    [self.tableView reloadData];
}

@end
