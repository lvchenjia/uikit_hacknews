#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HNItem;

@interface HNStoryCell : UITableViewCell

@property (nonatomic, strong) HNItem *item;
@property (nonatomic, copy) void (^onTranslationCompleted)(void);

+ (NSString *)reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
