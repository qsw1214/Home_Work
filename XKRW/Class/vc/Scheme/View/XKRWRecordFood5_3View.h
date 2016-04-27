//
//  XKRWRecordFood5_3View.h
//  XKRW
//
//  Created by ss on 16/4/13.
//  Copyright © 2016年 XiKang. All rights reserved.
//

@protocol XKRWRecordFood5_3ViewDelegate <NSObject>
@optional
-(void)RecordFoodViewpressCancle;
-(void)addMoreView;
-(void)entryRecordVCWith:(SchemeType)schemeType;
@end

#import <UIKit/UIKit.h>
#import "XKRWRecordSchemeEntity.h"

@interface XKRWRecordFood5_3View : UIView
@property (assign,nonatomic) id<XKRWRecordFood5_3ViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *recommendedTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *habitLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordTypeLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *labSeperate;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *centerbutton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIView *actionView;

// 点击的是记录饮食圆环  进入营养分析
- (IBAction)leftButtonAction:(UIButton *)sender;
// 记录推荐饮食  推荐运动  运动
- (IBAction)centerButtonAction:(UIButton *)sender;
//点击的是记录饮食圆环  进入记录食物
- (IBAction)rightButtonAction:(UIButton *)sender;

//关闭页面
- (IBAction)cancleAction:(UIButton *)sender;
//选中记录按钮 action
- (IBAction)recordSeclctAction:(UIButton *)sender;
//选中推荐按钮 action
- (IBAction)recommendedSelectAction:(UIButton *)sender;

-(void)initSubViews;

@property (assign) NSInteger positionX;
@property (assign ,nonatomic) NSInteger pageIndex;
@property (strong ,nonatomic) NSArray *reocrdArray;
@property (strong ,nonatomic) NSArray *schemeArray;
@property (assign ,nonatomic) energyType type;
@property (strong ,nonatomic) NSMutableDictionary *dicCollection;
@property (strong ,nonatomic) UIImageView *shadowImageView;

@property (nonatomic,strong) UIViewController *vc;

@end