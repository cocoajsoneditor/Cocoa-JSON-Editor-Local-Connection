//
//  JSMainMenuVC.m
//  CocoaJSONEditorLocalConnection
//
//  Created by Jan Kubny on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSMainMenuVC.h"
#import "JSGetResponseByIdVC.h"
#import "JSDataExampleVC.h"

@interface JSMainMenuVC ()

@end

@implementation JSMainMenuVC
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Main Menu";
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

- (void)dealloc {
    [tableView release];
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell autorelease];
    }
    
    // Configure the cell...
    
    NSString *cellTitle = nil;
    switch (indexPath.row) {
        case 0:
            cellTitle = @"Get Response By ID";
            break;
            
        case 1:
            cellTitle = @"Example 1";
            break;

        default:
            break;
    }
    
    cell.textLabel.text = cellTitle;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    switch (indexPath.row)
    {
        case 0:
        {
            JSGetResponseByIdVC *detailViewController = [[JSGetResponseByIdVC alloc] initWithNibName:@"JSGetResponseByIdVC" bundle:nil];
            // ...
            // Pass the selected object to the new view controller.
            [self.navigationController pushViewController:detailViewController animated:YES];
            [detailViewController release];
        }
            break;
            
        case 1:
        {
            JSDataExampleVC *detailViewController = [[JSDataExampleVC alloc] initWithNibName:@"JSDataExampleVC" bundle:nil];
            // ...
            // Pass the selected object to the new view controller.
            [self.navigationController pushViewController:detailViewController animated:YES];
            [detailViewController release];
        }
            break;

            
        default:
            break;
    }
    
}


@end
