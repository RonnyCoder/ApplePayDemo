//
//  CheckOutViewController.m
//  ApplePayDemo
//
//  Created by Rohit Wankhede on 27/07/16.
//  Copyright © 2016 Rohit Wankhede. All rights reserved.
//

#import "CheckOutViewController.h"

//for Apple Pay
#import "Passkit/Passkit.h"
//for Apple Pay
static NSString * const kShippingMethodForTomorrow = @"Tomorrow";
static NSString * const kShippingMethodForToday       = @"Today";
static NSString * const kShippingMethodForSomeDay  = @"Some Day";

@interface CheckOutViewController () <PKPaymentAuthorizationViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *itemPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemDiscount;
@property (weak, nonatomic) IBOutlet UIButton *buttonBuy;
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;

@property (strong, nonatomic) PKPaymentSummaryItem *subTotal;
@property (strong, nonatomic) PKPaymentSummaryItem *total;
@property (strong, nonatomic) PKPaymentSummaryItem *discount;
@property (strong, nonatomic) PKPaymentSummaryItem *tax;
@property (strong, nonatomic) PKPaymentSummaryItem *shippingCost;
@property (nonatomic, copy) NSArray <PKPaymentSummaryItem *> *paymentSummaryItems;
@property (nonatomic, copy, nullable) NSArray<PKShippingMethod *> *shippingMethods;
@property (nonatomic, strong) PKContact *selectedContact;
@property (nonatomic, strong) PKShippingMethod *selectedShippingMethod;

@end

