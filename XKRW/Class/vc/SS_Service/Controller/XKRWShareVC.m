//
//  XKRWShareVC.m
//  XKRW
//
//  Created by Jiang Rui on 13-12-11.
//  Copyright (c) 2013年 XiKang. All rights reserved.
//

#import "XKRWShareVC.h"
#import "WXApi.h"
#import "XKRWServiceCell.h"
#import "XKRWMoreCells.h"
#import "XKRWEnumDefine.h"
#import "XKRWFatReasonService.h"
#import "XKRWBuyRecordVC.h"
#import "XKRWAttentionWechatVC.h"
#import "XKRWiSlimAssessmentPurchaseVC.h"
#import "XKRWPhysicalAssessmentVC.h"
#import "XKRWPersonalCircumstancesVC.h"
#import "XKRWDietCircumstancesVC.h"
#import "XKRWUserDefaultService.h"
#import "XKRWDietModel.h"
#import "XKRWServerPageService.h"
#import "XKRWRecordService4_0.h"
#import "XKRWServerPageService.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
//#import "XKRW-Swift.h"
#import "XKRWNavigationController.h"
#import "XKRWServiceIslimADDCell.h"
#import "XKRWUtil.h"
#import "XKRWIslimModel.h"
#import "XKRWNewWebView.h"
#import "XKRWUserService.h"

static NSString *ssbuyUrl = @"http://ssbuy.xikang.com/?third_party=xikang&third_token=";
@interface XKRWShareVC ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray  *cellIconImageArrays;
    NSArray  *titleArrays ;
    NSArray  *describeArrays;
    NSString *weChatNum;  // 关注微信的人数
    NSString *buyServerNum; //购买服务的人数
    NSMutableArray  *testArray;
    
    NSMutableArray  * islimAddArray;    ///< islim 广告
    NSInteger _shopNumber;
    BOOL _isShowiSlim;
}
@end


@implementation XKRWShareVC
{
    BOOL _isShowRedHot;    //是否显示红色的热键
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[XKRWServerPageService sharedService] needRequestStateOfSwitch]) {
        _isShowiSlim = NO;
        [self downloadWithTaskID:@"requestState" outputTask:^{
            return @([[XKRWServerPageService sharedService] isShowPurchaseEntry_uploadVersion]);
        }];
    } else {
        _isShowiSlim = YES;
    }
    [self reloadData];
    
    [MobClick event:@"in_Service"];
    [_serviceTableView reloadData];
    [self loadDataFromRemote];
}

- (void)viewDidLoad
{
    self.forbidAutoAddCloseButton = YES;
    [super viewDidLoad];
    self.title = @"服务";
    weChatNum = @"";
    buyServerNum =@"";
    [self initView];
    
    [self downloadWithTaskID:@"islimDataForAdd" outputTask:^id{
        return [[XKRWServerPageService sharedService] requestIslimDataForAdd];
    }];
}


/**
 *  初始化子视图
 */
- (void)initView
{
    _serviceTableView = [[XKRWUITableViewBase alloc]initWithFrame:CGRectMake(0, 0, XKAppWidth, XKAppHeight - 64 -49) style:UITableViewStylePlain];
    _serviceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _serviceTableView.delegate = self;
    _serviceTableView.dataSource = self;
    _serviceTableView.backgroundColor = colorSecondary_f4f4f4;
    [_serviceTableView registerNib:[UINib nibWithNibName:@"XKRWServiceIslimADDCell" bundle:nil] forCellReuseIdentifier:@"islimADDCell"];
    [self.view addSubview:_serviceTableView];
    self.navigationItem.leftBarButtonItem = nil;
    
    [self addNaviBarRightButtonWithText:@"服务记录" action:@selector(servicerecordAction:)];
}
/**
 *  初始化数据
 */
- (void)reloadData {
    
    if (_isShowiSlim) {
        
        cellIconImageArrays = @[@"serviceIcon_01",@"icon_02_",@"shop_icon"];
        titleArrays = @[@"iSlim专业瘦身评估",@"咨询私人顾问",@"瘦瘦官方商城"];
        describeArrays = @[@"让减肥从困难变容易",@"最专业的瘦身指导",@"用极少的费用，让减肥效果加倍吧"];
    }
    else {
        cellIconImageArrays = @[@"icon_02_",@"shop_icon"];
        titleArrays = @[@"咨询私人顾问",@"瘦瘦官方商城"];
        describeArrays = @[@"最专业的瘦身指导",@"用极少的费用，让减肥效果加倍吧"];
    }
}


