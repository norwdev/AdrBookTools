//
//  ContactManager.m
//  AdrBookTools
//
//  Created by 陈浩 on 16/5/27.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import "ContactManager.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "pinyin.h"
#import "UIAlertView+YH.h"

@implementation ContactManager
+ (BOOL)isAllowedToUseEbook {
    BOOL allow = NO;
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
    {
        allow = YES;
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        allow = YES;
    }
    else
    {
        allow = NO;
        [ContactManager alertRefuseAccess];
    }
    return allow;
}
+ (ABAddressBookRef)getABAddressBookRef{
    ABAddressBookRef tmpAddressBook = NULL;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0000){
        tmpAddressBook=ABAddressBookCreateWithOptions(NULL, NULL);
        dispatch_semaphore_t sema=dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(tmpAddressBook, ^(bool greanted, CFErrorRef error){
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }else{
        tmpAddressBook = ABAddressBookCreate();
    }
    return tmpAddressBook;
}
+ (NSArray *)getAllContanct
{
    ABAddressBookRef tmpAddressBook = [ContactManager getABAddressBookRef];
    if(tmpAddressBook == NULL){
        return [[NSArray alloc] init];
    }
    
    //取得本地所有联系人记录
    __block BOOL accessGranted = NO;
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
    {
        ABAddressBookRequestAccessWithCompletion(tmpAddressBook,
                                                 ^(bool granted, CFErrorRef error)
                                                 {
                                                     accessGranted = granted;
                                                 });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        accessGranted = YES;
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ContactManager alertRefuseAccess];
        });
        return nil;
    }
    if (tmpAddressBook==nil) {
        return nil;
    };
    if (accessGranted) {
        NSArray* tmpPeoples = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(tmpAddressBook);
        NSMutableArray *peoples = [[NSMutableArray alloc] init];
        for(id tmpPerson in tmpPeoples)
        {
            ABRecordRef record = (__bridge ABRecordRef)(tmpPerson);
            ContactModel *contact = [ContactModel new];
            //获取的联系人单一属性:First name
            NSString* tmpFirstName = (__bridge NSString*)ABRecordCopyValue(record, kABPersonFirstNameProperty);
            if (tmpFirstName == Nil) {
                tmpFirstName = @"";
            }else{
                tmpFirstName = [NSString stringWithFormat:@"%@ ", tmpFirstName];
            }
            //获取的联系人单一属性:Last name
            NSString* tmpLastName = (__bridge NSString*)ABRecordCopyValue(record, kABPersonLastNameProperty);
            if (tmpLastName == Nil) {
                tmpLastName = @"";
            }
            contact.name = [NSString stringWithFormat:@"%@%@",tmpLastName,tmpFirstName];
            if (contact.name.length == 0) {
                NSString* companyName = (__bridge NSString*)ABRecordCopyValue(record, kABPersonOrganizationProperty);
                if (companyName == Nil) {
                    companyName = @"";
                }
                contact.name = companyName;
            }
            
            ABRecordID personID = ABRecordGetRecordID(record);
            contact.personID = [NSNumber numberWithInt:personID];
            
            //            //获取的联系人单一属性:Nickname
            //            NSString* tmpNickname = (__bridge NSString*)ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonNicknameProperty);
            //            NSString *friendName;
            //            //若有昵称，则nick为昵称，否则为该用户的姓名
            //            if (tmpNickname != Nil) {
            //                friendName = tmpNickname;
            //            }else{
            //                friendName = [NSString stringWithFormat:@"%@%@", tmpFirstName,tmpLastName];
            //            }
            //获取的联系人单一属性:Generic phone number
            //一个人可能有多个电话号码
            ABMultiValueRef tmpPhones = ABRecordCopyValue(record, kABPersonPhoneProperty);
            NSMutableArray *phoneArray = [NSMutableArray array];
            for(NSInteger j = 0; j < ABMultiValueGetCount(tmpPhones); j++)
            {
                NSString* tmpPhoneIndex = (__bridge NSString*)ABMultiValueCopyValueAtIndex(tmpPhones, j);
                NSMutableString *str = [[NSMutableString alloc] initWithString:tmpPhoneIndex];
                NSRange range = [str rangeOfString:@"+86 "];
                if (range.location != NSNotFound) {
                    [str replaceCharactersInRange:range withString:@""];
                }
                NSRange range2 = [str rangeOfString:@"+86"];
                if (range2.location != NSNotFound) {
                    [str replaceCharactersInRange:range2 withString:@""];
                }
                
                NSRange range3 = [str rangeOfString:@" "];
                if (range3.location != NSNotFound) {
                    [str replaceCharactersInRange:range3 withString:@""];
                }
                
                NSString *mobel = [str stringByReplacingOccurrencesOfString:@"-" withString:@""];
                [phoneArray addObject:mobel];
            }
            contact.phoneArray = [phoneArray copy];
            if (phoneArray.count > 0) {
                contact.mobile = phoneArray[0];
            }
            CFRelease(tmpPhones);
            
            if (contact.mobile == nil) {
                contact.mobile = @"";
            }
            if(ABPersonHasImageData(record))
            {
                NSData * imageData = (__bridge  NSData *)ABPersonCopyImageData(record);
                UIImage * image = [[UIImage alloc] initWithData:imageData];
                contact.user_icon = image;
            }
            
            [peoples addObject:contact];
        }
        
        CFRelease(tmpAddressBook);
        return peoples;
    }
    return nil;
}

