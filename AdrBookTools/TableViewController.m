//
//  TableViewController.m
//  AdrBookTools
//
//  Created by 陈浩 on 16/5/27.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import "TableViewController.h"
#import "ContactManager.h"
#import "NorwTableViewCell.h"

@interface TableViewController ()
{
    BOOL _isShowCellCheckBox;
}
@property (nonatomic, strong) NSMutableArray *sortedArrForArrays;
@property (nonatomic, strong) NSMutableArray *sectionHeadsKeys;
@end
@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![ContactManager isAllowedToUseEbook]) {
        return ;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *dataArray = [NSMutableArray arrayWithArray:[ContactManager getAllContanct ]];
        NSDictionary *dic = [ContactManager getChineseStringArr:dataArray];
        NSMutableArray *sortedArrForArrays = dic[@"arrayForArrays"];
        NSMutableArray *sectionHeadsKeys = dic[@"sectionHeadsKeys"];
        if (sectionHeadsKeys.count) {
            if ([sectionHeadsKeys[0] isEqualToString:@"#"]) {
                [sectionHeadsKeys removeObject:@"#"];
                NSArray *array = sortedArrForArrays[0];
                [sortedArrForArrays removeObjectAtIndex:0];
                [sortedArrForArrays addObject:array];
                [sectionHeadsKeys addObject:@"#"];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.sectionHeadsKeys = [NSMutableArray arrayWithArray:sectionHeadsKeys];
            self.sortedArrForArrays = [NSMutableArray arrayWithArray:sortedArrForArrays];
            [self.tableView reloadData];
        });
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (IBAction)editAction:(id)sender {
    _isShowCellCheckBox = !_isShowCellCheckBox;
    
    [self.tableView reloadData];
}
- (IBAction)addaction:(id)sender {
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sortedArrForArrays count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.sortedArrForArrays objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NorwTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellid"];
    if (cell == nil) {
        cell = [[NorwTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellid"];
    }
    cell.isShowCheckBox = _isShowCellCheckBox;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(NorwTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactModel *contact = self.sortedArrForArrays[indexPath.section][indexPath.row];
    cell.headerView.image = contact.user_icon == nil ? [UIImage imageNamed:@"default"] : contact.user_icon;
    cell.nameLabel.text = contact.name == nil ? @"" : contact.name;
    cell.numLabel.text = contact.mobile == nil ? @"" : contact.mobile;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 15)];
    bgView.backgroundColor = UIColorFromRGB(0xe4e4e4);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, bgView.bounds.size.width - 30, 15)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = UIColorFromRGB(0x797979);
    titleLabel.font = [UIFont systemFontOfSize:14.0];
    titleLabel.text = [self.sectionHeadsKeys objectAtIndex:section];
    [bgView addSubview:titleLabel];
    return bgView;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionHeadsKeys;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}



@end
