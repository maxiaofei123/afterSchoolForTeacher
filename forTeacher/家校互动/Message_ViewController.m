//
//  Message_ViewController.m
//  afterShoolForTeacher
//
//  Created by susu on 15/4/17.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "Message_ViewController.h"
#import "SKSTableView.h"
#import "SKSTableViewCell.h"
#import "MyMessageList_ViewController.h"

@interface Message_ViewController ()<UITextViewDelegate>
{
    UITextView * titleText;
    UITextView * contentText;
    UILabel * classLable;
    NSMutableArray * classArr;
    NSMutableArray *classId;

    NSMutableArray * messageArr;
    int pageFlag;

}
@end

@implementation Message_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.automaticallyAdjustsScrollViewInsets =NO;
    self.navigationItem.title = @"消息通知";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"我的通知  " style:UIBarButtonItemStylePlain target:self action:@selector(myMessage:)];
    self.navigationItem.rightBarButtonItem=anotherButton;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    messageArr =[[NSMutableArray alloc] init];

    [self drawView];
}

-(void)myMessage:(UIButton * )sender
{
    MyMessageList_ViewController * list = [[MyMessageList_ViewController alloc] init];
    list.classID = self.classId;
    [self.navigationController pushViewController:list animated:YES];

}

-(void)drawView
{
    UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20, 200)];
    topView.backgroundColor = [UIColor whiteColor];
    topView.layer.cornerRadius = 8;
    [self.view addSubview:topView];
    
    titleText = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, Main_Screen_Width-40, 40)];
    titleText.layer.borderColor = [[UIColor grayColor] CGColor];
    titleText.text = @"输入消息标题";
    titleText.font = [UIFont systemFontOfSize:18.];
    titleText.layer.borderWidth = 1.0f;
    titleText.tag = 101 ;
    titleText.delegate = self ;
    [topView addSubview:titleText];

    contentText = [[UITextView alloc] initWithFrame:CGRectMake(10, 60, Main_Screen_Width-40, 100  )];
    contentText.text = @"输入消息内容";
    contentText.layer.borderColor = [[UIColor grayColor] CGColor];
    contentText.layer.borderWidth = 1.0f;
    contentText.delegate = self ;
    contentText.font = [UIFont systemFontOfSize:16.];
    [topView addSubview:contentText];
    
    UIButton * commitBt = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width-120, 162, 100, 35)];
    [commitBt addTarget:self action:@selector(commitMessage) forControlEvents:UIControlEventTouchUpInside];
    [commitBt setImage:[UIImage imageNamed:@"tijiao.png"] forState:UIControlStateNormal];
    [topView addSubview:commitBt];
    
    UIToolbar * TabbarView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 30)];
    TabbarView.backgroundColor = [UIColor colorWithRed:244/255. green:244/255. blue:226/255. alpha:1.];
    [TabbarView setBarStyle:UIBarStyleBlackTranslucent];
    
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(2, 5, 50, 25);
    [btn addTarget:self action:@selector(hiden) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    [btn setTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneBtn,nil];
    [TabbarView setItems:buttonsArray];
    [titleText setInputAccessoryView:TabbarView];
    [contentText setInputAccessoryView:TabbarView];
    
    ////////////
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    _messageTableView= [[SKSTableView alloc] initWithFrame:CGRectMake(10,210, Main_Screen_Width-20, Main_Screen_Height-64-59-210)];
    _messageTableView.SKSTableViewDelegate = self;
    [self.view addSubview:_messageTableView];
    _messageTableView.layer.cornerRadius = 8;
    [_messageTableView addHeaderWithTarget:self action:@selector(headerRefresh)];
    [_messageTableView addFooterWithTarget:self action:@selector(footerRefresh)];
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
    NSDictionary * parameters = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",pageIndex],@"page",nil];//,,@"NOTOP",@"message_type"
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/teachers/%@/user_messages?",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]]parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSArray * arr =[responseObject objectForKey:@"user_messages"];
        if (pageFlag == 1) {
            [messageArr removeAllObjects];
        }

        [messageArr addObjectsFromArray:arr];
        [_messageTableView footerEndRefreshing];
        [_messageTableView headerEndRefreshing];
        
        [_messageTableView reloadData];
        NSLog(@"res messege list = %@",messageArr);
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

-(void)commitMessage
{
    NSString * str1;
    NSString * str2 ;
    NSString * ok = @"请输入消息内容";
    
    if (!([titleText.text isEqualToString:@"输入消息标题"])) {
        if (titleText.text.length>0) {
            str1 = [NSString stringWithFormat:@"%@",titleText.text];
        }
    }
    if (!([contentText.text isEqualToString:@"输入消息内容"])) {
        if (contentText.text.length>0) {
            str2 = [NSString stringWithFormat:@"%@",contentText.text];
        }
    }
    NSLog(@"str1 =%@  str2 =%@",str1,str2);
    if (str1.length >0 && str2.length > 0) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.labelText = @"正在提交...";
            
        NSDictionary * pa = [[NSDictionary alloc] initWithObjectsAndKeys:str1,@"inform[title]",str2,@"inform[body]",self.classId,@"inform[school_class_id]" ,[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"],@"inform[teacher_id]",nil];
        
        AFHTTPRequestOperationManager * manager =[AFHTTPRequestOperationManager manager];
        [manager POST:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/teachers/%@/informs?",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]] parameters:pa success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self commitMyMessage];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error =%@",error);
            HUD.labelText = @"请求超时";
            [HUD hide:YES afterDelay:1.];
        }];
            
    }else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:ok delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}