@implementation CheckOutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  UIButton *leftBarButton = [UIButton  buttonWithType:UIButtonTypeCustom];
  leftBarButton.frame = CGRectMake(0,0,40, 20);
  [leftBarButton setTitle:@"Back" forState:UIControlStateNormal];
  [leftBarButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [leftBarButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
  UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
  self.navigationItem.leftBarButtonItem = barButton;
  
  self.itemImageView.image = [UIImage imageNamed:self.selectedItem.itemImage];
  self.itemPriceLabel.text = [NSString stringWithFormat:@"$%@",self.selectedItem.itemPrice];
  
  self.itemDiscount.text = [NSString stringWithFormat:@"$%@",self.selectedItem.itemDiscount];
  
  if(self.selectedItem.itemDiscount<=[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithFloat:0.0] decimalValue]])
    self.itemDiscount.text = @"NA";
  
  self.title = self.selectedItem.itemName;
  
  
  /* To check whether Apple Pay is supported by this device’s hardware and parental controls, use the canMakePayments methodIf canMakePayments returns NO, the device does not support Apple Pay. Do not display the Apple Pay button. Instead, fall back to another method of payment. */
  if (![PKPaymentAuthorizationViewController canMakePayments]) {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@""
                                          message:@"Device is not supported for Apple Pay"
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"Ok"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                 NSLog(@"OK action");
                               }];
    
    [alertController addAction:okAction];
    
    //hide Apple Pay button
    [self.buttonBuy setHidden:YES];
  }
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)backButtonAction:(id)sender {
  [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)buyWithApplePay_action:(id)sender {
  
  //Prepare supported network array
  NSArray *arraySupportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkDiscover, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa];
  
  /*
   Before creating a payment request, determine whether the user will be able to make payments using a network that you support by calling the canMakePaymentsUsingNetworks: method of the PKPaymentAuthorizationViewController class. If returns NO means the device supports Apple Pay, but the user has not added a card for any of the requested networks. You can, optionally, display a payment setup button, prompting the user to set up his or her card. As soon as the user taps this button, initiate the process of setting up a new card
   */
  if ([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:arraySupportedNetworks]) {
    
    PKPaymentRequest *request = [PKPaymentRequest new];
    request.currencyCode = @"USD";
    request.countryCode = @"US";
    
    // The merchant ID you set in a payment request must match one of the merchant IDs in your app’s entitlement
    request.merchantIdentifier = @"merchant.com.example";
    
    /*Create an instance of PKShippingMethod for each available shipping method
     - Identifier  for developer to distinguish shipping methods 
     - Amount for shipping cost, this will get add in grand total
     - Details for some messages to show user respective to shipping method*/
    NSArray *shippingMethods = @[
                                 [self shippingMethodWithIdentifier:kShippingMethodForTomorrow detail:kShippingMethodForTomorrow amount:10.00 details:@"Deliver tomorrow"],
                                 [self shippingMethodWithIdentifier:kShippingMethodForToday detail:kShippingMethodForToday amount:15.f details:@"Delive today"],
                                 [self shippingMethodWithIdentifier:kShippingMethodForSomeDay detail:kShippingMethodForSomeDay amount:00.f details:@"Some day you will get it"]
                                 ];
    self.shippingMethods = shippingMethods;
  
    /*set ENUM shippingtype set as per your requirement , you can have PKShippingTypeShipping, PKShippingTypeDelivery, PKShippingTypeStorePickup, PKShippingTypeServicePickup*/
    
    request.shippingType = PKShippingTypeShipping;
    
    //Set shipping method to request
    request.shippingMethods = self.shippingMethods;
    
    /*Payment summary items, represented by the PKPaymentSummaryItem class, describe the different parts of the payment request to the user. Use a small number of summary items—typically the subtotal, any discount, the shipping, the tax, and the grand total.
     
     Each summary item has a label and an amount, as shown in Listing 3-2.
     The label is a user-readable description of what the item summarizes.
     The amount is the corresponding payment amount.
     All of the amounts in a payment request use the currency specified in the payment request. For a discount or a coupon, set the amount to a negative number.
     */
    PKPaymentSummaryItem *itemSummary = [self paymentSummaryItemWithLabel:self.selectedItem.itemName amount:self.selectedItem.itemPrice];
    
    self.subTotal = [self paymentSummaryItemWithLabel:@"Sub-Total" amount:self.selectedItem.itemPrice];
    
    NSDecimalNumber *discountValue = self.selectedItem.itemDiscount;
    self.discount = [self paymentSummaryItemWithLabel:@"Discount" amount:discountValue];
    
    NSDecimalNumber *tax = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithFloat:3.0] decimalValue]];
    self.tax = [self paymentSummaryItemWithLabel:@"Tax" amount:tax];
    
    //By default selected 0 index shippping method for user so setting shipping cost
    NSDecimalNumber *shippingValue = [self.shippingMethods objectAtIndex:0].amount;
    self.shippingCost = [self paymentSummaryItemWithLabel:@"Shipping Cost" amount:shippingValue];
    
    NSDecimalNumber *totalvalue = [NSDecimalNumber zero];
    totalvalue = [totalvalue decimalNumberByAdding:shippingValue];
    totalvalue = [totalvalue decimalNumberByAdding:self.subTotal.amount];
    totalvalue = [totalvalue decimalNumberBySubtracting:self.discount.amount];
    totalvalue = [totalvalue decimalNumberByAdding:self.tax.amount];
    
    self.total = [self paymentSummaryItemWithLabel:@"Total" amount:totalvalue];
    
    self.discount.amount = [self.discount.amount decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithFloat:-1.0] decimalValue]]];
    
    //created paymentSummaryItems instance, so later can set to request property paymentSummaryItems
    self.paymentSummaryItems = @[itemSummary,
                                 self.subTotal,
                                 self.discount,
                                 self.tax,
                                 self.shippingCost,
                                 self.total];
    
    //set request property paymentSummaryItems
    [request setPaymentSummaryItems:self.paymentSummaryItems];
    
    //Set supported Network
    request.supportedNetworks = arraySupportedNetworks;
    
    // Supports 3DS only
    request.merchantCapabilities = PKMerchantCapability3DS;
    
    // Supports both 3DS and EMV
    request.merchantCapabilities = PKMerchantCapability3DS | PKMerchantCapabilityEMV;

    // Set requiredBillingAddressFields and requiredShippingAddressFields as per your requirements.
    /*IMPORTANT: set these fileds proper, If you miss any, you will not able to get delegte method calls*/
    request.requiredBillingAddressFields = PKAddressFieldPostalAddress | PKAddressFieldPhone | PKAddressFieldEmail;
    
    request.requiredShippingAddressFields = PKAddressFieldPostalAddress | PKAddressFieldPhone | PKAddressFieldEmail;
    
    
    /* Apple Pay uses this information by default; however, the user can still choose other contact information as part of the payment authorization process.
     
    PKContact *contact = [[PKContact alloc] init];
    
    NSPersonNameComponents *name = [[NSPersonNameComponents alloc] init];
    name.givenName = @"John";
    name.familyName = @"Appleseed";
    
    contact.name = name;
    
    CNMutablePostalAddress *address = [[CNMutablePostalAddress alloc] init];
    address.street = @"1234 Laurel Street";
    address.city = @"Atlanta";
    address.state = @"GA";
    address.postalCode = @"30303";
    
    contact.postalAddress = address;
    
    request.shippingContact = contact;
     
     NOTE
     Address information can come from a wide range of sources in iOS. Always validate the information before you use it.
    */
    
    // Ready to send request
    PKPaymentAuthorizationViewController *authVC = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    authVC.delegate = self;
    [self presentViewController:authVC animated:YES completion:nil];
    
  } else {
    
    [self.buttonBuy setTitle:@"Setup Apple Pay" forState:UIControlStateNormal];
  }
}

