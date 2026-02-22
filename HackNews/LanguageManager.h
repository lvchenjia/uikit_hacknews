//
//  LanguageManager.h
//  HackNews
//
//  Created by horse on 2026/2/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LanguageType) {
    LanguageTypeSystem,   // 跟随系统
    LanguageTypeEnglish,  // English
    LanguageTypeChinese   // 简体中文
};

/**
 * Replace NSLocalizedString with this macro to support instant language switching.
 */
#define LS(key) [[LanguageManager sharedManager] localizedString:key]

@interface LanguageManager : NSObject

@property (nonatomic, assign) LanguageType currentLanguage;
@property (nonatomic, strong, readonly) NSBundle *bundle;

+ (instancetype)sharedManager;

/**
 * Get localized string from the current bundle
 */
- (NSString *)localizedString:(NSString *)key;

/**
 * Resets the language preference
 */
- (void)setLanguage:(LanguageType)language;

@end

NS_ASSUME_NONNULL_END
