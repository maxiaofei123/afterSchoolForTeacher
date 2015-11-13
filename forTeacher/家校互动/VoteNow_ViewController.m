//
//  VoteNow_ViewController.m
//  forTeacher
//
//  Created by susu on 15/6/9.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "VoteNow_ViewController.h"

@interface VoteNow_ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIScrollView * scrollView;
    NSArray * voteOptionArr;
    NSString * voteStr ;
    int  valueOption;
}
@property(nonatomic,strong)UITableView * voteTableView;
@end

@implementation VoteNow_ViewController

-(void)viewWillAppear:(BOOL)animated
{
    [self requestList];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247/255. green:247/255. blue:247/255. alpha:1.];
    self.view.layer.cornerRadius = 8;
    [self requestList];
    [self initView];
}

-(void)requestList
{
    
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/teachers/%@/votes?school_class_id=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"],self.voteNowClassId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
//        NSLog(@"vote list =%@",responseObject);
        NSArray * arr = responseObject;
        if (arr.count>0) {
            if ([[responseObject objectForKey:@"votes"] count] > 0) {
                NSString * voteId = [[[responseObject objectForKey:@"votes"]objectAtIndex:0] objectForKey:@"id"];
                [self requestVoteWithId:voteId];
            }else
            {
                HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
                HUD.labelText = @"没有进行的投票";
                [HUD hide:YES afterDelay:1.];
            }
        }else
        {
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
            HUD.labelText = @"没有进行的投票";
            [HUD hide:YES afterDelay:1.];
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];

}
-(void)requestVoteWithId:(NSString * )voteCountId
{
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/teachers/%@/votes/%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"],voteCountId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"vote  =%@",responseObject);
        
        voteOptionArr = [responseObject objectForKey:@"result"];
        voteStr =[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"vote"] objectForKey:@"title"]] ;
        for (int i=0; i<voteOptionArr.count; i++) {
            int  XX = [[[voteOptionArr objectAtIndex:i] objectAtIndex:2] intValue];
            int  XXX = valueOption;
            valueOption = XX + XXX;
        }
        [self.voteTableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)initView
{
    self.voteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width-20, Main_Screen_Height-49-64-50)];
    self.voteTableView .backgroundColor = [UIColor colorWithRed:247/255. green:247/255. blue:247/255. alpha:1.];
    self.voteTableView.layer.cornerRadius = 8 ;
    self.voteTableView .delegate =self;
    self.voteTableView .dataSource =self;
    [self.view addSubview:self.voteTableView ];
}

-(void)chooReleaseVote
{
    if (self.addVoteBlock) {
        self.addVoteBlock();
    }
}

//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (voteOptionArr.count + 2);
}

//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tableSampleIdentifier = @"TableSampleIdentifier";
    
    UITableViewCell * cell =  [tableView dequeueReusableCellWithIdentifier:tableSampleIdentifier];
    [cell removeFromSuperview];
    if (cell ==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableSampleIdentifier];
    }else
    {
        [cell removeFromSuperview];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableSampleIdentifier];
        
    }
    [self.voteTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.backgroundColor = [UIColor clearColor];
    if (voteOptionArr.count>0) {
        
        if (indexPath.row == 0 ) {//标题
            NSString * titleStr = [NSString stringWithFormat:@"投票: %@",voteStr];
            cell.textLabel.text = titleStr;
        }else if (indexPath.row == voteOptionArr.count+1)//发布投票按钮
        {
            UIButton * voteBt = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, self.view.frame.size.width-40, 60)];
            [voteBt setImage:[UIImage imageNamed:@"touPiao.png"] forState:UIControlStateNormal];
            [voteBt addTarget:self action:@selector(chooReleaseVote) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:voteBt];
        }
        else
        {
            NSString * voteX = [[voteOptionArr objectAtIndex:indexPath.row-1] objectAtIndex:1];
            float voteXHeight = [publicRequest lableSizeWidth:self.view.frame.size.width-20 content:voteX];
            
            UILabel * voteOptionLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, voteXHeight)];
            voteOptionLable.text = voteX;
            voteOptionLable.alpha = 0.5;
            [cell.contentView addSubview:voteOptionLable];
            
            //        进度条和后面的%比
            UIImageView * bcView = [[UIImageView alloc] initWithFrame:CGRectMake(10, voteXHeight+20-3, self.view.frame.size.width-80, 9)];
            bcView.image = [UIImage imageNamed:@"pross.png"];
            [cell.contentView  addSubview:bcView];
            
            UIProgressView* progressView_=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
            progressView_.frame = CGRectMake(10, voteXHeight+20, self.view.frame.size.width-80,6);
            CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 3.0f);
            progressView_.transform = transform;

            progressView_.backgroundColor = [UIColor clearColor ];
            progressView_.progressTintColor=[UIColor colorWithRed:76/255. green:197/255. blue:36/255. alpha:1.];
            progressView_.layer.masksToBounds = YES;
            progressView_.layer.cornerRadius = 2;
            progressView_.progress = 0;
            [cell.contentView  addSubview:progressView_];
            
            int value=  [[[voteOptionArr objectAtIndex:indexPath.row-1] objectAtIndex:2] intValue];
            
            UILabel * valueLable = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, voteXHeight+10, 80, 20)];
            valueLable.text = [NSString stringWithFormat:@"%d%@",0,@"%"];
            valueLable.alpha = 0.3;
            valueLable.font = [UIFont systemFontOfSize:14.];
            [cell.contentView  addSubview:valueLable];
            
            
            if (valueOption > 0) {
                int s =  value/valueOption; // 取整数
                int ss =( value * 10000) / valueOption; //取余
                
                if (s <1 ) {
                    valueLable.text = [NSString stringWithFormat:@"%d.%d%@",ss/100,ss%100,@"%"];
                }else
                {
                    valueLable.text = [NSString stringWithFormat:@"%d%@",100,@"%"];
                }
                
                NSString * aa = [NSString stringWithFormat:@"%d.%d",s,ss];
                progressView_.progress = [aa floatValue];
                NSLog(@"vale=%d  voteoptineValue=%d  ss=%d %d ",value,valueOption,ss,s);
            }

        }
        
    }
 
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row ==0) {
        NSString * titleStr = [NSString stringWithFormat:@"投票: %@",voteStr];
        float height = [publicRequest lableSizeWidthFont18:self.view.frame.size.width-20 content:titleStr];
        return height+10;
    }else if (indexPath.row == voteOptionArr.count+1)//发布投票按钮
    {
        return 80;
    }
    else
    {
        NSString * voteX = [[voteOptionArr objectAtIndex:indexPath.row-1] objectAtIndex:1];
        float voteXHeight = [publicRequest lableSizeWidth:self.view.frame.size.width-20 content:voteX];
        
        return voteXHeight+40;
    }
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
