//
//  ViewController.m
//  MainProject
//
//  Created by baidu on 2017/12/4.
//  Copyright © 2017年 baidu. All rights reserved.
//

#import "ViewController.h"
#import "BSStaticLibraryThree.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[[BSStaticLibraryThree alloc] init] saySomething];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
