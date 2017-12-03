//
//  MockTSMessageOperation.h
//  MockTSMessages
//
//  Created by baidu on 2017/11/26.
//  Copyright © 2017年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
// TODO 全局和非全局任务，全局任务不能取消，非全局任务需要当controller销毁后，进行销毁

@import UIKit;
@class MockTSMessageModel;
typedef NS_ENUM(NSInteger,MockTSMessageType);
typedef NS_ENUM(NSInteger,MockTSMessagePosition);

@interface MockTSMessageOperation : NSOperation

- (instancetype _Nonnull )initWithViewController:(UIViewController *_Nonnull)view_controller
                                   title:(NSString *_Nonnull)title
                                subtitle:(NSString *_Nullable)subtitle
                                   image:(UIImage *_Nullable)image
                                    type:(MockTSMessageType)type
                                durationSecs:(NSTimeInterval)duration_secs
                              atPosition:(MockTSMessagePosition)messagePosition;


- (void)dismissActiveMessageView;
- (BOOL)isEqual:(id _Nullable )object;
- (void)cancelInvalidExecutingOperation;

+ (BOOL)isMainQueue;


@property (nonatomic,assign,readonly) BOOL  isMessageShowingNow;


@end
