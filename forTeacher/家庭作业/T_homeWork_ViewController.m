//
//  T_homeWork_ViewController.m
//  afterShoolForTeacher
//
//  Created by susu on 15/3/16.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "T_homeWork_ViewController.h"
#import "releaseWork_ViewController.h"
#import "GetClass_ViewController.h"

@interface T_homeWork_ViewController ()

@end

@implementation T_homeWork_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationItem.title = @"家庭作业";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self drawView];
}

-(void)drawView
{
    UIView * blueView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20, Main_Screen_Height-64-59)];
    blueView.layer.cornerRadius = 8;
    blueView.layer.masksToBounds = YES;
    blueView.backgroundColor =[UIColor colorWithRed:0/255. green:179/255. blue:245/255. alpha:1.];
    [self.view addSubview:blueView];
    
    UIButton * markBt = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width/2 - 125, Main_Screen_Height/2-120, 100, 100)];
    [markBt setImage:[UIImage imageNamed:@"marking.png"] forState:UIControlStateNormal];
    [markBt addTarget:self action:@selector(choose:) forControlEvents:UIControlEventTouchUpInside];
    markBt.tag = 1;
    [self.view addSubview:markBt];
    UILabel * markLable = [[UILabel alloc] initWithFrame:CGRectMake(Main_Screen_Width/2 - 125, Main_Screen_Height/2-15, 100, 20)];
    markLable.text =@"待批阅作业";
    markLable.textColor = [UIColor whiteColor];
    markLable.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:markLable];
    
    UIButton * releaseBt = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width/2 + 25, Main_Screen_Height/2-120, 100, 100)];
    [releaseBt setImage:[UIImage imageNamed:@"releaseWork.png"] forState:UIControlStateNormal];
    [releaseBt addTarget:self action:@selector(choose:) forControlEvents:UIControlEventTouchUpInside];
    releaseBt.tag = 2;
    [self.view addSubview:releaseBt];
    UILabel * releaseLable = [[UILabel alloc] initWithFrame:CGRectMake(Main_Screen_Width/2 + 25, Main_Screen_Height/2-15, 100, 20)];
    releaseLable.textColor = [UIColor whiteColor];
    releaseLable.textAlignment = NSTextAlignmentCenter;
    releaseLable.text =@"发布作业";
    [self.view addSubview:releaseLable];
}

-(void)choose:(UIButton *)sender
{
    if (sender.tag ==1) {
        GetClass_ViewController * class = [[GetClass_ViewController alloc] init];
        class.type = @"homeWork";
        [self.navigationController pushViewController:class animated:YES];
    }else
    {
        releaseWork_ViewController * relaese = [[releaseWork_ViewController alloc] init];
        
        [self.navigationController pushViewController:relaese animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
