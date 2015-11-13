//
//  classMenagement_ViewController.m
//  afterShoolForTeacher
//
//  Created by susu on 15/4/23.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "classMenagement_ViewController.h"
#import "addStudentInfo_ViewController.h"

@interface classMenagement_ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
     NSMutableArray * studentArr;
    int deleteId;
}

@property(nonatomic,strong)UITableView * topicTableView;
@end

@implementation classMenagement_ViewController
-(void)viewWillAppear:(BOOL)animated
{
    [self request];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.automaticallyAdjustsScrollViewInsets =NO;
    self.navigationItem.title = @"班级管理";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self initTableView];
}

-(void)request
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/school_classes/%@",self.classId]parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        NSLog(@"get student of class = %@",responseObject);
        studentArr = [responseObject objectForKey:@"students"];
        [self.topicTableView reloadData];
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"erro =%@",error);
     }];

}

-(void)initTableView
{
    UIView * backView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20, Main_Screen_Height-64-59)];
    backView.backgroundColor = [UIColor colorWithRed:247/255. green:247/255. blue:247/255. alpha:1.];
    backView.layer.cornerRadius = 8 ;
    [self.view addSubview:backView];
    
    UILabel * studentLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 100, 20)];
    studentLable.text = @"学生信息";
    studentLable.font = [UIFont systemFontOfSize:13.];
    studentLable.alpha = 0.7;
    [backView addSubview:studentLable];
    
    UIButton * addBt = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width-100, 10, 80, 30)];
    [addBt setImage:[UIImage imageNamed:@"addStudent.png"] forState:UIControlStateNormal];
    [addBt addTarget:self action:@selector(addStudentInfo) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:addBt];
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    _topicTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 50, Main_Screen_Width-20,Main_Screen_Height-64-59-40)];
    _topicTableView.backgroundColor = [UIColor clearColor];
    _topicTableView.delegate =self;
    _topicTableView.dataSource = self;
    [_topicTableView setTableFooterView:view];
    [self.view addSubview:_topicTableView];
}

-(void)addStudentInfo
{
    addStudentInfo_ViewController * add = [[addStudentInfo_ViewController alloc] init];
    add.changeOrCreate = @"create";
    [self.navigationController pushViewController:add animated:YES];
}

-(void)changeInfo:(UIButton *)sender
{
    
    addStudentInfo_ViewController * add = [[addStudentInfo_ViewController alloc] init];
    add.changeOrCreate = @"change";
    add.class_Id = self.classId;
    add.studentDic = [studentArr objectAtIndex:sender.tag];
    [self.navigationController pushViewController:add animated:YES];
}


//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([studentArr isKindOfClass:[NSNull class]]) {
        return 0;
    }
    return studentArr.count;
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
    cell.backgroundColor = [UIColor whiteColor];
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.textLabel.text = [[studentArr objectAtIndex:indexPath.row] objectForKey:@"nickname"];
    cell.textLabel.font = [UIFont systemFontOfSize:14.];
    cell.alpha = 0.5;
    
    UILabel * emailLable = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, Main_Screen_Width-160, 20)];
    emailLable.text = [[studentArr objectAtIndex:indexPath.row] objectForKey:@"email"];
    emailLable.textAlignment = NSTextAlignmentCenter;
    emailLable.font = [UIFont systemFontOfSize:14.];
    emailLable.alpha = 0.5;
    [cell.contentView addSubview:emailLable];
    
    UIButton * changeBt = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width-75, 10, 20, 20)];
    [changeBt setImage:[UIImage imageNamed:@"change.png"] forState:UIControlStateNormal];
    [changeBt addTarget:self action:@selector(changeInfo:) forControlEvents:UIControlEventTouchUpInside];
    changeBt.tag = indexPath.row;
    [cell.contentView addSubview:changeBt];
    
    
    UIButton * deleteBt = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width-52, 10, 25, 25)];
    [deleteBt setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
    [deleteBt addTarget:self action:@selector(deleteInfo:) forControlEvents:UIControlEventTouchUpInside];
    deleteBt.tag = indexPath.row;
    [cell.contentView addSubview:deleteBt];
    
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
   
}


-(void)deleteInfo:(UIButton *)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"删除提示" message:@"确认删除该学生信息么？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    deleteId = sender.tag;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==0) {
        
    }else
    {
        NSString * studentId = [[studentArr objectAtIndex:deleteId] objectForKey:@"id"];
        AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
        [manager DELETE:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/students/%@",studentId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"delete =%@",responseObject);
            [self request];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
