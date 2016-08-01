//
//  APItemCell.m
//  ApplePayDemo
//
//  Created by Rohit Wankhede on 27/07/16.
//  Copyright © 2016 Rohit Wankhede. All rights reserved.
//

#import "APItemCell.h"

@implementation APItemCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)configureCell:(APItem*)item {
  
  self.itemName.text = item.itemName;
  self.itemImage.image = [UIImage imageNamed:item.itemImage];
  self.itemPrice.text = [NSString stringWithFormat:@"$%@",item.itemPrice];
  
}

@end
