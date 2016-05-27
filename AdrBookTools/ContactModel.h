//
//  ContactModel.h
//  AdrBookTools
//
//  Created by 陈浩 on 16/5/27.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ContactModel : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *FullSpell;
@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, strong) NSNumber *personID;
@property (nonatomic, strong) NSArray *phoneArray;
@property (nonatomic, strong) UIImage *user_icon;
@end