- (void)servicerecordAction:(UIButton *)button
{
    XKRWBuyRecordVC *buyRecordVc = [[XKRWBuyRecordVC alloc]init];
    buyRecordVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:buyRecordVc animated:YES];
}

//远程加载  系统推荐方案数据
- (void) loadDataFromRemote
{
    if (![XKUtil isNetWorkAvailable]) {
        [XKRWCui hideProgressHud];
        [XKRWCui showInformationHudWithText:@"没有网络，请检查网络设置"];
        return;
    }
    XKDispatcherOutputTask block = ^(){
        return [[XKRWServerPageService sharedService] getServerDataFromNetwork];
    };
    [self downloadWithTaskID:@"getServerData" outputTask:block];
}

#pragma mark - Net Data
- (void)didDownloadWithResult:(id)result taskID:(NSString *)taskID{
    
    if([taskID isEqualToString:@"getServerData"])
    {
        if([[result objectForKey:@"EvaluateTotal"] integerValue] !=0)
        {
            buyServerNum = [NSString stringWithFormat:@"%ld在用", (long)[[result objectForKey:@"EvaluateTotal"] integerValue]];
            
            [[NSUserDefaults standardUserDefaults] setObject:buyServerNum forKey:BUYSERVERNUM];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        weChatNum =[result objectForKey:@"AttentionTotal"];
        [_serviceTableView reloadData];
    } else if ([taskID isEqualToString:@"requestState"]) {
        _isShowiSlim = [result boolValue];
        if (_isShowiSlim) {
            [self reloadData];
            [_serviceTableView reloadData];
        }
    }else if ([taskID isEqualToString:@"islimDataForAdd"]){
        
        islimAddArray = [NSMutableArray arrayWithArray:(NSMutableArray *)result];
        for (XKRWIslimAddModel * model in islimAddArray) {
            _shopNumber += [model.name isEqualToString:@"瘦瘦商城"] ? 1 : 0;
        }
        [_serviceTableView reloadData];
    }
}

/**
 *  方案网络请求失败后 处理数据
 *
 *  @param problem
 *  @param taskID
 */
- (void)handleDownloadProblem:(id)problem withTaskID:(NSString *)taskID
{
    [super handleDownloadProblem:problem withTaskID:taskID];
    if ([taskID isEqualToString:@"getServerData"]) {
        XKLog(@"网络请求失败");
    }
}


- (BOOL)shouldRespondForDefaultNotification:(XKDefaultNotification *)notication
{
    return YES;
}




#pragma tabDelegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_isShowiSlim) {
        return 3 + islimAddArray.count - _shopNumber;
    }
    
    return 2 + islimAddArray.count - _shopNumber;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0 || indexPath.section==1) {
        return 80;
    }
    return XKAppWidth/5;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, XKAppWidth, 10)];
    [view setBackgroundColor:XKClearColor];
    
    return view;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(_isShowiSlim) {
        if (indexPath.section == 0 ) {
            
            XKRWServiceCell *cell = LOAD_VIEW_FROM_BUNDLE(@"XKRWServiceCell");
            
            if([[NSUserDefaults standardUserDefaults] objectForKey:BUYSERVERNUM]){
                buyServerNum = [[NSUserDefaults standardUserDefaults] objectForKey:BUYSERVERNUM];
            }
            
            [cell initSubViewsWithIconImageName:[cellIconImageArrays objectAtIndex:indexPath.section] Title:[titleArrays objectAtIndex:indexPath.section] Describe:[describeArrays objectAtIndex:indexPath.section] tip:buyServerNum isShowHotImageView:NO isShowRedDot:NO];
            
            return cell;
            
        }else if (indexPath.section <= 2)
        {
            
            NSString *str = indexPath.section == 1 ? weChatNum : @"";
            XKRWServiceCell *cell = LOAD_VIEW_FROM_BUNDLE(@"XKRWServiceCell");
            [cell initSubViewsWithIconImageName:[cellIconImageArrays objectAtIndex:indexPath.section] Title:[titleArrays objectAtIndex:indexPath.section] Describe:[describeArrays objectAtIndex:indexPath.section] tip:str isShowHotImageView:NO isShowRedDot:NO];
            
            return cell;
        }else{
            
            XKRWIslimAddModel * model = islimAddArray[indexPath.section - 2];
            XKRWServiceIslimADDCell * cell = [tableView dequeueReusableCellWithIdentifier:@"islimADDCell" forIndexPath:indexPath];
            [XKRWUtil addViewUpLineAndDownLine:cell andUpLineHidden:NO DownLineHidden:NO];
            
            [cell.IconButton setImageWithURL:[NSURL URLWithString:model.image] forState:UIControlStateNormal placeholderImage:nil options:SDWebImageRetryFailed];
            
            XKRWIslimAddModel __block * blockModel = model;
            __weak __typeof(self)weakSelf = self;
            
            cell.ButtonHanle = ^{
                
                [MobClick event:@"clk_FocusMap"];
                
                XKRWNewWebView * adVC = [XKRWNewWebView new];
                adVC.hidesBottomBarWhenPushed = YES;
                adVC.contentUrl = blockModel.addr;
                adVC.webTitle = blockModel.name;
                adVC.showType = YES;
                
                [weakSelf presentViewController:[[XKRWNavigationController alloc]initWithRootViewController:adVC withNavigationBarType:NavigationBarTypeDefault] animated:YES completion:^{
                    
                }];
            };
            return cell;
            
        }
    }
    else{
        
        if (indexPath.section <= 1 ) {
            NSString *str = indexPath.section == 0 ? weChatNum : @"";
            XKRWServiceCell *cell = LOAD_VIEW_FROM_BUNDLE(@"XKRWServiceCell");
            [cell initSubViewsWithIconImageName:[cellIconImageArrays objectAtIndex:indexPath.section] Title:[titleArrays objectAtIndex:indexPath.section] Describe:[describeArrays objectAtIndex:indexPath.section] tip:str isShowHotImageView:NO isShowRedDot:NO];
            
            return cell;
            
        }else{
            
            XKRWIslimAddModel * model = islimAddArray[indexPath.section - 1];
            
            XKRWServiceIslimADDCell * cell = [tableView dequeueReusableCellWithIdentifier:@"islimADDCell" forIndexPath:indexPath];
            [XKRWUtil addViewUpLineAndDownLine:cell andUpLineHidden:NO DownLineHidden:NO];
            
            [cell.IconButton setImageWithURL:[NSURL URLWithString:model.image] forState:UIControlStateNormal placeholderImage:nil];
            
            if ([model.name isEqualToString:@"瘦瘦商城"]) {
                model.addr = [NSString stringWithFormat:@"%@%@",ssbuyUrl,[[XKRWUserService sharedService] getToken]];
            }
            
            XKRWIslimAddModel __block * blockModel = model;
            __weak __typeof(self)weakSelf = self;
            
            
            cell.ButtonHanle = ^{
                
                [MobClick event:@"clk_FocusMap"];
                
                XKRWNewWebView * adVC = [XKRWNewWebView new];
                adVC.hidesBottomBarWhenPushed = YES;
                adVC.contentUrl = blockModel.addr;
                adVC.webTitle = blockModel.name;
                adVC.showType = YES;
                
                [weakSelf presentViewController:[[XKRWNavigationController alloc]initWithRootViewController:adVC withNavigationBarType:NavigationBarTypeDefault] animated:YES completion:^{
                    
                }];
                
            };
            return cell;
        }
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(_isShowiSlim)
    {
        if (indexPath.section == 0) {
            [MobClick event:@"in_iSlim"];
            XKRWiSlimAssessmentPurchaseVC  *slimVC = [[XKRWiSlimAssessmentPurchaseVC alloc]init];
            slimVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:slimVC animated:YES];
            
        } else if (indexPath.section == 1) {
            [MobClick event:@"in_WcSvc"];
            XKRWAttentionWechatVC *attentionWechatVC = [[XKRWAttentionWechatVC alloc]init];
            attentionWechatVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:attentionWechatVC animated:YES];
            
        }else{
            XKRWNewWebView * adVC = [XKRWNewWebView new];
            adVC.hidesBottomBarWhenPushed = YES;
            adVC.contentUrl = [NSString stringWithFormat:@"%@%@",ssbuyUrl,[[XKRWUserService sharedService] getToken]];
            adVC.webTitle = @"瘦瘦官方商城";
            adVC.showType = YES;
            [self.navigationController pushViewController:adVC animated:YES];
        }
        
    }else{
        if (indexPath.section == 0)
        {
            [MobClick event:@"in_WcSvc"];
            XKRWAttentionWechatVC *attentionWechatVC = [[XKRWAttentionWechatVC alloc]init];
            attentionWechatVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:attentionWechatVC animated:YES];
            
        }else if (indexPath.section == 1){
            XKRWNewWebView * adVC = [XKRWNewWebView new];
            adVC.hidesBottomBarWhenPushed = YES;
            adVC.contentUrl = [NSString stringWithFormat:@"%@%@",ssbuyUrl,[[XKRWUserService sharedService] getToken]];
            adVC.webTitle = @"瘦瘦官方商城";
            adVC.showType = YES;
            [self.navigationController pushViewController:adVC animated:YES];
            
        } else {
            
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
