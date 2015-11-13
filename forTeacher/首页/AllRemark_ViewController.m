//
//  AllRemark_ViewController.m
//  afterShoolForTeacher
//
//  Created by susu on 15/4/12.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "AllRemark_ViewController.h"

@interface AllRemark_ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray * buttonArr ;
    NSDictionary * workDic ;
    NSArray * peopleArr ;
    NSArray * markArr;
    int submit;
    int classSubmit ;
    int total ;
}
@property(strong,nonatomic)UITableView * remarkHomeWorkTableView;
@end

@implementation AllRemark_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationItem.title = @"批阅作业";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    markArr= [[NSArray alloc] initWithObjects:@"完成的很好",@"做的不错",@"", nil];
    buttonArr = [[NSMutableArray alloc] init];
    [self requestWork];
}

-(void)requestWork
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/work_papers/%@",self.workId ]parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        NSLog(@"teacherwork =%@",responseObject);
        workDic = [responseObject objectForKey:@"work_paper"];
        peopleArr = [workDic objectForKey:@"classes"];
        for (int i= 0; i<peopleArr.count; i++) {
            int a = [[[peopleArr objectAtIndex:i] objectForKey:@"submit_students"] intValue];
            submit = submit + a ;
            int b = [[[peopleArr objectAtIndex:i] objectForKey:@"total_students"] intValue];
            total = total + b ;
            int classi = [self.classId intValue];
            int schooClass = [[[peopleArr objectAtIndex:i] objectForKey:@"school_class_id"]intValue];
            if (classi == schooClass) {
                classSubmit = [[[peopleArr objectAtIndex:i] objectForKey:@"submit_students"] intValue];
            }
        }
        [self initTableView];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"erro =%@",error);
     }];

}

-(void)initTableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _remarkHomeWorkTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20, Main_Screen_Height-64-59)style:UITableViewStylePlain];
    _remarkHomeWorkTableView.backgroundColor = [UIColor colorWithRed:247/255. green:247/255. blue:247/255. alpha:1.];
    _remarkHomeWorkTableView.layer.cornerRadius = 8;
    _remarkHomeWorkTableView.delegate =self;
    _remarkHomeWorkTableView.dataSource = self;
    [_remarkHomeWorkTableView setTableFooterView:view];
    [self.view addSubview:_remarkHomeWorkTableView];
}

-(void)remarkCommit
{
    NSString * markStr =  [NSString stringWithFormat:@""] ;
    for (int i=0; i<buttonArr.count; i++) {
         UIButton * button = [buttonArr objectAtIndex:i];
        if (button.selected) {
            markStr = [NSString stringWithFormat:@"%@",[markArr objectAtIndex:i]];
        }
    }
    if (markStr.length > 2) {
        
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.labelText = @"正在提交...";
        NSDictionary * dic;
        if([self.markType isEqualToString:@"forAll"])
        {
            dic = [[NSDictionary alloc] initWithObjectsAndKeys:markStr,@"work_review[remark]",@"0",@"work_review[rate]", nil];
        }else
        {
            dic = [[NSDictionary alloc] initWithObjectsAndKeys:self.classId,@"school_class_id",markStr,@"work_review[remark]",@"0",@"work_review[rate]", nil];
        }

        AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
        [manager POST:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/teachers/%@/work_reviews/batch_review?work_paper_id=%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"],self.workId] parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"批量批阅成功, %@",responseObject);
            HUD.labelText = @"批阅成功";
            [HUD hide:YES afterDelay:1.];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error =%@",error);
            HUD.labelText = @"请求失败,请检查网络链接";
            [HUD hide:YES afterDelay:1.];
        }];
        }else
        {
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.labelText = @"请选择评语";
            [HUD hide:YES afterDelay:1.];
        }

}


//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section ==1) {
        return 3 ;
    }
    return 1;
}
- ( CGFloat )tableView:( UITableView *)tableView heightForHeaderInSection:( NSInteger )section

