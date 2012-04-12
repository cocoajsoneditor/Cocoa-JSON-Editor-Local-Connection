//
//  JSDataExampleCell.m
//  CocoaJSONEditorLocalConnection
//
//  Created by Jan Kubny on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSDataExampleCell.h"

@interface JSDataExampleCell ()
@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, assign) BOOL *isLoading;

- (void) loadImage:(NSURL *)url;
@end

@implementation JSDataExampleCell
@synthesize imageView;
@synthesize titleLabel;
@synthesize detailLabel;
@synthesize imageURL;
@synthesize isLoading;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [imageView release];
    [imageURL release];
    [titleLabel release];
    [detailLabel release];
    [super dealloc];
}

- (void) loadImage:(NSURL *)url
{
    // This is just a example ...
    
    if (self.imageURL == url)
    {
        return;
    }
    
    self.imageURL = url;
    self.imageView.image = nil;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue,^{   
        
        // Background Thread...
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        
        dispatch_sync(dispatch_get_main_queue(), ^ {
           
            // Back To Main Thread...
            self.imageView.image = image;            
        });
        
    });  

}


@end
