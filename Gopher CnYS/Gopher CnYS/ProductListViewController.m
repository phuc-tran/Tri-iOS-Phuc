//
//  ProductListViewController.m
//  Gopher CnYS
//
//  Created by Trần Huy Phúc on 1/14/15.
//  Copyright (c) 2015 cnys. All rights reserved.
//

#import "ProductListViewController.h"
#import "ProductTableViewCell.h"
#import "ProductHeaderView.h"
#import "ProductDetailViewController.h"
#import "HomeViewController.h"
#import "SellViewController.h"
#import "MyListingViewController.h"
#import "ProductListTableHeaderView.h"
#import "ProductListTableFooterView.h"

@interface ProductListViewController () <ProductTableViewCellDelegate>
{
    CGPoint pointNow;
    NSMutableArray *productData;
    PFGeoPoint *currentLocaltion;
    NSUInteger selectedIndex;
    PFQuery *queryTotal;
    BOOL isSearchNavi;
    BOOL isLoadFinished;
}
@end


@implementation ProductListViewController

//@synthesize btnFavorite, btnNew, btnPrice, btnSelectCategory;

#pragma mark - Self View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            // do something with the new geoPoint
            currentLocaltion = geoPoint;
        }
        NSLog(@"get location %@", currentLocaltion);
    }];

    productData = [[NSMutableArray alloc] init];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProductTableViewCell" bundle:nil] forCellReuseIdentifier:@"ProductTableViewCell"];
    
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"ProductTableViewCell" bundle:nil] forCellReuseIdentifier:@"ProductTableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.pullToRefreshEnabled = NO;
    
    // set the custom view for "pull to refresh". See ProductListTableHeaderView.xib.
//    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProductListTableHeaderView" owner:self options:nil];
//    ProductListTableHeaderView *headerView = (ProductListTableHeaderView *)[nib objectAtIndex:0];
//    self.headerView = headerView;
    
    // set the custom view for "load more". See ProductListTableFooterView.xib.
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProductListTableFooterView" owner:self options:nil];
    ProductListTableFooterView *footerView = (ProductListTableFooterView *)[nib objectAtIndex:0];
    self.footerView = footerView;
    
    [self.productSearchBar setShowsScopeBar:NO];
    [self.productSearchBar sizeToFit];
    // Hide the search bar until user scrolls up
    CGRect newBounds = [[self tableView] bounds];
    newBounds.origin.y = newBounds.origin.y + self.productSearchBar.bounds.size.height;
    [[self tableView] setBounds:newBounds];
    
    //init query
    queryTotal = [ProductInformation query];
    [queryTotal whereKey:@"deleted" notEqualTo:[NSNumber numberWithBool:YES]];
    [queryTotal orderByDescending:@"createdAt"];
    queryTotal.limit = 100;
    
    isSearchNavi = NO;
    isLoadFinished = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    
    isFavoriteTopSelected = NO;
    isNewTopSelected = NO;
    isPriceTopSelected = NO;
    
    [self.tableView reloadData];
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    UIImage *buttonImage = [UIImage imageNamed:@"menu-icon.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0.0f, 0.0f, 25.0f, 25.0f);
    [button addTarget:self action:@selector(leftMenuClick:) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

-(void)leftMenuClick:(UIBarButtonItem*)btn
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"ProductDetaiFormProduct"])
    {
        ProductDetailViewController *vc = [segue destinationViewController];
        [vc setProductData:productData];
        [vc setSelectedIndex:selectedIndex];
        [vc setCurrentLocaltion:currentLocaltion];
    }
    else if ([segue.identifier isEqualToString:@"product_list_form_login"]) {
        HomeViewController *destViewController = (HomeViewController *)[segue destinationViewController];
        destViewController.shouldGoBack = YES;
    }

}

