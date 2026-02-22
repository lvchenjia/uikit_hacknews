//
//  HNTranslationManager.h
//  HackNews
//
//  Created by horse on 2026/2/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HNTranslationManager : NSObject

+ (instancetype)sharedManager;

/**
 *  Translate a given text to the target language.
 *  Uses Google Translate free API for demonstration.
 *
 *  @param text The text to translate.
 *  @param targetCode The target language code (e.g., "zh-CN", "en").
 *  @param completion Block called with the translated string or error.
 */
- (void)translateText:(NSString *)text toLanguage:(NSString *)targetCode completion:(void (^)(NSString * _Nullable translatedText, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
