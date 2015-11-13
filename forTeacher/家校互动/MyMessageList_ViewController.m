//
//  MyMessageList_ViewController.m
//  forTeacher
//
//  Created by susu on 15/6/8.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "MyMessageList_ViewController.h"
#import "YFJLeftSwipeDeleteTableView.h"
#import "ChangeMessage_ViewController.h"
@interface MyMessageList_ViewController ()<UITableViewDataSource,UITableViewDelegate,UIViewChangeValueDelegate>
{
     NSMutableArray * messageArr;
    int pageFlag;
    
    UIButton * _deleteButton;
    NSIndexPath * _editingIndexPath;
    
    UISwipeGestureRecognizer * _leftGestureRecognizer;
    UISwipeGestureRecognizer * _rightGestureRecognizer;
    UITapGestureRecognizer * _tapGestureRecognizer;
}
@property (nonatomic, strong)  YFJLeftSwipeDeleteTableView *messageTableView;
@end

@implementation MyMessageList_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.automaticallyAdjustsScrollViewInsets =NO;
    self.navigationItem.title = @"消息通知";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    messageArr =[[NSMutableArray alloc] init];
    [self drawView];

}

-(void)drawView
{
//    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20, Main_Screen_Height-10)];
//    backView.layer.cornerRadius = 8;
//    backView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:backView];
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    _messageTableView= [[YFJLeftSwipeDeleteTableView alloc] initWithFrame:CGRectMake(10,0, Main_Screen_Width-20, Main_Screen_Height-20)];
    _messageTableView.delegate = self;
    _messageTableView.dataSource = self;
    [_messageTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:_messageTableView];
    _messageTableView.layer.cornerRadius = 8;
    [_messageTableView addHeaderWithTarget:self action:@selector(headerRefresh)];
//    [_messageTableView addFooterWithTarget:self action:@selector(footerRefresh)];
    [_messageTableView headerBeginRefreshing];
    [_messageTableView setTableFooterView:view];
}

-(void)headerRefresh
{
    pageFlag = 1 ;
    [self requesMessage:pageFlag];
}

-(void)footerRefresh
{
    [self requesMessage:++pageFlag];
}


-(void)requesMessage:(int)pageIndex
{
    //[NSString stringWithFormat:@"%d",pageIndex],@"page",
    NSDictionary * parameters = [[NSDictionary alloc] initWithObjectsAndKeys:self.classID,@"school_class_id",nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/teachers/%@/informs?",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]]parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSArray * arr =responseObject;
        if (pageFlag == 1) {
            [messageArr removeAllObjects];
        }
        [messageArr addObjectsFromArray:arr];
        
        [_messageTableView footerEndRefreshing];
        [_messageTableView headerEndRefreshing];
        
        [_messageTableView reloadData];
        NSLog(@"my messege list = %@",arr);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [_messageTableView footerEndRefreshing];
         [_messageTableView headerEndRefreshing];
         HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
         HUD.labelText = @"请求失败,请检查网络链接";
         [HUD hide:YES afterDelay:1.];
         NSLog(@"erro =%@",error);
     }];
}

-(void)deleteMyMessage:(int) index
{
    NSString * messageId = [[messageArr objectAtIndex:index] objectForKey:@"id"];
    AFHTTPRequestOperationManager * manager = [[AFHTTPRequestOperationManager manager] init];
    [manager DELETE:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/teachers/%@/informs/%@?",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"],messageId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self commitMyMessage:index];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
         HUD.labelText = @"请求失败,请检查网络链接";
         [HUD hide:YES afterDelay:1.];
         [self headerRefresh];
    }];
}

-(void)commitMyMessage:(int)index
{
    NSDictionary * pa = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"删除消息:%@",[[messageArr objectAtIndex:index] objectForKey:@"title"]],@"topic",[NSString stringWithFormat:@"删除消息:%@",[[messageArr objectAtIndex:index] objectForKey:@"title"]],@"body",self.classID,@"school_class_id" ,@"user_message",@"message_type",nil];
    NSLog(@"pa = %@",pa);
    
    AFHTTPRequestOperationManager * manager =[AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/teachers/%@/send_message_to_class",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]] parameters:pa success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.labelText = @"删除成功。。。";
        [HUD hide:YES afterDelay:1.];
        //返回刷新列表
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error =%@",error);
        HUD.labelText = @"请求超时";
        [HUD hide:YES afterDelay:1.];
    }];
}





#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return messageArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SKSTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell ==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];    }else
        {
            [cell removeFromSuperview];
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
        }
    
    UILabel * timeLbale =[[UILabel alloc] initWithFrame:CGRectMake(10, 5, 200, 20)];
    timeLbale.text = [NSString stringWithFormat:@"时间:%@",[[[messageArr objectAtIndex:indexPath.row] objectForKey:@"updated_at" ] substringToIndex:10 ]];
    timeLbale.font = [UIFont systemFontOfSize:14.];
    [cell.contentView addSubview:timeLbale];
    
    UILabel * tilteLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, Main_Screen_Width-40, 20)];
    tilteLable.text = [[messageArr objectAtIndex:indexPath.row] objectForKey:@"title"];
    [cell.contentView addSubview:tilteLable];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self deleteMyMessage:indexPath.row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [messageArr removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {

    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_messageTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ChangeMessage_ViewController * change = [[ChangeMessage_ViewController alloc] init];
    change.conentDic = [messageArr objectAtIndex:indexPath.row];
    change.classId = self.classID ;
    change.delegate = self;
    [self.navigationController pushViewController:change animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
