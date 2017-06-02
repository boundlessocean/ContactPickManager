//
//  BLContactPickerManager.m
//  NMWalletAPP
//
//  Created by boundlessocean on 2017/6/2.
//  Copyright © 2017年 Lemon. All rights reserved.
//

#import "BLContactPickerManager.h"
#import <AddressBookUI/AddressBookUI.h>
#import <ContactsUI/ContactsUI.h>
@interface BLContactPickerManager()
<ABPeoplePickerNavigationControllerDelegate,
CNContactPickerDelegate>

{
    UIViewController *_rootVC;
    BLContactSelectCompleteBlock _completeBlock;
}
@end

@implementation BLContactPickerManager

static BLContactPickerManager *_singleton = nil;

+ (instancetype)sharedInstance{
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _singleton = [[self alloc] init];
    });
    return _singleton;
}

- (void)start{
    
    _rootVC = [[UIApplication sharedApplication].windows firstObject].rootViewController;
    
    if ([[UIDevice currentDevice].systemVersion integerValue] >= 9) {
        CNContactPickerViewController *picker = [CNContactPickerViewController new];
        picker.delegate = self;
        [_rootVC presentViewController:picker animated:YES completion:nil];
    } else {
        ABPeoplePickerNavigationController *picker = [ABPeoplePickerNavigationController new];
        picker.peoplePickerDelegate = self;
        [_rootVC presentViewController:picker animated:YES completion:nil];
    }
}

- (void)startWithContactSelectComplete:(void (^)(BLContactModel *))complete{
    _completeBlock = complete;
    [self start];
}

#pragma mark - - CNContactPickerDelegate
- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker{
    [_rootVC dismissViewControllerAnimated:YES completion:nil];
}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
    [self handleContact:contact];
    [_rootVC dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - - ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [_rootVC dismissViewControllerAnimated:YES completion:nil];
}

-(void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person{
    [self handlePerson:person];
    [_rootVC dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - - 处理数据

- (void)handleContact:(CNContact *)contact{
    // name
    NSString *name = @"";
    NSString *givenName = contact.givenName ? contact.givenName : @"";
    NSString *familyName = contact.familyName ? contact.familyName : @"";
    name = [givenName stringByAppendingString:familyName];
    
    // phone
    NSMutableArray <NSString *> *phoneNumberArray = [NSMutableArray arrayWithCapacity:0];
    [contact.phoneNumbers enumerateObjectsUsingBlock:^(CNLabeledValue<CNPhoneNumber *> * _Nonnull obj,
                                                       NSUInteger idx,
                                                       BOOL * _Nonnull stop) {
        
        //可以把-、+86、空格这些过滤掉
        NSString *phoneNum = obj.value.stringValue;
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"+86" withString:@""];
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@" " withString:@""];
        [phoneNumberArray addObject:phoneNum];
    }];
    
    // email
    NSMutableArray <NSString *> *emailArray = [NSMutableArray arrayWithCapacity:0];
    [contact.emailAddresses enumerateObjectsUsingBlock:^(CNLabeledValue<NSString *> * _Nonnull obj,
                                                         NSUInteger idx,
                                                         BOOL * _Nonnull stop) {
        [emailArray addObject:obj.value];
    }];
    [self responseDelegateWithName:name
                            Emails:emailArray
                      PhoneNumbers:phoneNumberArray];
}

- (void)handlePerson:(ABRecordRef)person{
    
    // name
    NSMutableString *nameStr = [NSMutableString string];
    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *middleName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
    NSString *lastname = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (firstName != nil) {
        [nameStr appendString:firstName];
    }
    if (lastname != nil) {
        [nameStr appendString:lastname];
    }
    if (middleName != nil) {
        [nameStr appendString:middleName];
    }
    
    // phone
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,kABPersonPhoneProperty);
    NSMutableArray <NSString *>* phoneNumberArray = [NSMutableArray arrayWithCapacity:0];
    CFIndex phoneCount = ABMultiValueGetCount(phoneNumbers);
    for (int i = 0; i < phoneCount; i++) {
        NSString *phoneNum = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
        //可以把-、+86、空格这些过滤掉
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"+86" withString:@""];
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        [phoneNumberArray addObject:phoneNum];
    }
    
    // email
    ABMultiValueRef emailNumbers = ABRecordCopyValue(person, kABPersonEmailProperty);
    NSMutableArray <NSString *>* emailArray = [NSMutableArray arrayWithCapacity:0];
    CFIndex emailCount = ABMultiValueGetCount(phoneNumbers);
    for (int i = 0; i < emailCount; i++) {
        NSString *emailNum = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailNumbers, i);
        [emailArray addObject:emailNum];
    }
    
    
    [self responseDelegateWithName:nameStr
                            Emails:emailArray
                      PhoneNumbers:phoneNumberArray];
}

#pragma mark - - response delegate
- (void)responseDelegateWithName:(NSString *)name
                          Emails:(NSMutableArray *)emails
                    PhoneNumbers:(NSMutableArray *)phoneNumbers{
    
    // model
    BLContactModel *contactModel = [BLContactModel new];
    contactModel.name = name;
    contactModel.emailsAddress = emails;
    contactModel.phoneNumbers = phoneNumbers;
    
    // delegate
    if (_delegate && [_delegate respondsToSelector:@selector(pickerManager:didSelectContact:)]) {
        [self.delegate pickerManager:self didSelectContact:contactModel];
    }
    [_rootVC dismissViewControllerAnimated:YES completion:nil];
    
    !_completeBlock ? : _completeBlock(contactModel);
}


@end

@implementation BLContactModel
@end
