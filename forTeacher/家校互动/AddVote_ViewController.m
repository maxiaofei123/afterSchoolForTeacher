//
//  AddVote_ViewController.m
//  forTeacher
//
//  Created by susu on 15/6/17.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "AddVote_ViewController.h"

@interface AddVote_ViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate>
{
    NSMutableArray * voteOptionMutableArr;
    UITextView * titleTextView ;
    NSString * titleStr ;
    BOOL typeChoose ;
    NSMutableArray * buttonArr ;
    NSMutableArray * textViewMArr;
    NSInteger optionCount;
}
@property(nonatomic,strong)UITableView * voteTableView;
@property(nonatomic,strong)UIScrollView * scrollView;
@end

@implementation AddVote_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.automaticallyAdjustsScrollViewInsets =NO;
    self.navigationItem.title = @"发布投票";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    optionCount = 4 ;
    voteOptionMutableArr = [[NSMutableArray alloc] init];
    textViewMArr = [[NSMutableArray alloc] init];
    buttonArr = [[NSMutableArray alloc] init];
    typeChoose = NO;
    titleStr = @"输入投票标题";
    
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20, Main_Screen_Height-49-64)];
    _scrollView.layer.cornerRadius = 8;
    _scrollView.userInteractionEnabled = YES;
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.contentSize = CGSizeMake(Main_Screen_Width-20, Main_Screen_Height-49-64);
    [self.view addSubview:_scrollView];
    
    self.voteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width-20,Main_Screen_Height-49-64)style:UITableViewStyleGrouped];
    self.voteTableView.layer.cornerRadius = 8;
    self.voteTableView .delegate =self;
    self.voteTableView .dataSource =self;
    [_scrollView addSubview:self.voteTableView ];
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [self.voteTableView setTableFooterView:view];
}


-(void)commitVote
{
    NSString * OK = @"OK";
    int count = 0 ;
    NSMutableArray * optionTextArr = [[NSMutableArray alloc] init];
    for (int i=0; i<optionCount; i++) {
        UITextField * text = [textViewMArr objectAtIndex:i];
        if (text.text.length > 0) {
            count ++;
            [optionTextArr addObject:text.text];
        }
    }

    if ([titleTextView.text isEqualToString:@"输入投票标题"] || (titleTextView.text.length == 0)){
        OK = @"请输入投票标题";
    }else {
        
        if (count <4) {
            OK = @"请输入至少四个选项";
        }
    }
    
    if ([OK isEqualToString:@"OK"]) {
        NSString * mu = @"false";//单选
        if (typeChoose) {
            mu = @"true" ;//多选
        }
        NSString * parStr;
        for (int i=0; i<optionTextArr.count; i++) {
            NSString * ss = parStr;
            NSString * s = [NSString stringWithFormat:@"&vote_option[title][]=%@",[optionTextArr objectAtIndex:i]];
            parStr = [NSString stringWithFormat:@"%@%@",ss,s];
        }
        
        NSString * userId =[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
        AFHTTPRequestOperationManager * manager = [[AFHTTPRequestOperationManager manager] init];
        [manager POST:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/teachers/%@/votes?vote[teacher_id]=%@&vote[school_class_id]=%@&vote[title]=%@&vote[is_multi]=%@%@",userId,userId,self.AddVoteClassId,titleTextView.text,mu,parStr] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
//            NSLog(@"vote =%@",responseObject);
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
            HUD.labelText = @"创建成功";
            [HUD hide:YES afterDelay:1.];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"errpr =%@",error.userInfo);
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
            HUD.labelText = @"请检查网络连接";
            [HUD hide:YES afterDelay:1.];
        }];
        
        
//        // 1.创建请求
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/teachers/%@/votes",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]]];
//        
//        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//        request.HTTPMethod = @"POST";
//        
//        // 2.设置请求头
//        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//        
//        for (int i=0; i<optionTextArr.count; i++) {
//             [request setValue:[optionTextArr objectAtIndex:i] forKey:@"vote_option[title][]"];
//        }
//        
//        [request setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] forKey:@"vote[teacher_id]"];
//        [request setValue:self.AddVoteClassId forKey:@"vote[school_class_id]"];
//        [request setValue:titleTextView.text forKey:@"vote[title]"];
//        [request setValue:mu forKey:@"vote[is_multi]"];
//        
//        // 4.发送请求
//        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//            
//            NSLog(@"%@", response);
//        }];
        
        
        
    }else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:OK delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1) {
        return optionCount;
    }else if (section ==2)
        return 2;
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
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    switch (indexPath.section) {
        case 0:
        {
            titleTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 5, Main_Screen_Width-40, 50)];
            titleTextView.text = titleStr;
            titleTextView.font = [UIFont systemFontOfSize:16.];
            titleTextView.delegate  = self ;
            [cell addSubview:titleTextView];
            
            UIToolbar * TabbarView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 30)];
            TabbarView.backgroundColor = [UIColor colorWithRed:244/255. green:244/255. blue:226/255. alpha:1.];
            [TabbarView setBarStyle:UIBarStyleBlackTranslucent];
            
            UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(2, 5, 50, 25);
            btn.tag = indexPath.row;
            [btn addTarget:self action:@selector(hiden:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:@"完成" forState:UIControlStateNormal];
            [btn setTintColor:[UIColor whiteColor]];
            
            UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
            NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneBtn,nil];
            [TabbarView setItems:buttonsArray];
            [titleTextView setInputAccessoryView:TabbarView];
            
            
        }
            break;
        case 1:
        {
            UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, Main_Screen_Width-40, 30)];
            textField.placeholder = [NSString stringWithFormat:@"输入选项%d",indexPath.row+1];
            textField.alpha = 0.5;
            textField.tag = indexPath.row;
            textField.delegate = self;
            textField.font = [UIFont systemFontOfSize:16.];
            [cell addSubview:textField];
            [textViewMArr addObject:textField];
            
            
            UIToolbar * TabbarView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 30)];
            TabbarView.backgroundColor = [UIColor colorWithRed:244/255. green:244/255. blue:226/255. alpha:1.];
            [TabbarView setBarStyle:UIBarStyleBlackTranslucent];
            
            UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(2, 5, 50, 25);
            btn.tag = indexPath.row;
            [btn addTarget:self action:@selector(hiden:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:@"完成" forState:UIControlStateNormal];
            [btn setTintColor:[UIColor whiteColor]];
            
            UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
            NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneBtn,nil];
            [TabbarView setItems:buttonsArray];
            [textField setInputAccessoryView:TabbarView];
            
        }
            break;
        case 2:
        {
            UIButton * quanBt = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
            [quanBt setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
            [quanBt setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateSelected];
             quanBt.tag = indexPath.row ;
            [quanBt addTarget:self action:@selector(chooseBt:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:quanBt];
            [buttonArr addObject:quanBt];
            
            if (quanBt.tag ==0) {
                quanBt.selected = YES ;
            }
            
            UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, 100, 30)];
            lable.text = @"单选";
            lable.font = [UIFont systemFontOfSize:18.];
            lable.alpha = 0.5;
            [cell.contentView addSubview:lable];
            if (indexPath.row ==1) {
                lable.text = @"多选";
            }
        }
            break;
            
            
        default:
            break;
    }
    
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section ==0) {
        return 60;
    }
    return 40;
}


