//
//  T_schollAndFamily_ViewController.m
//  afterShoolForTeacher
//
//  Created by susu on 15/3/16.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "T_schollAndFamily_ViewController.h"
#import "Message_ViewController.h"
#import "Topic_ViewController.h"
#import "GetClass_ViewController.h"
#import "VoteManagement_ViewController.h"
@interface T_schollAndFamily_ViewController ()

@end

@implementation T_schollAndFamily_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.automaticallyAdjustsScrollViewInsets =NO;
    self.navigationItem.title = @"家校互动";
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
    
    for (int i=0; i<4; i++) {
        UIButton * bt = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width/2, blueView.frame.size.height/2, 110, 140)];
        if (i/2 == 0) {
            bt.frame = CGRectMake(Main_Screen_Width/2-140 +170*i, blueView.frame.size.height/2-180, 110, 140);
        }else
        {
            bt.frame = CGRectMake(Main_Screen_Width/2-140 +170*(i-2), blueView.frame.size.height/2+40, 110, 140);
        }
        bt.tag = i ;
        [bt addTarget:self action:@selector(chooose:) forControlEvents:UIControlEventTouchUpInside];
        [bt setImage:[UIImage imageNamed:[NSString stringWithFormat:@"schoolAddClass%d.png",i+1]] forState:UIControlStateNormal];
        [self.view addSubview:bt];
    }
    
    UIView * viewW = [[UIView alloc] initWithFrame:CGRectMake(0, blueView.frame.size.height/2, blueView.frame.size.width, 0.5)];
    viewW.backgroundColor = [UIColor blackColor];//[UIColor colorWithRed:19/255. green:131/255. blue:176/255 alpha:1.];
    viewW.alpha = 0.2;
    [blueView addSubview:viewW];
    
    UIView * viewY = [[UIView alloc] initWithFrame:CGRectMake(blueView.frame.size.width/2, 0, 0.5, blueView.frame.size.height)];
    viewY.backgroundColor = [UIColor blackColor];//[UIColor colorWithRed:19/255. green:131/255. blue:176/255 alpha:1.];
    viewY.alpha = 0.2;
    [blueView addSubview:viewY];

}

-(void)chooose:(UIButton *)sender
{
    switch (sender.tag) {
        case 0:
        {
            
            GetClass_ViewController * class =[[GetClass_ViewController alloc] init];
            class.type = @"vote";
            [self.navigationController pushViewController:class animated:YES];

        }
            break;
        case 1:
        {
            
            
            GetClass_ViewController * class =[[GetClass_ViewController alloc] init];
            class.type = @"menagement";
            [self.navigationController pushViewController:class animated:YES];
        
        }
            break;
        case 2:
        {
            GetClass_ViewController * class =[[GetClass_ViewController alloc] init];
            class.type = @"topic";
            [self.navigationController pushViewController:class animated:YES];
        }
            break;
        case 3:
        {
            GetClass_ViewController * class =[[GetClass_ViewController alloc] init];
            class.type = @"message";
            [self.navigationController pushViewController:class animated:YES];
        }
            break;
            
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
