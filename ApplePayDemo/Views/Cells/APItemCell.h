//
//  APItemCell.h
//  ApplePayDemo
//
//  Created by Rohit Wankhede on 27/07/16.
//  Copyright © 2016 Rohit Wankhede. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APItem.h"

@interface APItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *itemName;
@property (weak, nonatomic) IBOutlet UILabel *itemPrice;
@property (weak, nonatomic) IBOutlet UIImageView *itemImage;

- (void)configureCell:(APItem*)item;
@end