- ( CGFloat )tableView:( UITableView *)tableView heightForHeaderInSection:( NSInteger )section

{
    return 40.0 ;
}
-(CGFloat)tableView:(UITableView *)tableView  heightForFooterInSection:(NSInteger)section
{
    if (section==1) {
        return 40;
    }else if (section == 2)
    {
        return 60;
    }
    return 1.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 40)];
    view.backgroundColor = [UIColor clearColor];
    if (section ==1) {
        UIButton * addButton=[[UIButton alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
        [addButton setImage:[UIImage imageNamed:@"tianjiao.png"] forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(addCell) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:addButton];
        
        UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 200, 30)];
        lable.text = @"添加更多选项";
        [view addSubview:lable];
    }else if (section ==2)
    {
        UIButton * commitBt=[[UIButton alloc] initWithFrame:CGRectMake(10, 5, Main_Screen_Width-40, 50)];
        [commitBt setImage:[UIImage imageNamed:@"touPiao.png"] forState:UIControlStateNormal];
        [commitBt addTarget:self action:@selector(commitVote) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:commitBt];
    }
    
    return view;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 300, 20)];
    if (section == 1) {
        headerLabel.text = @"   投票标题";
    }else if(section == 0)
    {
        headerLabel.text = @"   投票选项";
    }else
    {
        headerLabel.text = @"   投票方式";
    }
    [headerLabel setFont:[UIFont systemFontOfSize:14.0]];
    [headerLabel setTextColor:[UIColor blackColor]];
    headerLabel.alpha = 0.5;
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    return headerLabel;
}

-(void)addCell
{
    if (optionCount < 6) {
        optionCount ++;
        
        NSArray *cells = [NSArray arrayWithObjects:
                          [NSIndexPath indexPathForRow:optionCount-1 inSection:1],
                          nil];
        [self.voteTableView beginUpdates];
        [self.voteTableView insertRowsAtIndexPaths:cells withRowAnimation:UITableViewRowAnimationNone];
        [self.voteTableView endUpdates];
        

    }else{
    
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
        HUD.labelText = @"最多只能创建6个选项";
        [HUD hide:YES afterDelay:1.];
    }
}

-(void)chooseBt:(UIButton *)sender
{
    UIButton * button1 = [buttonArr objectAtIndex:0];
    UIButton * button2 = [buttonArr objectAtIndex:1];
    
    if (button1.selected) {
        button1.selected = NO ;
        button2.selected = YES ;
        typeChoose = YES ;
    }else if(button2.selected) {
        button2.selected = NO ;
        button1.selected = YES ;
        typeChoose = NO;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {

    if ( [titleTextView.text isEqualToString:@"输入投票标题"]) {
        titleTextView.text = @"";
    }
    
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    titleStr = titleTextView.text;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag ==1) {
        [_scrollView setContentOffset:CGPointMake(0, 100) animated:YES];
    }
    else if (textField.tag ==2) {
        [_scrollView setContentOffset:CGPointMake(0, 120) animated:YES];
    }else if (textField.tag ==3)
    {
        [_scrollView setContentOffset:CGPointMake(0, 140) animated:YES];
    }
    else if (textField.tag ==4)
    {
        [_scrollView setContentOffset:CGPointMake(0, 160) animated:YES];
    }else if (textField.tag ==5)
    {
        [_scrollView setContentOffset:CGPointMake(0, 190) animated:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

-(void)hiden:(UIButton *)sender
{
    UITextField * text = [textViewMArr objectAtIndex:sender.tag];
    [text resignFirstResponder];
    [titleTextView resignFirstResponder];
    
}

@end
