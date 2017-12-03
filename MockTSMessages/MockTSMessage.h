//
//  MockTSMessage.h
//  MockTSMessages
//
//  Created by baidu on 2017/11/26.
//  Copyright © 2017年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


// 消息类型
typedef NS_ENUM(NSInteger,MockTSMessageType) {
    MockTSMessageType_Message = 0,// default
    MockTSMessageType_Success = 1,
    MockTSMessageType_Failed = 2,
    MockTSMessageType_Error = 3
    
};

// 消息位置
typedef NS_ENUM(NSInteger,MockTSMessagePosition) {
    MockTSMessagePosition_Top = 0,// default
    MockTSMessagePosition_Bottom = 1,
    MockTSMessagePosition_OverNavBar = 2 // 不管传入的vc是什么，都会加到keywindow上
};

// 时长，判断是否要自动消失
typedef NS_ENUM(NSInteger,MockTSMessageDuration_Seconds) {
    MockTSMessageDuration_Seconds_AutoDisappear_After4 = 0,
    MockTSMessageDuration_Seconds_Stay = -1
};

@interface MockTSMessage : NSObject


+ (instancetype _Nonnull)sharedInstance;

// 全局方法，展示消息到TopViewcontroller，当切换viewcontroller，不会展示；当overbar类型，切换viewcontroller会显示
// 调用此方法会产生，一个全局提示框：默认top、自动消失
+ (void)showMessageWithTitle:(NSString * _Nullable)title
                        type:(MockTSMessageType)type;

+ (void)showMessageWithTitle:(NSString *_Nullable)title
                    subtitle:(NSString *_Nullable)subtitle
                        type:(MockTSMessageType)type;

+ (void)showMessageWithTitle:(NSString *_Nullable)title
                    subtitle:(NSString *_Nullable)subtitle
                       image:(UIImage *_Nullable)image
                        type:(MockTSMessageType)type;

+ (void)showMessageWithTitle:(NSString *_Nullable)title
                    subtitle:(NSString *_Nullable)subtitle
                       image:(UIImage *_Nullable)image
                        type:(MockTSMessageType)type
                durationSecs:(NSTimeInterval)duration
                  atPosition:(MockTSMessagePosition)message_position;


// 可以在指定的viewcontroller展示，当viewcontroller不可见或者dealloc，触发消息展示，相应的消息队列会不展示此消息
+ (void)showMessageInViewController:(UIViewController *_Nonnull)view_controller
                              title:(NSString *_Nullable)title
                               type:(MockTSMessageType)type;

+ (void)showMessageInViewController:(UIViewController *_Nonnull)view_controller
                              title:(NSString *_Nullable)title
                           subtitle:(NSString *_Nullable)subtitle
                              image:(UIImage *_Nullable)image
                               type:(MockTSMessageType)type
                       durationSecs:(NSTimeInterval)duration
                         atPosition:(MockTSMessagePosition)message_position;



// 让当前展示的消息消失
+ (BOOL)dismissActiveMessage;


#warning with no button?

@end
