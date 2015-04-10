//
// ProductListTableHeaderView.h
//
// @author Shiki
//

#import <UIKit/UIKit.h>


@interface ProductListTableHeaderView : UIView {
    
  UILabel *title;
  UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
