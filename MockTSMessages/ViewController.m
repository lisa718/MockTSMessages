//
//  ViewController.m
//  MockTSMessages
//
//  Created by baidu on 2017/11/25.
//  Copyright © 2017年 baidu. All rights reserved.
//

#import "ViewController.h"
#import "MockTSMessage.h"

@interface ViewController ()

// transition
@property (nonatomic,strong) UIStackView *transitionContainerView;
@property (nonatomic,strong) UIButton *pushBtn;
@property (nonatomic,strong) UIButton *presentBtn;
@property (nonatomic,strong) UIButton *overbarBtn;
@property (nonatomic,strong) UIButton *hideNavbarBtn;

// top
@property (nonatomic,strong) UIStackView *topContainerView;
@property (nonatomic,strong) UIButton *topSuccessBtn;
@property (nonatomic,strong) UIButton *topErrorBtn;
@property (nonatomic,strong) UIButton *topFailedBtn;
@property (nonatomic,strong) UIButton *topMessageBtn;


// bottom + stay
@property (nonatomic,strong) UIStackView *bottomContainerView;
@property (nonatomic,strong) UIButton *dimissBtn;
@property (nonatomic,strong) UIButton *topSuccessStayBtn;
@property (nonatomic,strong) UIButton *bottomErrorStayBtn;
@property (nonatomic,strong) UIButton *bottomSuccessBtn;



@end

@implementation ViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // nav
    self.title = @"测试提示框";
//    self.navigationController.navigationBarHidden = YES;

    if (self.navigationController == nil) {
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setFrame:CGRectMake(0, 0, 70, 40)];
        [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.view addSubview:closeButton];
    }
    
    // image for blur test
    UIImage *img = [UIImage imageNamed:@"1"];
    UIImageView *blurTestView = [[UIImageView alloc] initWithImage:img];
    blurTestView.frame = CGRectMake(0, 64, img.size.width, img.size.height);
    [self.view addSubview:blurTestView];
    
    // transition stack view
    self.transitionContainerView.frame = CGRectMake(0, 300, self.view.bounds.size.width, 100);
    [self.view addSubview:self.transitionContainerView];
    [self.transitionContainerView addArrangedSubview:self.presentBtn];
    [self.transitionContainerView addArrangedSubview:self.pushBtn];
    [self.transitionContainerView addArrangedSubview:self.overbarBtn];
    
    
    // Top stack view
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.topContainerView.frame = CGRectMake(0, 400, self.view.bounds.size.width, 100);

    [self.view addSubview:self.topContainerView];
    [self.topContainerView addArrangedSubview:self.topSuccessBtn];
    [self.topContainerView addArrangedSubview:self.topErrorBtn];
    [self.topContainerView addArrangedSubview:self.topFailedBtn];
    [self.topContainerView addArrangedSubview:self.topMessageBtn];

    // Bottom
    [self.view addSubview:self.bottomContainerView];
    [self.bottomContainerView addArrangedSubview:self.dimissBtn];
    [self.bottomContainerView addArrangedSubview:self.topSuccessStayBtn];
    [self.bottomContainerView addArrangedSubview:self.bottomErrorStayBtn];
    [self.bottomContainerView addArrangedSubview:self.bottomSuccessBtn];

    [self configLayout];
}


- (void)configLayout {
    self.transitionContainerView.frame = CGRectMake(0, 300, self.view.bounds.size.width, 100);
    self.topContainerView.frame = CGRectMake(0, 400, self.view.bounds.size.width, 100);
    self.bottomContainerView.frame = CGRectMake(0, 500, self.view.bounds.size.width, 100);
}
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self configLayout];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions
- (void)close {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)transitionClick :(UIButton *)button {
    if (button == self.pushBtn) {
        [self.navigationController pushViewController:[[[self class] alloc] init] animated:YES] ;
    }
    else if (button == self.presentBtn) {
        [self presentViewController:[[[self class] alloc] init] animated:YES completion:nil];
    }
}

- (void)topSuccessBtnClick:(UIButton *)button {
//    [MockTSMessage showMessageInViewController:self.navigationController
//                                         title:nil
//                                      subtitle:@"评论成功啦！"
//                                         image:nil
//                                          type:MockTSMessageType_Success
//                                      durationSecs:MockTSMessageDuration_Seconds_AutoDisappear_After4
//                                    atPosition:MockTSMessagePosition_Top];
    [MockTSMessage showMessageWithTitle:@"成功" subtitle:@"sdfsdf" type:MockTSMessageType_Success];
}

