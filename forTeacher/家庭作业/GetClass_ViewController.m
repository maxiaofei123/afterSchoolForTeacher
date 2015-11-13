//
//  GetClass_ViewController.m
//  afterShoolForTeacher
//
//  Created by susu on 15/3/23.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "GetClass_ViewController.h"
#import "GetWorkPaperForClass_ViewController.h"
#import "classMenagement_ViewController.h"
#import "Topic_ViewController.h"
#import "Message_ViewController.h"
#import "VoteManagement_ViewController.h"

@interface GetClass_ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray * classNoArr;
}
@property(nonatomic,strong)UITableView * classTableView;
@end

@implementation GetClass_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationItem.title = @"班级列表";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    [self requestClass];
}

-(void)requestClass
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/teachers/%@/school_classes",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"class =%@",responseObject);
        classNoArr = [responseObject objectForKey:@"school_classes"];
        [self initTableView];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
//        [self.navigationController popViewControllerAnimated:YES];
        
    }];
}

-(void)initTableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    self.classTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20,Main_Screen_Height-64-59)style:UITableViewStylePlain];
     self.classTableView.backgroundColor = [UIColor colorWithRed:247/255. green:247/255. blue:247/255. alpha:1.];
    self.classTableView.layer.cornerRadius = 8 ;
     self.classTableView.delegate =self;
     self.classTableView.dataSource = self;
    [self.classTableView setTableFooterView:view];
    [self.view addSubview: self.classTableView];
}

//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (classNoArr.count%3 >0) {
        return (classNoArr.count/3 +1);
    }
    return (classNoArr.count/3);
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
    [self.classTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    cell.backgroundColor = [UIColor clearColor];
    for (int i =0; i< 3; i++) {
        if ((indexPath.row*3 +i)<classNoArr.count) {
            UIImageView * classImage = [[UIImageView alloc] initWithFrame:CGRectMake(((Main_Screen_Width-20)/3-60)/2+(Main_Screen_Width-20)/3*i, 10, 60, 60)];
            classImage.image = [UIImage imageNamed:@"header.png"];
            classImage.layer.cornerRadius = 30 ;
            classImage.layer.masksToBounds = YES;
            classImage.userInteractionEnabled = YES ;
            [cell.contentView addSubview:classImage];
            
            NSString * url = [NSString stringWithFormat:@"%@",[[[classNoArr objectAtIndex:indexPath.row*3 +i] objectForKey:@"avatar"] objectForKey:@"url"]];
            NSLog(@"url =%@",url);
            if (url.length > 0) {
                [classImage setImageWithURL:[NSURL URLWithString:url]];
            }
            if (classImage.image == nil) {
                classImage.image =[UIImage imageNamed:@"header.png"];;
            }

            UIButton * bt = [UIButton buttonWithType:0];
            bt.frame=CGRectMake(0,0,60,60);
            bt.layer.cornerRadius = 30;
            bt.backgroundColor = [UIColor clearColor];
            bt.tag = indexPath.row*3 + i;
            
            [bt addTarget:self action:@selector(chooseBt:) forControlEvents:UIControlEventTouchUpInside];
            [classImage addSubview:bt];

            
            UILabel * lable = [[UILabel alloc]initWithFrame:CGRectMake(0+(Main_Screen_Width-20)/3*i, 65, (Main_Screen_Width-20)/3, 30)];
            lable.font = [UIFont systemFontOfSize:15.];
            lable.alpha = 0.7;
            lable.textAlignment = NSTextAlignmentCenter;
            lable.text = [[classNoArr objectAtIndex:indexPath.row*3 +i] objectForKey:@"class_no"];
            [cell.contentView addSubview:lable];
        }
    }
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
}


-(void)chooseBt:(UIButton * )sender
{
    if ([self.type isEqualToString:@"homeWork"]) {
        GetWorkPaperForClass_ViewController * remark = [[GetWorkPaperForClass_ViewController alloc] init];
        
        remark.classId = [[classNoArr objectAtIndex:sender.tag] objectForKey:@"id"];
        [self.navigationController pushViewController:remark animated:YES];
    }else if ([self.type isEqualToString:@"menagement"])
    {
        classMenagement_ViewController * menagement = [[classMenagement_ViewController alloc] init];
        menagement.classId = [[classNoArr objectAtIndex:sender.tag] objectForKey:@"id"];
        [self.navigationController pushViewController:menagement animated:YES];
    }else if([self.type isEqualToString:@"topic"])
    {
        Topic_ViewController * topic = [[Topic_ViewController alloc] init];
        topic.classId = [[classNoArr objectAtIndex:sender.tag] objectForKey:@"id"];
        [self.navigationController pushViewController:topic animated:YES];
    }else if ([self.type isEqualToString:@"message"])
    {
        Message_ViewController * message = [[Message_ViewController alloc] init];
        message.classId = [[classNoArr objectAtIndex:sender.tag] objectForKey:@"id"];
        [self.navigationController pushViewController:message animated:YES];
    }else if ([self.type isEqualToString:@"vote"])
    {
        VoteManagement_ViewController * vote = [[VoteManagement_ViewController alloc] init];
        vote.classId = [[classNoArr objectAtIndex:sender.tag] objectForKey:@"id"];
        [self.navigationController pushViewController:vote animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
