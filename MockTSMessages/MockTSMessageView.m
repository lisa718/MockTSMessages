//
//  MockTSMessageView.m
//  MockTSMessages
//
//  Created by baidu on 2017/11/26.
//  Copyright © 2017年 baidu. All rights reserved.
//

#import "MockTSMessageView.h"
#import "MockTSMessage.h"
#import "HexColor.h"

//#warning iPhone X and status bar not right

NSString * const kTypeKeySuccess = @"success";
NSString * const kTypeKeyError = @"error";
NSString * const kTypeKeyFailed = @"failed";
NSString * const kTypeKeyMessage = @"message";

static NSDictionary *defaultAppearceDictionary = nil;

#define IS_IPHONEX (([[UIScreen mainScreen] bounds].size.height - 812) ? NO : YES)


@interface MockTSMessageView () {
    
}

// model
@property (nonatomic,copy) NSString            * _Nonnull title;
@property (nonatomic,copy) NSString            * _Nullable subtitle;
@property (nonatomic,strong) UIImage           * _Nullable image;
@property (nonatomic,assign) MockTSMessageType type;

// view
@property (nonatomic,strong) UILabel            *titleLabel;
@property (nonatomic,strong) UILabel            *subtitleLabel;
@property (nonatomic,strong) UIImageView        *iconImageView;
@property (nonatomic,strong) UIVisualEffectView *blurBackgroundImageView;
@property (nonatomic,strong) UIImageView        *closeImageView;

// ges
@property (nonatomic,strong) UITapGestureRecognizer     *tapGes;
@property (nonatomic,strong) UISwipeGestureRecognizer   *swipeGes;

@end

@implementation MockTSMessageView

+ (void)initialize {
    if (self == [MockTSMessageView class]) {
        defaultAppearceDictionary = @{
                                      kTypeKeySuccess:@{
                                              @"titleFontSize":@14,
                                              @"subtitleFontSize":@14,
                                              @"textColor":@"#FFFFFF",
                                              @"imageName":@"mockmessage_prompting_succeed",
                                              @"backgroundColor":@"#8FE092",
                                              @"titleDefault":@"请求成功"
                                              },
                                      kTypeKeyFailed:@{
                                              @"titleFontSize":@14,
                                              @"subtitleFontSize":@14,
                                              @"textColor":@"#FFFFFF",
                                              @"imageName":@"mockmessage_prompting_fail",
                                              @"backgroundColor":@"#FF6F6F",
                                              @"titleDefault":@"请求失败"
                                              },
                                      kTypeKeyError:@{
                                              @"titleFontSize":@14,
                                              @"subtitleFontSize":@14,
                                              @"textColor":@"#FFFFFF",
                                              @"imageName":@"mockmessage_prompting_error",
                                              @"backgroundColor":@"#FFC666",
                                              @"titleDefault":@"操作错误"
                                              },
                                      kTypeKeyMessage:@{
                                              @"titleFontSize":@14,
                                              @"subtitleFontSize":@14,
                                              @"textColor":@"#333333",
                                              @"imageName":@"mockmessage_prompting_message",
                                              @"backgroundColor":@"#E5E5E5",
                                              @"titleDefault":@"提示信息"
                                              }
                                      };
    }
}

- (instancetype _Nonnull )initWithFrame:(CGRect)frame
                                  title:(NSString *_Nullable)title
                               subtitle:(NSString *_Nullable)subtitle
                                  image:(UIImage *_Nullable)image
                                   type:(MockTSMessageType)type {
    
//    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    self = [super initWithEffect:blurEffect];
    self = [super initWithFrame:frame];
    if (self) {
        // set model
        _subtitle = [subtitle copy];
        _type = type;
        _paddingTop = 11;
        
        self.backgroundColor = [UIColor clearColor];
//        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);

#warning no blur effect
        // background
        self.blurBackgroundImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
        self.blurBackgroundImageView.backgroundColor = [self defaultBackgroudColor];
        self.blurBackgroundImageView.alpha = 0.75;
        self.blurBackgroundImageView.frame = self.bounds;
        [self addSubview:self.blurBackgroundImageView];
//        self.backgroundColor = [self defaultBackgroudColor];
        
        // set view
        // titleLabel
        _title = title ? [title copy] : [self defaultTitle];
        self.titleLabel.text = _title;
        [self addSubview:self.titleLabel];
        
        // subtitleLabel
        if (subtitle && ![subtitle isEqualToString:@""]) {
            self.subtitleLabel.text = subtitle;
            [self addSubview:self.subtitleLabel];
        }
        
        // image
        _image = image ? image : [self defaultImage];
        if (_image) {
            [self.iconImageView setImage:_image];
            [self addSubview:self.iconImageView];
        }
        [self addSubview:self.closeImageView];
    
        // 布局
        [self configLayout];
        
    }
    return self;
}


