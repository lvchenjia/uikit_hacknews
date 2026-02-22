#import <Foundation/Foundation.h>
#import "HNItem.h"

NS_ASSUME_NONNULL_BEGIN

// 定义新闻类型枚举
typedef NS_ENUM(NSInteger, HNFeedType) {
    HNFeedTypeTop = 0,
    HNFeedTypeNew,
    HNFeedTypeBest,
    HNFeedTypeAsk,
    HNFeedTypeShow,
    HNFeedTypeJob
};

// 定义回调 Block，方便在网络请求完成后通知调用者
// stories: 请求成功返回的数据数组；error: 如果失败返回的错误信息
typedef void(^HNStoriesCompletion)(NSArray<HNItem *> * _Nullable stories, NSError * _Nullable error);
// ids: 只有 ID 列表的回调
typedef void(^HNIdsCompletion)(NSArray<NSNumber *> * _Nullable ids, NSError * _Nullable error);

/**
 * HNNetworkManager: 网络管理类
 * 负责所有与 Hacker News API 的通信
 * 设计模式：单例模式 (Singleton) + 回调 (Block/Closure)
 */
@interface HNNetworkManager : NSObject

// 获取单例实例，保证全局只有一个网络管理者
+ (instancetype)sharedManager;

// 获取特定类型的新闻 ID 列表
- (void)fetchStoryIdsForType:(HNFeedType)type completion:(HNIdsCompletion)completion;

// 根据一组 ID 获取具体的新闻详情
// 使用 Dispatch Group 并发请求提高效率
- (void)fetchItemsWithIds:(NSArray<NSNumber *> *)ids completion:(HNStoriesCompletion)completion;

@end

NS_ASSUME_NONNULL_END
