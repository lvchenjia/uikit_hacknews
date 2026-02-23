#import "HNStoryCell.h"
#import "HNItem.h"
#import "LanguageManager.h"

#import "HNTranslationManager.h"

@interface HNStoryCell ()

@property (nonatomic, strong) UIView *containerActionView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *translatedTitleLabel; // New
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

    // Translated Title
    _translatedTitleLabel = [[UILabel alloc] init];
    _translatedTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _translatedTitleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    _translatedTitleLabel.textColor = [UIColor secondaryLabelColor];
    _translatedTitleLabel.numberOfLines = 2; // Limit to 2 lines
    _translatedTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_containerActionView addSubview:_translatedTitleLabel];
    
    // Score (Orange)
    _scoreLabel = [[UILabel alloc] init];
    _scoreLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _scoreLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
    _scoreLabel.textColor = [UIColor systemOrangeColor];
    [_scoreLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [_containerActionView addSubview:_scoreLabel];
    
    // Meta (Author • Time)
    _metaLabel = [[UILabel alloc] init];
    _metaLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _metaLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    _metaLabel.textColor = [UIColor tertiaryLabelColor];
    [_metaLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [_containerActionView addSubview:_metaLabel];
    
    // Comments
    _commentLabel = [[UILabel alloc] init];
    _commentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _commentLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    _commentLabel.textColor = [UIColor secondaryLabelColor];
    [_commentLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
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
        
        // Translated Title
        [_translatedTitleLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:4],
        [_translatedTitleLabel.leadingAnchor constraintEqualToAnchor:_containerActionView.leadingAnchor constant:padding],
        [_translatedTitleLabel.trailingAnchor constraintEqualToAnchor:_containerActionView.trailingAnchor constant:-padding],
        
        // Score (Bottom Left) -> Variable constraint logic needed if translated title is hidden?
        // Actually, if text is empty and numberOfLines=0, height is 0. But separate padding remains?
        // Let's rely on bottom spacing.
        [_scoreLabel.topAnchor constraintEqualToAnchor:_translatedTitleLabel.bottomAnchor constant:12],
        
        [_scoreLabel.leadingAnchor constraintEqualToAnchor:_containerActionView.leadingAnchor constant:padding],
        [_scoreLabel.bottomAnchor constraintEqualToAnchor:_containerActionView.bottomAnchor constant:-padding],
        
        // Meta (After Score)
        [_metaLabel.centerYAnchor constraintEqualToAnchor:_scoreLabel.centerYAnchor],
        [_metaLabel.leadingAnchor constraintEqualToAnchor:_scoreLabel.trailingAnchor constant:8],
        
        // Comments (Bottom Right)
        [_commentLabel.centerYAnchor constraintEqualToAnchor:_scoreLabel.centerYAnchor],
        [_commentLabel.trailingAnchor constraintEqualToAnchor:_containerActionView.trailingAnchor constant:-padding],
    ]];
    
    [self updateFonts];
}

- (void)updateFonts {
    NSInteger offset = [[NSUserDefaults standardUserDefaults] integerForKey:@"AppFontSizeOffset"];
    
    _titleLabel.font = [UIFont systemFontOfSize:17 + offset weight:UIFontWeightSemibold];
    _translatedTitleLabel.font = [UIFont systemFontOfSize:15 + offset weight:UIFontWeightRegular];
    _domainLabel.font = [UIFont systemFontOfSize:11 + offset weight:UIFontWeightMedium];
    _scoreLabel.font = [UIFont systemFontOfSize:12 + offset weight:UIFontWeightBold];
    _metaLabel.font = [UIFont systemFontOfSize:12 + offset weight:UIFontWeightRegular];
    _commentLabel.font = [UIFont systemFontOfSize:12 + offset weight:UIFontWeightMedium];
}

- (void)setItem:(HNItem *)item {
    _item = item;
    
    [self updateFonts];
    
    _titleLabel.text = item.title;
    
    // Translation Logic
    LanguageType currentLang = [LanguageManager sharedManager].currentLanguage;
    NSString *systemLangPrefix = [[NSLocale currentLocale].languageCode lowercaseString];
    BOOL isEnglishContext = (currentLang == LanguageTypeEnglish) || (currentLang == LanguageTypeSystem && [systemLangPrefix hasPrefix:@"en"]);
    
    // Only translate if NOT English context
    if (!isEnglishContext) {
        _translatedTitleLabel.hidden = NO;
        if (item.translatedTitle) {
            _translatedTitleLabel.text = item.translatedTitle;
        } else {
            _translatedTitleLabel.text = @"Translating...";
            
            // Determine target lang code
            NSString *targetCode = @"zh-CN"; 
            if (currentLang == LanguageTypeChinese) {
                targetCode = @"zh-CN";
            } else if (currentLang == LanguageTypeSystem) {
                if ([systemLangPrefix hasPrefix:@"zh"]) targetCode = @"zh-CN";
                // Add more logic if needed
            }
            
            __weak typeof(self) weakSelf = self;
            [[HNTranslationManager sharedManager] translateText:item.title toLanguage:targetCode completion:^(NSString * _Nullable translatedText, NSError * _Nullable error) {
                if (translatedText) {
                    item.translatedTitle = translatedText;
                    // Check if cell is still showing the same item
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (weakSelf.item == item) {
                            weakSelf.translatedTitleLabel.text = translatedText;
                            [weakSelf setNeedsLayout];
                            if (weakSelf.onTranslationCompleted) {
                                weakSelf.onTranslationCompleted();
                            }
                        }
                    });
                }
            }];
        }
    } else {
        _translatedTitleLabel.text = nil;
        _translatedTitleLabel.hidden = YES;
    }
    
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
    
    _metaLabel.text = [NSString stringWithFormat:@"%@ • %@", item.by, timeString];
    
    // Comment Icon (Flat style)
    if (@available(iOS 13.0, *)) {
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        UIImage *icon = [UIImage systemImageNamed:@"bubble.right"];
        if (icon) {
            attachment.image = icon;
            CGFloat fontHeight = _commentLabel.font.capHeight;
            // Adjust bounds slightly for vertical alignment
            attachment.bounds = CGRectMake(0, -2, fontHeight + 4, fontHeight + 2);
            
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
            
            // Add spacing and count
            [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %ld", (long)item.descendants]]];
            
            // Apply color to the whole string (including attachment if template)
            [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor secondaryLabelColor] range:NSMakeRange(0, attrStr.length)];
            
            _commentLabel.attributedText = attrStr;
        } else {
            _commentLabel.text = [NSString stringWithFormat:@"💬 %ld", (long)item.descendants];
        }
    } else {
         _commentLabel.text = [NSString stringWithFormat:@"💬 %ld", (long)item.descendants];
    }
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
