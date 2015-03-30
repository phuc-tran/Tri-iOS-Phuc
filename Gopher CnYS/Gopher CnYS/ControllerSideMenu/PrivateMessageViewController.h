//
//  PrivateMessageViewController.h
//  GopherCNYS
//
//  Created by Vu Tiet on 3/28/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQMessages.h"
#import <Parse/Parse.h>

@interface PrivateMessageViewController : JSQMessagesViewController

@property (nonatomic, strong) PFObject *chatRoom;
@property (nonatomic, strong) PFObject *product;
@property (nonatomic, strong) UIImage *incomingImage;

@end