#pragma mark - Useful methods
/**
 *  This method used to create PKPaymentSummaryItem
 *
 *  @param label  label
 *  @param amount amount
 *
 *  @return PKPaymentSummaryItem
 */
- (PKPaymentSummaryItem *)paymentSummaryItemWithLabel:(NSString *)label amount:(NSDecimalNumber *)amount
{
  return [PKPaymentSummaryItem summaryItemWithLabel:label amount:amount];
}

/**
 *  This method used to create PKShippingMethod
 *
 *  @param idenfifier idenfifier
 *  @param label      label
 *  @param amount     amount
 *  @param details    details
 *
 *  @return PKShippingMethod
 */
- (PKShippingMethod *)shippingMethodWithIdentifier:(NSString *)idenfifier detail:(NSString *)label amount:(CGFloat)amount details:(NSString*)details
{
  PKShippingMethod *shippingMethod = [PKShippingMethod new];
  shippingMethod.identifier = idenfifier;
  shippingMethod.detail = details;
  shippingMethod.amount = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithFloat:amount] decimalValue]];
  shippingMethod.label = label;
  
  return shippingMethod;
}

/**
 *  This method is used to calculate shipping cost. This method will get trigger when shipping method changes, also when Shipping Address/Contact information changes as may be there extra charges for shipping address.
 */
- (void)updateShippingCost {
  
  if (!self.selectedShippingMethod) {
    self.selectedShippingMethod = [self.shippingMethods objectAtIndex:0];
  }
  
  NSDecimalNumber *shippingValue = self.shippingCost.amount;
  NSDecimalNumber *totalvalue = self.total.amount;
  totalvalue = [totalvalue decimalNumberBySubtracting:shippingValue];
  totalvalue = [totalvalue decimalNumberByAdding:self.selectedShippingMethod.amount];
  
  PKPaymentSummaryItem *selectedItemPrice = nil;
  
  for (PKPaymentSummaryItem *item in self.paymentSummaryItems) {
    
    if ([item.label isEqualToString:@"Shipping Cost"]) {
      self.shippingCost.amount = self.selectedShippingMethod.amount;
    } else if ([item.label isEqualToString:@"Total"]) {
      self.total.amount = totalvalue;
    } else if ([item.label isEqualToString:self.selectedItem.itemName]) {
      selectedItemPrice = item;
    } else if ([item.label isEqualToString:@"Sub-Total"]) {
      self.subTotal.amount = item.amount;
    } else if ([item.label isEqualToString:@"Discount"]) {
      self.discount.amount = item.amount;
    } else if ([item.label isEqualToString:@"Tax"]) {
      self.tax.amount = item.amount;
    }
    
  }
  
  self.paymentSummaryItems = @[selectedItemPrice,
                               self.subTotal,
                               self.discount,
                               self.tax,
                               self.shippingCost,
                               self.total];
}

/**
 *  This method used to check which shipping methods are available for updated contact.
 *
 *  @param contact contact
 *
 *  @return return NSArray of shipping methods
 */
- (NSArray *)shippingMethodsForContact:(PKContact*)contact {
  
  return self.shippingMethods;
}

