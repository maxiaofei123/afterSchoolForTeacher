//
//  addStudentInfo_ViewController.m
//  afterShoolForTeacher
//
//  Created by susu on 15/4/23.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "addStudentInfo_ViewController.h"

@interface addStudentInfo_ViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    UITextField * nameField;
    UITextField * emailFeild;
    UITextField  *passwordFeild;
    UITextField  *commitPassworFeild;
    
    NSIndexPath *_selsectedIndexPath;
    BOOL boolSelect;
    NSMutableArray *classArr;
    NSMutableArray *classIdArr;
    NSString * classChooseStr;
    NSString * classId ;
    NSString * studentId;
    UIScrollView * scrollView;
}
@property(nonatomic,strong)UITableView *createTableView;
@end

@implementation addStudentInfo_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.title = @"新建学生";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    boolSelect = NO;
    classChooseStr = [NSString stringWithFormat:@"学生所在班级"];
    [self requestClass];
    [self initTableView];
}

-(void)initTableView
{
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 0,Main_Screen_Width-20, Main_Screen_Height-64-59)];
    scrollView.userInteractionEnabled = YES;
    scrollView.backgroundColor =[UIColor clearColor];
    [self.view addSubview:scrollView];
    
    _createTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width-20, Main_Screen_Height-64-59)style:UITableViewStyleGrouped];
    _createTableView.layer.cornerRadius = 8 ;
    _createTableView.backgroundColor = [UIColor colorWithRed:247/255. green:247/255. blue:247/255. alpha:1.];

    _createTableView.delegate = self ;
    _createTableView.dataSource = self;
    [scrollView addSubview:_createTableView];
    
}

-(void)requestClass
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/teachers/%@/school_classes",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray * arr;
        classArr = [[NSMutableArray alloc] init];
        classIdArr = [[NSMutableArray alloc] init];
        arr = [responseObject objectForKey:@"school_classes"];
        for (int i=0; i<arr.count; i++) {
            [classArr addObject:[[arr objectAtIndex:i] objectForKey:@"class_no"]];
            [classIdArr addObject:[[arr objectAtIndex:i] objectForKey:@"id"]];
            int x =[[[arr objectAtIndex:i] objectForKey:@"id"] intValue];
            int xx = [self.class_Id intValue];
            if (x==xx) {
                classChooseStr =[[arr objectAtIndex:i] objectForKey:@"class_no"];
            }
        }
//        NSLog(@"class =%@",classArr);
        [self initTableView];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //        [self.navigationController popViewControllerAnimated:YES];
        
    }];
}


-(void)commitCreate
{
    NSString * ok = @"ok";
    if (nameField.text.length < 1) {
        ok = @"请输入学生姓名";
    }else if (emailFeild.text.length <1)
    {
        ok = @"请输入学生联系邮箱";
    }
    else if ([classChooseStr isEqualToString:@"学生所在班级"] ) {
        ok = @"请选择学生所在班级";
    }
    else if (passwordFeild.text.length <1 &&passwordFeild.text.length <8)
    {
        ok = @"请输入8-20位密码";
    }
    else if (![passwordFeild.text isEqualToString:commitPassworFeild.text])
    {
        ok = @"前后密码输入不一致";
    }
    if([ok isEqualToString:@"ok"])
    {
        if ([self.changeOrCreate isEqualToString:@"change"]) {
            studentId = [self.studentDic objectForKey:@"id"];
            [self commitProfile];
        }else {
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.labelText = @"正在提交...";
            NSDictionary * dic =[[NSDictionary alloc] initWithObjectsAndKeys:nameField.text,@"student[nickname]",emailFeild.text,@"student[email]",classId,@"student[school_class_id]",passwordFeild.text,@"student[password]",commitPassworFeild.text,@"student[password_confirmation]", nil];
            AFHTTPRequestOperationManager * manager =[AFHTTPRequestOperationManager manager];
            [manager POST:@"http://114.215.125.31/api/v1/students" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"create =%@",responseObject);
                
                HUD.labelText = @"创建成功";
                [HUD hide:YES afterDelay:1.];
                
                [self.navigationController popViewControllerAnimated:YES];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"create error =%@",error);
                HUD.labelText = @"请求失败,请检查网络链接";
                [HUD hide:YES afterDelay:1.];
            }];
        }
    
    }else
    {
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:ok delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

-(void)commitPwd
{
    NSLog(@"student id =%@",studentId);
        NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:passwordFeild.text,@"student[password]" ,commitPassworFeild.text,@"student[password_confirmation]",nil];
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    [manager PUT:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/students/%@",studentId] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"密码修改成功:%@",responseObject);
        if([responseObject objectForKey:@"error"])
        {
            HUD.labelText = @"用户名或密码错误";
            [HUD hide:YES afterDelay:1.];
        }else{
            
            HUD.labelText = @"修改成功。。。";
            [HUD hide:YES];
            [self.navigationController popViewControllerAnimated:YES];
            //刷新tableView单行数据；
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        HUD.labelText = @"请求失败请检查网络连接";
        [HUD hide:YES afterDelay:1.];
        NSLog(@"修改密码error =%@",error);
    }];
}

