#import "HNStoryCell.h"
#import "HNItem.h"
#import "LanguageManager.h"

@interface HNStoryCell ()

@property (nonatomic, strong) UIView *containerActionView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *domainLabel;
@property (nonatomic, strong) UILabel *metaLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *commentLabel;

- (void)updateShadow;

@end

@implementation HNStoryCell

+ (NSString *)reuseIdentifier {
    return @"HNStoryCell";
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor]; // Table view background
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // Card Container
    _containerActionView = [[UIView alloc] init];
    _containerActionView.translatesAutoresizingMaskIntoConstraints = NO;
    _containerActionView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    _containerActionView.layer.cornerRadius = 12;
    _containerActionView.layer.masksToBounds = NO;
    
    // Shadow
    _containerActionView.layer.shadowOffset = CGSizeMake(0, 2);
    _containerActionView.layer.shadowRadius = 4;
    [self updateShadow];
    
    [self.contentView addSubview:_containerActionView];
    
    // Domain (Top Right)
    _domainLabel = [[UILabel alloc] init];
    _domainLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _domainLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
    _domainLabel.textColor = [UIColor secondaryLabelColor];
    _domainLabel.textAlignment = NSTextAlignmentRight;
    [_containerActionView addSubview:_domainLabel];
    
    // Title
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    _titleLabel.textColor = [UIColor labelColor];
    _titleLabel.numberOfLines = 0;
    [_containerActionView addSubview:_titleLabel];
    
    // Score (Orange)
    _scoreLabel = [[UILabel alloc] init];
    _scoreLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _scoreLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
    _scoreLabel.textColor = [UIColor systemOrangeColor];
    [_containerActionView addSubview:_scoreLabel];
    
    // Meta (Author • Time)
    _metaLabel = [[UILabel alloc] init];
    _metaLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _metaLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    _metaLabel.textColor = [UIColor tertiaryLabelColor];
    [_containerActionView addSubview:_metaLabel];
    
    // Comments
    _commentLabel = [[UILabel alloc] init];
    _commentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _commentLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    _commentLabel.textColor = [UIColor secondaryLabelColor];
    [_containerActionView addSubview:_commentLabel];

    // Constraints
    CGFloat padding = 16.0;
    
    [NSLayoutConstraint activateConstraints:@[
        // Container
        [_containerActionView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8],
        [_containerActionView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [_containerActionView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [_containerActionView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8],
        
        // Domain
        [_domainLabel.topAnchor constraintEqualToAnchor:_containerActionView.topAnchor constant:padding],
        [_domainLabel.trailingAnchor constraintEqualToAnchor:_containerActionView.trailingAnchor constant:-padding],
        
        // Title
        [_titleLabel.topAnchor constraintEqualToAnchor:_domainLabel.bottomAnchor constant:4],
        [_titleLabel.leadingAnchor constraintEqualToAnchor:_containerActionView.leadingAnchor constant:padding],
        [_titleLabel.trailingAnchor constraintEqualToAnchor:_containerActionView.trailingAnchor constant:-padding],
        
        // Score (Bottom Left)
        [_scoreLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:12],
        [_scoreLabel.leadingAnchor constraintEqualToAnchor:_containerActionView.leadingAnchor constant:padding],
        [_scoreLabel.bottomAnchor constraintEqualToAnchor:_containerActionView.bottomAnchor constant:-padding],
        
        // Meta (After Score)
        [_metaLabel.centerYAnchor constraintEqualToAnchor:_scoreLabel.centerYAnchor],
        [_metaLabel.leadingAnchor constraintEqualToAnchor:_scoreLabel.trailingAnchor constant:8],
        
        // Comments (Bottom Right)
        [_commentLabel.centerYAnchor constraintEqualToAnchor:_scoreLabel.centerYAnchor],
        [_commentLabel.trailingAnchor constraintEqualToAnchor:_containerActionView.trailingAnchor constant:-padding],
        
        // Priority for compression to keep title visible
        [_titleLabel.bottomAnchor constraintLessThanOrEqualToAnchor:_scoreLabel.topAnchor constant:-12]
    ]];
}

- (void)setItem:(HNItem *)item {
    _item = item;
    
    _titleLabel.text = item.title;
    
    // Domain logic
    if (item.url) {
        NSURL *url = [NSURL URLWithString:item.url];
        _domainLabel.text = url.host ? [[url.host stringByReplacingOccurrencesOfString:@"www." withString:@""] uppercaseString] : @"WEB";
    } else {
        _domainLabel.text = @"HN";
    }
    
    _scoreLabel.text = [NSString stringWithFormat:@"▲ %ld", (long)item.score];
    
    // Time formatting
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval timeSince = now - item.time;
    NSString *timeString = @"";
    if (timeSince < 60) {
        timeString = LS(@"time_just_now");
    } else if (timeSince < 3600) {
        timeString = [NSString stringWithFormat:@"%ld%@", (long)(timeSince / 60), LS(@"time_m")];
    } else if (timeSince < 86400) {
        timeString = [NSString stringWithFormat:@"%ld%@", (long)(timeSince / 3600), LS(@"time_h")];
    } else {
        timeString = [NSString stringWithFormat:@"%ld%@", (long)(timeSince / 86400), LS(@"time_d")];
    }
    
    _metaLabel.text = [NSString stringWithFormat:@"%@%@ • %@", LS(@"author_prefix"), item.by, timeString];
    
    _commentLabel.text = [NSString stringWithFormat:@"💬 %ld", (long)item.descendants];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.containerActionView.transform = highlighted ? CGAffineTransformMakeScale(0.97, 0.97) : CGAffineTransformIdentity;
    }];
}

#pragma mark - Theme Management

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    // 如果颜色外观发生变化（比如从浅色切换到深色），则更新阴影
    if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
        [self updateShadow];
    }
}

- (void)updateShadow {
    // 根据当前的模式设置阴影或边框
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        // Dark Mode: 阴影不可见，使用微弱的边框描边增加层次感
        self.containerActionView.layer.shadowOpacity = 0.0;
        self.containerActionView.layer.borderColor = [UIColor separatorColor].CGColor;
        self.containerActionView.layer.borderWidth = 0.5;
    } else {
        // Light Mode: 使用阴影
        self.containerActionView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.containerActionView.layer.shadowOpacity = 0.08;
        self.containerActionView.layer.borderColor = [UIColor clearColor].CGColor;
        self.containerActionView.layer.borderWidth = 0.0;
    }
}

@end
