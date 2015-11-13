//
//  VoteDetail_ViewController.m
//  forTeacher
//
//  Created by susu on 15/6/22.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "VoteDetail_ViewController.h"

@interface VoteDetail_ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIScrollView * scrollView;
    NSArray * voteOptionArr;
    NSString * voteStr ;
    int  valueOption;
}
@property(nonatomic,strong)UITableView * voteTableView;


@end

@implementation VoteDetail_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.automaticallyAdjustsScrollViewInsets =NO;
    self.navigationItem.title = @"投票统计";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self requestVoteWithId];
    [self initView];
}


-(void)requestVoteWithId
{
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/teachers/%@/votes/%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"],self.voteId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
//        NSLog(@"vote  =%@",responseObject);
        
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
    self.voteTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20, Main_Screen_Height-59-64)];
    self.voteTableView .backgroundColor = [UIColor whiteColor];
    self.voteTableView.layer.cornerRadius = 8 ;
    self.voteTableView .delegate =self;
    self.voteTableView .dataSource =self;
    [self.view addSubview:self.voteTableView ];
}

//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (voteOptionArr.count + 1);
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
        }
        else
        {
            if ((indexPath.row <= voteOptionArr.count)) {
                NSLog(@"optiom =%@",[voteOptionArr objectAtIndex:(indexPath.row -1)]);
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
