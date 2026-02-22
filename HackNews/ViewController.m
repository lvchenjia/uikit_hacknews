//
//  ViewController.m
//  HackNews
//
//  Created by horse on 2026/2/22.
//

#import "ViewController.h"
#import "HNItem.h"
#import "HNStoryCell.h"
#import "HNNetworkManager.h"
#import "SettingsViewController.h"
#import "LanguageManager.h"
#import <SafariServices/SafariServices.h>

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<HNItem *> *stories;
@property (nonatomic, strong) NSArray<NSNumber *> *topStoryIds;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIActivityIndicatorView *pagingSpinner;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isPaging;
@property (nonatomic, assign) HNFeedType currentFeedType; // Added property

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = LS(@"title_top");
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.stories = [NSMutableArray array];
    self.currentFeedType = HNFeedTypeTop;
    
    // Initialize refresh control early
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchStories) forControlEvents:UIControlEventValueChanged];
    
    [self setupNavigationBar];
    
    [self setupTableView];
    [self setupFooterLoading];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFontSizeChange) name:@"FontSizeChangedNotification" object:nil];
    
    [self startLoading];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleFontSizeChange {
    [self.tableView reloadData];
}

- (void)setupNavigationBar {
    // 1. Settings on the right
    UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"gear"] style:UIBarButtonItemStylePlain target:self action:@selector(openSettings)];
    self.navigationItem.rightBarButtonItem = settingsItem;
    
    // 2. Feed Selection on the left
    UIBarButtonItem *feedItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"line.3.horizontal.decrease.circle"] menu:[self createFeedMenu]];
    self.navigationItem.leftBarButtonItem = feedItem;
    
    // 3. Standard Title
    self.navigationItem.titleView = nil;
}

- (UIMenu *)createFeedMenu {
    __weak typeof(self) weakSelf = self;
    UIAction *topAction = [UIAction actionWithTitle:LS(@"tab_top") image:[UIImage systemImageNamed:@"flame"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [weakSelf switchFeedType:HNFeedTypeTop title:LS(@"title_top")];
    }];
    UIAction *newAction = [UIAction actionWithTitle:LS(@"tab_new") image:[UIImage systemImageNamed:@"clock"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [weakSelf switchFeedType:HNFeedTypeNew title:LS(@"title_new")];
    }];
    UIAction *bestAction = [UIAction actionWithTitle:LS(@"tab_best") image:[UIImage systemImageNamed:@"star"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [weakSelf switchFeedType:HNFeedTypeBest title:LS(@"title_best")];
    }];
    UIAction *showAction = [UIAction actionWithTitle:LS(@"tab_show") image:[UIImage systemImageNamed:@"eye"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [weakSelf switchFeedType:HNFeedTypeShow title:LS(@"title_show")];
    }];
    UIAction *askAction = [UIAction actionWithTitle:LS(@"tab_ask") image:[UIImage systemImageNamed:@"bubble.left.and.bubble.right"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [weakSelf switchFeedType:HNFeedTypeAsk title:LS(@"title_ask")];
    }];
    UIAction *jobAction = [UIAction actionWithTitle:LS(@"tab_job") image:[UIImage systemImageNamed:@"briefcase"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [weakSelf switchFeedType:HNFeedTypeJob title:LS(@"title_job")];
    }];
    
    return [UIMenu menuWithTitle:LS(@"menu_title") children:@[topAction, newAction, bestAction, showAction, askAction, jobAction]];
}

- (void)openSettings {
    SettingsViewController *vc = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


// 切换当前的数据源类型
- (void)switchFeedType:(HNFeedType)type title:(NSString *)title {
    if (self.currentFeedType == type) return;
    
    self.currentFeedType = type;
    self.title = title;
    
    // 滚动到顶部
    if (self.stories.count > 0 && [self.tableView numberOfSections] > 0 && [self.tableView numberOfRowsInSection:0] > 0) {
        NSIndexPath *top = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    // 触发刷新
    [self startLoading];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor systemBackgroundColor];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[HNStoryCell class] forCellReuseIdentifier:[HNStoryCell reuseIdentifier]];
    self.tableView.refreshControl = self.refreshControl;
}

