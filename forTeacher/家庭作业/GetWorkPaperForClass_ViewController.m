//
//  GetWorkPaperForClass_ViewController.m
//  afterShoolForTeacher
//
//  Created by susu on 15/4/12.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "GetWorkPaperForClass_ViewController.h"
#import "RemarkForClassList_ViewController.h"
@interface GetWorkPaperForClass_ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray * workArr;
    int pageFlag;
}
@property(strong ,nonatomic)UITableView * homeTableView;
@end

@implementation GetWorkPaperForClass_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationItem.title = @"作业";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    self.view.backgroundColor =[UIColor colorWithRed:62/255. green:56/255. blue:65/255. alpha:1.];
        self.edgesForExtendedLayout = UIRectEdgeNone;
    workArr = [[NSMutableArray alloc] init];
    [self initTableView];
    [self requestHomeWork:1];
}

-(void)initTableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    _homeTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20,Main_Screen_Height-64-49)style:UITableViewStylePlain];
    _homeTableView.backgroundColor = [UIColor clearColor];
    _homeTableView.delegate =self;
    _homeTableView.dataSource = self;
    [_homeTableView addHeaderWithTarget:self action:@selector(headerRefresh)];
    [_homeTableView addFooterWithTarget:self action:@selector(footerRefresh)];
    [self.homeTableView setTableFooterView:view];
    [self.view addSubview:_homeTableView];
    
    [_homeTableView headerBeginRefreshing];
}

-(void)headerRefresh
{
    pageFlag = 1 ;
    [self requestHomeWork:pageFlag];
}

-(void)footerRefresh
{
    [self requestHomeWork:++pageFlag];
}

-(void)requestHomeWork:(int)pageIndex
{
    NSDictionary * parameters = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",pageIndex],@"page", nil];
    NSLog(@"claass id =%@  ＝%@",self.classId,[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]);
    NSLog(@"id = %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] );
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/teachers/%@/work_papers?school_class_id=%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"],self.classId]parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSArray * arr = responseObject;
        if (pageFlag == 1) {
            [workArr removeAllObjects];
        }
        [workArr addObjectsFromArray:arr];
        [_homeTableView footerEndRefreshing];
        [_homeTableView headerEndRefreshing];
        [_homeTableView reloadData];
        NSLog(@"res work list = %@",workArr);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [_homeTableView footerEndRefreshing];
         [_homeTableView headerEndRefreshing];
         NSLog(@"erro =%@",error);
     }];
}

//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [workArr count];
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableSampleIdentifier = @"TableSampleIdentifier";
    UITableViewCell * cell =  [tableView dequeueReusableCellWithIdentifier:tableSampleIdentifier];
    if (cell ==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableSampleIdentifier];
    }else
    {
        [cell removeFromSuperview];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableSampleIdentifier];
        
    }
    [_homeTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.cornerRadius = 5;
    
    NSDictionary * workDic = [workArr objectAtIndex:indexPath.section];
    //消息图标
    
    NSString * url = [NSString stringWithFormat:@"%@",[[workDic objectForKey:@"teacher"]objectForKey:@"avatar" ]];
    UIImageView * notifaceImage = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 60, 60)];
    //圆角设置
    notifaceImage.layer.cornerRadius = 30;
    notifaceImage.layer.masksToBounds = YES;
    if (![url isKindOfClass:[NSNull class]]) {
        [notifaceImage setImageWithURL:[NSURL URLWithString:url]];
    }else {
        notifaceImage.image = [UIImage imageNamed:@"header.png"];
    }
    [cell.contentView addSubview:notifaceImage];
    
    //消息类型
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(75, 15, 200, 20)];
    lable.text = [workDic objectForKey:@"title"];
    lable.font = [UIFont systemFontOfSize:16.];
    [cell.contentView addSubview:lable];
    UILabel * dateLable = [[UILabel alloc] initWithFrame:CGRectMake(75, 35, 200, 20)];
    dateLable.textColor = [UIColor grayColor];
    dateLable.font = [UIFont systemFontOfSize:13.];
    dateLable.text = [[workDic objectForKey:@"updated_at"] substringToIndex:10];
    [cell.contentView addSubview:dateLable];
    
    //内容
    float height = [publicRequest lableSizeWidth:Main_Screen_Width-40 content:[workDic objectForKey:@"description"]];
    float h = height > 30 ? height:30;
    if (height > 80) {
        h= 80 ;
    }
    UILabel * contentLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, Main_Screen_Width-40, h)];
    contentLable.text = [workDic objectForKey:@"description"];
    contentLable.font = [UIFont systemFontOfSize:14.];
    contentLable.lineBreakMode = NSLineBreakByWordWrapping;
    contentLable.numberOfLines = 0;
    contentLable.alpha = 0.6;
    [cell.contentView addSubview:contentLable];

    
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * workDic = [workArr objectAtIndex:indexPath.section];
    float height = [publicRequest lableSizeWidth:Main_Screen_Width-40 content:[workDic objectForKey:@"description"]];
    float h = height > 30 ? height:30;
    if (height > 80) {
        h= 80 ;
    }
    return 80+h;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    
    RemarkForClassList_ViewController * remark = [[RemarkForClassList_ViewController alloc] init];
    remark.classId = [[[[workArr objectAtIndex:indexPath.section] objectForKey:@"classes"] objectAtIndex:0] objectForKey:@"school_class_id"];
    remark.workId = [[workArr objectAtIndex:indexPath.section] objectForKey:@"id"];
    [self.navigationController pushViewController:remark animated:YES];

}

- ( CGFloat )tableView:( UITableView *)tableView heightForHeaderInSection:( NSInteger )section
{  if(section ==0 )
    return 0;
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