-(void)commitMyMessage
{
    NSString * str1;
    NSString * str2 ;
    NSString * ok = @"请输入消息内容";
    
    if (!([titleText.text isEqualToString:@"输入消息标题"])) {
        if (titleText.text.length>0) {
            str1 = [NSString stringWithFormat:@"%@",titleText.text];
        }
    }
    if (!([contentText.text isEqualToString:@"输入消息内容"])) {
        if (contentText.text.length>0) {
            str2 = [NSString stringWithFormat:@"%@",contentText.text];
        }
    }
    NSLog(@"str1 =%@  str2 =%@",str1,str2);
    if (str1.length >0 && str2.length > 0) {
        NSDictionary * pa = [[NSDictionary alloc] initWithObjectsAndKeys:str1,@"topic",str2,@"body",self.classId,@"school_class_id",@"user_message",@"message_type" ,nil];
        
        NSLog(@"pa =%@",pa);
        AFHTTPRequestOperationManager * manager =[AFHTTPRequestOperationManager manager];
        [manager POST:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/teachers/%@/send_message_to_class",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]] parameters:pa success:^(AFHTTPRequestOperation *operation, id responseObject) {
            HUD.labelText = @"提交成功。。。";
            [HUD hide:YES afterDelay:1.];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            HUD.labelText = @"请求超时";
            [HUD hide:YES afterDelay:1.];
        }];
        
    }else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:ok delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}


- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.tag ==101) {

      if ( [titleText.text isEqualToString:@"输入消息标题"]) {
           titleText.text = @"";
      }
        
    }else if ( [contentText.text isEqualToString:@"输入消息内容"]) {
         contentText.text = @"";
       }
}

-(void)hiden
{
    [titleText resignFirstResponder];
    [contentText resignFirstResponder];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  messageArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SKSTableViewCell";
    
    SKSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell ==nil) {
        cell = [[SKSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];    }else
    {
        [cell removeFromSuperview];
        cell = [[SKSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    NSDictionary * workDic = [messageArr objectAtIndex:indexPath.section];
    float height = [publicRequest lableSizeWidthFont16:Main_Screen_Width-70 content:[ workDic objectForKey:@"topic"]];
    //消息类型
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, Main_Screen_Width-70, height>30?height:30)];
    lable.text = [workDic objectForKey:@"topic"];
    lable.lineBreakMode = NSLineBreakByWordWrapping;
    lable.font = [UIFont systemFontOfSize:16.];
    lable.numberOfLines = 0;
    [cell.contentView addSubview:lable];
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(Main_Screen_Width-50, height>40 ?height-10:25, 18, 12)];
    imageView.image =[UIImage imageNamed:@"studentClassChoose.png"];
    [cell.contentView addSubview:imageView];
    
//    UILabel * dateLable = [[UILabel alloc] initWithFrame:CGRectMake(75, 35, 200, 20)];
//    dateLable.textColor = [UIColor grayColor];
//    dateLable.font = [UIFont systemFontOfSize:13.];
//    dateLable.text = [[workDic objectForKey:@"updated_at"] substringToIndex:10];
//    [cell.contentView addSubview:dateLable];

    cell.isExpandable = YES;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableSampleIdentifier = @"TableSampleIdentifier";
    UITableViewCell * cell =  [tableView dequeueReusableCellWithIdentifier:tableSampleIdentifier];
    if (cell ==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableSampleIdentifier];
    }else
    {
        [cell removeFromSuperview];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableSampleIdentifier];
        
    }

     NSDictionary * workDic = [messageArr objectAtIndex:indexPath.section];
    //内容
    float titleLableSizeHeight= [publicRequest lableSizeWidth:Main_Screen_Width-40 content:[workDic objectForKey:@"body"]] ;

    UILabel * contentLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, Main_Screen_Width-40, titleLableSizeHeight)];
    contentLable.text = [workDic objectForKey:@"body"];
    contentLable.font = [UIFont systemFontOfSize:14.];
    contentLable.lineBreakMode = NSLineBreakByWordWrapping;
    contentLable.numberOfLines = 0;
    contentLable.alpha = 0.6;
    [cell.contentView addSubview:contentLable];
    
    return cell;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0) {
        float height = [publicRequest lableSizeWidthFont16:Main_Screen_Width-70 content:[ [messageArr objectAtIndex:indexPath.section] objectForKey:@"topic"]];
        
        return height>40?height+8:40;
        
    }else
    {
        NSDictionary * workDic = [messageArr objectAtIndex:indexPath.section];
        float titleLableSizeHeight= [publicRequest lableSizeWidth:Main_Screen_Width-40 content:[workDic objectForKey:@"body"]] ;
        
        float h = titleLableSizeHeight>30?titleLableSizeHeight+10:40;
        return h ;
    }
    return 80;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
