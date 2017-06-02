//
//  BLContactPickerManager.h
//  NMWalletAPP
//
//  Created by boundlessocean on 2017/6/2.
//  Copyright © 2017年 Lemon. All rights reserved.
//


#import <Foundation/Foundation.h>
@class BLContactModel;
@class BLContactPickerManager;
typedef void(^BLContactSelectCompleteBlock)(BLContactModel *contact);

/******************************** Protocol ******************************/
@protocol ContactPickManagerDelegate <NSObject>
/** 取消 */
- (void)contactPickerDidCancel;
/**
 选择了联系人

 @param manager manager
 @param contact 联系人
 */
- (void)pickerManager:(BLContactPickerManager *)manager didSelectContact:(BLContactModel *)contact;
@end


/******************************** Manager ******************************/
@interface BLContactPickerManager : NSObject
/** 代理 */
@property (nonatomic,   weak) id<ContactPickManagerDelegate> delegate;
+ (instancetype)sharedInstance;

/** 弹出选择页面 */
- (void)start;

/**
 弹出选择页面

 @param complete 选择完成回调
 */
- (void)startWithContactSelectComplete:(BLContactSelectCompleteBlock)complete;
@end



/******************************** Model ******************************/
@interface BLContactModel : NSObject
/* 姓名 */
@property (nonatomic, strong) NSString *name;
/* 电话 */
@property (nonatomic, strong) NSArray <NSString *> *phoneNumbers;
/* 邮箱 */
@property (nonatomic, strong) NSArray <NSString *> *emailsAddress;
@end
