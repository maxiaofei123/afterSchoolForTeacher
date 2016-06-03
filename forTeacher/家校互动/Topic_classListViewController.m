//
//  Topic_classListViewController.m
//  forTeacher
//
//  Created by susu on 15/11/13.
//  Copyright © 2015年 susu. All rights reserved.
//

#import "Topic_classListViewController.h"
#import "Topic_ViewController.h"

@interface Topic_classListViewController ()<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray * studentArr;
    int deleteId;
    NSArray *filterData;
}

@property(nonatomic,strong)UISearchDisplayController *searchDisplayController;
@property(nonatomic,strong)UITableView * topicTableView;
@property (readwrite, nonatomic) BOOL isSearching;
@end

@implementation Topic_classListViewController
@synthesize searchDisplayController;

-(void)viewWillAppear:(BOOL)animated
{
    [self request];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.automaticallyAdjustsScrollViewInsets =NO;
    self.navigationItem.title = @"班级信息";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self initTableView];
}


-(void)initSerchView
{

    UISearchBar * searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width-20, 30)];
    searchBar.delegate = self;
//    UITextField * searchFeild = [[searchBar subviews] lastObject];
//    [searchFeild setReturnKeyType:UIReturnKeyDone];
//    searchBar.placeholder = @"请输入搜索内容";
    
    
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate = self;
    // searchResultsDataSource 就是 UITableViewDataSource
    searchDisplayController.searchResultsDataSource = self;
    // searchResultsDelegate 就是 UITableViewDelegate
    searchDisplayController.searchResultsDelegate = self;
    
    self.topicTableView.tableHeaderView = searchBar;
    
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
    
    
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    _topicTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20,Main_Screen_Height-64-59-10)];
    _topicTableView.backgroundColor = [UIColor clearColor];
    _topicTableView.delegate =self;
    _topicTableView.dataSource = self;
    [_topicTableView setTableFooterView:view];
    [self.view addSubview:_topicTableView];
    
    
    [self initSerchView];
}


//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([studentArr isKindOfClass:[NSNull class]]) {
        return 0;
    }else
    {
        if (!self.isSearching) {
            return studentArr.count;
        }else{
//            // 谓词搜索
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains [cd] %@",searchDisplayController.searchBar.text];
//            filterData =  [[NSArray alloc] initWithArray:[studentArr filteredArrayUsingPredicate:predicate]];
            return filterData.count;
        }
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
    
    if (!self.isSearching ){
        cell.textLabel.text = [[studentArr objectAtIndex:indexPath.row] objectForKey:@"nickname"];
    }else{
        cell.textLabel.text = [[filterData objectAtIndex:indexPath.row] objectForKey:@"nickname"];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:14.];
    cell.alpha = 0.5;
    

    
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    
    NSDictionary * dic;
    if (!self.isSearching ){
        
        
        dic = @{
                @"userName":[[studentArr objectAtIndex:indexPath.row] objectForKey:@"nickname"],
                @"userID":[[studentArr objectAtIndex:indexPath.row] objectForKey:@"id"]
                };
    }else{
        dic = @{
                @"userName":[[filterData objectAtIndex:indexPath.row] objectForKey:@"nickname"],
                @"userID":[[filterData objectAtIndex:indexPath.row] objectForKey:@"id"]
                };
    }
    
    
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[Topic_ViewController class]]) {
          
            [controller performSelector:@selector(popViewBack:) withObject:dic];
            [self.navigationController popViewControllerAnimated:YES];
            
        }
    }
    
}


/**
 * search
 */


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if(self.searchDisplayController.searchBar.text.length>0) {
        self.isSearching=YES;
        NSString *strSearchText = self.searchDisplayController.searchBar.text;
        NSMutableArray *ar=[NSMutableArray array];
        // correctly working ! Thanx for watching video !
        for (NSDictionary *d in studentArr) {
            NSString *strData = [d objectForKey:@"nickname"];
            if([strData rangeOfString:strSearchText].length>0) {
                [ar addObject:d];
            }
        }
        filterData =[NSArray arrayWithArray:ar];
    } else {
        self.isSearching=NO;
    }
    return YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
