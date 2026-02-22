#import "HNNetworkManager.h"

@implementation HNNetworkManager

// 单例模式标准写法 (Thread-safe)
+ (instancetype)sharedManager {
    static HNNetworkManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HNNetworkManager alloc] init];
    });
    return manager;
}

// 获取特定类型的新闻 ID
- (void)fetchStoryIdsForType:(HNFeedType)type completion:(HNIdsCompletion)completion {
    NSString *endpoint = @"";
    switch (type) {
        case HNFeedTypeTop: endpoint = @"topstories"; break;
        case HNFeedTypeNew: endpoint = @"newstories"; break;
        case HNFeedTypeBest: endpoint = @"beststories"; break;
        case HNFeedTypeAsk: endpoint = @"askstories"; break;
        case HNFeedTypeShow: endpoint = @"showstories"; break;
        case HNFeedTypeJob: endpoint = @"jobstories"; break;
        default: endpoint = @"topstories"; break;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://hacker-news.firebaseio.com/v0/%@.json", endpoint];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 创建一个网络任务 (Data Task)
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 1. 如果有网络错误，直接返回
        if (error) {
            completion(nil, error);
            return;
        }
        
        // 2. 解析 JSON 数据为 NSArray
        NSError *jsonError;
        NSArray *ids = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (ids && [ids isKindOfClass:[NSArray class]]) {
            // 成功：返回 ID 列表
            completion(ids, nil);
        } else {
            // 失败：构造一个自定义错误
            completion(nil, [NSError errorWithDomain:@"HNError" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid JSON data"}]);
        }
    }] resume]; // 别忘了调用 resume 启动任务
}

/**
 * 批量获取新闻详情
 * 并发请求多个 ID，等全部完成后再一次性返回
 * 技术点：Dispatch Group (GCD)
 */
- (void)fetchItemsWithIds:(NSArray<NSNumber *> *)ids completion:(HNStoriesCompletion)completion {
    // Dispatch Group 用于监控多个异步任务的完成状态
    dispatch_group_t group = dispatch_group_create();
    
    // 用来存放结果的数组，因为是多线程写入，需要注意线程安全
    NSMutableArray *fetchedItems = [NSMutableArray array];
    
    // 遍历每一个 ID 发起请求
    for (NSNumber *storyId in ids) {
        dispatch_group_enter(group); // 标记一个任务开始
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://hacker-news.firebaseio.com/v0/item/%@.json", storyId]];
        
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                    // 转模型 JSON -> Model
                    HNItem *item = [[HNItem alloc] initWithDictionary:dict];
                    
                    // 简单的过滤逻辑：必须有标题
                    if (item.title.length > 0) {
                        // 锁：保证多线程安全地向数组添加对象
                        @synchronized (fetchedItems) {
                            [fetchedItems addObject:item];
                        }
                    }
                }
            }
            dispatch_group_leave(group); // 标记一个任务结束
        }] resume];
    }
    
    // 当所有 enter 的任务都 leave 后，这个 block 会被调用
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 网络请求回来的顺序是不确定的，这里需要按原来 ID 的顺序重新排序
        [fetchedItems sortUsingComparator:^NSComparisonResult(HNItem *obj1, HNItem *obj2) {
            NSUInteger idx1 = [ids indexOfObject:@(obj1.itemId)];
            NSUInteger idx2 = [ids indexOfObject:@(obj2.itemId)];
            // 保持原始顺序
            return idx1 < idx2 ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        // 完成回调，把整理好的数据给 VC
        completion(fetchedItems, nil);
    });
}

@end
