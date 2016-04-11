//
//  XKRWPlanVC.m
//  XKRW
//
//  Created by 忘、 on 16/4/1.
//  Copyright © 2016年 XiKang. All rights reserved.
//

#import "XKRWPlanVC.h"
#import "XKRWRecordAndTargetView.h"
#import "XKRWUITableViewBase.h"
#import "XKRWUITableViewCellbase.h"
#import "KMSearchBar.h"
#import "KMSearchDisplayController.h"
#import "XKRWPlanEnergyView.h"
#import "XKRWWeightRecordPullView.h"
#import "XKRWWeightPopView.h"
#import <iflyMSC/IFlyRecognizerView.h>
#import <iflyMSC/IFlyRecognizerViewDelegate.h>
#import <iflyMSC/iflyMSC.h>
#import "XKRWCui.h"
#import "XKRW-Swift.h"

@interface XKRWPlanVC ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate, UISearchDisplayDelegate, UISearchControllerDelegate,KMSearchDisplayControllerDelegate,XKRWWeightRecordPullViewDelegate,XKRWWeightPopViewDelegate,IFlyRecognizerViewDelegate>
{
    XKRWUITableViewBase  *planTableView;
    KMSearchBar* foodAndSportSearchBar;
    KMSearchDisplayController * searchDisplayCtrl;
    IFlyRecognizerView *iFlyControl;
    NSString *searchKey;
   
}
@property (nonatomic, strong) XKRWPlanEnergyView *planEnergyView;
@property (nonatomic, strong) XKRWRecordAndTargetView *recordAndTargetView;
@property (nonatomic, strong) XKRWWeightRecordPullView *pullView;
@property (nonatomic, strong) XKRWWeightPopView *popView;
@end

@implementation XKRWPlanVC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self addTouchWindowEvent];
}

-(void)addTouchWindowEvent{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelPopView)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
//    [[UIApplication sharedApplication].keyWindow addGestureRecognizer:singleTap];
}

#pragma --mark UI
- (void)initView {
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    planTableView = [[XKRWUITableViewBase alloc]initWithFrame:CGRectMake(0, 0, XKAppWidth, XKAppHeight) style:UITableViewStylePlain];
    planTableView.delegate = self;
    planTableView.dataSource = self;
    [self.view addSubview:planTableView];
    
    _planEnergyView = [[XKRWPlanEnergyView alloc] initWithFrame:CGRectMake(0, 0, XKAppWidth, 68 + (XKAppWidth - 66)/3.0)];
    [_planEnergyView setEatEnergyCircleGoalNumber:4000 currentNumber:3000 isBehaveCurrect:YES];
    [_planEnergyView setSportEnergyCircleGoalNumber:400 currentNumber:200 isBehaveCurrect:NO];
    [_planEnergyView setHabitEnergyCircleGoalNumber:12 currentNumber:3 isBehaveCurrect:NO];
    
    iFlyControl = [[IFlyRecognizerView alloc]initWithCenter:CGPointMake(XKAppWidth/2, XKAppHeight/2)];
    [iFlyControl setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN] ];
    [iFlyControl setParameter:@"srview.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH] ];
    [iFlyControl setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT] ];
    [iFlyControl setParameter:@"16000" forKey:[IFlySpeechConstant SAMPLE_RATE] ];
    [iFlyControl setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE] ];
    [iFlyControl setParameter:@"1" forKey:[IFlySpeechConstant ASR_PTT] ];
    [iFlyControl setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source" ];
    
    iFlyControl.delegate = self;
    iFlyControl.hidden = YES;
    [self.view addSubview:iFlyControl];

}

