//
//  VoteHistory_ViewController.m
//  forTeacher
//
//  Created by susu on 15/6/9.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "VoteHistory_ViewController.h"
#import "VoteDetail_ViewController.h"

@interface VoteHistory_ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray * voteMutableArr;
    int  pageIndex;
}
@property(nonatomic,strong)UITableView * voteTableView;


@end

@implementation VoteHistory_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:247/255. green:247/255. blue:247/255. alpha:1.];
    self.view.layer.cornerRadius = 8;
    pageIndex = 1 ;
    voteMutableArr = [[NSMutableArray alloc] init];
    [self initView];
    [self requestList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    self.voteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width-40,Main_Screen_Height-49-64-50)];
    self.voteTableView.layer.cornerRadius = 8 ;
    self.voteTableView .backgroundColor = [UIColor colorWithRed:247/255. green:247/255. blue:247/255. alpha:1.];
    self.voteTableView .delegate =self;
    self.voteTableView .dataSource =self;
//    [self.voteTableView  addHeaderWithTarget:self action:@selector(headerRefresh)];
//    [self.voteTableView  addFooterWithTarget:self action:@selector(footerRefresh)];
//    [self.voteTableView  headerBeginRefreshing];
    [self.voteTableView  setTableFooterView:view];
    [self.view addSubview:self.voteTableView ];
}


-(void)headerRefresh
{
    pageIndex = 1 ;
    [self requestList];
}

-(void)footerRefresh
{
    ++pageIndex;
    [self requestList];
}
-(void)requestList
{
//     NSDictionary * parameters = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",pageIndex],@"page",nil];
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/teachers/%@/votes?school_class_id=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"],self.historyclassID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"vote list =%@",responseObject);
        
        NSArray * arr = [responseObject objectForKey:@"votes"];
        if (arr.count>0) {
//            if (pageIndex == 1) {
//                [voteMutableArr removeAllObjects];
//            }
            [voteMutableArr addObjectsFromArray:arr];
        }else
        {
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
            HUD.labelText = @"还没有投票";
            [HUD hide:YES afterDelay:1.];
        }
        
//        [self.voteTableView footerEndRefreshing];
//        [self.voteTableView headerEndRefreshing];
        [self.voteTableView reloadData];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self.voteTableView footerEndRefreshing];
        [self.voteTableView headerEndRefreshing];

    }];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    if (self.addVoteBlock) {
        self.addVoteBlock([[voteMutableArr objectAtIndex:indexPath.row] objectForKey:@"id"]);
    }
}

//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return voteMutableArr.count;
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
//    [self.voteTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    cell.backgroundColor = [UIColor clearColor];
    cell.layer.cornerRadius = 5;
    if (voteMutableArr.count > 0) {
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
        imageView.image = [UIImage imageNamed:@"voteListIcon.png"];
        [cell.contentView addSubview:imageView];
        
//        NSLog(@"indecpath.row =%d",indexPath.row);
        UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, Main_Screen_Width-60, 20)];
        titleLable.text = [[voteMutableArr objectAtIndex:indexPath.row] objectForKey:@"title"];
        [cell.contentView addSubview:titleLable];
        
        UILabel * timeLable = [[UILabel alloc] initWithFrame:CGRectMake(70, 35, Main_Screen_Width-60, 20)];
        timeLable.alpha = 0.5;
        timeLable.text = [[[voteMutableArr objectAtIndex:indexPath.row] objectForKey:@"updated_at"] substringToIndex:10];
        [cell.contentView addSubview:timeLable];
        
    }
    
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}



@end
