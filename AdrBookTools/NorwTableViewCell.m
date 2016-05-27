//
//  NorwTableViewCell.m
//  AdrBookTools
//
//  Created by 陈浩 on 16/5/27.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import "NorwTableViewCell.h"

@implementation NorwTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}
- (UIImageView *)headerView {
    if (!_headerView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        _headerView = imageView;
        [self.contentView addSubview:_headerView];
    }
    
    return _headerView;
    
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        UILabel *label = [[UILabel alloc] init];
        _nameLabel = label;
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)numLabel {
    if (!_numLabel) {
        UILabel *label = [[UILabel alloc] init];
        _numLabel = label;
        [self.contentView addSubview:_numLabel];
    }
    return _numLabel;
}

- (UIButton *)checkBox {
    if (!_checkBox) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"activate_friends_not_seleted"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"activate_friends_seleted"] forState:UIControlStateSelected];
        _checkBox = btn;
        [self.contentView addSubview:_checkBox];
    }
    return _checkBox;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_isShowCheckBox) {
        
        self.checkBox.frame = CGRectMake(-40, self.frame.size.height / 2 - 20, 40, 40);
        
        self.headerView.frame = CGRectMake(15, 5, 45, 45);
        self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.headerView.frame) + 10, CGRectGetMinY(self.headerView.frame), self.frame.size.width - 30 - (CGRectGetMaxX(self.headerView.frame) + 10), 25);
        self.numLabel.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetMaxY(self.headerView.frame) - 25, self.nameLabel.frame.size.width, 25);
        self.checkBox.hidden = !_isShowCheckBox;
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.checkBox.frame = CGRectMake(10, self.frame.size.height / 2 - 20, 40, 40);
            self.headerView.frame = CGRectMake(self.checkBox.frame.size.width + 10 + 10, 5, 45, 45);
            self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.headerView.frame) + 10, CGRectGetMinY(self.headerView.frame), self.frame.size.width - 30 - (CGRectGetMaxX(self.headerView.frame) + 10), 25);
            self.numLabel.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetMaxY(self.headerView.frame) - 25, self.nameLabel.frame.size.width, 25);
        } completion:^(BOOL finished) {
            
        }];
        
        
    } else {
        
        if (self.checkBox.hidden == NO) {
            [UIView animateWithDuration:0.25 animations:^{
                self.checkBox.frame = CGRectMake(-40, self.frame.size.height / 2 - 20, 40, 40);
                self.headerView.frame = CGRectMake(15, 5, 45, 45);
                self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.headerView.frame) + 10, CGRectGetMinY(self.headerView.frame), self.frame.size.width - 30 - (CGRectGetMaxX(self.headerView.frame) + 10), 25);
                self.numLabel.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetMaxY(self.headerView.frame) - 25, self.nameLabel.frame.size.width, 25);
            } completion:^(BOOL finished) {
                self.checkBox.hidden = YES;
            }];
        } else {
            self.headerView.frame = CGRectMake(15, 5, 45, 45);
            self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.headerView.frame) + 10, CGRectGetMinY(self.headerView.frame), self.frame.size.width - 30 - (CGRectGetMaxX(self.headerView.frame) + 10), 25);
            self.numLabel.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetMaxY(self.headerView.frame) - 25, self.nameLabel.frame.size.width, 25);
            self.checkBox.hidden = YES;
        }
        
    }
    
    
}
@end