- (void)topMessageBtnClick:(UIButton *)button {
//    [MockTSMessage showMessageInViewController:self
//                                         title:nil
//                                      subtitle:@"评论成功啦！"
//                                         image:nil
//                                          type:MockTSMessageType_Message
//                                  durationSecs:MockTSMessageDuration_Seconds_AutoDisappear_After4
//                                    atPosition:MockTSMessagePosition_Top];
    [MockTSMessage showMessageWithTitle:nil subtitle:@"sdfsdf" type:MockTSMessageType_Message];
}

- (void)topErrorBtnClick:(UIButton *)button {
    [MockTSMessage showMessageInViewController:self
                                         title:nil
                                      subtitle:@"评论成功啦！"
                                         image:nil
                                          type:MockTSMessageType_Error
                                  durationSecs:MockTSMessageDuration_Seconds_AutoDisappear_After4
                                    atPosition:MockTSMessagePosition_Top];
}
- (void)topFailedBtnClick:(UIButton *)button {
    [MockTSMessage showMessageInViewController:self
                                         title:nil
                                      subtitle:@"评论失败啦啦！水电费水电费水电费三等分是 舒服点是是  说的反倒是发"
                                         image:nil
                                          type:MockTSMessageType_Failed
                                  durationSecs:MockTSMessageDuration_Seconds_AutoDisappear_After4
                                    atPosition:MockTSMessagePosition_Top];
}

- (void)topSuccessStayBtnClick:(UIButton *)button {
    [MockTSMessage showMessageInViewController:self
                                         title:nil
                                      subtitle:nil
                                         image:nil
                                          type:MockTSMessageType_Success
                                      durationSecs:MockTSMessageDuration_Seconds_Stay
                                    atPosition:MockTSMessagePosition_Top];
}

- (void)overbarBtnClick:(UIButton *)button {
    [MockTSMessage showMessageInViewController:self
                                         title:@"SDsdfSDfsdfdfsdfsdf"
                                      subtitle:@"sdfsdfsdfsdfsdf"
                                         image:nil
                                          type:MockTSMessageType_Success
                                  durationSecs:MockTSMessageDuration_Seconds_AutoDisappear_After4
                                    atPosition:MockTSMessagePosition_OverNavBar];
}

- (void)bottomSuccessBtnClick:(UIButton *)button {
    [MockTSMessage showMessageInViewController:self
                                         title:@"底部成功了"
                                      subtitle:@"设置成功了底部的弹框"
                                         image:nil
                                          type:MockTSMessageType_Success
                                  durationSecs:MockTSMessageDuration_Seconds_AutoDisappear_After4
                                    atPosition:MockTSMessagePosition_Bottom];
}
- (void)bottomErrorStayBtnClick:(UIButton *)button {
    [MockTSMessage showMessageInViewController:self
                                         title:@"底部成功了"
                                      subtitle:@"设置成功了底部的弹框"
                                         image:nil
                                          type:MockTSMessageType_Error
                                  durationSecs:MockTSMessageDuration_Seconds_Stay
                                    atPosition:MockTSMessagePosition_Bottom];
}

- (void)dimissBtnClick:(UIButton *)button {
    [MockTSMessage dismissActiveMessage];
}


#pragma mark - getters & setters
- (UIButton *)topSuccessBtn {
    if (_topSuccessBtn == nil) {
        _topSuccessBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_topSuccessBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_topSuccessBtn setTitle:@"TopSuccess" forState:UIControlStateNormal];
        [_topSuccessBtn addTarget:self action:@selector(topSuccessBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_topSuccessBtn setFrame:CGRectMake(0, 0, 70, 40)];

    }
    return _topSuccessBtn;
}

- (UIButton *)topErrorBtn {
    if (_topErrorBtn == nil) {
        _topErrorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_topErrorBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_topErrorBtn setTitle:@"TopError" forState:UIControlStateNormal];
        [_topErrorBtn addTarget:self action:@selector(topErrorBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_topErrorBtn setFrame:CGRectMake(0, 0, 70, 40)];
        
    }
    return _topErrorBtn;
}

- (UIButton *)topFailedBtn {
    if (_topFailedBtn == nil) {
        _topFailedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_topFailedBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_topFailedBtn setTitle:@"TopFailed" forState:UIControlStateNormal];
        [_topFailedBtn addTarget:self action:@selector(topFailedBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_topFailedBtn setFrame:CGRectMake(0, 0, 70, 40)];
        
    }
    return _topFailedBtn;
}

- (UIButton *)topMessageBtn {
    if (_topMessageBtn == nil) {
        _topMessageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_topMessageBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_topMessageBtn setTitle:@"TopMessage" forState:UIControlStateNormal];
        [_topMessageBtn addTarget:self action:@selector(topMessageBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_topMessageBtn setFrame:CGRectMake(0, 0, 70, 40)];
        
    }
    return _topMessageBtn;
}

