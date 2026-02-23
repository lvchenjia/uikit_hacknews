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

// Font size values corresponding to the 4 segments
- (NSArray *)fontSizeValues {
    return @[@(-4), @(0), @(4), @(8)];
}

// Font size labels
- (NSArray *)fontSizeLabels {
    return @[
        [[LanguageManager sharedManager] localizedString:@"font_small"],
        [[LanguageManager sharedManager] localizedString:@"font_normal"],
        [[LanguageManager sharedManager] localizedString:@"font_large"],
        [[LanguageManager sharedManager] localizedString:@"font_extra_large"]
    ];
}

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
          @"type": @"font_slider"
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

    if ([type isEqualToString:@"options"]) {
        return [sectionData[@"options"] count];
    } else if ([type isEqualToString:@"font_slider"] || [type isEqualToString:@"about"]) {
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

    // Font size slider cell
    if ([type isEqualToString:@"font_slider"]) {
        static NSString *sliderCellId = @"FontSizeSliderCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sliderCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sliderCellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            // Container view for slider and labels
            UIView *containerView = [[UIView alloc] init];
            containerView.translatesAutoresizingMaskIntoConstraints = NO;
            containerView.tag = 100;
            [cell.contentView addSubview:containerView];

            // Create slider
            UISlider *slider = [[UISlider alloc] init];
            slider.translatesAutoresizingMaskIntoConstraints = NO;
            slider.minimumValue = 0;
            slider.maximumValue = 3;
            slider.continuous = YES;
            slider.tag = 101;
            [slider addTarget:self action:@selector(fontSizeSliderChanged:) forControlEvents:UIControlEventValueChanged];
            [containerView addSubview:slider];

            // Create labels container for the 4 segment labels
            UIView *labelsContainer = [[UIView alloc] init];
            labelsContainer.translatesAutoresizingMaskIntoConstraints = NO;
            labelsContainer.tag = 102;
            [containerView addSubview:labelsContainer];

            // Create 4 labels for the segments
            NSArray *labels = [self fontSizeLabels];
            for (int i = 0; i < 4; i++) {
                UILabel *label = [[UILabel alloc] init];
                label.text = labels[i];
                label.font = [UIFont systemFontOfSize:12];
                label.textColor = [UIColor secondaryLabelColor];
                label.textAlignment = NSTextAlignmentCenter;
                label.translatesAutoresizingMaskIntoConstraints = NO;
                label.tag = 200 + i;
                [labelsContainer addSubview:label];
            }

            // Layout constraints
            [NSLayoutConstraint activateConstraints:@[
                [containerView.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:8],
                [containerView.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:16],
                [containerView.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16],
                [containerView.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-8],

                [slider.topAnchor constraintEqualToAnchor:containerView.topAnchor],
                [slider.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor],
                [slider.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor],
                [slider.heightAnchor constraintEqualToConstant:28],

                [labelsContainer.topAnchor constraintEqualToAnchor:slider.bottomAnchor constant:8],
                [labelsContainer.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor],
                [labelsContainer.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor],
                [labelsContainer.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor],
                [labelsContainer.heightAnchor constraintEqualToConstant:20]
            ]];

            // Position labels evenly across the width
            for (int i = 0; i < 4; i++) {
                UILabel *label = [labelsContainer viewWithTag:200 + i];
                [NSLayoutConstraint activateConstraints:@[
                    [label.centerYAnchor constraintEqualToAnchor:labelsContainer.centerYAnchor],
                    [label.widthAnchor constraintEqualToAnchor:labelsContainer.widthAnchor multiplier:0.25]
                ]];

                if (i == 0) {
                    [label.leadingAnchor constraintEqualToAnchor:labelsContainer.leadingAnchor].active = YES;
                } else {
                    [label.leadingAnchor constraintEqualToAnchor:[labelsContainer viewWithTag:199 + i].trailingAnchor].active = YES;
                }
            }
        }

        // Configure slider value based on saved preference
        UIView *containerView = [cell.contentView viewWithTag:100];
        UISlider *slider = (UISlider *)[containerView viewWithTag:101];

        NSInteger savedOffset = [[NSUserDefaults standardUserDefaults] integerForKey:@"AppFontSizeOffset"];
        NSArray *values = [self fontSizeValues];

        // Find the index of the saved value
        NSInteger index = 0;
        for (int i = 0; i < values.count; i++) {
            if ([values[i] integerValue] == savedOffset) {
                index = i;
                break;
            }
        }
        slider.value = index;

        // Get labels container
        UIView *labelsContainer = [containerView viewWithTag:102];

        // Update label colors to highlight selected
        for (int i = 0; i < 4; i++) {
            UILabel *label = (UILabel *)[labelsContainer viewWithTag:200 + i];
            label.textColor = (i == index) ? [UIColor systemOrangeColor] : [UIColor secondaryLabelColor];
            label.font = (i == index) ? [UIFont boldSystemFontOfSize:12] : [UIFont systemFontOfSize:12];
        }

        return cell;
    }

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

    // Standard option cells (Appearance, Language)
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
        LanguageType current = [LanguageManager sharedManager].currentLanguage;
        LanguageType optionLang = [option[@"value"] integerValue];
        isSelected = (current == optionLang);
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
        for (UIWindow *window in self.view.window.windowScene.windows) {
            window.overrideUserInterfaceStyle = style;
        }
        [[NSUserDefaults standardUserDefaults] setInteger:style forKey:@"AppAppearanceStyle"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    } else if (indexPath.section == 1) { // Language
        LanguageType lang = (LanguageType)value;
        [[LanguageManager sharedManager] setLanguage:lang];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - Font Size Slider

- (void)fontSizeSliderChanged:(UISlider *)slider {
    NSInteger index = (NSInteger)roundf(slider.value);
    NSArray *values = [self fontSizeValues];
    NSInteger value = [values[index] integerValue];

    // Get the cell and containers
    UITableViewCell *cell = (UITableViewCell *)slider.superview.superview.superview;
    UIView *containerView = [cell.contentView viewWithTag:100];
    UIView *labelsContainer = [containerView viewWithTag:102];

    // Update label colors to highlight selected
    for (int i = 0; i < 4; i++) {
        UILabel *label = (UILabel *)[labelsContainer viewWithTag:200 + i];
        label.textColor = (i == index) ? [UIColor systemOrangeColor] : [UIColor secondaryLabelColor];
        label.font = (i == index) ? [UIFont boldSystemFontOfSize:12] : [UIFont systemFontOfSize:12];
    }

    // Save and notify
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:@"AppFontSizeOffset"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"FontSizeChangedNotification" object:nil];
}

@end