-(void)commitProfile
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    HUD.labelText = @"正在修改...";
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:nameField.text,@"profile[nickname]",emailFeild.text,@"profile[email]",classId,@"profile[school_class_id]",nil];
//    NSLog(@"class is =%@",classId);
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    [manager PUT:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/students/%@/profile?",studentId] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"个人资料:%@",responseObject);
        [self commitPwd];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        HUD.labelText = @"请求失败请检查网络连接";
        [HUD hide:YES afterDelay:1.];
        NSLog(@"提交用户资料error =%@",error);
    }];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{

    if (textField == passwordFeild)
        [scrollView setContentOffset:CGPointMake(0, 120) animated:YES];
    else if (textField == commitPassworFeild)
        [scrollView setContentOffset:CGPointMake(0, 120) animated:YES];
}

-(void)hiden
{
    [nameField resignFirstResponder];
    [emailFeild resignFirstResponder];
    [passwordFeild resignFirstResponder];
    [commitPassworFeild resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section ==3||section ==1) {
        if(boolSelect)
        {
            return classArr.count+1;
        }else
        return 1;
    }
    return 2;
}

//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
 //   [self.createTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
 ///   UIView * line =[[UIView alloc] initWithFrame:CGRectMake(0, 39.5, Main_Screen_Width-20, 0.5)];
  //  line.backgroundColor =[UIColor grayColor];
  //  if (indexPath.section != 3) {
  ///      [cell.contentView addSubview:line];
        
  //   }
    
    cell.backgroundColor = [UIColor whiteColor];
    
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 30)];
    [topView setBarStyle:UIBarStyleBlackTranslucent];
    
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(2, 5, 50, 25);
    [btn addTarget:self action:@selector(hiden) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    [btn setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneBtn,nil];
    [topView setItems:buttonsArray];
   
    if(indexPath.section ==0)
    {
        if (indexPath.row ==0) {
            cell.textLabel.text = @"姓名";
            nameField = [[UITextField alloc] initWithFrame:CGRectMake(60, 10,Main_Screen_Width-40-60, 20)];
            nameField.placeholder = @"请输入学生姓名";
            nameField.delegate = self;
//            nameField.text =[[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
            nameField.font = [UIFont systemFontOfSize:16.];
            nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
            [cell.contentView addSubview:nameField];
            [nameField setInputAccessoryView:topView];
            if ([self.changeOrCreate isEqualToString:@"change"]) {
                nameField.text = [self.studentDic objectForKey:@"nickname"];
            }
            
        }else
        {
            cell.textLabel.text = @"邮箱";
            emailFeild = [[UITextField alloc] initWithFrame:CGRectMake(60, 10,Main_Screen_Width-40-60, 20)];
            emailFeild.placeholder = @"请输入联系人邮箱";
            emailFeild.delegate = self;
            emailFeild.font = [UIFont systemFontOfSize:16.];
            emailFeild.clearButtonMode = UITextFieldViewModeWhileEditing;
            [cell.contentView addSubview:emailFeild];
            [emailFeild setInputAccessoryView:topView];
            if ([self.changeOrCreate isEqualToString:@"change"]) {
                emailFeild.text = [self.studentDic objectForKey:@"email"];
            }
        }
    
    }else if (indexPath.section ==1)
    {
    
        UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(Main_Screen_Width-50, 13, 20, 15)];
        image.image = [UIImage imageNamed:@"studentClassChoose.png"];
        [cell.contentView addSubview:image];
        if (indexPath.row ==0) {
            UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 200, 20)];
            lable.text = classChooseStr;
            if ([classChooseStr isEqualToString:@"学生所在班级"]) {
                lable.alpha = 0.5 ;
            }else
                lable.alpha = 1. ;
            if ([self.changeOrCreate isEqualToString:@"change"]) {
                lable.alpha = 1. ;
            }

            [cell.contentView addSubview:lable];
        }
        if(boolSelect)
        {
            if (indexPath.row>0) {
                cell.textLabel.text = [classArr  objectAtIndex:indexPath.row-1];
                cell.textLabel.font = [UIFont systemFontOfSize:16.];
            }
        }
    
    }else if (indexPath.section ==2)
    {
        if (indexPath.row ==0) {
            cell.textLabel.text = @"密码";
            passwordFeild = [[UITextField alloc] initWithFrame:CGRectMake(60, 10, Main_Screen_Width-40-60, 20)];
            passwordFeild.placeholder = @"请输入密码";
            passwordFeild.delegate = self;
            passwordFeild.secureTextEntry = YES;
            passwordFeild.font = [UIFont systemFontOfSize:16.];
            passwordFeild.clearButtonMode = UITextFieldViewModeWhileEditing;
            [cell.contentView addSubview:passwordFeild];
            [passwordFeild setInputAccessoryView:topView];
        }else
        {
            cell.textLabel.text = @"确认";
            commitPassworFeild = [[UITextField alloc] initWithFrame:CGRectMake(60, 10, Main_Screen_Width-40-60, 20)];
            commitPassworFeild.placeholder = @"请再次输入密码";
            commitPassworFeild.delegate = self;
            commitPassworFeild.secureTextEntry = YES;
            commitPassworFeild.font = [UIFont systemFontOfSize:16.];
            commitPassworFeild.clearButtonMode = UITextFieldViewModeWhileEditing;
            [cell.contentView addSubview:commitPassworFeild];
            [commitPassworFeild setInputAccessoryView:topView];
        }
    }
    
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if(indexPath.section ==1 )
    {
        if (boolSelect) {
            boolSelect = NO;
            if (indexPath.row>0) {
                classChooseStr = [classArr objectAtIndex:indexPath.row -1];
                classId = [classIdArr objectAtIndex:indexPath.row -1] ;
            }
            for (NSInteger i = 1; i < ([classArr count]+1); i++) {
                NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
                [array addObject:index];
            }
            [self.createTableView deleteRowsAtIndexPaths:array
                                  withRowAnimation:UITableViewRowAnimationFade];
            NSIndexPath *indexPath_1=[NSIndexPath indexPathForRow:0 inSection:1];
            NSArray *indexArray=[NSArray arrayWithObject:indexPath_1];
            [self.createTableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
        }else{
            boolSelect = YES;
            for (NSInteger i = 1; i < ([classArr count]+1); i++) {
                NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
                [array addObject:index];
            }
            NSLog(@"arr =%@",array);
            [self.createTableView insertRowsAtIndexPaths:array
                                  withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 300, 30)];
    if (section == 0) {
        headerLabel.text = @"    基本信息";
    }else if(section == 1)
    {
        headerLabel.text = @"    班级选择";
    }else if(section == 2)
    {
        headerLabel.text = @"    密码设置";
    }
    
    [headerLabel setFont:[UIFont systemFontOfSize:14.0]];
    [headerLabel setTextColor:[UIColor blackColor]];
    headerLabel.alpha = 0.7;
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    return headerLabel;
}

-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section==2) {
        UIButton * commitBt = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, Main_Screen_Width-60, 50)];
        [commitBt setImage:[UIImage imageNamed:@"student_create.png"] forState:UIControlStateNormal];
        [commitBt addTarget:self action:@selector(commitCreate) forControlEvents:UIControlEventTouchUpInside];
        return commitBt;
    }
    return nil;
}

- ( CGFloat )tableView:( UITableView *)tableView heightForHeaderInSection:( NSInteger )section
{
    if(tableView.tag ==0)
    {
        return 40.0 ;
    }
    if (section == 2) {
        return 10.0;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView  heightForFooterInSection:(NSInteger)section
{
    if (section== 2) {
        return 70.0;
    }
    return 1.0;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
