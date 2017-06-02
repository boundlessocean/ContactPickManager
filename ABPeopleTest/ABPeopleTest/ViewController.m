//
//  ViewController.m
//  ABPeopleTest
//
//  Created by boundlessocean on 2017/6/2.
//  Copyright © 2017年 Lemon. All rights reserved.
//

#import "ViewController.h"
#import "BLContactPickerManager.h"
@interface ViewController ()<ContactPickManagerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[BLContactPickerManager sharedInstance] startWithContactSelectComplete:^(BLContactModel *contact) {
         NSLog(@"%@",contact);
    }];
}

- (void)contactPickerDidCancel{

}

- (void)pickerManager:(BLContactPickerManager *)manager didSelectContact:(BLContactModel *)contact{
    NSLog(@"%@",contact);
}

@end
