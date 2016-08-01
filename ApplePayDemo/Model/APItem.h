//
//  Item.h
//  ApplePayDemo
//
//  Created by Rohit Wankhede on 27/07/16.
//  Copyright © 2016 Rohit Wankhede. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APItem : NSObject
@property (nonatomic, strong) NSString* itemName;
@property (nonatomic, assign) NSInteger itemID;
@property (nonatomic, strong) NSDecimalNumber* itemPrice;
@property (nonatomic, strong) NSString* itemImage;
@property (nonatomic, strong) NSDecimalNumber* itemDiscount;
@end
