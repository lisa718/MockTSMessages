# 组件功能MockTSMessages的主要功能是
第一阶段
1、多条提示信息可以按调用先后顺序先后展示
2、可以手动让当前正在展示的消息消失，比如点击整个view或者点击别的button
----
只能在当前viewcontroller展示
1)、在目的viewcontroller内或者全局展示提示View -- McokTSMessageView
2)、退出当前viewcontroller，则需要自动或者手动清除在当前viewcontroller中调用的View
MockTSMessage showMessageInViewController:
MockTSMessage removeMessageInViewController:

能在全局或者指定的全局controller展示，不在某个viewcontroller展示的
类方法处理
1)、在某个viewcontroller调用，但是，viewcontroller退出，需要继续在别的页面能够继续展示消息
MockTSMessage showMessageWithTitle


所以组件提供类方法并将对接类，设置为单例


----
下面是支持的信息类型：
2、展示内容：Success、Failed、Error、Message
3、展示位置：调用controller的Top、Bottom、OverNavBar
4、展示时长：自动消失、不能自动消失（需要点击本view的按钮进行消失）



第二阶段
可以支持button，和点击反馈 （已支持）


# 类设计

## MockTSMessage--管理类，调度类
它是对外接口类，也是展示提示信息调用的管理类，他来实现以上”主要功能”的内容
方案一:
他如果不把view创建出来，他就要存储用户调用展示的model，每次创建一个view，这里不需要model，将提示信息，直接放入成员数组进行存储
方案二：
放入NSOperationQueue中，执行的时候，再创建view，需要model，放入NSOperation中


### 成员
方案一：NSArray <MockTSMessageView *> * _messageView
方案二：NSOperationQueue队列中


### 成员方法
添加消息view：调用showMessage系列方法时
删除消息view：

### 类方法
单例

```objective-c
[TSMessage showMessageWithTitle:@"Your Title"
subtitle:@"A description"
type:TSMessageNotificationTypeError];


// Add a button inside the message
[TSMessage showMessageInViewController:self
title:@"Update available"
subtitle:@"Please update the app"
image:nil
type:TSMessageNotificationTypeMessage
duration:TSMessageMessageDurationAutomatic
callback:nil
buttonTitle:@"Update"
buttonCallback:^{
NSLog(@"User tapped the button");
}
atPosition:TSMessageNotificationPositionTop
canBeDismissedByUser:YES];

+ (BOOL)dissmissActiveMessage;
```


## McokTSMessageView -- View类
```o
UI展示提示信息样式：
icon左侧
title
subtitle
背景blur XXXX
button
```
### 动画 （done）
根据传入pos来做动画
自上而下出现，动画
自下而上出现，动画

消失动画，相反

### 支持横竖屏（done）
### 适配iPhone X
### 指定位置进行展示

# Usage

To show notifications use the following code:


You can define a default view controller in which the notifications should be displayed:
```objective-c
   [TSMessage setDefaultViewController:myNavController];
```

You can define a default view controller in which the notifications should be displayed:
```objective-c
   [TSMessage setDelegate:self];
   
   ...
   
   - (CGFloat)messageLocationOfMessageView:(TSMessageView *)messageView
   {
    return messageView.viewController...; // any calculation here
   }
```

You can customize a message view, right before it's displayed, like setting an alpha value, or adding a custom subview
```objective-c
   [TSMessage setDelegate:self];
   
   ...
   
   - (void)customizeMessageView:(TSMessageView *)messageView
   {
      messageView.alpha = 0.4;
      [messageView addSubview:...];
   }
```

You can customize message view elements using UIAppearance
```objective-c
#import <TSMessages/TSMessageView.h>
@implementation TSAppDelegate
....

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//If you want you can overidde some properties using UIAppearance
[[TSMessageView appearance] setTitleFont:[UIFont boldSystemFontOfSize:6]];
[[TSMessageView appearance] setTitleTextColor:[UIColor redColor]];
[[TSMessageView appearance] setContentFont:[UIFont boldSystemFontOfSize:10]];
[[TSMessageView appearance]setContentTextColor:[UIColor greenColor]];
[[TSMessageView appearance]setErrorIcon:[UIImage imageNamed:@"NotificationButtonBackground"]];
[[TSMessageView appearance]setSuccessIcon:[UIImage imageNamed:@"NotificationButtonBackground"]];
[[TSMessageView appearance]setMessageIcon:[UIImage imageNamed:@"NotificationButtonBackground"]];
[[TSMessageView appearance]setWarningIcon:[UIImage imageNamed:@"NotificationButtonBackground"]];
//End of override

return YES;
}
```



The following properties can be set when creating a new notification:

* **viewController**: The view controller to show the notification in. This might be the navigation controller.
* **title**: The title of the notification view
* **subtitle**: The text that is displayed underneath the title (optional)
* **image**: A custom icon image that is used instead of the default one (optional)
* **type**: The notification type (Message, Warning, Error, Success)
* **duration**: The duration the notification should be displayed
* **callback**: The block that should be executed, when the user dismissed the message by tapping on it or swiping it to the top.

Except the title and the notification type, all of the listed values are optional

If you don't want a detailed description (the text underneath the title) you don't need to set one. The notification will automatically resize itself properly. 

## Screenshots

**iOS 7 Design**

![iOS 7 Error](http://www.toursprung.com/wp-content/uploads/2013/09/error_ios7.png)

![iOS 7 Message](http://www.toursprung.com/wp-content/uploads/2013/09/warning_ios7.png)

**iOS 6 Design**

![Warning](http://www.toursprung.com/wp-content/uploads/2013/04/iNotificationWarning.png)

![Success](http://www.toursprung.com/wp-content/uploads/2013/04/iNotificationSuccess.png)

![Error](http://www.toursprung.com/wp-content/uploads/2013/04/iNotificationError.png)

![Message](http://www.toursprung.com/wp-content/uploads/2013/04/iNotificationMessage.png)


# License
TSMessages is available under the MIT license. See the LICENSE file for more information.

# Recent Changes
Can be found in the [releases section](https://github.com/KrauseFx/TSMessages/releases) of this repo.
