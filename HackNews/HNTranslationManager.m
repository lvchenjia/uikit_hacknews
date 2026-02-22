//
//  HNTranslationManager.m
//  HackNews
//
//  Created by horse on 2026/2/22.
//

#import "HNTranslationManager.h"

@interface HNTranslationManager ()
@property (nonatomic, strong) NSCache *cache; // Simple cache for translations
@end

@implementation HNTranslationManager

+ (instancetype)sharedManager {
    static HNTranslationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HNTranslationManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cache = [[NSCache alloc] init];
        _cache.countLimit = 500;
    }
    return self;
}

- (void)translateText:(NSString *)text toLanguage:(NSString *)targetCode completion:(void (^)(NSString * _Nullable translatedText, NSError * _Nullable error))completion {
    if (text.length == 0 || targetCode.length == 0) {
        return completion(nil, [NSError errorWithDomain:@"HNTranslationError" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid input"}]);
    }
    
    NSString *cacheKey = [NSString stringWithFormat:@"%@_%@", text, targetCode];
    NSString *cachedTranslation = [self.cache objectForKey:cacheKey];
    if (cachedTranslation) {
        return completion(cachedTranslation, nil);
    }
    
    // Using Google Translate 'gtx' endpoint for free translation (unofficial, demo purposes)
    // https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=zh-CN&dt=t&q=hello
    
    NSString *urlString = [NSString stringWithFormat:@"https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=%@&dt=t&q=%@", targetCode, [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        return completion(nil, [NSError errorWithDomain:@"HNTranslationError" code:-2 userInfo:@{NSLocalizedDescriptionKey: @"Invalid URL"}]);
    }
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Translation network error: %@", error);
            return completion(nil, error);
        }
        
        if (!data) {
            return completion(nil, [NSError errorWithDomain:@"HNTranslationError" code:-3 userInfo:@{NSLocalizedDescriptionKey: @"No data"}]);
        }
        
        NSError *jsonError;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, jsonError);
            });
            return;
        }
        
        if ([json isKindOfClass:[NSArray class]]) {
            NSArray *result = (NSArray *)json;
            if (result.count > 0) {
                // The first element is the array of sentence parts
                
                // Usually [[[result objectAtIndex:0] objectAtIndex:0] objectAtIndex:0] is the translated text
                id sentences = result[0];
                if ([sentences isKindOfClass:[NSArray class]]) {
                    NSMutableString *finalTranslation = [NSMutableString string];
                    for (id part in sentences) {
                        if ([part isKindOfClass:[NSArray class]] && [part count] > 0) {
                             NSString *segment = part[0];
                             if ([segment isKindOfClass:[NSString class]]) {
                                 [finalTranslation appendString:segment];
                             }
                        }
                    }
                    
                    if (finalTranslation.length > 0) {
                        NSString *res = [finalTranslation copy];
                        [self.cache setObject:res forKey:cacheKey];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(res, nil);
                        });
                        return;
                    }
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, [NSError errorWithDomain:@"HNTranslationError" code:-4 userInfo:@{NSLocalizedDescriptionKey: @"Unexpected API format"}]);
        });
    }];
    
    [task resume];
}

@end