+ (void)delContactInEbook:(NSDictionary *)contacts {
    if (![ContactManager isAllowedToUseEbook]) {
        return ;
    }
    
    ABAddressBookRef tmpAddressBook = [ContactManager getABAddressBookRef];
    if(tmpAddressBook == NULL){
        return;
    }
    NSArray* tmpPersonArray = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(tmpAddressBook);
    for(id tmpPerson in tmpPersonArray)
    {
        ABRecordID personID = ABRecordGetRecordID((__bridge ABRecordRef)(tmpPerson));
        NSNumber *ID = [NSNumber numberWithInt:personID];
        if ([[contacts allKeys] containsObject:ID]) {
            ABAddressBookRemoveRecord(tmpAddressBook, (__bridge ABRecordRef)(tmpPerson), nil);
        }
    }
    //保存电话本
    ABAddressBookSave(tmpAddressBook, nil);
    CFRelease(tmpAddressBook);
}
+ (void)alertRefuseAccess
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 8.0000) {
        [UIAlertView showAlertViewWithTitle:@"用户拒绝访问通讯录" message:@"请到『设置->隐私』授权访问" cancelButtonTitle:@"取消" otherButtonTitle:@[@"设置"] onDismiss:^(int buttonIndex) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } onCancel:^{
            
        }];
    } else {
        [UIAlertView showAlertViewWithTitle:@"用户拒绝访问通讯录" message:@"请到『设置->隐私』授权访问" cancelButtonTitle:@"知道了" otherButtonTitle:nil onDismiss:^(int buttonIndex) {
        } onCancel:^{
            
        }];
    }
}

+ (NSDictionary *)getChineseStringArr:(NSMutableArray *)arrToSort {
    NSMutableArray *chineseStringsArray = [NSMutableArray array];
    for(int i = 0; i < [arrToSort count]; i++) {
        ContactModel *model = arrToSort[i];
        if(model.name==nil){
            model.name=@"";
        }
        if(![model.name isEqualToString:@""]){
            NSString *pinYinResult = [NSString string];
            for(int j = 0;j < model.name.length; j++) {
                NSString *singlePinyinLetter = [[NSString stringWithFormat:@"%c",
                                                 pinyinFirstLetter([model.name characterAtIndex:j])]uppercaseString];
                
                pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
            }
            model.FullSpell = pinYinResult;
        } else {
            model.FullSpell = @"#";
        }
        [chineseStringsArray addObject:model];
    }
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"FullSpell" ascending:YES]];
    [chineseStringsArray sortUsingDescriptors:sortDescriptors];
    
    
    NSMutableArray *arrayForArrays = [NSMutableArray array];
    BOOL checkValueAtIndex= NO;
    NSMutableArray *TempArrForGrouping = [NSMutableArray array];
    NSMutableArray *sectionHeadsKeys = [NSMutableArray array];
    for(int index = 0; index < [chineseStringsArray count]; index++)
    {
        ContactModel *chineseStr = (ContactModel *)[chineseStringsArray objectAtIndex:index];
        NSMutableString *strchar= [NSMutableString stringWithString:chineseStr.FullSpell];
        NSString *sr= [strchar substringToIndex:1];
        if(![sectionHeadsKeys containsObject:[sr uppercaseString]])
        {
            [sectionHeadsKeys addObject:[sr uppercaseString]];
            TempArrForGrouping = [NSMutableArray array];
            checkValueAtIndex = NO;
        }
        if([sectionHeadsKeys containsObject:[sr uppercaseString]])
        {
            [TempArrForGrouping addObject:[chineseStringsArray objectAtIndex:index]];
            if(checkValueAtIndex == NO)
            {
                
                [arrayForArrays addObject:TempArrForGrouping];
                checkValueAtIndex = YES;
            }
        }
    }
    for (int i = 0 ; i < arrayForArrays.count; i ++) {
        NSArray *array = arrayForArrays[i];
        NSArray *tempArray = [array sortedArrayUsingFunction:nickNameSort context:NULL];
        [arrayForArrays replaceObjectAtIndex:i withObject:tempArray];
    }
    NSDictionary *returnDic = @{@"arrayForArrays": arrayForArrays,
                                @"sectionHeadsKeys": sectionHeadsKeys};
    return returnDic;
}
//联系人排序
NSInteger nickNameSort(id user1, id user2, void *context)
{
    ContactModel *u1,*u2;
    //类型转换
    u1 = (ContactModel*)user1;
    u2 = (ContactModel*)user2;
    return  [u1.name localizedCompare:u2.name];
}
@end
