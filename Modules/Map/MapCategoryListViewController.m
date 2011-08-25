#import "MapCategoryListViewController.h"
#import "KGOSearchModel.h"
#import "KGOMapCategory.h"
#import "KGOCalendar.h"
#import "KGOAppDelegate+ModuleAdditions.h"
#import "KGOTheme.h"
#import "CoreDataManager.h"
#import "Foundation+KGOAdditions.h"
#import "KGOPlacemark.h"
//#import "KGOEvent.h"
#import <QuartzCore/QuartzCore.h>

@implementation MapCategoryListViewController

@synthesize parentCategory, //categoriesRequest, 
categoryEntityName, //leafItemsRequest, 
leafItemEntityName,
dataManager,
listItems,
headerView = _headerView;

- (void)loadView {
	[super loadView];
    
    self.title = NSLocalizedString(@"Browse", nil);

    UITableViewStyle style = UITableViewStyleGrouped;
    BOOL isPopulated = NO;
    if (self.listItems.count) {
        id object = [self.listItems objectAtIndex:0];
        if ([object conformsToProtocol:@protocol(KGOCategory)]) {
            isPopulated = YES;
        } else if ([object conformsToProtocol:@protocol(KGOSearchResult)]) {
            style = UITableViewStylePlain;
            isPopulated = YES;
        }
    }

	if (isPopulated && !self.tableView) {
		CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
		self.tableView = [self addTableViewWithFrame:frame style:style];

	} else {
        self.dataManager.delegate = self;
        if (self.parentCategory) {
            [self.dataManager requestChildrenForCategory:self.parentCategory.identifier];
        } else {
            [self.dataManager requestBrowseIndex];
        }
        [self showLoadingView];
    }
    /*
    if (!self.categories.count && self.categoriesRequest) {
        [self.categoriesRequest connect];
        
    } else if (!self.leafItems.count && self.leafItemsRequest) {
        [self.leafItemsRequest connect];
        [self showLoadingView];
    }
    */
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [[KGOTheme sharedTheme] backgroundColorForApplication];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}
/*
- (NSArray *)categories {
	return _categories;
}

- (void)setCategories:(NSArray *)categories {
	[_categories release];
	_categories = [categories retain];
	
	if ([self isViewLoaded]) {
		[self reloadDataForTableView:self.tableView];
	}
}

- (NSArray *)leafItems {
	return _leafItems;
}

- (void)setLeafItems:(NSArray *)leafItems {
	[_leafItems release];
	_leafItems = [leafItems retain];
	
	if ([self isViewLoaded]) {
		[self reloadDataForTableView:self.tableView];
	}
}

- (UIView *)headerView {
	return _headerView;
}

- (void)setHeaderView:(UIView *)headerView {
	[_headerView release];
	_headerView = [headerView retain];
	self.tableView.tableHeaderView = _headerView;
}
*/
#pragma mark KGORequestDelegate

- (void)showLoadingView
{
    if (!_loadingView) {
        UIActivityIndicatorView *spinny = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];

        NSString *text = NSLocalizedString(@"Loading...", nil);
        UIFont *font = [UIFont systemFontOfSize:15];
        CGSize size = [text sizeWithFont:font];
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(spinny.frame.size.width, 0, size.width, size.height)] autorelease];
        label.text = text;
        label.font = font;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
                
        CGFloat totalWidth = spinny.frame.size.width + label.frame.size.width;
        CGFloat totalHeight = fmaxf(spinny.frame.size.height, label.frame.size.height);
        _loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, totalWidth + 20, totalHeight + 20)];
        _loadingView.center = self.view.center;
        _loadingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _loadingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        _loadingView.layer.cornerRadius = 10;

        spinny.frame = CGRectMake(10, 10, spinny.frame.size.width, spinny.frame.size.height);
        label.frame = CGRectMake(label.frame.origin.x + 10, 10, label.frame.size.width, label.frame.size.height);
        
        [spinny startAnimating];
        [_loadingView addSubview:spinny];
        [_loadingView addSubview:label];
        
        [self.view addSubview:_loadingView];
    }
}

- (void)hideLoadingView
{
    if (_loadingView) {
        [_loadingView removeFromSuperview];
        [_loadingView release];
        _loadingView = nil;
    }
}
/*
- (void)request:(KGORequest *)request didHandleResult:(NSInteger)returnValue {
    if (request == self.categoriesRequest) {    
        self.categoriesRequest = nil;
        
        NSArray *categories = nil;
        if (self.parentCategory == nil) {
            NSPredicate *pred = nil;
            NSArray *sortDescriptors = nil;
            if ([self.categoryEntityName isEqualToString:MapCategoryEntityName]) {
                pred = [NSPredicate predicateWithFormat:@"parentCategory = nil AND browsable = YES"];
                sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES]];
            } else {
                pred = [NSPredicate predicateWithFormat:@"parentCategory = nil"];
            }
            categories = [[CoreDataManager sharedManager] objectsForEntity:self.categoryEntityName
                                                         matchingPredicate:pred
                                                           sortDescriptors:sortDescriptors];

        } else {
            categories = [self.parentCategory children];
        }
        
        self.categories = categories;

    } else if (request == self.leafItemsRequest) {
        self.leafItems = self.parentCategory.items;
        DLog(@"parent category: %@", self.parentCategory);
        DLog(@"leaf items: %@", self.leafItems);
    }

    [self hideLoadingView];
    [self reloadDataForTableView:self.tableView];
}

- (void)requestWillTerminate:(KGORequest *)request {
    if (request == self.categoriesRequest) {
        self.categoriesRequest = nil;
        [self hideLoadingView];

    } else if (request == self.leafItemsRequest) {
        self.leafItemsRequest = nil;
        [self hideLoadingView];
    }
}
*/