#pragma mark - PKPaymentAuthorizationViewControllerDelegate methods
/*
 When the user provides shipping information, the authorization view controller calls your delegate’s paymentAuthorizationViewController:didSelectShippingContact:completion: and paymentAuthorizationViewController:didSelectShippingMethod:completion: methods. Use these methods to update the payment request based on the new information.
 */

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didSelectShippingContact:(PKContact *)contact completion:(void (^)(PKPaymentAuthorizationStatus, NSArray<PKShippingMethod *> * _Nonnull, NSArray<PKPaymentSummaryItem *> * _Nonnull))completion
{
  // This is where you would update the shipping methods based on the user's address
  // pass an array into the (mandatory) completion block
  
  // You can also abort payment here if you can't ship to the user's address by changing PKPaymentAuthorizationStatus
  
  self.selectedContact = contact;
  
  [self updateShippingCost];
  
  NSArray *shippingMethods = [self shippingMethodsForContact:contact];
  
  completion(PKPaymentAuthorizationStatusSuccess, shippingMethods, self.paymentSummaryItems);
}

// Sent when the user has selected a new shipping method.  The delegate should determine
// shipping costs based on the shipping method and either the shipping address supplied in the original
// PKPaymentRequest or the address fragment provided by the last call to paymentAuthorizationViewController:
// didSelectShippingAddress:completion:.
//
// The delegate must invoke the completion block with an updated array of PKPaymentSummaryItem objects.
//
// The delegate will receive no further callbacks except paymentAuthorizationViewControllerDidFinish:
// until it has invoked the completion block.
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                   didSelectShippingMethod:(nonnull PKShippingMethod *)shippingMethod completion:(nonnull void (^)(PKPaymentAuthorizationStatus, NSArray<PKPaymentSummaryItem *> * _Nonnull))completion
{
  // This is where you update the line items & total to reflect the user's chosen shipping method
  
  self.selectedShippingMethod = shippingMethod;
  
  [self updateShippingCost];
  
  completion(PKPaymentAuthorizationStatusSuccess, self.paymentSummaryItems);
}


// Sent when the user has selected a new payment card.  Use this delegate callback if you need to
// update the summary items in response to the card type changing (for example, applying credit card surcharges)
//
// The delegate will receive no further callbacks except paymentAuthorizationViewControllerDidFinish:
// until it has invoked the completion block.
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                    didSelectPaymentMethod:(PKPaymentMethod *)paymentMethod
                                completion:(void (^)(NSArray<PKPaymentSummaryItem *> *summaryItems))completion NS_AVAILABLE_IOS(9_0) {
  
  
  completion(self.paymentSummaryItems);
  
}

/*When the user authorizes a payment request, the framework creates a payment token by coordinating with Apple’s server and the Secure Element. You send this payment token to your server in the paymentAuthorizationViewController:didAuthorizePayment:completion: delegate method, along with any other information you need to process the purchase—for example, the shipping address and a shopping cart identifier.*/
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion
{
//  NSError *error;
//  PKContact *addressMultiValue = payment.billingContact;
//  CNPostalAddress *addressMultiValue = payment.billingContact.postalAddress;
  
//  NSData *json = [NSJSONSerialization dataWithJSONObject:addressMultiValue options:NSJSONWritingPrettyPrinted error: &error];
  
  // ... Send payment token, shipping and billing address, and order information to your server ...
  
  PKPaymentAuthorizationStatus status;  // From your server
  completion(status);
}

/*After the framework displays the transaction’s status, the authorization view controller calls your delegate’s paymentAuthorizationViewControllerDidFinish: method. In your implementation, dismiss the authorization view controller and then display your own app-specific order-confirmation page.*/
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
  // This fires when I successfully complete billing/shipping info
  // Or when I hit Cancel
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end

/* If your app uses a web-based interface for purchasing goods and services, you must move the request from the web interface to native iOS code before processing an Apple Pay transaction. Bellow code shows the steps needed to process requests from a web view.
 
// Called when the web view tries to load "myShoppingApp:buyItem"
-(void)webView:(nonnull WKWebView *)webView
decidePolicyForNavigationAction:(nonnull WKNavigationAction *)navigationAction
decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler {

// Get the URL for the selected link.
NSURL *URL = navigationAction.request.URL;

// If the scheme and resource specifier match those defined by your app,
// handle the payment in native iOS code.
if ([URL.scheme isEqualToString:@"myShoppingApp"] &&
[URL.resourceSpecifier isEqualToString:@"buyItem"]) {

// Create and present the payment request here.

// The web view ignores the link.
decisionHandler(WKNavigationActionPolicyCancel);
}

// Otherwise the web view loads the link.
decisionHandler(WKNavigationActionPolicyAllow);
}
 
*/
