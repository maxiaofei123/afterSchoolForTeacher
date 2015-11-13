//
//  ChangeMessage_ViewController.m
//  forTeacher
//
//  Created by susu on 15/6/8.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "ChangeMessage_ViewController.h"

@interface ChangeMessage_ViewController ()<UITextViewDelegate>
{
    UITextView * titleText;
    UITextView * contentText;
    UILabel * classLable;
    NSMutableArray * classArr;
    
}
@end

@implementation ChangeMessage_ViewController

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
    
    
    [self drawView];
}

-(void)drawView
{
    UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20, Main_Screen_Height-64-59)];
    topView.backgroundColor = [UIColor whiteColor];
    topView.layer.cornerRadius = 8;
    [self.view addSubview:topView];
    
    titleText = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, Main_Screen_Width-40, 50)];
    titleText.layer.borderColor = [[UIColor grayColor] CGColor];
    titleText.text = [self.conentDic objectForKey:@"title"];
    titleText.font = [UIFont systemFontOfSize:18.];
    titleText.layer.borderWidth = 1.0f;
    titleText.tag = 101 ;
    titleText.delegate = self ;
    [topView addSubview:titleText];
    
    contentText = [[UITextView alloc] initWithFrame:CGRectMake(10, 70, Main_Screen_Width-40, 120  )];
    contentText.text =[self.conentDic objectForKey:@"body"];
    contentText.layer.borderColor = [[UIColor grayColor] CGColor];
    contentText.layer.borderWidth = 1.0f;
    contentText.delegate = self ;
    contentText.font = [UIFont systemFontOfSize:16.];
    [topView addSubview:contentText];
    
    UIButton * commitBt = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width-130, 195, 100, 32)];
    [commitBt addTarget:self action:@selector(commitMessage) forControlEvents:UIControlEventTouchUpInside];
    [commitBt setImage:[UIImage imageNamed:@"saveChange.png"] forState:UIControlStateNormal];
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
    
}

-(void)commitMessage
{
    NSString * ok = @"请输入消息内容";
    
    if ([titleText.text isEqualToString:[self.conentDic objectForKey:@"title"]]&&[contentText.text isEqualToString:[self.conentDic objectForKey:@"body"]]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您还没有更改内容" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else {
        if (titleText.text.length >0 && contentText.text.length > 0) {
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.labelText = @"正在提交...";
            
            NSDictionary * pa = [[NSDictionary alloc] initWithObjectsAndKeys:titleText.text,@"inform[title]",contentText.text,@"inform[body]",self.classId,@"inform[school_class_id]" ,[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"],@"inform[teacher_id]", [self.conentDic objectForKey:@"id"],@"inform[id]",nil];
            
            AFHTTPRequestOperationManager * manager =[AFHTTPRequestOperationManager manager];
            [manager PUT:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/teachers/%@/informs/%@?",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"],[self.conentDic objectForKey:@"id"]] parameters:pa success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                NSLog(@"change message =%@",responseObject);
                [self commitMyMessage];
        
                //返回刷新列表 

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
    
}


-(void)commitMyMessage
{

    NSDictionary * pa = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"修改消息:%@",titleText.text],@"topic",contentText.text,@"body",self.classId,@"school_class_id" ,@"user_message",@"message_type",nil];

    AFHTTPRequestOperationManager * manager =[AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/teachers/%@/send_message_to_class",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"]] parameters:pa success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        HUD.labelText = @"修改成功。。。";
        [HUD hide:YES afterDelay:1.];
        [self.delegate headerRefresh];
        [self.navigationController popViewControllerAnimated:YES];
        //返回刷新列表
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error =%@",error);
        HUD.labelText = @"请求超时";
        [HUD hide:YES afterDelay:1.];
    }];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