{  if(section ==0)
    return 0;
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
//绘制Cell

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
    [_remarkHomeWorkTableView setSeparatorInset:UIEdgeInsetsMake(0,0, 0, 0)];
//    [_remarkHomeWorkTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    cell.backgroundColor = [UIColor whiteColor];
    if (indexPath.section ==0) {
        float titleLableSizeHeight= [publicRequest lableSizeWidth:Main_Screen_Width-40 content:[workDic objectForKey:@"title"]] ;
        float contentLableSizeHeight= [publicRequest lableSizeWidth:Main_Screen_Width-40 content:[workDic objectForKey:@"description"]] ;
        
        UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, Main_Screen_Width-40, titleLableSizeHeight)];
        titleLable.text = [workDic objectForKey:@"title"];
        titleLable.font = [UIFont systemFontOfSize:16.];
        titleLable.lineBreakMode = NSLineBreakByWordWrapping;
        titleLable.numberOfLines = 0;
        [cell.contentView addSubview:titleLable];
        
        UILabel * dateLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 30+(titleLableSizeHeight-20), Main_Screen_Width-40, 20)];
        dateLable.text = [[workDic objectForKey:@"updated_at"] substringToIndex:10];
        dateLable.font = [UIFont systemFontOfSize:14.];
        dateLable.textColor = [UIColor grayColor];
        [cell.contentView addSubview:dateLable];
        
        UILabel * contentLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 50+(titleLableSizeHeight-20), Main_Screen_Width-40, contentLableSizeHeight)];
        contentLable.text = [workDic objectForKey:@"description"];
        contentLable.lineBreakMode = NSLineBreakByWordWrapping;
        contentLable.numberOfLines = 0;
        contentLable.alpha = 0.6;
        contentLable.font = [UIFont systemFontOfSize:14.];
        [cell.contentView addSubview:contentLable];
    }
    if (indexPath.section ==1) {
        if (indexPath.row ==0) {
            UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 200, 40)];
            if([self.markType isEqualToString:@"forClass"])
            {
                 lable.text = [NSString stringWithFormat:@"作业已完成人数:(%d人)",classSubmit];
            }else {
                lable.text = [NSString stringWithFormat:@"作业已完成人数:(%d人)",submit];
            }
            [cell.contentView addSubview:lable];
            
            UIButton * commit = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width-110, 5,80, 30)];
            [commit setImage:[UIImage imageNamed:@"piLiangPiYue.png"] forState:UIControlStateNormal];
            [commit addTarget:self action:@selector(remarkCommit) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:commit];
           
        }else
        {
            cell.backgroundColor = [UIColor colorWithRed:232/255. green:232/255. blue:232/255. alpha:1.];
            UIButton * quanBt = [[UIButton alloc] initWithFrame:CGRectMake(40, 0, 40, 40)];
            [quanBt setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
            [quanBt setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateSelected];
            quanBt.tag = indexPath.row ;
            [quanBt addTarget:self action:@selector(choose:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:quanBt];
            [buttonArr addObject:quanBt];
            
            UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 200, 40)];
            lable.text = [markArr objectAtIndex:indexPath.row-1];
            [cell.contentView addSubview:lable];
            
        }
    }
    
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section ==1) {
        return 40 ;
    }
    float titleLableSizeHeight= [publicRequest lableSizeWidth:Main_Screen_Width-40 content:[workDic objectForKey:@"title"]] ;
    float contentLableSizeHeight= [publicRequest lableSizeWidth:Main_Screen_Width-40 content:[workDic objectForKey:@"description"]] ;
    return 80+titleLableSizeHeight+contentLableSizeHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失

}

-(void)choose:(UIButton *)sender
{
    UIButton * button = [buttonArr objectAtIndex:sender.tag-1];
    if (button.selected) {
        button.selected = NO ;
    }else{
        button.selected = YES ;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