- (UIButton *)topSuccessStayBtn {
    if (_topSuccessStayBtn == nil) {
        _topSuccessStayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_topSuccessStayBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_topSuccessStayBtn setTitle:@"TopStay" forState:UIControlStateNormal];
        [_topSuccessStayBtn addTarget:self action:@selector(topSuccessStayBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_topSuccessStayBtn setFrame:CGRectMake(0, 0, 70, 40)];
        
    }
    return _topSuccessStayBtn;
}
- (UIButton *)dimissBtn {
    if (_dimissBtn == nil) {
        _dimissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dimissBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_dimissBtn setTitle:@"dismiss" forState:UIControlStateNormal];
        [_dimissBtn addTarget:self action:@selector(dimissBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_dimissBtn setFrame:CGRectMake(0, 0, 70, 40)];
    }
    return _dimissBtn;
}

- (UIStackView *)topContainerView {
    if (_topContainerView == nil) {
        _topContainerView = [[UIStackView alloc] init];
        _topContainerView.axis = UILayoutConstraintAxisHorizontal;
        _topContainerView.distribution = UIStackViewDistributionFillEqually;
        _topContainerView.alignment = UIStackViewAlignmentCenter;
        _topContainerView.spacing = 10;

    }
    return _topContainerView;
}

- (UIStackView *)bottomContainerView {
    if (_bottomContainerView == nil) {
        _bottomContainerView = [[UIStackView alloc] init];
        _bottomContainerView.axis = UILayoutConstraintAxisHorizontal;
        _bottomContainerView.distribution = UIStackViewDistributionFillEqually;
        _bottomContainerView.alignment = UIStackViewAlignmentCenter;
        _bottomContainerView.spacing = 10;
        
    }
    return _bottomContainerView;
}

- (UIStackView *)transitionContainerView {
    if (_transitionContainerView == nil) {
        _transitionContainerView = [[UIStackView alloc] init];
        _transitionContainerView.axis = UILayoutConstraintAxisHorizontal;
        _transitionContainerView.distribution = UIStackViewDistributionFillEqually;
        _transitionContainerView.alignment = UIStackViewAlignmentCenter;
        _transitionContainerView.spacing = 10;
        
    }
    return _transitionContainerView;
}

- (UIButton *)bottomSuccessBtn {
    if (_bottomSuccessBtn == nil) {
        _bottomSuccessBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bottomSuccessBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_bottomSuccessBtn setTitle:@"BottomSuccess" forState:UIControlStateNormal];
        [_bottomSuccessBtn addTarget:self action:@selector(bottomSuccessBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomSuccessBtn setFrame:CGRectMake(0, 0, 70, 60)];
    }
    return _bottomSuccessBtn;
}

- (UIButton *)bottomErrorStayBtn {
    if (_bottomErrorStayBtn == nil) {
        _bottomErrorStayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bottomErrorStayBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_bottomErrorStayBtn setTitle:@"BottomErrorStay" forState:UIControlStateNormal];
        [_bottomErrorStayBtn addTarget:self action:@selector(bottomErrorStayBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomErrorStayBtn setFrame:CGRectMake(0, 0, 70, 60)];
        
    }
    return _bottomErrorStayBtn;
}

- (UIButton *)pushBtn {
    if (_pushBtn == nil) {
        _pushBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pushBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_pushBtn setTitle:@"Push" forState:UIControlStateNormal];
        [_pushBtn addTarget:self action:@selector(transitionClick:) forControlEvents:UIControlEventTouchUpInside];
        [_pushBtn setFrame:CGRectMake(0, 0, 70, 40)];
        
    }
    return _pushBtn;
}

- (UIButton *)presentBtn {
    if (_presentBtn == nil) {
        _presentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_presentBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_presentBtn setTitle:@"Present" forState:UIControlStateNormal];
        [_presentBtn addTarget:self action:@selector(transitionClick:) forControlEvents:UIControlEventTouchUpInside];
        [_presentBtn setFrame:CGRectMake(0, 0, 70, 40)];
        
    }
    return _presentBtn;
}

- (UIButton *)overbarBtn {
    if (_overbarBtn == nil) {
        _overbarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_overbarBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_overbarBtn setTitle:@"OverbarSuccess" forState:UIControlStateNormal];
        [_overbarBtn addTarget:self action:@selector(overbarBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_overbarBtn setFrame:CGRectMake(0, 0, 70, 40)];
        
    }
    return _overbarBtn;
}

@end
