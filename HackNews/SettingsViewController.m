//
//  SettingsViewController.m
//  HackNews
//
//  Created by horse on 2026/2/22.
//

#import "SettingsViewController.h"
#import "LanguageManager.h"
#import <UIKit/UIKit.h>

@interface SettingsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *sections;

@end

// 关于页面的 View Controller
@interface AboutViewController : UIViewController
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [[LanguageManager sharedManager] localizedString:@"about_title"];
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:scrollView];

    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 16;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:stackView];

    [NSLayoutConstraint activateConstraints:@[
        [stackView.topAnchor constraintEqualToAnchor:scrollView.topAnchor constant:40],
        [stackView.leadingAnchor constraintEqualToAnchor:scrollView.leadingAnchor constant:20],
        [stackView.trailingAnchor constraintEqualToAnchor:scrollView.trailingAnchor constant:-20],
        [stackView.bottomAnchor constraintEqualToAnchor:scrollView.bottomAnchor constant:-40],
        [stackView.widthAnchor constraintEqualToAnchor:scrollView.widthAnchor constant:-40]
    ]];

    // App Icon
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[[UIImage systemImageNamed:@"newspaper.fill"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    iconView.tintColor = [UIColor systemOrangeColor];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    [iconView.heightAnchor constraintEqualToConstant:80].active = YES;
    [iconView.widthAnchor constraintEqualToConstant:80].active = YES;
    [stackView addArrangedSubview:iconView];

    // App Name
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = @"HackNews";
    nameLabel.font = [UIFont boldSystemFontOfSize:24];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [stackView addArrangedSubview:nameLabel];

    // Version
    UILabel *versionLabel = [[UILabel alloc] init];
    versionLabel.text = @"Version 1.0.0";
    versionLabel.font = [UIFont systemFontOfSize:14];
    versionLabel.textColor = [UIColor secondaryLabelColor];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    [stackView addArrangedSubview:versionLabel];

    // Description
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.text = [[LanguageManager sharedManager] localizedString:@"about_description"];
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.textColor = [UIColor labelColor];
    descLabel.textAlignment = NSTextAlignmentCenter;
    descLabel.numberOfLines = 0;
    [stackView addArrangedSubview:descLabel];

    // GitHub Link
    UIButton *githubButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [githubButton setTitle:[[LanguageManager sharedManager] localizedString:@"about_github"] forState:UIControlStateNormal];
    githubButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [githubButton addTarget:self action:@selector(openGitHub) forControlEvents:UIControlEventTouchUpInside];
    [stackView addArrangedSubview:githubButton];
}

- (void)openGitHub {
    NSURL *url = [NSURL URLWithString:@"https://github.com/lvchenjia/uikit_hacknews"];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [[LanguageManager sharedManager] localizedString:@"settings_title"];
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // Define sections structure
    self.sections = @[
        @{@"title": [[LanguageManager sharedManager] localizedString:@"settings_appearance"],
          @"type": @"options",
          @"options": @[
              @{@"title": [[LanguageManager sharedManager] localizedString:@"settings_system"], @"value": @(UIUserInterfaceStyleUnspecified)},
              @{@"title": [[LanguageManager sharedManager] localizedString:@"settings_light"], @"value": @(UIUserInterfaceStyleLight)},
              @{@"title": [[LanguageManager sharedManager] localizedString:@"settings_dark"], @"value": @(UIUserInterfaceStyleDark)}
          ]
        },
        @{@"title": [[LanguageManager sharedManager] localizedString:@"settings_language"],
          @"type": @"options",
          @"options": @[
              @{@"title": [[LanguageManager sharedManager] localizedString:@"settings_system"], @"value": @(LanguageTypeSystem)},
              @{@"title": @"English", @"value": @(LanguageTypeEnglish)},
              @{@"title": @"简体中文", @"value": @(LanguageTypeChinese)}
          ]
        },
        @{@"title": [[LanguageManager sharedManager] localizedString:@"settings_font_size"],
          @"type": @"options",
          @"options": @[
              @{@"title": [[LanguageManager sharedManager] localizedString:@"font_small"], @"value": @(-4)},
              @{@"title": [[LanguageManager sharedManager] localizedString:@"font_normal"], @"value": @(0)},
              @{@"title": [[LanguageManager sharedManager] localizedString:@"font_large"], @"value": @(4)},
              @{@"title": [[LanguageManager sharedManager] localizedString:@"font_extra_large"], @"value": @(8)}
          ]
        },
        @{@"title": [[LanguageManager sharedManager] localizedString:@"about_title"],
          @"type": @"about"}
    ];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *sectionData = self.sections[section];
    NSString *type = sectionData[@"type"];

    if ([type isEqualToString:@"options"] || [type isEqualToString:@"font_options"]) {
        return [sectionData[@"options"] count];
    } else if ([type isEqualToString:@"about"]) {
        return 1;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section][@"title"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *sectionData = self.sections[indexPath.section];
    NSString *type = sectionData[@"type"];

    // About cell
    if ([type isEqualToString:@"about"]) {
        static NSString *aboutCellId = @"AboutCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:aboutCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:aboutCellId];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = [[LanguageManager sharedManager] localizedString:@"about_title"];
        cell.imageView.image = [UIImage systemImageNamed:@"info.circle"];
        cell.imageView.tintColor = [UIColor systemOrangeColor];
        return cell;
    }

    // Standard option cells (Appearance, Language, Font Size)
    static NSString *cellId = @"SettingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }

    NSDictionary *option = sectionData[@"options"][indexPath.row];
    cell.textLabel.text = option[@"title"];

    // Checkmark logic
    BOOL isSelected = NO;
    if (indexPath.section == 0) { // Appearance
        NSInteger savedStyle = [[NSUserDefaults standardUserDefaults] integerForKey:@"AppAppearanceStyle"];
        UIUserInterfaceStyle optionStyle = [option[@"value"] integerValue];
        isSelected = (savedStyle == optionStyle);
    } else if (indexPath.section == 1) { // Language
        LanguageType currentLang = [LanguageManager sharedManager].currentLanguage;
        LanguageType optionLang = [option[@"value"] integerValue];
        isSelected = (currentLang == optionLang);
    } else if (indexPath.section == 2) { // Font Size
        NSInteger savedOffset = [[NSUserDefaults standardUserDefaults] integerForKey:@"AppFontSizeOffset"];
        NSInteger optionOffset = [option[@"value"] integerValue];
        isSelected = (savedOffset == optionOffset);
    }

    cell.accessoryType = isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *sectionData = self.sections[indexPath.section];
    NSString *type = sectionData[@"type"];

    // Handle About section
    if ([type isEqualToString:@"about"]) {
        AboutViewController *aboutVC = [[AboutViewController alloc] init];
        [self.navigationController pushViewController:aboutVC animated:YES];
        return;
    }

    NSDictionary *option = sectionData[@"options"][indexPath.row];
    NSInteger value = [option[@"value"] integerValue];

    if (indexPath.section == 0) { // Appearance
        UIUserInterfaceStyle style = (UIUserInterfaceStyle)value;
        // Set globally for all windows in the scene
        for (UIWindow *window in self.view.window.windowScene.windows) {
            window.overrideUserInterfaceStyle = style;
        }

        // Save to UserDefaults
        [[NSUserDefaults standardUserDefaults] setInteger:style forKey:@"AppAppearanceStyle"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    } else if (indexPath.section == 1) { // Language
        LanguageType lang = (LanguageType)value;
        [[LanguageManager sharedManager] setLanguage:lang];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    } else if (indexPath.section == 2) { // Font Size
        [[NSUserDefaults standardUserDefaults] setInteger:value forKey:@"AppFontSizeOffset"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"FontSizeChangedNotification" object:nil];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
    }
}

@end
