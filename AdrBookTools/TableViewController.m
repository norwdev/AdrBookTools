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
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <ContactsUI/ContactsUI.h>
@interface TableViewController ()<ABNewPersonViewControllerDelegate,CNContactViewControllerDelegate>
{
    BOOL _isShowCellCheckBox;
    BOOL _isDoCellAnimation;
    UIToolbar *_bottomBar;
    UIButton *_delBtn;
}
@property (nonatomic, strong) NSMutableArray *sortedArrForArrays;
@property (nonatomic, strong) NSMutableArray *sectionHeadsKeys;
@property (nonatomic, strong) NSMutableDictionary *selectedContactDic;
@end
@implementation TableViewController

#pragma mark - super
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - initData 
- (void)initData {
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
#pragma mark - action
- (IBAction)editAction:(id)sender {
    
    _isShowCellCheckBox = !_isShowCellCheckBox;
    _isDoCellAnimation = YES;
    [self.tableView reloadData];
    
    if (_isShowCellCheckBox) {
        [self showToolBar];
    } else {
        [self disMissToolBar];
    }
}
- (IBAction)addaction:(id)sender {
#ifdef __IPHONE_9_0
    
    CNContactViewController *nContactVC = [CNContactViewController viewControllerForNewContact:NULL];
    nContactVC.delegate = self;
    [self.navigationController pushViewController:nContactVC animated:YES];
#else
    ABNewPersonViewController* llViewController = [[ABNewPersonViewController alloc] init];
    llViewController.newPersonViewDelegate = self;
    [self.navigationController pushViewController:llViewController animated:YES];
#endif
    
    
}

#ifdef __IPHONE_9_0
- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact
{
    [self.navigationController popViewControllerAnimated:viewController];
    [self initData];
}
#else
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person {
    [self.navigationController popViewControllerAnimated:newPersonView];
    [self initData];
}

#endif
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
    cell.isDoAnimation = _isDoCellAnimation;
    if (![[_selectedContactDic allKeys] containsObject:[self.sortedArrForArrays[indexPath.section][indexPath.row] personID]]) {
        cell.checkBox.selected = NO;
    } else {
        cell.checkBox.selected = YES;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 15)];
    bgView.backgroundColor = UIColorFromRGB(0xe4e4e4);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, bgView.bounds.size.width - 20, 15)];
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
    _isDoCellAnimation = NO;
    if (_selectedContactDic == nil) {
        _selectedContactDic = [NSMutableDictionary dictionary];
    }
    
    if (![[_selectedContactDic allKeys] containsObject:[self.sortedArrForArrays[indexPath.section][indexPath.row] personID]]) {
        [_selectedContactDic setObject:self.sortedArrForArrays[indexPath.section][indexPath.row] forKey:[self.sortedArrForArrays[indexPath.section][indexPath.row] personID]];
    } else {
        [_selectedContactDic removeObjectForKey:[self.sortedArrForArrays[indexPath.section][indexPath.row] personID]];
    }
    if (_delBtn) {
        [self setDelBtnTitle];
    }
    [tableView reloadData];
}


#pragma mark - scrollview delegate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    _isDoCellAnimation = YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _isDoCellAnimation = NO;
}

#pragma mark - toolBar

- (void)showToolBar {
    if (_bottomBar == nil) {
        _bottomBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [[UIApplication sharedApplication] keyWindow].frame.size.height, [[UIApplication sharedApplication] keyWindow].frame.size.width, 44)];
        UIButton *allBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        allBtn.frame = CGRectMake(15, 0, 40, _bottomBar.frame.size.height);
        [allBtn addTarget:self action:@selector(allBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [allBtn setTitle:@"全选" forState:UIControlStateNormal];
        [_bottomBar addSubview:allBtn];
        
        _delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _delBtn.frame = CGRectMake([[UIApplication sharedApplication] keyWindow].frame.size.width - 100, 0, 100, _bottomBar.frame.size.height);
        [_delBtn addTarget:self action:@selector(delBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_delBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _delBtn.enabled = NO;
        [_delBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_bottomBar addSubview:_delBtn];
        
    }
    _bottomBar.hidden = NO;
    [[[UIApplication sharedApplication] keyWindow] addSubview:_bottomBar];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height - 44);
        _bottomBar.frame = CGRectMake(0, [[UIApplication sharedApplication] keyWindow].frame.size.height - 44, [[UIApplication sharedApplication] keyWindow].frame.size.width, 44);
    }];
    
    
}

- (void)disMissToolBar {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height + 44);
        _bottomBar.frame = CGRectMake(0, [[UIApplication sharedApplication] keyWindow].frame.size.height, [[UIApplication sharedApplication] keyWindow].frame.size.width, 44);
    } completion:^(BOOL finished) {
        _bottomBar.hidden = YES;
    }];
    
}

- (void)allBtnAction:(UIButton *)btn {
    btn.selected = !btn.selected;
    _isDoCellAnimation = NO;
    if (_selectedContactDic == nil) {
        _selectedContactDic = [NSMutableDictionary dictionaryWithCapacity:100];
    }
    if (btn.selected) {
        for (NSArray *array in self.sortedArrForArrays) {
            for (ContactModel *contact in array) {
                if (![[_selectedContactDic allKeys] containsObject:[contact personID]]) {
                    [_selectedContactDic setObject:contact forKey:[contact personID]];
                }
            }
        }
    } else {
        [_selectedContactDic removeAllObjects];
    }
    
    
    [self.tableView reloadData];
}

- (void)delBtnAction {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [ContactManager delContactInEbook:_selectedContactDic];
        [self initData];
        [_selectedContactDic removeAllObjects];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setDelBtnTitle];
            [self.tableView reloadData];
        });
    });
}

- (void)setDelBtnTitle {
    if ([[_selectedContactDic allKeys] count] > 0) {
        [_delBtn setTitle:[NSString stringWithFormat:@"删除(%ld)",[[_selectedContactDic allKeys] count]] forState:UIControlStateNormal];
        _delBtn.enabled = YES;
    } else {
        [_delBtn setTitle:[NSString stringWithFormat:@"删除"] forState:UIControlStateNormal];
        _delBtn.enabled = NO;
    }
}
@end
