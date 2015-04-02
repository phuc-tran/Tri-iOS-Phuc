//
//  ProductDetailViewController.m
//  GopherCNYS
//
//  Created by Minh Tri on 3/16/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "PrivateMessageViewController.h"
#import "UserListingViewController.h"

@interface ProductDetailViewController ()
@property (nonatomic, weak) IBOutlet UIButton *messageButton;
@end

@implementation ProductDetailViewController

@synthesize productData, selectedIndex, currentLocaltion, carousel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"Products Detail"];
    
//    NSLog(@"current user objectId -- seller objectId: %@ || %@", [[PFUser currentUser] valueForKey:@"objectId"], [[[productData objectAtIndex:selectedIndex] valueForKey:@"seller"] valueForKey:@"objectId"]);
    if (![[[PFUser currentUser] valueForKey:@"objectId"] isEqualToString:[[[productData objectAtIndex:selectedIndex] valueForKey:@"seller"] valueForKey:@"objectId"]]) {
        // enable message button if seller and buyer are different people
        self.messageButton.enabled = YES;
    }
    
//    self.carouselController = [[FPCarouselNonXIBViewController alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, carousel.frame.size.height)];
//    [self.carousel addSubview:self.carouselController.view];
    
    PFGeoPoint *positionItem  = [[productData objectAtIndex:selectedIndex] objectForKey:@"position"];
    self.productlocationLbl.text = [NSString stringWithFormat:@"%.f miles", [currentLocaltion distanceInMilesTo:positionItem]];
    
    PFUser *seller = [[productData objectAtIndex:selectedIndex] valueForKey:@"seller"];
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:[seller objectId]];
    [query selectKeys:@[@"username", @"name", @"profileImage"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            PFUser *user = [objects objectAtIndex:0];
            NSString *name = [user valueForKey:@"name"];
            if (name == nil) {
                name = user.username;
            }
            self.productSellerLbl.text = name;
            PFFile *imageFile = [user objectForKey:@"profileImage"];
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                if (!error) {
                    if (data != nil) {
                        UIImage *image = [UIImage imageWithData:data];
                        self.profileAvatar.image = image;
                    }
                }
            }];
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    self.profileAvatar.layer.cornerRadius = 5.0f;
    self.profileAvatar.layer.borderWidth = 2.0f;
    self.profileAvatar.layer.borderColor = [UIColor colorWithRed:226/255.0f green:226/255.0f blue:226/255.0f alpha:1.0f].CGColor;
    self.profileAvatar.clipsToBounds = YES;
    
    self.productImgaeView.layer.cornerRadius = 5.0f;
    self.productImgaeView.layer.borderWidth = 2.0f;
    self.productImgaeView.layer.borderColor = [UIColor colorWithRed:226/255.0f green:226/255.0f blue:226/255.0f alpha:1.0f].CGColor;
    self.productImgaeView.clipsToBounds = YES;
    
    PFFile *imageFile = [[productData objectAtIndex:selectedIndex] objectForKey:@"photo1"];
    if (imageFile == nil) {
        imageFile = [[productData objectAtIndex:selectedIndex] objectForKey:@"photo2"];
    }
    
    if (imageFile == nil) {
        imageFile = [[productData objectAtIndex:selectedIndex] objectForKey:@"photo3"];
    }
    
    if (imageFile == nil) {
        imageFile = [[productData objectAtIndex:selectedIndex] objectForKey:@"photo4"];
    }
    
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            self.productImgaeView.image = image;
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    
    self.productNameLbl.text = [[productData objectAtIndex:selectedIndex] valueForKey:@"title"];
    self.productDescription.textColor = [UIColor colorWithRed:148/255.0f green:148/255.0f blue:148/255.0f alpha:1.0f];
    self.productDescription.text = [[[productData objectAtIndex:selectedIndex] objectForKey:@"description"] description];
    NSInteger price  = [[[productData objectAtIndex:selectedIndex] valueForKey:@"price"] integerValue];
    self.productPriceLbl.text = [NSString stringWithFormat:@"$%ld", (long)price];
    bool condition = [[productData objectAtIndex:selectedIndex] valueForKey:@"condition"];
    self.productConditionLbl.text = ((condition == true) ? @"New" : @"Used");
    NSInteger quantity = [[[productData objectAtIndex:selectedIndex] valueForKey:@"quantity"] integerValue];
    self.productQuantityLbl.text = [NSString stringWithFormat:@"%ld", (long)quantity];
    NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
    [dateformater setDateFormat:@"MMMM dd, yyyy"];
    NSDate *date = [[productData objectAtIndex:selectedIndex] valueForKey:@"createdAt"];
    self.productPostedLbl.text = [dateformater stringFromDate:date];
    
    NSLog(@"view size %f", self.productDescription.frame.size.height);
    NSLog(@"content size %f", [self getContentSize:self.productDescription].height);
}

-(CGSize) getContentSize:(UITextView*) myTextView{
    return [myTextView sizeThatFits:CGSizeMake(myTextView.frame.size.width, FLT_MAX)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"productDetail_to_privateMessage"])
    {
        PrivateMessageViewController *vc = (PrivateMessageViewController *)[segue destinationViewController];
        vc.product = [productData objectAtIndex:selectedIndex];
    } else if ([[segue identifier] isEqualToString:@"productDetail_to_userListing"]) {
        UserListingViewController *vc= (UserListingViewController *)[segue destinationViewController];
        vc.curUser = [[productData objectAtIndex:selectedIndex] valueForKey:@"seller"];
    }
        
}

- (IBAction)messageButtonDidTouch:(id)sender {
    // Go to Private Message screen
    [self performSegueWithIdentifier:@"productDetail_to_privateMessage" sender:self];
}

- (IBAction)userListingButtonDidTouch:(id)sender {
    [self performSegueWithIdentifier:@"productDetail_to_userListing" sender:self];
}


@end
