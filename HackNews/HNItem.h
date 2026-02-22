#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HNItem : NSObject

@property (nonatomic, assign) NSInteger itemId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *by;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, copy, nullable) NSString *url;
@property (nonatomic, assign) NSInteger descendants; // Comment count

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
