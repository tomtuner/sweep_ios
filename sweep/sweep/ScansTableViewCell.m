//
//  ScansTableViewCell.m
//  sweep
//
//  Created by Thomas DeMeo on 6/11/14.
//  Copyright (c) 2014 Kanzu LLC. All rights reserved.
//

#import "ScansTableViewCell.h"

@implementation ScansTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
