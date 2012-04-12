//
//  JSDataExampleCell.h
//  CocoaJSONEditorLocalConnection
//
//  Created by Jan Kubny on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JSDataExampleCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *detailLabel;

- (void) loadImage:(NSURL *)url;

@end