- (void)mapDataManager:(MapDataManager *)dataManager
    didReceiveChildren:(NSArray *)children
           forCategory:(NSString *)categoryID
{
    [self hideLoadingView];

    self.listItems = children;
    id object = [self.listItems objectAtIndex:0];
    
    UITableViewStyle style = UITableViewStyleGrouped;
    if ([object conformsToProtocol:@protocol(KGOSearchResult)]) {
        style = UITableViewStylePlain;
    }
    
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.tableView = [self addTableViewWithFrame:frame style:style];
}

#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    /*
    NSInteger count = 0;
    if (self.categories) {
        count = self.categories.count;
    } else if (self.leafItems) {
        count = self.leafItems.count;
    }
    return count;
     */
    return self.listItems.count;
}

- (KGOTableCellStyle)tableView:(UITableView *)tableView styleForCellAtIndexPath:(NSIndexPath *)indexPath {
    return KGOTableCellStyleDefault;
}

- (CellManipulator)tableView:(UITableView *)tableView manipulatorForCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = nil;
    NSString *accessory = nil;
    
    id object = [self.listItems objectAtIndex:indexPath.row];
    if ([object conformsToProtocol:@protocol(KGOCategory)]) {
        title = [(id<KGOCategory>)object title];
        accessory = KGOAccessoryTypeChevron;
    } else if ([object conformsToProtocol:@protocol(KGOSearchResult)]) {
        title = [(id<KGOCategory>)object title];
    }
    
    /*
    if (self.categories) {        
        id<KGOCategory> category = [self.categories objectAtIndex:indexPath.row];
        title = category.title;
        accessory = KGOAccessoryTypeChevron;

    } else if (self.leafItems) {
        id<KGOSearchResult> leafItem = [self.leafItems objectAtIndex:indexPath.row];
        title = leafItem.title;
        //accessory = KGOAccessoryTypeChevron;
    }
     */
    
    return [[^(UITableViewCell *cell) {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.text = title;
        cell.accessoryView = [[KGOTheme sharedTheme] accessoryViewForType:accessory];
    } copy] autorelease];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.listItems objectAtIndex:indexPath.row];
    if ([object conformsToProtocol:@protocol(KGOCategory)]) {
        id<KGOCategory> category = (id<KGOCategory>)object;
        if ([category respondsToSelector:@selector(moduleTag)]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:category, @"parentCategory", nil];
            if (category.children.count) {
                //[params setObject:category.children forKey:@"categories"];
                [params setObject:category.children forKey:@"listItems"];
                
            } else if (category.items.count) {
                //[params setObject:category.items forKey:@"items"];
                [params setObject:category.items forKey:@"listItems"];
            }
            [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameCategoryList forModuleTag:[category moduleTag] params:params];
        }
    } else if ([object conformsToProtocol:@protocol(KGOSearchResult)]) {
        id<KGOSearchResult> leafItem = (id<KGOSearchResult>)leafItem;
        if ([leafItem respondsToSelector:@selector(moduleTag)]) {
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:leafItem, @"detailItem", nil];
            [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameDetail forModuleTag:[leafItem moduleTag] params:params];
        }
    }
    /*    
    if (self.categories) {
        id<KGOCategory> category = [self.categories objectAtIndex:indexPath.row];
        if ([category respondsToSelector:@selector(moduleTag)]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:category, @"parentCategory", nil];
            if (category.children) {
                [params setObject:category.children forKey:@"categories"];
                
            } else if (category.items) {
                [params setObject:category.items forKey:@"items"];
            }
            [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameCategoryList forModuleTag:[category moduleTag] params:params];
        }
        
    } else if (self.leafItems) {
        id<KGOSearchResult> leafItem = [self.leafItems objectAtIndex:indexPath.row];
        if ([leafItem respondsToSelector:@selector(moduleTag)]) {
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:leafItem, @"detailItem", nil];
            [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameDetail forModuleTag:[leafItem moduleTag] params:params];
        }
    }
     */
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    /*
    self.categoriesRequest.delegate = nil;
    self.categoriesRequest = nil;
    
    self.leafItemsRequest.delegate = nil;
    self.leafItemsRequest = nil;
    */
	self.headerView = nil;
	//self.categories = nil;
    //self.leafItems = nil;
    
    self.categoryEntityName = nil;
    self.leafItemEntityName = nil;
    
    [super dealloc];
}

@end