#pragma mark - TableView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [super scrollViewWillBeginDragging:scrollView];
    pointNow = scrollView.contentOffset;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    if (scrollView.contentOffset.y< pointNow.y) {
        self.bottomView.hidden = NO;
    } else if (scrollView.contentOffset.y> pointNow.y) {
        self.bottomView.hidden = YES;
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 162;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return productData.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"ProductDetaiFormProduct" sender:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductTableViewCell *cell = (ProductTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ProductTableViewCell"];
    cell.delegate = self;
    cell.cellIndex = indexPath.row;
    ProductInformation *product = [productData objectAtIndex:indexPath.row];
    [cell loadData:product];
    return cell;
}

- (BOOL)checkItemisFavorited:(NSArray*)array {
    
    NSString *str = [PFUser currentUser].objectId;
    for (NSInteger i = array.count-1; i>-1; i--) {
        NSObject *object = [array objectAtIndex:i];
        if ([object isKindOfClass:[NSString class]]) {
            NSString *item = [NSString stringWithFormat:@"%@", object];
            if ([item rangeOfString:str].location != NSNotFound) {
                return true;
            }
        }
    }
    return false;
}

- (void) loadProductList {
    if (queryTotal != nil) {
        NSLog(@"load product list");
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        isLoadFinished = NO;
        queryTotal.skip = [productData count];
        [queryTotal findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (!error) {
                // The find succeeded.
                self.canLoadMore = (objects.count > 0);
                NSLog(@"can load more %d", self.canLoadMore);
                if (self.canLoadMore) {
                    for (ProductInformation *object in objects) {
                        [productData addObject:object];
                    }
                    
                    NSLog(@"Successfully retrieved %lu products.", (unsigned long)objects.count);
                    NSArray *tmpArr = [productData sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                        ProductInformation *first = (ProductInformation*)a;
                        ProductInformation *second = (ProductInformation*)b;
                        return [self compare:first withProduct:second];
                    }];
                    productData = [NSMutableArray arrayWithArray:tmpArr];
                    NSLog(@"product count %ld", (unsigned long)[productData count]);
                    if (_isNewSearch) {
                        [self filterResultsWithSearch];
                    }
                    [self.tableView reloadData];
                    if (isSearchNavi) {
                        [self.searchDisplayController.searchResultsTableView reloadData];
                    }
                    isLoadFinished = YES;
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
}

- (void)filterResults:(NSString *)searchTerm
{
    [productData removeAllObjects];
    PFQuery *queryTitle = [ProductInformation query];
    [queryTitle whereKey:@"title" matchesRegex:searchTerm modifiers:@"i"];
    
    PFQuery *queryDes = [ProductInformation query];
    [queryDes whereKey:@"description" matchesRegex:searchTerm modifiers:@"i"];
    
    queryTotal = [PFQuery orQueryWithSubqueries:@[queryTitle, queryDes]];
    [queryTotal orderByDescending:@"createdAt"];
    [queryTotal whereKey:@"deleted" notEqualTo:[NSNumber numberWithBool:YES]];
    queryTotal.limit = 100;
    
    [queryTotal findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            // The find succeeded.
                for (ProductInformation *object in objects) {
                    [productData addObject:object];
                }
                
                NSLog(@"Successfully retrieved %lu products.", (unsigned long)objects.count);
                NSArray *tmpArr = [productData sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    ProductInformation *first = (ProductInformation*)a;
                    ProductInformation *second = (ProductInformation*)b;
                    return [self compare:first withProduct:second];
                }];
                productData = [NSMutableArray arrayWithArray:tmpArr];
                NSLog(@"product count %ld", (unsigned long)[productData count]);
            //}
            [self.searchDisplayController.searchResultsTableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}


- (int)compare:(PFObject*)product1 withProduct:(PFObject*)product2
{
    PFGeoPoint *point1 = [product1 objectForKey:@"position"];
    PFGeoPoint *point2 = [product2 objectForKey:@"position"];
    
    if(currentLocaltion != nil && point1 != nil && point2 != nil)
    {
        double dist1 = [currentLocaltion distanceInMilesTo:point1];
        double dist2 = [currentLocaltion distanceInMilesTo:point2];
        if(dist1 > dist2)
            return 1;
        else if(dist1 == dist2)
            return 0;
        else
            return -1;
    } else {
        return 0;
    }
}

- (void)filterResultsWithSearch
{
    NSString *name = _searchTab[@"name"];
    NSString *keywords = _searchTab[@"keywords"];
    NSInteger distance = [_searchTab[@"distance"] integerValue];
    BOOL notify = [_searchTab[@"notify"] boolValue];
    NSString *notifystr = ((notify == YES) ? @"YES" : @"NO");
    NSLog(@"name %@ - %@ - %ld miles - Notify me when new post match my search key criteria: %@", name, keywords, (long)distance, notifystr);
    _isNewSearch = NO;
    NSMutableArray *finalArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < productData.count; i++) {
        NSString *title = [[productData objectAtIndex:i] valueForKey:@"title"];
        NSString *desc = [[[productData objectAtIndex:i] objectForKey:@"description"] description];
        PFGeoPoint *positionItem  = [[productData objectAtIndex:i] objectForKey:@"position"];
        double miles = [currentLocaltion distanceInMilesTo:positionItem];
        if ([keywords isEqualToString:@""]) {
            if (miles <= distance) {
                [finalArray addObject:[productData objectAtIndex:i]];
            }
        } else {
            if ([title rangeOfString:keywords options:NSCaseInsensitiveSearch].location != NSNotFound ||
                [desc rangeOfString:keywords options:NSCaseInsensitiveSearch].location != NSNotFound
                || miles <= distance
                )
            {
                [finalArray addObject:[productData objectAtIndex:i]];
            }
        }
    }
    productData = finalArray;
}

-(BOOL) checkIfUserLoggedIn
{
    if ([[PFUser currentUser] isAuthenticated])
    {
        return YES;
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action
- (IBAction)gotoSearcg:(UIBarButtonItem *)sender {
    if (isLoadFinished) {
        [self.productSearchBar becomeFirstResponder];
    }
}

#pragma mark - UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item == self.cameraTabBarItem) {
        MyListingViewController *myListing = (MyListingViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"MyListingViewController"];
        myListing.isFromTabBar = YES;
        [[self navigationController] pushViewController:myListing animated:YES];
    } else if (item == self.settingTabBarItem) {
        SearchViewController *searchVC = (SearchViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"mainPageFilter"];
        searchVC.delegate = self;
        [[self navigationController] pushViewController:searchVC animated:YES];
    }
}

#pragma mark - SearchViewControllerDelegate
- (void)onFilterContentForSearch:(NSMutableArray*)categoryList withPrice:(NSInteger)price withZipCode:(NSString *)zipcode withKeyword:(NSString *)keywords favoriteSelected:(BOOL)isSelected conditionOption:(NSInteger)condition {
    [productData removeAllObjects];
    self.canLoadMore = YES;
    if (keywords != nil && keywords.length > 0 && [keywords stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] ) {
        PFQuery *queryTitle = [ProductInformation query];
        [queryTitle whereKey:@"title" matchesRegex:keywords modifiers:@"i"];
        
        PFQuery *queryDes = [ProductInformation query];
        [queryDes whereKey:@"description" matchesRegex:keywords modifiers:@"i"];
        
        queryTotal = [PFQuery orQueryWithSubqueries:@[queryTitle, queryDes]];
    } else {
        queryTotal = [ProductInformation query];
    }
        
    
    if (price > 0) {
        [queryTotal whereKey:@"price" lessThanOrEqualTo:[NSNumber numberWithInteger:price]];
    }
    if (zipcode != nil && zipcode.length > 0 && [zipcode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] ) {
        if (![zipcode isEqualToString:@"85345"]) {
            [queryTotal whereKey:@"postalCode" equalTo:zipcode];
        }
    }
    if (isSelected) {
        [queryTotal whereKey:@"favoritors" containsAllObjectsInArray:@[[PFUser currentUser].objectId]];
    }
    
    if (categoryList.count > 0) {
        [queryTotal whereKey:@"category" containedIn:categoryList];
    }
    if (condition < 2) {
        [queryTotal whereKey:@"condition" equalTo:[NSNumber numberWithBool:(condition == 0)]];
    }
    
    [queryTotal orderByDescending:@"createdAt"];
    [queryTotal whereKey:@"deleted" notEqualTo:[NSNumber numberWithBool:YES]];
    queryTotal.limit = 100;
}

#pragma mark - ProductTableViewCellDelegate

- (void)onFavoriteCheck:(NSInteger)index isFavorite:(BOOL)isFv
{
    NSLog(@"index %ld is check %d", (long)index, isFv);
    if(isFv)
    {
        NSMutableArray *array = [[productData objectAtIndex:index] objectForKey:@"favoritors"];
        if(array == nil)
            array = [[NSMutableArray alloc] init];
        [array addObject:[PFUser currentUser].objectId];
        PFObject *item = [productData objectAtIndex:index];
        item[@"favoritors"] = array;
        [item saveInBackground];
        
    } else {
        
        NSMutableArray *array = [[productData objectAtIndex:index] objectForKey:@"favoritors"];
        if(array != nil)
        {
            NSString *str = [PFUser currentUser].objectId;
            for (NSInteger i=array.count-1; i>-1; i--) {
                NSString *strItem = [array objectAtIndex:i];
                if ([strItem rangeOfString:str].location != NSNotFound) {
                    [array removeObject:strItem];
                }
            }
            
            PFObject *item = [productData objectAtIndex:index];
            [item setObject:array forKey:@"favoritors"];
            [item saveInBackground];
        }
    }
}

#pragma mark - UISearchDisplayController Delegate Methods

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // Tells the table data source to reload when text changes
//    [self filterContentForSearchText:searchString scope:
//     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // Tells the table data source to reload when scope bar selection changes
//    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
//     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return NO;
}

#pragma mark - UISearchBarDelegate
// called when keyboard search button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    isSearchNavi = YES;
    [self.productSearchBar resignFirstResponder];
    [self filterResults:searchBar.text];
   
}

// called when bookmark button pressed
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    isSearchNavi = NO;
    [productData removeAllObjects];
    queryTotal = [ProductInformation query];
    [queryTotal whereKey:@"deleted" notEqualTo:[NSNumber numberWithBool:YES]];
    [queryTotal orderByDescending:@"createdAt"];
    queryTotal.limit = 100;
    [self loadProductList];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Pull to Refresh

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) pinHeaderView
{
    [super pinHeaderView];
    
    // do custom handling for the header view
    ProductListTableHeaderView *hv = (ProductListTableHeaderView *)self.headerView;
    [hv.activityIndicator startAnimating];
    hv.title.text = @"Loading...";
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) unpinHeaderView
{
    [super unpinHeaderView];
    
    // do custom handling for the header view
    [[(ProductListTableHeaderView *)self.headerView activityIndicator] stopAnimating];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Update the header text while the user is dragging
//
- (void) headerViewDidScroll:(BOOL)willRefreshOnRelease scrollView:(UIScrollView *)scrollView
{
    ProductListTableHeaderView *hv = (ProductListTableHeaderView *)self.headerView;
    if (willRefreshOnRelease)
        hv.title.text = @"Release to refresh...";
    else
        hv.title.text = @"Pull down to refresh...";
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// refresh the list. Do your async calls here.
//
- (BOOL) refresh
{
    if (![super refresh])
        return NO;
    
    // Do your async call here
    // This is just a dummy data loader:
    [self performSelector:@selector(addItemsOnTop) withObject:nil afterDelay:2.0];
    // See -addItemsOnTop for more info on how to finish loading
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Load More

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// The method -loadMore was called and will begin fetching data for the next page (more).
// Do custom handling of -footerView if you need to.
//
- (void) willBeginLoadingMore
{
    ProductListTableFooterView *fv = (ProductListTableFooterView *)self.footerView;
    [fv.activityIndicator startAnimating];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Do UI handling after the "load more" process was completed. In this example, -footerView will
// show a "No more items to load" text.
//
- (void) loadMoreCompleted
{
    [super loadMoreCompleted];
    
    ProductListTableFooterView *fv = (ProductListTableFooterView *)self.footerView;
    [fv.activityIndicator stopAnimating];
    
    if (!self.canLoadMore) {
        // Do something if there are no more items to load
        
        // We can hide the footerView by: [self setFooterViewVisibility:NO];
        
        // Just show a textual info that there are no more items to load
        fv.infoLabel.hidden = NO;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) loadMore
{
    if (![super loadMore])
        return NO;
    
    // Do your async loading here
    [self performSelector:@selector(addItemsOnBottom) withObject:nil afterDelay:2.0];
    // See -addItemsOnBottom for more info on what to do after loading more items
    
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Dummy data methods

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addItemsOnTop
{
//    for (int i = 0; i < 3; i++)
//        [items insertObject:[self createRandomValue] atIndex:0];
    
    [self.tableView reloadData];
    
    // Call this to indicate that we have finished "refreshing".
    // This will then result in the headerView being unpinned (-unpinHeaderView will be called).
    [self refreshCompleted];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addItemsOnBottom
{
    [self loadProductList];
    //[self.tableView reloadData];
    
    // Inform STableViewController that we have finished loading more items
    [self loadMoreCompleted];
}

@end