#pragma mark - layout
- (void)layoutSubviews {
    [super layoutSubviews];
    [self configLayout];
}

- (void)setPaddingTop:(CGFloat)paddingTop {
    _paddingTop = _paddingTop?paddingTop:11;
    [self setNeedsLayout];
}
- (void)configLayout {
//    CGFloat paddingTop = self.paddingTop;//35;
    CGFloat paddingBottom = 11;//30;
    CGFloat paddingLeft = 20;//40;
    CGFloat titleSpace = 5;//10;
    
    CGFloat totalHeight = self.paddingTop;
    
    // title can not be nil
    CGFloat titleLeftX = paddingLeft*2;
    CGFloat titleLeftY = self.paddingTop;
    if (self.image) {
        titleLeftX += self.image.size.width;
    }
    
    CGFloat titleWidth = self.bounds.size.width - titleLeftX - paddingLeft;
    self.titleLabel.frame = CGRectMake(titleLeftX, titleLeftY, titleWidth, 0);
    [self.titleLabel sizeToFit];
    
    totalHeight += CGRectGetHeight(self.titleLabel.frame) +  paddingBottom;
    
    
    //subtitle
    if (self.subtitle) {
        CGFloat subtitleLeftY = CGRectGetMaxY(self.titleLabel.frame) + titleSpace;
        self.subtitleLabel.frame = CGRectMake(titleLeftX, subtitleLeftY, titleWidth, 0);
        [self.subtitleLabel sizeToFit];
         totalHeight += CGRectGetHeight(self.subtitleLabel.frame) + titleSpace;
    }
    
    //
    self.frame = CGRectMake(0, self.frame.origin.y, self.frame.size.width, totalHeight);
    self.blurBackgroundImageView.frame = self.bounds;
    
    // image 居中
    if (self.image) {
        if (IS_IPHONEX) {
            self.iconImageView.frame = CGRectMake(paddingLeft, CGRectGetMinY(self.titleLabel.frame), self.image.size.width, self.image.size.height);
        }
        else {
            self.iconImageView.frame = CGRectMake(paddingLeft,
                                              self.bounds.size.height/2.0 - self.image.size.height/2.0,
                                              self.image.size.width,
                                              self.image.size.height);
        }
    }
    
    // close button
    UIImage * closeImage = self.closeImageView.image;
    self.closeImageView.frame = CGRectMake(self.bounds.size.width - closeImage.size.width - 7,
                                           self.paddingTop,
                                           closeImage.size.width,
                                           closeImage.size.height);
    
}

- (NSString *)currentTypeKey {
    if (self.type == MockTSMessageType_Success) {
        return kTypeKeySuccess;
    }
    else if (self.type == MockTSMessageType_Failed) {
        return kTypeKeyFailed;
    }
    else if (self.type == MockTSMessageType_Error) {
        return kTypeKeyError;
    }
    else if (self.type == MockTSMessageType_Message) {
        return kTypeKeyMessage;
    }
    return kTypeKeyMessage;
}
- (NSString *)defaultTitle {
    NSString *key = [self currentTypeKey];
    return defaultAppearceDictionary[key][@"titleDefault"];
}

- (UIImage *)defaultImage {
    
    NSString *key = [self currentTypeKey];
    return [UIImage imageNamed:defaultAppearceDictionary[key][@"imageName"] inBundle:nil compatibleWithTraitCollection:nil];
}

- (UIColor *)defaultBackgroudColor {
    NSString *key = [self currentTypeKey];
    return [UIColor colorWithHexString:defaultAppearceDictionary[key][@"backgroundColor"] alpha:1];
}


