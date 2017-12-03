//
//  MockTSMessageOperation.m
//  MockTSMessages
//
//  Created by baidu on 2017/11/26.
//  Copyright © 2017年 baidu. All rights reserved.
//

#import "MockTSMessageOperation.h"
#import "MockTSMessage.h"
#import "MockTSMessageView.h"

const NSTimeInterval kAnimationDuration = 0.2;

@interface MockTSMessageOperation () {
    
}
// NSOperation
@property (nonatomic,assign,getter=isAsynchronous) BOOL asynchronous API_AVAILABLE(macos(10.8), ios(7.0), watchos(2.0), tvos(9.0));
@property (nonatomic,assign,getter=isCancelled) BOOL cancelled;
@property (nonatomic,assign,getter=isFinished) BOOL finished;
@property (nonatomic,assign,getter=isExecuting) BOOL executing;


// model
@property (nonatomic,weak)   UIViewController       *attachedViewController;
@property (nonatomic,copy)   NSString               *title;
@property (nonatomic,copy)   NSString               *subtitle;
@property (nonatomic,strong) UIImage                *hintIcon;
@property (nonatomic,assign) MockTSMessageType      type;
@property (nonatomic,assign) NSTimeInterval         durationSecs;
@property (nonatomic,assign) MockTSMessagePosition  messagePosition;
@property (nonatomic,strong) NSTimer                *disappearTimer;
@property (nonatomic,weak)   MockTSMessageView      *currentShowingView;


@end

@implementation MockTSMessageOperation

@synthesize asynchronous = _asynchronous,cancelled = _cancelled,finished = _finished,executing = _executing;

- (instancetype _Nonnull)initWithViewController:(UIViewController *_Nonnull)view_controller
                                           title:(NSString *_Nonnull)title
                                        subtitle:(NSString *_Nullable)subtitle
                                           image:(UIImage *_Nullable)image
                                            type:(MockTSMessageType)type
                                   durationSecs:(NSTimeInterval)duration_secs
                                      atPosition:(MockTSMessagePosition)messagePosition {
    self = [super init];
    if (self) {
        NSParameterAssert(view_controller);
        _attachedViewController = view_controller;
        _title = [title copy];
        _subtitle = [subtitle copy];
        _hintIcon = image;
        _type = type;
        _durationSecs = duration_secs;
        _messagePosition = messagePosition;
    }
    return self;
}

// 展示当前的messageBox
- (void) start {
    
    NSLog(@"%s ; current thread = %@",__FUNCTION__,[NSThread currentThread]);
    self.executing = YES;
    self.cancelled = NO;
    self.finished = NO;
    // 如果要添加的attachedViewController不存在或者被释放，则直接返回
    if (self.attachedViewController == nil) {
        [self taskFinished];
        return;
    }
    
    // 由于Task不一定需要在MainQueue
//    if ([[self class] isMainQueue]) {
    if ([NSThread isMainThread]) {
        [self executeTask];
    }
    else {
#warning dispatch_aync is right?
      dispatch_async(dispatch_get_main_queue(), ^{
          [self executeTask];
      });
    }
}


#pragma mark - Main Function

- (void)executeTask {
    NSLog(@"%s ; current thread = %@",__FUNCTION__,[NSThread currentThread]);
    
    // 根据MockTSMessageType生成view合适的view
    // 初始化view
    MockTSMessageView *messageView = [[MockTSMessageView alloc] initWithFrame:
                                      CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)
                                                                        title:self.title
                                                                     subtitle:self.subtitle
                                                                        image:self.hintIcon
                                                                         type:self.type];
    

    // 添加事件
    [messageView addTarget:self action:@selector(dismissActiveMessageView) forEvent:MockTSMessageViewEvent_Tap];
    [messageView addTarget:self action:@selector(dismissActiveMessageView) forEvent:(self.messagePosition == MockTSMessagePosition_Bottom)?MockTSMessageViewEvent_Swipe_Down:MockTSMessageViewEvent_Swipe_Up];
    
    
    // 将view插入到view_controller的view层级中，并根据duration 设置展示时间
    [self addMessageViewAnimated:messageView];
    
    
}

