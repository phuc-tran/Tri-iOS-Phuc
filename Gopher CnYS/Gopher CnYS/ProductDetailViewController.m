//
//  ProductDetailViewController.m
//  GopherCNYS
//
//  Created by Minh Tri on 3/16/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "ProductDetailViewController.h"

@interface ProductDetailViewController ()

@end

@implementation ProductDetailViewController

@synthesize productData, selectedIndex, currentLocaltion, carousel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"Products Detail"];
    
//    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
//    backbtn.tintColor = [UIColor blackColor];
//    self.navigationItem.backBarButtonItem = backbtn;
    
    self.carouselController = [[FPCarouselNonXIBViewController alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, carousel.frame.size.height)];
    [self.carousel addSubview:self.carouselController.view];
}

-(void)viewWillAppear:(BOOL)animated {
    
//    PFFile *imageFile = [[productData objectAtIndex:selectedIndex] objectForKey:@"photo1"];
//    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
//        if (!error) {
//            UIImage *image = [UIImage imageWithData:data];
//            self.productImgaeView.image = image;
//        }
//    }];
    
    
    PFGeoPoint *positionItem  = [[productData objectAtIndex:selectedIndex] objectForKey:@"position"];
    self.productlocationLbl.text = [NSString stringWithFormat:@"%.f miles", [currentLocaltion distanceInMilesTo:positionItem]];
    
//    PFUser *seller = [[productData objectAtIndex:selectedIndex] valueForKey:@"seller"];
//    PFQuery *query = [PFQuery queryWithClassName:@"User"];
//    [query whereKey:@"objectId" equalTo:[seller objectId]];
//    [query selectKeys:@[@"username", @"name"]];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            // The find succeeded.
//            self.productSellerLbl.text = [[objects objectAtIndex:0] valueForKey:@"username"];
//        } else {
//            // Log details of the failure
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];

    
    self.productNameLbl.text = [[productData objectAtIndex:selectedIndex] valueForKey:@"title"];
    self.productDescription.textColor = [UIColor colorWithRed:148/255.0f green:148/255.0f blue:148/255.0f alpha:1.0f];
    self.productDescription.text = [[[productData objectAtIndex:selectedIndex] objectForKey:@"description"] description];
    NSInteger price  = [[[productData objectAtIndex:selectedIndex] valueForKey:@"price"] integerValue];
    self.productPriceLbl.text = [NSString stringWithFormat:@"$%ld", (long)price];
    bool condition = [[productData objectAtIndex:selectedIndex] valueForKey:@"condition"];
    self.productConditionLbl.text = ((condition == true) ? @"Used" : @"");
    NSInteger quantity = [[[productData objectAtIndex:selectedIndex] valueForKey:@"quantity"] integerValue];
    self.productQuantityLbl.text = [NSString stringWithFormat:@"%ld", (long)quantity];
    NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
    [dateformater setDateFormat:@"MMMM dd, yyyy"];
    NSDate *date = [[productData objectAtIndex:selectedIndex] valueForKey:@"createdAt"];
    self.productPostedLbl.text = [dateformater stringFromDate:date];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
