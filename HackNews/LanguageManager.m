//
//  LanguageManager.m
//  HackNews
//
//  Created by horse on 2026/2/22.
//

#import "LanguageManager.h"
#import <UIKit/UIKit.h>

static NSString *const kLanguageKey = @"AppLanguage";
static NSString *const kSystemLanguage = @"System";

@interface LanguageManager ()

@property (nonatomic, strong, readwrite) NSBundle *bundle;

@end

@implementation LanguageManager

+ (instancetype)sharedManager {
    static LanguageManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LanguageManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Load stored language preference
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *langCode = [defaults stringForKey:kLanguageKey];
        
        if ([langCode isEqualToString:@"en"]) {
            _currentLanguage = LanguageTypeEnglish;
            [self loadBundle:@"en"];
        } else if ([langCode isEqualToString:@"zh-Hans"]) {
            _currentLanguage = LanguageTypeChinese;
            [self loadBundle:@"zh-Hans"];
        } else {
            // Default to system
            _currentLanguage = LanguageTypeSystem;
             // Check system locale, fallback to English if not known
            NSArray<NSString *> *languages = [NSLocale preferredLanguages];
            NSString *systemLang = languages.firstObject;
            
            if ([systemLang hasPrefix:@"zh-Hans"]) {
                [self loadBundle:@"zh-Hans"];
            } else {
                [self loadBundle:@"en"]; // Or Base
            }
        }
    }
    return self;
}

- (void)loadBundle:(NSString *)langCode {
    NSString *path = [[NSBundle mainBundle] pathForResource:langCode ofType:@"lproj"];
    if (path) {
        self.bundle = [NSBundle bundleWithPath:path];
    } else {
        self.bundle = [NSBundle mainBundle];
    }
}

- (NSString *)localizedString:(NSString *)key {
    return [self.bundle localizedStringForKey:key value:@"" table:nil];
}

- (void)setLanguage:(LanguageType)language {
    _currentLanguage = language;
    
    NSString *langCode = nil;
    switch (language) {
        case LanguageTypeEnglish:
            langCode = @"en";
            break;
        case LanguageTypeChinese:
            langCode = @"zh-Hans";
            break;
        case LanguageTypeSystem:
        default:
            langCode = nil; // Will remove from storage
            break;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (langCode) {
        [defaults setObject:langCode forKey:kLanguageKey];
        [self loadBundle:langCode];
        
        // Also set standard AppleLanguages just in case
        [defaults setObject:@[langCode] forKey:@"AppleLanguages"];
    } else {
        [defaults removeObjectForKey:kLanguageKey];
        [defaults removeObjectForKey:@"AppleLanguages"];
        
        // Fallback logic
        NSArray<NSString *> *languages = [NSLocale preferredLanguages];
        NSString *systemLang = languages.firstObject;
        if ([systemLang hasPrefix:@"zh-Hans"]) {
             [self loadBundle:@"zh-Hans"];
         } else {
             [self loadBundle:@"en"];
         }
    }
    [defaults synchronize];
    
    // Trigger root view controller reload
    [self resetRootViewController];
}

- (void)resetRootViewController {
    // Get the window scene
    // This is simplified but works for single window apps
    UIWindowScene *scene = (UIWindowScene *)UIApplication.sharedApplication.connectedScenes.anyObject;
    UIWindow *window = scene.windows.firstObject;
    if (window.rootViewController) {
        // Create a new instance of the root view controller
        // This requires importing SceneDelegate or just relying on SceneDelegate logic?
        // Let's post a notification instead, SceneDelegate will listen
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LanguageChangedNotification" object:nil];
    }
}

@end