- (void)taskFinished {
    
    // 停止计时器,也必须在主线程上，要不然不能停止，没有runloop
#warning "NSTimer in multithread can not stop appropriately，need change timer"
    [self stopTimer];
    self.executing = NO;
    self.finished = YES;
    self.currentShowingView = nil;
}
- (void)addMessageViewAnimated:(MockTSMessageView *)message_view {
    
    // 此函数只能在主线程执行
    NSLog(@"current thread = %@",[NSThread currentThread]);
    
    // 将message_view添加到目标controller.view上，或者finished
    // 传入的attatchViewController可能有容器controller，也可能有topViewcontroller
    // 判断viewcontroller是否可见，是因为如果不可见，那么就可以直接finish，节省时间，动画倒计时等
    // 根据被添加的父亲controller的view的不同,来判断
    __block UIViewController * currentVC;
    
    // 计算位置
    __block CGPoint toPos = CGPointZero;
    void (^calculateToPos)(void) = ^void(){
        
        UINavigationController *currentNav;
        UITabBarController *currentTab;
        currentNav = currentVC.navigationController;
        currentTab = currentVC.tabBarController;
        
        if (self.messagePosition == MockTSMessagePosition_Top) {
            // nav
            if ([[self class] isNavBarInNavigationControllerShowed:currentNav]) {
                toPos.y += CGRectGetHeight(currentNav.navigationBar.frame);
                // status
                if ([UIApplication sharedApplication].isStatusBarHidden == NO) {
                    toPos.y += CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
                }
            }
            else {
                // status
                if ([UIApplication sharedApplication].isStatusBarHidden == NO) {
                    // 增加message_view的padding
                    message_view.paddingTop += CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
                }
            }
        }
        else if (self.messagePosition == MockTSMessagePosition_Bottom) {
            if (currentVC.hidesBottomBarWhenPushed == NO && currentTab.tabBar.isHidden == NO) {
                toPos.y = CGRectGetHeight(currentVC.view.frame) - CGRectGetHeight(currentTab.tabBar.frame) - CGRectGetHeight(message_view.frame);
            }
        }
        else {
            // status
            if ([UIApplication sharedApplication].isStatusBarHidden == NO) {
                // 增加message_view的padding
                message_view.paddingTop += CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
            }
        }
    };

    // 添加消息
    // find prop parent view to show message
    if (self.messagePosition == MockTSMessagePosition_OverNavBar) {
        // 如果overNavBar，那么不考虑传入的attatchedViewController，需要加当前的nav的bar下面或者tabcontroller的view上，都可以盖在上面,不需要判断是否有nav
        // 直接加到keywindow上就行了
        [[UIApplication sharedApplication].keyWindow addSubview:message_view];
        calculateToPos();
    }
    else { // 其他位置,需要都需要加到topViewController上
        BOOL isViewcontroller = ![self.attachedViewController isKindOfClass:[UITabBarController class]] &&
        ![self.attachedViewController isKindOfClass:[UINavigationController class]] &&
        [self.attachedViewController isKindOfClass:[UIViewController class]];
        if (isViewcontroller) { // 指定添加到内容viewcontroller，如果vc可见，直接 add 到上面，然后进行位置判断设置
            currentVC = self.attachedViewController;
            if ([[self class] isVisibleViewController:currentVC]) {
                [currentVC.view addSubview:message_view];
                // 更新位置：需要判断是否有nav和tab
                calculateToPos();
            }
            else {
                [self taskFinished];
                return;
            }
        }
        else { // add 到当前的topViewController上,因为当前如果没有指定内容viewcontroller，那么说明都要消息要全局展示，所以执行时要选出当前的topViewController,添加在nav或者tab下面
#warning different with specific viewcontroller
            currentVC = [[self class] findCurrentViewControllerRecursively];
            if ([[self class] isVisibleViewController:currentVC]) {
                [currentVC.view addSubview:message_view];
                // 更新位置:需要判断是否有nav和tab
                calculateToPos();
            }
            else {
                [self taskFinished];
                return;
            }
        }
    }
    
    //
    self.currentShowingView = message_view;
    
#warning viewcontroller is not judge full display or not

    // 根据传入的pos添加动画
    [self addShowingAnimationOnMessageView:message_view toPosition:toPos messageShowPositionType:self.messagePosition];
    
    
    // 根据传入的duration 进行时长展示
    // 如果传入stay则，不消失，需要用户手动进行消失
    if (self.durationSecs == MockTSMessageDuration_Seconds_Stay) {
        return;
    }
    if (self.durationSecs >= MockTSMessageDuration_Seconds_AutoDisappear_After4) {
        NSTimeInterval d  = self.durationSecs > 0 ? self.durationSecs : 4;
        self.disappearTimer = [NSTimer scheduledTimerWithTimeInterval:d target:self selector:@selector(dismissActiveMessageView) userInfo:nil repeats:NO];
        
    }
}

- (void)removeMessageViewAnimated:(MockTSMessageView *)message_view {
    
    // view已经展示出来，所以只需要从现有fromPos变化到toPos就可以了
    CGPoint fromPos = message_view.frame.origin;
    CGPoint toPos = CGPointZero;
    if (self.messagePosition == MockTSMessagePosition_Top || self.messagePosition == MockTSMessagePosition_OverNavBar) {
        toPos.y = fromPos.y - message_view.frame.size.height;
        toPos.x = fromPos.x;
    }
    else {
        toPos.y = fromPos.y + message_view.frame.size.height;
        toPos.x = fromPos.x;
    }
    
    // animation
    [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        [message_view setFrame:CGRectMake(toPos.x, toPos.y, message_view.frame.size.width, message_view.frame.size.height)];
        
    } completion:^(BOOL finished) {
        // remove
        [message_view removeFromSuperview];
        [self taskFinished];
    }];

}