#pragma mark - events
- (void)addTarget:(nonnull id)target
           action:(nonnull SEL)action
         forEvent:(MockTSMessageViewEvent)event {
    NSParameterAssert(target);
    NSParameterAssert(action);
    if (event == MockTSMessageViewEvent_Tap) {
        if (self.tapGes == nil) {
            self.tapGes = [[UITapGestureRecognizer alloc] init];
            [self addGestureRecognizer:self.tapGes];
        }
        [self.tapGes addTarget:target action:action];
    }
    else if (event == MockTSMessageViewEvent_Swipe_Up || event == MockTSMessageViewEvent_Swipe_Down) {
        if (self.swipeGes == nil) {
            self.swipeGes = [[UISwipeGestureRecognizer alloc] init];
            [self.swipeGes setDirection:(event == MockTSMessageViewEvent_Swipe_Up)?UISwipeGestureRecognizerDirectionUp:UISwipeGestureRecognizerDirectionDown];
            [self addGestureRecognizer:self.swipeGes];
        }
        [self.swipeGes addTarget:target action:action];
    }
}
#pragma mark - getters & setters

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor colorWithHexString:defaultAppearceDictionary[[self currentTypeKey]][@"textColor"] alpha:1];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        NSNumber * fontSize = defaultAppearceDictionary[[self currentTypeKey]][@"titleFontSize"];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:[fontSize floatValue]]];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (_subtitleLabel == nil) {
        _subtitleLabel = [UILabel new];
        _subtitleLabel.textColor = [UIColor colorWithHexString:defaultAppearceDictionary[[self currentTypeKey]][@"textColor"] alpha:1.0];
        _subtitleLabel.textAlignment = NSTextAlignmentLeft;
        NSNumber * fontSize = defaultAppearceDictionary[[self currentTypeKey]][@"subtitleFontSize"];
        [_subtitleLabel setFont:[UIFont systemFontOfSize:[fontSize floatValue]]];
        [_subtitleLabel setBackgroundColor:[UIColor clearColor]];
        _subtitleLabel.numberOfLines = 0;
        _subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _subtitleLabel;
}

- (UIImageView *)iconImageView {
    if(_iconImageView == nil) {
        _iconImageView = [UIImageView new];
    }
    return _iconImageView;
}

- (UIImageView *)closeImageView {
    if(_closeImageView == nil) {
        _closeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mockmessage_prompting_close" inBundle:nil compatibleWithTraitCollection:nil]];
    }
    return _closeImageView;
}

- (UIVisualEffectView *)blurBackgroundImageView {
    if(_blurBackgroundImageView == nil) {
        // blur effect
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _blurBackgroundImageView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];

    }
    return _blurBackgroundImageView;
}

#pragma mark -  UI_APPEARANCE_SELECTOR
- (void)setTitleFont:(UIFont *)title_font {
    _titleFont = title_font;
    [self.titleLabel setFont:title_font];
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    [self.titleLabel setTextColor:titleColor];
}

- (void)setSubtitleFont:(UIFont *)subtitle_font {
    _subtitleFont = subtitle_font;
    [self.subtitleLabel setFont:subtitle_font];
}

- (void)setSubtitleColor:(UIColor *)subtitleColor {
    _subtitleColor = subtitleColor;
    [self.subtitleLabel setTextColor:subtitleColor];
}

- (void)setSuccessIcon:(UIImage *)successIcon {
    _successIcon = successIcon;
    _image = successIcon?successIcon:[self defaultImage];
}

- (void)setFailedIcon:(UIImage *)failedIcon {
    _failedIcon = failedIcon;
    _image = failedIcon?failedIcon:[self defaultImage];
}

-(void)setErrorIcon:(UIImage *)errorIcon {
    _errorIcon = errorIcon;
    _image = errorIcon?errorIcon:[self defaultImage];
}

- (void)setMessageIcon:(UIImage *)messageIcon {
    _messageIcon = messageIcon;
    _image = messageIcon?messageIcon:[self defaultImage];
}

- (void)setCloseIcon:(UIImage *)closeIcon {
    _closeIcon = closeIcon;
    [self.closeImageView setImage:closeIcon];
}

@end



