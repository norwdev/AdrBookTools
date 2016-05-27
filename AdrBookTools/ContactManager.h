//
//  ContactManager.h
//  AdrBookTools
//
//  Created by 陈浩 on 16/5/27.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactModel.h"
#import "Header.h"

@interface ContactManager : NSObject
+ (BOOL)isAllowedToUseEbook;
+ (NSArray *)getAllContanct;
+ (NSDictionary *)getChineseStringArr:(NSMutableArray *)arrToSort;
@end