- (void)dismissActiveMessageView {
//     if ([[self class] isMainQueue]) {
    if ([NSThread isMainThread]) {
        [self removeMessageViewAnimated:self.currentShowingView];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeMessageViewAnimated:self.currentShowingView];
        });
    }
}

- (void)addShowingAnimationOnMessageView:(MockTSMessageView *)message_view
                              toPosition:(CGPoint)to_position
                 messageShowPositionType:(MockTSMessagePosition)message_showpostion_type {
    
    // 根据message_showpostion_type设置起点
    if (self.messagePosition == MockTSMessagePosition_Top || self.messagePosition == MockTSMessagePosition_OverNavBar) {
        
        [message_view setFrame:CGRectMake(to_position.x,
                                          to_position.y - message_view.frame.size.height,
                                          message_view.frame.size.width,
                                          message_view.frame.size.height)];
        
    }
    else {
        [message_view setFrame:CGRectMake(to_position.x,
                                          to_position.y + message_view.frame.size.height,
                                          message_view.frame.size.width,
                                          message_view.frame.size.height)];
    }
    
    // 动画
    [UIView animateWithDuration:kAnimationDuration delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        // 动画期间，禁用操作
        message_view.userInteractionEnabled = NO;
        // 设置目标位置
        [message_view setFrame:CGRectMake(to_position.x, to_position.y, message_view.frame.size.width, message_view.frame.size.height)];
    } completion:^(BOOL finished) {
        // 动画结束，
        message_view.userInteractionEnabled = YES;
    }];
    
}

- (void)stopTimer {
    [self.disappearTimer invalidate];
    self.disappearTimer = nil;
}

- (void)cancelInvalidExecutingOperation {
    
    if (!self.executing) {
        return;
    }
    
    if (self.currentShowingView == nil) {
        [self taskFinished];
        return;
    }

    UIResponder *next = [self.currentShowingView nextResponder];
    while (next != nil) {
        if ([next isKindOfClass:[UIViewController class]]) {
            if (![[self class] isVisibleViewController:(UIViewController*)next]) {
                [self dismissActiveMessageView];
            }
            break;
        }
        next = [next nextResponder];

    }
    
}


#pragma mark - Tool Method
+ (BOOL)isMainQueue {
    static const void* mainQueueKey = @"mainQueue";
    static void* mainQueueContext = @"mainQueue";
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_set_specific(dispatch_get_main_queue(), mainQueueKey, mainQueueContext, nil);
    });
    
    return dispatch_get_specific(mainQueueKey) == mainQueueContext;
}
#warning why should judge twice,you should see controller & navbar
+ (BOOL)isNavBarInNavigationControllerShowed:(UINavigationController *)navController {

    if (navController == nil){
        return NO;
    }
    if (navController.isNavigationBarHidden) {
        return NO;
    }
    else if (navController.navigationBar.isHidden) {
        return NO;
    }
    return YES;
}

+ (BOOL)isVisibleViewController:(UIViewController *)view_controller {
    
    BOOL isVisible = view_controller.isViewLoaded && view_controller.view.window;
    return isVisible;
    
}
+ (UIViewController *)findCurrentViewControllerRecursively {

    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self findCurrentVCFrom:rootViewController];
    return currentVC;
}

+ (UIViewController *)findCurrentVCFrom:(UIViewController *)rootVC {
    
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [[self class] findCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [[self class] findCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    
    return currentVC;
}

#pragma mark - Object Equal
- (BOOL)isEqual:(id _Nullable )object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [self isEqualToMockTSMessageOperation:object];
}

- (BOOL)isEqualToMockTSMessageOperation:(MockTSMessageOperation*)operation {
    if (operation == nil) {
        return NO;
    }
    
    BOOL isTitleEqualed = (self.title==nil && operation.title==nil) || [self.title isEqualToString:operation.title];
    BOOL isSubtitleEqualed = (self.subtitle==nil && operation.subtitle==nil) || [self.subtitle isEqualToString:operation.subtitle];
    BOOL isTypeEqualed = (self.type == operation.type);
    
    return isTitleEqualed && isSubtitleEqualed && isTypeEqualed;
}

- (NSUInteger)hash {
    return [self.title hash] ^ [self.subtitle hash];
}

#pragma mark - Getters & Setters
- (BOOL)isAsynchronous {
    return NO;
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setCancelled:(BOOL)cancelled {
    [self willChangeValueForKey:@"isCancelled"];
    _cancelled = cancelled;
    if (cancelled) {
        [self dismissActiveMessageView];
    }
    [self didChangeValueForKey:@"isCancelled"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isMessageShowingNow {
    if (self.currentShowingView) {
        return YES;
    }
    return NO;
}

@end
