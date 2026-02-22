//
//  SettingsViewController.m
//  HackNews
//
//  Created by horse on 2026/2/22.
//

#import "SettingsViewController.h"
#import "LanguageManager.h"

@interface SettingsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *sections;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [[LanguageManager sharedManager] localizedString:@"settings_title"];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // Define sections structure
    self.sections = @[
        @{@"title": [[LanguageManager sharedManager] localizedString:@"settings_appearance"],
          @"options": @[
              @{@"title": [[LanguageManager sharedManager] localizedString:@"settings_system"], @"value": @(UIUserInterfaceStyleUnspecified)},
              @{@"title": [[LanguageManager sharedManager] localizedString:@"settings_light"], @"value": @(UIUserInterfaceStyleLight)},
              @{@"title": [[LanguageManager sharedManager] localizedString:@"settings_dark"], @"value": @(UIUserInterfaceStyleDark)}
          ]
        },
        @{@"title": [[LanguageManager sharedManager] localizedString:@"settings_language"],
          @"options": @[
              @{@"title": [[LanguageManager sharedManager] localizedString:@"settings_system"], @"value": @(LanguageTypeSystem)},
              @{@"title": @"English", @"value": @(LanguageTypeEnglish)},
              @{@"title": @"简体中文", @"value": @(LanguageTypeChinese)}
          ]
        }
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
    return [self.sections[section][@"options"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section][@"title"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SettingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    NSDictionary *option = self.sections[indexPath.section][@"options"][indexPath.row];
    cell.textLabel.text = option[@"title"];
    
    // Checkmark logic
    BOOL isSelected = NO;
    if (indexPath.section == 0) {
        UIUserInterfaceStyle currentStyle = self.view.window.windowScene.windows.firstObject.overrideUserInterfaceStyle;
        UIUserInterfaceStyle optionStyle = [option[@"value"] integerValue];
        isSelected = (currentStyle == optionStyle);
    } else {
        LanguageType currentLang = [LanguageManager sharedManager].currentLanguage;
        LanguageType optionLang = [option[@"value"] integerValue];
        isSelected = (currentLang == optionLang);
    }
    
    cell.accessoryType = isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *option = self.sections[indexPath.section][@"options"][indexPath.row];
    NSInteger value = [option[@"value"] integerValue];
    
    if (indexPath.section == 0) { // Appearance
        UIUserInterfaceStyle style = (UIUserInterfaceStyle)value;
        // Set globally for all windows in the scene
        for (UIWindow *window in self.view.window.windowScene.windows) {
            window.overrideUserInterfaceStyle = style;
        }
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    } else { // Language
        LanguageType lang = (LanguageType)value;
        [[LanguageManager sharedManager] setLanguage:lang];
        // The app will reload root view controller via notification, but we might want to alert if needed
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
}

@end
