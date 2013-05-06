//
//  SideMenuTableViewCell.h
//  Sweep
//
//  Created by Thomas DeMeo on 5/6/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenuTableViewCell : UITableViewCell

@property(nonatomic, strong) IBOutlet UILabel *nameLabel;
@property(nonatomic, strong) IBOutlet UITextField *nameTextField;

//@property(nonatomic, strong) IBOutlet UILabel *dateLabel;
//@property(nonatomic, strong) IBOutlet UILabel *priceLabel;

@end
