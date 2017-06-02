//
//  BLABPeoplePickerManager.m
//  NMWalletAPP
//
//  Created by boundlessocean on 2017/6/2.
//  Copyright © 2017年 Lemon. All rights reserved.
//

#import "BLABPeoplePickerManager.h"
#import <AddressBookUI/AddressBookUI.h>

@interface BLABPeoplePickerManager() <ABPeoplePickerNavigationControllerDelegate>
{
    UIViewController *_rootVC;
}
@end

@implementation BLABPeoplePickerManager

static BLABPeoplePickerManager *_singleton = nil;

+ (instancetype)sharedInstance{
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _singleton = [[self alloc] init];
    });
    return _singleton;
}

- (void)start{
    ABPeoplePickerNavigationController *picker =[[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    _rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [_rootVC presentViewController:picker animated:YES completion:nil];
}

#pragma mark - - ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [_rootVC dismissViewControllerAnimated:YES completion:^{}];
}

-(void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person{
    [self displayPerson:person];
    [_rootVC dismissViewControllerAnimated:YES completion:^{}];
}
- (void)displayPerson:(ABRecordRef)person{
    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *middleName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
    NSString *lastname = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSMutableString *nameStr = [NSMutableString string];
    if (lastname!=nil) {
        [nameStr appendString:lastname];
    }
    if (middleName!=nil) {
        [nameStr appendString:middleName];
    }
    if (firstName!=nil) {
        [nameStr appendString:firstName];
    }
    
    NSString* phone = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    } else {
        phone = @"[None]";
    }
    
    //可以把-、+86、空格这些过滤掉
    NSString *phoneStr = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    
}

@end
