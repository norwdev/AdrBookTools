//
//  NorwTableViewCell.h
//  AdrBookTools
//
//  Created by 陈浩 on 16/5/27.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NorwTableViewCell : UITableViewCell
@property (nonatomic, strong) UIImageView *headerView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, strong) UIButton *checkBox;
@property (nonatomic, assign) BOOL isShowCheckBox;
@end
