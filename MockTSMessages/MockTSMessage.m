//
//  MockTSMessage.m
//  MockTSMessages
//
//  Created by baidu on 2017/11/26.
//  Copyright © 2017年 baidu. All rights reserved.
//

#import "MockTSMessage.h"
#import "MockTSMessageOperation.h"

// 如果不传任何attatchviewcontroller，消息会挂在这个controller上，变成全局controller
__weak static UIViewController *_defaultViewController;

@interface MockTSMessage ()

@property (nonatomic,strong) NSOperationQueue * messageQueueInMainThread;

@end

@implementation MockTSMessage

// 单例
+ (instancetype _Nonnull)sharedInstance {
    static dispatch_once_t onceToken;
    static MockTSMessage *instance;
    dispatch_once(&onceToken, ^{
        instance = [MockTSMessage new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _messageQueueInMainThread = [[NSOperationQueue alloc] init];
        _messageQueueInMainThread.name = @"messageQueueInMainThread";
        _messageQueueInMainThread.maxConcurrentOperationCount = 1;
    }
    return self;
}

// 外部调用方法
// 调用此方法会产生，一个全局提示框：默认top、自动消失,
+ (void)showMessageWithTitle:(NSString *_Nullable)title
                    subtitle:(NSString *_Nullable)subtitle
                        type:(MockTSMessageType)type {
    
    [[self class] showMessageInViewController:[[self class] defaultViewController]
                                        title:title
                                     subtitle:subtitle
                                        image:nil
                                         type:type
                                 durationSecs:MockTSMessageDuration_Seconds_AutoDisappear_After4
                                   atPosition:MockTSMessagePosition_Top];
}

+ (void)showMessageWithTitle:(NSString * _Nullable)title
                        type:(MockTSMessageType)type {
    [[self class] showMessageInViewController:[[self class] defaultViewController]
                                        title:title
                                     subtitle:nil
                                        image:nil
                                         type:type
                                 durationSecs:MockTSMessageDuration_Seconds_AutoDisappear_After4
                                   atPosition:MockTSMessagePosition_Top];
}



+ (void)showMessageWithTitle:(NSString *_Nullable)title
                    subtitle:(NSString *_Nullable)subtitle
                       image:(UIImage *_Nullable)image
                        type:(MockTSMessageType)type {
    [[self class] showMessageInViewController:[[self class] defaultViewController]
                                        title:title
                                     subtitle:subtitle
                                        image:image
                                         type:type
                                 durationSecs:MockTSMessageDuration_Seconds_AutoDisappear_After4
                                   atPosition:MockTSMessagePosition_Top];
}

+ (void)showMessageWithTitle:(NSString *_Nullable)title
                    subtitle:(NSString *_Nullable)subtitle
                       image:(UIImage *_Nullable)image
                        type:(MockTSMessageType)type
                durationSecs:(NSTimeInterval)duration
                  atPosition:(MockTSMessagePosition)message_position {
    
    [[self class] showMessageInViewController:[[self class] defaultViewController]
                                        title:title
                                     subtitle:subtitle
                                        image:image
                                         type:type
                                 durationSecs:duration
                                   atPosition:message_position];
}


// 可以在指定的viewcontroller展示，当viewcontroller不可见或者dealloc，相应的消息队列会不展示此消息
+ (void)showMessageInViewController:(UIViewController *_Nonnull)view_controller
                              title:(NSString *_Nullable)title
                               type:(MockTSMessageType)type {
    
    [[self class] showMessageInViewController:view_controller
                                        title:title
                                     subtitle:nil
                                        image:nil
                                         type:type
                                 durationSecs:MockTSMessageDuration_Seconds_AutoDisappear_After4
                                   atPosition:MockTSMessagePosition_Top];
}

// 最全方法，不支持button和点击反馈
// 生成一个NSOperation，加入队列，给lastObject添加依赖，按顺序展示，让队列开始执行，执行就是生成view，然后展示在对应的viewcontroller中
// NSOpreation
+ (void)showMessageInViewController:(UIViewController *_Nonnull)view_controller
                              title:(NSString *_Nullable)title
                           subtitle:(NSString *_Nullable)subtitle
                              image:(UIImage *_Nullable)image
                               type:(MockTSMessageType)type
                       durationSecs:(NSTimeInterval)duration
                         atPosition:(MockTSMessagePosition)message_position {
    
    NSOperationQueue *queue = [MockTSMessage sharedInstance].messageQueueInMainThread;
    NSLog(@"operations count = %ld,all operations = %@",queue.operations.count,queue.operations);

    // 取消所有attatchView_controller 为nil的任务
    [queue.operations makeObjectsPerformSelector:@selector(cancelInvalidExecutingOperation)];
    
    // 生成一个NSOpration
    MockTSMessageOperation * msgOperation = [[MockTSMessageOperation alloc] initWithViewController:view_controller
                                                                                             title:title
                                                                                          subtitle:subtitle
                                                                                             image:image
                                                                                              type:type
                                                                                          durationSecs:duration
                                                                                        atPosition:message_position];
    
    
    // 避免添加同样的message，正在执行的Opration,或者将要执行的提示
    if ([queue.operations containsObject:msgOperation]) {
        return;
    }
    
    // 加到队列中,保持队列FIFO
    MockTSMessageOperation * lastOperation = queue.operations.lastObject;
    if (lastOperation) {
        [msgOperation addDependency:lastOperation];
    }
    [queue addOperation:msgOperation];
}

+ (BOOL)dismissActiveMessage {
    // 选出正在执行的operation，也就是第0个
    NSOperationQueue *queue = [MockTSMessage sharedInstance].messageQueueInMainThread;
    MockTSMessageOperation * firstOperation = queue.operations.firstObject;
    
    // 判断他是不是正在执行中,是不是有view展示
    BOOL hasActiveMessage = [firstOperation isMessageShowingNow];
    if (hasActiveMessage) {
#warning cancel don not call remove operation immediately
        // 如果是则调用cancel operation 会调用remove方法
        if (firstOperation.executing){
            [firstOperation cancel];
            NSLog(@"operations count = %ld",queue.operations.count);
        }

        [firstOperation dismissActiveMessageView];
    }
    
    return hasActiveMessage;
}
#pragma mark - getters & setters
+ (UIViewController *)defaultViewController
{
    __strong UIViewController *defaultViewController = _defaultViewController;
    
    if (defaultViewController == nil) {
        defaultViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    return defaultViewController;
}
@end
