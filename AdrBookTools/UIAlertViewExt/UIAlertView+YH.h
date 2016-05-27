//
//  UIAlertView+YH.h
//  TheCarWash
//
//  Created by 王亚辉 on 14-6-14.
//  Copyright (c) 2014年 王亚辉. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (YH)

typedef void (^AlertDismissBlock) (int buttonIndex);
typedef void (^AlertCancelBlock) ();

+ (UIAlertView *)showAlertViewWithTitle:(NSString *)title
                                message:(NSString *)message
                      cancelButtonTitle:(NSString *)cancelButtonTitle
                       otherButtonTitle:(NSArray *)otherButtons
                              onDismiss:(AlertDismissBlock)dismissed
                               onCancel:(AlertCancelBlock)cancelled;

+ (void)alertWithMsg:(NSString *)msg;
+ (BOOL)alertViewIsShow;
@end
