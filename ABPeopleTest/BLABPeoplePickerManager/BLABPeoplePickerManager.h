//
//  BLABPeoplePickerManager.h
//  NMWalletAPP
//
//  Created by boundlessocean on 2017/6/2.
//  Copyright © 2017年 Lemon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLABPeoplePickerManager : NSObject 
+ (instancetype)sharedInstance;
- (void)start;
@end
