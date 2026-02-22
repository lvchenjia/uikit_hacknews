#import "HNItem.h"

@implementation HNItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _itemId = [dictionary[@"id"] integerValue];
        _title = dictionary[@"title"] ?: @"No Title";
        _by = dictionary[@"by"] ?: @"Unknown";
        _score = [dictionary[@"score"] integerValue];
        _time = [dictionary[@"time"] doubleValue];
        _url = dictionary[@"url"];
        _descendants = [dictionary[@"descendants"] integerValue];
    }
    return self;
}

@end
