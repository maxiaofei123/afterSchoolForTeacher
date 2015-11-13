//
//  RemarkWork_ViewController.m
//  afterShoolForTeacher
//
//  Created by susu on 15/3/26.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "RemarkWork_ViewController.h"
#import "Remark_DetailViewController.h"
#import "AllRemark_ViewController.h"

@interface RemarkWork_ViewController ()<UITableViewDataSource,UITableViewDelegate,UIViewPassValueDelegate>{
    NSArray * homeWorkArr;
    NSArray * remarkTalkArr;
    NSMutableArray * buttonArr;
    int pageFlag;
}
@property(nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSArray *contents;

@end

@implementation RemarkWork_ViewController
@synthesize tableView = _tableView;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationItem.title = @"批阅作业";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"批量批阅" style:UIBarButtonItemStylePlain target:self action:@selector(allRemark)];
    self.navigationItem.rightBarButtonItem=anotherButton;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self initView];
    
    [self requestHomeworkId];
}

-(void)allRemark
{
    AllRemark_ViewController * remark = [[AllRemark_ViewController alloc] init];
    remark.workId = self.workId;
    remark.markType = @"forAll";
    [self.navigationController pushViewController:remark animated:YES];
}

-(void)initView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20, Main_Screen_Height-49-74)style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate =self;
    _tableView.dataSource = self;
    _tableView.layer.cornerRadius = 8 ;
    [_tableView setTableFooterView:view];
    [_tableView addHeaderWithTarget:self action:@selector(headerRefresh)];
    [_tableView addFooterWithTarget:self action:@selector(footerRefresh)];
    [self.view addSubview:_tableView];
    [_tableView headerBeginRefreshing];

}

-(void)headerRefresh
{
    pageFlag = 1 ;
    [self requestHomeworkId];
}

-(void)footerRefresh
{
    [self requestHomeworkId];
}

-(void)requestHomeworkId
{
    NSDictionary * parameters = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",pageFlag],@"page", nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/work_papers/%@/home_works",self.workId ]parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        homeWorkArr = responseObject;
        NSLog(@"getHomeWork =%@",homeWorkArr);
        
        [_tableView footerEndRefreshing];
        [_tableView headerEndRefreshing];
        [_tableView reloadData];
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [_tableView footerEndRefreshing];
         [_tableView headerEndRefreshing];
         NSLog(@"erro =%@",error);
     }];

}

//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return homeWorkArr.count;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
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

    [_tableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.cornerRadius = 5;
    NSDictionary * dic = [homeWorkArr objectAtIndex:indexPath.section];
    
    NSString * url = [NSString stringWithFormat:@"%@",[[dic objectForKey:@"student"]objectForKey:@"avatar" ]];
    UIImageView * notifaceImage = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 60, 60)];
    //圆角设置
    notifaceImage.layer.cornerRadius = 30;
    notifaceImage.layer.masksToBounds = YES;
    if (![url isKindOfClass:[NSNull class]]) {
        [notifaceImage setImageWithURL:[NSURL URLWithString:url]];
    }else{
        notifaceImage.image = [UIImage imageNamed:@"header.png"];
    }
    [cell.contentView addSubview:notifaceImage];
    
    //消息类型
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(75, 15, 200, 20)];
    lable.text = [[dic objectForKey:@"student"]objectForKey:@"student" ];
    lable.font = [UIFont systemFontOfSize:16.];
    [cell.contentView addSubview:lable];
    
    UILabel * dateLable = [[UILabel alloc] initWithFrame:CGRectMake(75, 35, 200, 20)];
    dateLable.textColor = [UIColor grayColor];
    dateLable.font = [UIFont systemFontOfSize:13.];
    dateLable.text = [[dic objectForKey:@"updated_at"] substringToIndex:10];
    [cell.contentView addSubview:dateLable];

    //批阅状态
    NSString * state = [dic objectForKey:@"state"];
    UIImageView * finishImage = [[UIImageView alloc] initWithFrame:CGRectMake(Main_Screen_Width-100, 20, 70, 30)];
    if ([state isEqualToString:@"init"]) {
        finishImage.image = [UIImage imageNamed:@"daiPiYue.png"];
    }else
    {
        finishImage.image = [UIImage imageNamed:@"yiPiYue.png"];
    }
    [cell.contentView addSubview:finishImage];
    
    return cell;
}

- ( CGFloat )tableView:( UITableView *)tableView heightForHeaderInSection:( NSInteger )section
{
    if(section ==0 )
    return 0;
    
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}


-(void)chooseRemark:(int)index
{
//    UIButton * bt = (UIButton *)[]
    
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    
    Remark_DetailViewController * detail = [[Remark_DetailViewController alloc] init];
    detail.workPaperId = self.workId ;
    detail.studentWorkId = [[[homeWorkArr objectAtIndex:indexPath.section] objectForKey:@"student"] objectForKey:@"student_id"];
    detail.delegate = self;
    [self.navigationController pushViewController:detail animated:YES];

}


@end