- (void)setupFooterLoading {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    self.pagingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.pagingSpinner.center = footerView.center;
    self.pagingSpinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [footerView addSubview:self.pagingSpinner];
    self.tableView.tableFooterView = footerView;
}

- (void)startLoading {
    [self.refreshControl beginRefreshing];
    // Create fetch logic
    [self fetchStories];
}

#pragma mark - Networking

- (void)fetchStories {
    if (self.isLoading) return;
    self.isLoading = YES;
    self.isPaging = NO;
    
    // Clear existing data so we start fresh
    self.stories = [NSMutableArray array];
    [self.tableView reloadData];
    
    // Use the current feed type
    HNFeedType type = self.currentFeedType;
    
    __weak typeof(self) weakSelf = self;
    [[HNNetworkManager sharedManager] fetchStoryIdsForType:type completion:^(NSArray<NSNumber *> * _Nullable ids, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Fetch error: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.isLoading = NO;
                [weakSelf.refreshControl endRefreshing];
            });
            return;
        }
        
        weakSelf.topStoryIds = ids;
        [weakSelf loadNextPageOfStories];
    }];
}

- (void)loadNextPageOfStories {
    if (self.topStoryIds.count == 0 || self.stories.count >= self.topStoryIds.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isLoading = NO;
            self.isPaging = NO;
            [self.refreshControl endRefreshing];
            [self.pagingSpinner stopAnimating];
        });
        return;
    }
    
    NSInteger startIndex = self.stories.count;
    NSInteger batchSize = 20;
    NSInteger endIndex = MIN(startIndex + batchSize, self.topStoryIds.count);
    
    NSArray *nextBatchIds = [self.topStoryIds subarrayWithRange:NSMakeRange(startIndex, endIndex - startIndex)];
    
    [[HNNetworkManager sharedManager] fetchItemsWithIds:nextBatchIds completion:^(NSArray<HNItem *> * _Nullable stories, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (stories.count > 0) {
                if (!self.isPaging) {
                    // First page load, refresh entirely
                    self.stories = [stories mutableCopy];
                    [self.tableView reloadData];
                } else {
                    // Append for paging
                    NSMutableArray *indexPaths = [NSMutableArray array];
                    NSInteger startRow = self.stories.count;
                    [self.stories addObjectsFromArray:stories];
                    
                    for (int i = 0; i < stories.count; i++) {
                        [indexPaths addObject:[NSIndexPath indexPathForRow:startRow + i inSection:0]];
                    }
                    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                }
            }
            
            self.isLoading = NO;
            self.isPaging = NO;
            [self.refreshControl endRefreshing];
            [self.pagingSpinner stopAnimating];
        });
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HNStoryCell *cell = [tableView dequeueReusableCellWithIdentifier:[HNStoryCell reuseIdentifier] forIndexPath:indexPath];
    cell.item = self.stories[indexPath.row];
    
    // Check if we are near the bottom to trigger paging
    if (indexPath.row == self.stories.count - 1 && !self.isLoading && self.stories.count < self.topStoryIds.count) {
        [self startPaging];
    }
    
    return cell;
}

- (void)startPaging {
    self.isLoading = YES;
    self.isPaging = YES;
    
    if (!self.pagingSpinner) {
        [self setupFooterLoading];
    }
    [self.pagingSpinner startAnimating];
    
    [self loadNextPageOfStories];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HNItem *item = self.stories[indexPath.row];
    if (item.url) {
        NSURL *url = [NSURL URLWithString:item.url];
        if (url) {
            SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:url];
            [self presentViewController:safariVC animated:YES completion:nil];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // If we return automatic dimension, we must ensure constraints are complete
    return UITableViewAutomaticDimension;
}

@end
