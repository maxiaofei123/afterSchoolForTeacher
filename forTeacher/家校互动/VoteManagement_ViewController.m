//
//  VoteManagement_ViewController.m
//  forTeacher
//
//  Created by susu on 15/6/9.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "VoteManagement_ViewController.h"
#import "VoteHistory_ViewController.h"
#import "VoteNow_ViewController.h"
#import "AddVote_ViewController.h"
#import "VoteDetail_ViewController.h"
@interface VoteManagement_ViewController ()
{

}
@property (weak, nonatomic) UISegmentedControl *segmentedControl;
@property(nonatomic,retain)VoteHistory_ViewController * voteHistory;
@property(nonatomic,retain)VoteNow_ViewController * voteNow;
@end

@implementation VoteManagement_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.automaticallyAdjustsScrollViewInsets =NO;
    self.navigationItem.title = @"投票管理";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self initUIsegmentedcontrol];
    
    __block VoteManagement_ViewController *vc = self;
    
    self.voteNow = [[VoteNow_ViewController alloc] init];
    self.voteHistory= [[VoteHistory_ViewController alloc] init];
    
    self.voteNow.voteNowClassId = self.classId;
    self.voteHistory.historyclassID = self.classId;
    
    
    self.voteNow.view.frame = CGRectMake(10, 40, Main_Screen_Width-20, Main_Screen_Height-59-64-50);
    self.voteHistory.view.frame = CGRectMake(10, 40, Main_Screen_Width-20, Main_Screen_Height-59-64-50);
    
    self.voteNow.addVoteBlock = ^()
    {   AddVote_ViewController * addvote = [[AddVote_ViewController alloc] init];
        addvote.AddVoteClassId = self.classId;
        [vc.navigationController pushViewController:addvote animated:YES];
    };
    self.voteHistory.addVoteBlock = ^(NSString * voteId)
    {
        VoteDetail_ViewController * voteDetail = [[VoteDetail_ViewController alloc] init];
        voteDetail.voteId = voteId;
        [self.navigationController pushViewController:voteDetail
                                             animated:YES];
    };
    
    [self.view addSubview:self.voteNow.view];
}

-(void)initUIsegmentedcontrol
{
    NSArray * arr = [[NSArray alloc] initWithObjects:@"最新投票",@"历史投票", nil];
    UISegmentedControl *segmentedTemp = [[UISegmentedControl alloc]initWithItems:arr];
    self.segmentedControl = segmentedTemp;
    self.segmentedControl.frame = CGRectMake(40 ,0,Main_Screen_Width-80 , 30);
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.tintColor = [UIColor colorWithRed:33/255. green:187/255. blue:252/255. alpha:1.];

    [ self.segmentedControl addTarget:self action:@selector(topic:)forControlEvents:UIControlEventValueChanged];  //添加委托方法
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,  [UIFont systemFontOfSize:15.],UITextAttributeFont ,[UIColor whiteColor],UITextAttributeTextShadowColor ,nil];
    [self.segmentedControl setTitleTextAttributes:dic forState:UIControlStateNormal];
    [self.segmentedControl setTitleTextAttributes:dic forState:UIControlStateSelected];
    [self.view addSubview:self.segmentedControl];
}

- (void)topic:(id)sender {
    
    if([sender selectedSegmentIndex]==0){
        [self.voteHistory removeFromParentViewController];
        [self.view addSubview:self.voteNow.view];
    }else if([sender selectedSegmentIndex]==1){
       
        [self.voteNow removeFromParentViewController];
        [self.view addSubview:self.voteHistory.view];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
