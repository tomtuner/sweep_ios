//
//  ScansTableViewCell.h
//  sweep
//
//  Created by Thomas DeMeo on 6/11/14.
//  Copyright (c) 2014 Kanzu LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScansTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *checkmark;
@property (weak, nonatomic) IBOutlet UILabel *scanValue;

@end