- (XKRWUITableViewCellbase *)setSearchAndRecordCell:(UITableView *)tableView {
    XKRWUITableViewCellbase *cell = [tableView dequeueReusableCellWithIdentifier:@"searchAndRecord"];
    if(cell == nil){
        cell = [[XKRWUITableViewCellbase alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchAndRecord"];
        cell.frame = CGRectMake(0, 0, XKAppWidth, 120);
    }
    if (foodAndSportSearchBar == nil) {
        foodAndSportSearchBar = [[KMSearchBar alloc]initWithFrame:CGRectMake(0, 20, XKAppWidth, 44)];
        
        foodAndSportSearchBar.delegate = self;
        foodAndSportSearchBar.barTintColor = [UIColor whiteColor];
        [foodAndSportSearchBar setSearchBarTextFieldColor:XKBGDefaultColor];
        
        foodAndSportSearchBar.showsBookmarkButton = true;
        foodAndSportSearchBar.showsScopeBar = true;
        
        [foodAndSportSearchBar setImage:[UIImage imageNamed:@"voice"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
        foodAndSportSearchBar.placeholder = @"查询食物和运动" ;
        searchDisplayCtrl = [[KMSearchDisplayController alloc] initWithSearchBar:foodAndSportSearchBar contentsController:self];
        searchDisplayCtrl.delegate = self ;
        
        searchDisplayCtrl.searchResultDelegate = self ;
        searchDisplayCtrl.searchResultDataSource = self ;
        
        searchDisplayCtrl.searchResultTableView.tag = 201 ;
        [searchDisplayCtrl.searchResultTableView registerNib:[UINib nibWithNibName:@"XKRWSearchResultCell" bundle:nil] forCellReuseIdentifier:@"searchResultCell"];
        
        
        
        [searchDisplayCtrl.searchResultTableView registerNib:[UINib nibWithNibName:@"XKRWSearchResultCategoryCell" bundle:nil] forCellReuseIdentifier:@"searchResultCategoryCell"];
        
        
        [searchDisplayCtrl.searchResultTableView registerNib:[UINib nibWithNibName:@"XKRWMoreSearchResultCell" bundle:nil] forCellReuseIdentifier:@"moreSearchResultCell"];
        
        
        searchDisplayCtrl.searchResultTableView.separatorStyle = UITableViewCellSeparatorStyleNone ;
        [cell.contentView addSubview:foodAndSportSearchBar];
    }
    
    if(_recordAndTargetView == nil){
        _recordAndTargetView
        = LOAD_VIEW_FROM_BUNDLE(@"XKRWRecordAndTargetView");
        _recordAndTargetView.frame = CGRectMake(0, 64, cell.contentView.width, 30);
        _recordAndTargetView.dayLabel.layer.masksToBounds = YES;
        _recordAndTargetView.dayLabel.layer.cornerRadius = 16;
        _recordAndTargetView.dayLabel.layer.borderColor = XKMainToneColor_29ccb1.CGColor;
        _recordAndTargetView.dayLabel.layer.borderWidth = 1;
        
        _recordAndTargetView.currentWeightLabel.layer.masksToBounds = YES;
        _recordAndTargetView.currentWeightLabel.layer.cornerRadius = 16;
        _recordAndTargetView.currentWeightLabel.layer.borderColor = XKMainToneColor_29ccb1.CGColor;
        _recordAndTargetView.currentWeightLabel.layer.borderWidth = 1;
        
        [_recordAndTargetView.weightButton addTarget:self action:@selector(setUserDataAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UILongPressGestureRecognizer *gesLongPressed = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressRecognizer:)];
        gesLongPressed.minimumPressDuration = 1.0f;
        gesLongPressed.numberOfTouchesRequired=1;
        [_recordAndTargetView.weightButton addGestureRecognizer:gesLongPressed];
        
        [_recordAndTargetView.calendarButton addTarget:self action:@selector(entryCalendarAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:_recordAndTargetView];

    }
    return cell;
}

#pragma --mark Action
/**
 *  长按按钮1秒钟直接进入记录体重
 *
 */
- (void)handleLongPressRecognizer:(UIButton *)sender {
    if (sender.state == UIGestureRecognizerStateBegan){
        NSLog(@"UIGestureRecognizerStateBegan.");
        [self pressWeight];
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"UIGestureRecognizerStateEnded");
    }
}

- (void)setUserDataAction:(UIButton *)button {

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = self.view.bounds;
    [btn addTarget:self action:@selector(removePullView:) forControlEvents:UIControlEventTouchDown];
    if (_pullView == nil) {
        
        _pullView = [[XKRWWeightRecordPullView alloc] initWithFrame:CGRectMake(0, 0, 80, 90)];
        CGPoint center = button.center;
        center.x = XKAppWidth - _pullView.frame.size.width/2 - 15;
        center.y = button.center.y + button.frame.size.height + _pullView.frame.size.height/2+foodAndSportSearchBar.frame.size.height;
        _pullView.center = center;
        [btn addSubview:_pullView];
        _pullView.alpha = 0;
        _pullView.delegate = self;
        
        [self.view addSubview:btn];
    }
    [self removePullView:btn];
}

-(void)removePullView:(UIButton *)button{
    if (_pullView.alpha == 0) {
        [UIView animateWithDuration:.3 animations:^{
            _pullView.alpha = 1;
        }];
    }else{
        [UIView animateWithDuration:.3 animations:^{
            _pullView.alpha = 0;
        }completion:^(BOOL finished) {
            [button removeFromSuperview];
            [_pullView removeFromSuperview];
            _pullView = nil;
        }];
    }
}

- (void)entryCalendarAction:(UIButton *)button{

}


#pragma XKRWWeightRecordPullViewDelegate method

/**
 *  记录体重
 */
-(void)pressWeight{
    [self popViewAppear:0];
}

/**
 *  记录围度
 */
-(void)pressContain{
    [self popViewAppear:1];
}

/**
 *  查看曲线
 */
-(void)pressGraph{
    [self popViewAppear:2];
}

/**
 *  点击不同的按钮类型不同
 *
 *  @param type 0:记录体重 
 *              1:记录围度
 *              2:查看曲线
 */
-(void)popViewAppear:(NSInteger)type{
    _popView = [[XKRWWeightPopView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    _popView.delegate = self;
    CGPoint center = self.view.center;
    center.y -= 100;
    _popView.center = center;
    _popView.alpha = 0;
    [UIView animateWithDuration:.3 delay:.1 options:0 animations:^{
        [_popView.textField becomeFirstResponder];
        [[UIApplication sharedApplication].keyWindow addSubview:_popView];
        _popView.center = self.view.center;
        _pullView.alpha = 0;
        self.view.alpha = .5;
        _popView.alpha = 1;
        self.view.userInteractionEnabled = NO;
        self.tabBarController.tabBar.hidden = YES;
    } completion:nil];
}

-(void)cancelPopView{
    if (_popView) {
        CGPoint center = _popView.center;
        center.y -= 100;
        [_popView.textField resignFirstResponder];
        [UIView animateWithDuration:.5 delay:0 options:0 animations:^{
            _popView.center = center;
            _popView.alpha = 0;
            self.view.alpha = 1;
        } completion:^(BOOL finished) {
            [_popView removeFromSuperview];
            _popView = nil;
            self.view.userInteractionEnabled = YES;
            self.tabBarController.tabBar.hidden = NO;
        }];
    }else{
        [self setUserDataAction:nil];
    }
}

#pragma XKRWWeightPopViewDelegate 
-(void)pressPopViewSure:(NSNumber *)inputNum{
    [self cancelPopView];
}

-(void)pressPopViewCancle{
    [self cancelPopView];
}

#pragma --mark Delegate
#pragma --mark TableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        XKRWUITableViewCellbase *cell  = [tableView dequeueReusableCellWithIdentifier:@"searchAndRecord"];
        if(cell == nil){
            cell = [self setSearchAndRecordCell:tableView];
        }
        
        return cell;
    } else if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"energyCircle"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"energyCircle"];
            cell.contentView.size = CGSizeMake(XKAppWidth, 68 + (XKAppWidth - 88)/3.0);
            [cell addSubview:_planEnergyView];
        }
        return cell;
    }

    
    return [UITableViewCell new];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        return 68 + (XKAppWidth - 88)/3.0;
    }
    return 120;
}


