//
//  ViewController.m
//  ApplePayDemo
//
//  Created by Rohit Wankhede on 27/07/16.
//  Copyright © 2016 Rohit Wankhede. All rights reserved.
//

#import "ViewController.h"
#import "APItem.h"
#import "APItemCell.h"
#import "CheckOutViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;
@property (strong, nonatomic) NSMutableArray *arrayItems;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  id jsonData = [self getJsonFromFileName:@"items"];
  if(jsonData) {
    [self sortJSON:jsonData];
  }
  self.itemsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

/**
 *  This method used to read json file
 *
 *  @param fileName JSON file name
 *
 *  @return json id
 */
- (id)getJsonFromFileName:(NSString *)fileName {
  NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
  NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
  NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
  id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
  
  return json;
}

- (void)sortJSON:(id)json {
  
  self.arrayItems = nil;
  self.arrayItems = [NSMutableArray array];
  
  if([json isKindOfClass:[NSArray class]]) {
    
    for (NSDictionary *dictionary in json) {
      
      APItem *itemObj = [[APItem alloc]init];
      
      itemObj.itemName = [dictionary valueForKey:@"name"];
      itemObj.itemID = [[dictionary valueForKey:@"id"] integerValue];
      itemObj.itemPrice = [NSDecimalNumber decimalNumberWithString:[dictionary valueForKey:@"price"]];
      itemObj.itemImage = [dictionary valueForKey:@"image_name"];
      itemObj.itemDiscount = [NSDecimalNumber decimalNumberWithString:[dictionary valueForKey:@"discount"]];
      
      [self.arrayItems addObject:itemObj];
    }
  }
  
  [self.itemsTableView reloadData];
}

#pragma mark- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.arrayItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  APItemCell *cell = (APItemCell *)[tableView dequeueReusableCellWithIdentifier:@"APItemCell"];
  if (cell == nil) {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"APItemCell" owner:self options:nil];
    cell = [nib objectAtIndex:0];
  }
  
  APItem *itemObj = [self.arrayItems objectAtIndex:indexPath.row];
  [cell configureCell:itemObj];
  
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  if (indexPath.row % 2) {
    cell.backgroundColor = [UIColor lightGrayColor];
  } else {
    cell.itemPrice.textColor = [UIColor whiteColor];
    cell.itemName.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor purpleColor];
  }
  
  
  return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  APItem *itemObj = [self.arrayItems objectAtIndex:indexPath.row];
  CheckOutViewController *checkOut = [self.storyboard instantiateViewControllerWithIdentifier:@"CheckOutViewController"];
  checkOut.selectedItem = itemObj;
  [self.navigationController pushViewController:checkOut animated:YES];
}

@end
