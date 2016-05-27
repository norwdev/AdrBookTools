//
//  UIAlertView+YH.m
//  TheCarWash
//
//  Created by 王亚辉 on 14-6-14.
//  Copyright (c) 2014年 王亚辉. All rights reserved.
//

#import "UIAlertView+YH.h"

@implementation UIAlertView (YH)

static AlertDismissBlock _dismissBlock;
static AlertCancelBlock _cancelBlock;
int alertIsShow = NO;
+ (UIAlertView *)showAlertViewWithTitle:(NSString *)title
                                message:(NSString *)message
                      cancelButtonTitle:(NSString *)cancelButtonTitle
                       otherButtonTitle:(NSArray *)otherButtons
                              onDismiss:(AlertDismissBlock)dismissed
                               onCancel:(AlertCancelBlock)cancelled {
    
    _cancelBlock = [cancelled copy];
    _dismissBlock = [dismissed copy];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:[self self]
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    if (otherButtons != nil) {
        for (NSString *buttonTitle in otherButtons) {
            [alert addButtonWithTitle:buttonTitle];
        }
    }
    [alert show];
    alertIsShow = YES;
    return alert;
}

+ (void)alertView:(UIAlertView *)alertView
    didDismissWithButtonIndex:(NSInteger)buttonIndex {
    alertIsShow = NO;
    if (buttonIndex == [alertView cancelButtonIndex]) {
        if (_cancelBlock) {
            _cancelBlock();
            _cancelBlock = nil;
        }
    } else {
        if (_dismissBlock) {
            _dismissBlock((int)buttonIndex - 1);
            _dismissBlock = nil;
        }
    }
}

+ (void)alertWithMsg:(NSString *)msg {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
    alertIsShow = YES;
}
+ (BOOL)alertViewIsShow {
    return alertIsShow;
}
@end