#pragma --mark UISearchBar Delegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchDisplayCtrl showSearchResultView];
//    self.isNeedHideNaviBarWhenPoped = YES;
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
//    self.isNeedHideNaviBarWhenPoped = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchDisplayCtrl hideSearchResultView];
//    self.isNeedHideNaviBarWhenPoped = NO;
}



- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
//    self.isNeedHideNaviBarWhenPoped = NO;
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
//    self.isNeedHideNaviBarWhenPoped = YES;
    
    if (searchBar.text.length > 0){
        searchKey = searchBar.text;
        [self downloadWithTaskID:@"search" outputTask:^id{
            
            return [[XKRWSearchService sharedService] searchWithKey:searchKey type:XKRWSearchTypeAll page:1 pageSize:30];
        }];
        
        if([searchBar resignFirstResponder])
        {
            [foodAndSportSearchBar setCancelButtonEnable:YES];
        }
    }
}



- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    [MobClick event:@"clk_VoiceSerch"];
    [searchDisplayCtrl showSearchResultView];
    [searchBar setShowsCancelButton:YES animated:YES];
    
    if (iFlyControl.hidden){
        iFlyControl.hidden = NO;
        [iFlyControl start];
    }else{
        iFlyControl.hidden = YES;
        [iFlyControl cancel];

    }
}

#pragma --mark IFlyDelegate
// MARK: - iFly's delegate

- (void)onError:(IFlySpeechError *)error {
    if ([error errorCode] != 0){
        [XKRWCui  showInformationHudWithText:@"搜索失败"];
    }
}

- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast {
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
