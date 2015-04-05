//
//  SearchViewController.h
//  GopherCNYS
//
//  Created by Minh Tri on 4/4/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CategoryCollectionViewCell.h"
#import "HMSegmentedControl.h"


@protocol SearchViewControllerDelegate <NSObject>
@optional
- (void)onFavoriteSelected:(NSMutableArray*)indexs;
@end

@interface SearchViewController : BaseViewController <UICollectionViewDataSource, UICollectionViewDelegate, CategoryCollectionViewCellDelegate>
{
    BOOL isFavoriteSelected;

}

@property (assign, nonatomic) id<SearchViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UICollectionView *categoryCollectionView;

@property (weak, nonatomic) IBOutlet UIView *rangeSegmentControl;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet UIButton *categorySelectAllBtn;
@property (weak, nonatomic) IBOutlet UIButton *categoryResetBtn;

@end
