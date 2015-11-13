//
//  Remark_DetailViewController.m
//  afterShoolForTeacher
//
//  Created by susu on 15/4/1.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "Remark_DetailViewController.h"
#import "RemarkChangeViewController.h"
#import "NIDropDown.h"


@interface Remark_DetailViewController ()<UITableViewDelegate,UITableViewDataSource,AVAudioPlayerDelegate,UITextViewDelegate>
{
     NIDropDown *dropDown;
    NSDictionary * homeWorkDic;
    NSMutableArray * imageUrlArr;
    NSMutableArray * mp3UrlArr;
    NSMutableArray * mp4UrlArr;
    UILabel * timeLable ;
    NSTimer *_progressUpdateTimer;
    
    NSTimer *stopTimer;
    NSTimer * shortTimer;
    int   shortTime;
    NSString *mp3FilePath;
    NSString * cafPath;
    AVAudioSession *session;
    AVAudioRecorder *recorder;
    UIButton *rateBt;
    
    UITextView * goodPointTextView;
    UITextView * badPointTextView;
    NSDictionary * teacherRemarkDic;
    NSArray * rateArr;
    int rate ;
          NSString * teachermarkMp3Str;
    
    BOOL record;
}

@property (nonatomic, retain) AudioStreamer *streamer;
@property (nonatomic,strong) UISlider *progressSlider;
@property (strong, nonatomic)  UIButton *playButton;
@property(strong,nonatomic)UITableView * remarkHomeWorkTableView;
//record
@property (nonatomic , retain) AVAudioPlayer *player;
@property (nonatomic , retain) NSURL *recordedFile;
@property (nonatomic) BOOL isRecording;
@property (strong, nonatomic)  UIButton *playRecord;
@property (strong, nonatomic)  UIButton *recordButton;

@property (strong, nonatomic)  UIButton *RemarkplayMusicButton;
@property (nonatomic, retain) AudioStreamer *RemarkStreamer;

@end

@implementation Remark_DetailViewController
@synthesize playButton;
@synthesize player,recordedFile;

-(void)viewWillDisappear:(BOOL)animated
{
    [_progressUpdateTimer invalidate];
    _progressUpdateTimer=nil;
    [_streamer stop];
     _streamer = nil;
    // remove notification observer for streamer
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ASStatusChangedNotification
                                                  object:_streamer];
    
    [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    
    [_RemarkStreamer stop];
    _RemarkStreamer = nil;
    // remove notification observer for streamer
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ASStatusChangedNotification
                                                  object:_RemarkStreamer];
    
    [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    rate = 0;

}

-(void)viewWillAppear:(BOOL)animated
{
   [self  request];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationItem.title = @"学生作业";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"修改批阅" style:UIBarButtonItemStylePlain target:self action:@selector(remarkChange)];
    self.navigationItem.rightBarButtonItem=anotherButton;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    imageUrlArr = [[NSMutableArray alloc] init];
    mp3UrlArr = [[NSMutableArray alloc] init];
    mp4UrlArr = [[NSMutableArray alloc] init];
    //录音
    cafPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/downloadFile.caf"];
    //    NSLog(@"%@",path);
    recordedFile = [[NSURL alloc] initFileURLWithPath:cafPath];
    self.isRecording = NO;
    record =NO;
    [self  request];
    [self initTableView];
}

-(void)initTableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _remarkHomeWorkTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20, Main_Screen_Height-64-49)style:UITableViewStylePlain];
    _remarkHomeWorkTableView.backgroundColor = [UIColor clearColor];
    _remarkHomeWorkTableView.delegate =self;
    _remarkHomeWorkTableView.dataSource = self;
    [_remarkHomeWorkTableView setTableFooterView:view];
    [self.view addSubview:_remarkHomeWorkTableView];
}

-(void)request
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/home_works?student_id=%@&work_paper_id=%@",self.studentWorkId,self.workPaperId ]parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        
           NSLog(@"作业详细 = %@",responseObject);
        homeWorkDic  =[responseObject objectAtIndex:0];
        imageUrlArr  = [[NSMutableArray alloc] init];
        mp3UrlArr = [[NSMutableArray alloc] init];
        mp4UrlArr = [[NSMutableArray alloc] init];
        for (int i=0 ; i<[[homeWorkDic objectForKey:@"medias"] count]; i++) {
            NSString * type = [[[homeWorkDic objectForKey:@"medias"] objectAtIndex:i]objectForKey:@"content_type"];
            NSString * str = [[[homeWorkDic objectForKey:@"medias"] objectAtIndex:i]objectForKey:@"avatar"];
            if(![str isKindOfClass:[NSNull class]])
            {
                NSRange range = [type rangeOfString:@"/"];
                NSString * rangeType = [type substringToIndex:range.location];
                //NSLog(@"range =%d =%@",range.location,rangeType);
                
                if ([rangeType isEqualToString:@"video"]) {
                    [mp4UrlArr addObject:str];
                }else if ([rangeType isEqualToString:@"audio"]||[rangeType isEqualToString:@"sound"])
                {
                    [mp3UrlArr addObject:str];
                    
                }else if ([rangeType isEqualToString:@"image"])
                {
                    [imageUrlArr addObject:str];
                }
            }
        }
          if (![[homeWorkDic objectForKey:@"state"] isEqualToString:@"init"])
          {
              [self requestTeacherRemark:[homeWorkDic objectForKey:@"id"]];
          }
        
        [_remarkHomeWorkTableView reloadData];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"erro =%@",error);
     }];
}

-(void)requestTeacherRemark:(NSString * )homeWorkId
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/home_works/%@/work_review",homeWorkId ]parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        teacherRemarkDic = [responseObject objectForKey:@"work_review"] ;
        NSLog(@"teacher remark =%@",responseObject);
        if ([[responseObject allKeys] containsObject:@"review_medias"])
        {
            NSArray * a = [responseObject objectForKey:@"review_medias"];
            if (a.count>0) {
                NSDictionary * dicR = [a objectAtIndex:0];
                if ([[dicR allKeys] containsObject:@"avatar"]) {
                    
                    teachermarkMp3Str = [NSString stringWithFormat:@"%@",[[dicR objectForKey:@"avatar"] objectForKey:@"url"]];
                }
            }
        }
        NSIndexPath * indexx = [NSIndexPath indexPathForItem:0 inSection:1];
        NSArray * array = [NSArray arrayWithObject:indexx];
        [_remarkHomeWorkTableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"erro =%@",error);
     }];
    
}

-(void)remarkChange
{
    RemarkChangeViewController * remark = [[RemarkChangeViewController alloc] init];
    remark.studentWorkId = self.studentWorkId;
    remark.workPaperId = self.workPaperId;
    [self.navigationController pushViewController:remark animated:YES];
}

-(void)commitResource
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = @"正在提交...";
    NSString * markStr ;
    NSString * str1 =[NSString stringWithFormat:@""];
    NSString * str2 = [NSString stringWithFormat:@""];
    
    if ( !([goodPointTextView.text isEqualToString:@"请输入作业精彩点"] || goodPointTextView.text.length == 0)) {
        str1 = [NSString stringWithFormat:@"精彩点:%@",goodPointTextView.text];
    }
    if ( !([badPointTextView.text isEqualToString:@"请输入作业不足之处"]|| badPointTextView.text.length == 0)) {
        str2 = [NSString stringWithFormat:@"可改善之处:%@",badPointTextView.text];
    }
    markStr = [NSString stringWithFormat:@"%@%@",str1,str2];
    
    NSDictionary * dic = [[NSDictionary alloc] initWithObjectsAndKeys:markStr,@"work_review[remark]",[NSString stringWithFormat:@"%d",rate],@"work_review[rate]",[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"],@"work_review[teacher_id]", nil];
    NSLog(@"home id =%@",[homeWorkDic objectForKey:@"id"]);
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"http://114.215.125.31/api/v1/home_works/%@/work_review",[homeWorkDic objectForKey:@"id"]] parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
        NSFileManager* manager = [NSFileManager defaultManager];
        if (record){
            if([ self audio_PCMtoMP3])
            {
                if ([manager fileExistsAtPath:mp3FilePath]){
                    NSData * mp3data = [NSData dataWithContentsOfFile:mp3FilePath];
                    [formData appendPartWithFileData:mp3data name:@"media_resource[avatar]"fileName:[NSString stringWithFormat:@"anyaudio_%d.mp3",1] mimeType:@"audio/mp3"];
                }
            }
        }
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //         清楚写入的 caf mp3
         NSFileManager * caffileManager = [[NSFileManager alloc]init];
         [caffileManager removeItemAtPath:cafPath error:nil];
         NSFileManager * mp3fileManager = [[NSFileManager alloc]init];
         [mp3fileManager removeItemAtPath:mp3FilePath error:nil];
         
         NSDictionary * dic =responseObject;
         NSLog(@"dic =%@",dic);
         HUD.labelText = @"提交成功。。。";
         [HUD hide:YES afterDelay:1.];
         
         [self.delegate headerRefresh];
         [self.navigationController popViewControllerAnimated:YES];
         
     }failure:^(AFHTTPRequestOperation *operation, NSError *error){
         NSLog(@"error =%@ ",[error description]);
         HUD.labelText = @"请求超时";
         [HUD hide:YES afterDelay:1.];
     }  ];

}


//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
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
    
    [_remarkHomeWorkTableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.cornerRadius = 5;
    
    if (indexPath.section ==0) {
        float titleLableSizeHeight= [publicRequest lableSizeWidth:Main_Screen_Width-40 content:[homeWorkDic objectForKey:@"title"]] ;
        float contentLableSizeHeight= [publicRequest lableSizeWidth:Main_Screen_Width-40 content:[homeWorkDic objectForKey:@"description"]] ;
        UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, Main_Screen_Width-40, titleLableSizeHeight)];
        titleLable.text = [homeWorkDic objectForKey:@"title"];
        titleLable.font = [UIFont systemFontOfSize:16.];
        titleLable.lineBreakMode = NSLineBreakByWordWrapping;
        titleLable.numberOfLines = 0;
        
        [cell.contentView addSubview:titleLable];
        
        UILabel * dateLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 30+(titleLableSizeHeight-20), Main_Screen_Width-40, 20)];
        dateLable.text = [[homeWorkDic objectForKey:@"updated_at"] substringToIndex:10];
        dateLable.font = [UIFont systemFontOfSize:14.];
        dateLable.textColor = [UIColor grayColor];
        [cell.contentView addSubview:dateLable];
        
        UILabel * contentLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 50+(titleLableSizeHeight-20), Main_Screen_Width-40, contentLableSizeHeight)];
        contentLable.text = [homeWorkDic objectForKey:@"description"];
        contentLable.lineBreakMode = NSLineBreakByWordWrapping;
        contentLable.numberOfLines = 0;
        contentLable.font = [UIFont systemFontOfSize:14.];
        contentLable.alpha = 0.6;
        [cell.contentView addSubview:contentLable];
        
        int mp3Heigh = 0;
        if (mp3UrlArr.count>0) {
            UIView * playView = [self drawPlayViewY:45+titleLableSizeHeight+contentLableSizeHeight];
            [cell.contentView addSubview:playView];
            self.progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(20,163+titleLableSizeHeight+contentLableSizeHeight, Main_Screen_Width-100-20, 10)];
            self.progressSlider.value = 0;
            self.progressSlider.minimumValue = 0;
            self.progressSlider.maximumValue = 100;
            self.progressSlider.minimumTrackTintColor = [UIColor greenColor];
            [self.progressSlider addTarget:self action:@selector(seek) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:self.progressSlider];
            
            timeLable = [[UILabel alloc] initWithFrame:CGRectMake(Main_Screen_Width-90,155+titleLableSizeHeight+contentLableSizeHeight, 100, 20)];
            timeLable.font = [UIFont systemFontOfSize:11.];
            timeLable.text = @"00:00";
            timeLable.textColor = [UIColor grayColor];
            [cell.contentView addSubview:timeLable];
            mp3Heigh = 140;
        }
        int  imageHeight = 0;
        if (imageUrlArr.count > 0) {
            UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, mp3Heigh+50+titleLableSizeHeight+contentLableSizeHeight, Main_Screen_Width-20, 100)];
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.contentSize = CGSizeMake(10+108 * imageUrlArr.count,100);
            scrollView.delegate =self;
            scrollView.pagingEnabled = YES;
            scrollView.userInteractionEnabled = YES;
            [cell.contentView addSubview:scrollView];
            
            for (int i= 0; i<[imageUrlArr count]; i++) {
                UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10+108*i, 0, 100, 100)];
                imageView.tag = i;
                imageView.userInteractionEnabled = YES;
                // 内容模式
                imageView.clipsToBounds = YES;
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                [scrollView addSubview:imageView];
                
                NSURL * imageUrl = [NSURL URLWithString:[imageUrlArr objectAtIndex:i]];
                [imageView setImageWithURL:imageUrl];
                imageView.tag =i;
                UITapGestureRecognizer *pass1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
                [imageView addGestureRecognizer:pass1];
            }
            imageHeight = 115;
        }
        if (mp4UrlArr.count > 0) {
            UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,imageHeight+mp3Heigh+50+titleLableSizeHeight+contentLableSizeHeight, Main_Screen_Width-20, 100)];
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.contentSize = CGSizeMake(10+108 * imageUrlArr.count,100);
            //        scrollView.bounces = NO;
            scrollView.delegate =self;
            scrollView.pagingEnabled = YES;
            scrollView.userInteractionEnabled = YES;
            [cell.contentView addSubview:scrollView];
            
            for (int i= 0; i<[mp4UrlArr count]; i++) {
                UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10+108*i, 0, 100, 100)];
                imageView.tag = i;
                imageView.userInteractionEnabled = YES;
                // 内容模式
                imageView.clipsToBounds = YES;
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                [scrollView addSubview:imageView];
                //如果有mp4则播放按钮显示
                imageView.backgroundColor = [UIColor colorWithRed:235/255. green:235/255. blue:235/255. alpha:1.];
                UIButton * imageBt = [[UIButton alloc] initWithFrame:CGRectMake(35+108*i,25, 50, 50)];
                [imageBt setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
                imageBt.tag = i;
                [imageBt addTarget:self action:@selector(initMpMOviePlayerPapers:) forControlEvents:UIControlEventTouchUpInside];
                [scrollView addSubview:imageBt];
            }
        }
        
    }else if (indexPath.section ==1)
    {
        if ([[homeWorkDic objectForKey:@"state"] isEqualToString:@"init"]) {

            UIView * playView = [[UIView alloc] initWithFrame:CGRectMake(10,10, Main_Screen_Width-40, 100)];
            playView.backgroundColor = [UIColor colorWithRed:235/255. green:235/255. blue:235/255. alpha:1.];
            [cell.contentView addSubview:playView];
            
            UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(playView.frame.size.width/2-120, 5, 240, 20)];
            titleLable.textColor = [UIColor greenColor];
            titleLable.text = @"语音留言";
            titleLable.font = [UIFont systemFontOfSize:14.];
            titleLable.textAlignment = NSTextAlignmentCenter;
            [playView addSubview:titleLable];
            
            _recordButton = [[UIButton alloc] initWithFrame:CGRectMake(playView.frame.size.width/2-70, 30, 50, 50)];
            [_recordButton setImage:[UIImage imageNamed:@"voice.png"] forState:UIControlStateNormal];
            [_recordButton addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];
            [playView addSubview:_recordButton];
            
            _playRecord = [[UIButton alloc] initWithFrame:CGRectMake(playView.frame.size.width/2+20, 30, 50, 50)];
            [_playRecord setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
            [_playRecord addTarget:self action:@selector(playRecord:) forControlEvents:UIControlEventTouchUpInside];
            [_playRecord setEnabled:NO];
            [playView addSubview:_playRecord];
            
            //写字good
            UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 120, 30, 30)];
            image.image = [UIImage imageNamed:@"wenziLiuyan.png"];
            [cell.contentView addSubview:image];
            
            UILabel * good = [[UILabel alloc] initWithFrame:CGRectMake(45, 125, 100, 20)];
            good.text = @"精彩点";
            good.alpha = 0.7;
            [cell.contentView addSubview:good];
            rateBt =[[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width-100, 123, 70, 25)];
            rateBt.backgroundColor = [UIColor colorWithRed:63/255. green:63/255. blue:63/255. alpha:1.];
            [rateBt setTitle:@"作业评分" forState:UIControlStateNormal];
            rateBt.titleLabel.font = [UIFont systemFontOfSize:14.];
            [rateBt addTarget:self action:@selector(rateChoose:) forControlEvents:UIControlEventTouchUpInside];
            rateBt.layer.cornerRadius = 10 ;
            [rateBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
            [cell.contentView addSubview:rateBt];
            
            UIView * messege = [[UIView alloc] initWithFrame:CGRectMake(10, 150, Main_Screen_Width-40, 60)];
            [messege.layer setBorderColor:[[UIColor grayColor] CGColor]];
            [messege.layer setBorderWidth:1];
            [cell.contentView addSubview:messege];

            goodPointTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 0, Main_Screen_Width-50, 60)];
            goodPointTextView.font = [UIFont systemFontOfSize:14.];
            goodPointTextView.delegate = self;
            goodPointTextView.alpha = 0.5;
            goodPointTextView.tag = 101;
            goodPointTextView.text = @"请输入作业精彩点";
            [messege addSubview:goodPointTextView];
            //不足
            UIImageView * imageBad = [[UIImageView alloc] initWithFrame:CGRectMake(10, 220, 30, 30)];
            imageBad.image = [UIImage imageNamed:@"wenziLiuyan.png"];
            [cell.contentView addSubview:imageBad];
            
            UILabel * bad = [[UILabel alloc] initWithFrame:CGRectMake(45, 225, 100, 20)];
            bad.text = @"可改善之处";
            bad.alpha = 0.7;
            [cell.contentView addSubview:bad];
            
            UIView * messegeBad = [[UIView alloc] initWithFrame:CGRectMake(10, 250, Main_Screen_Width-40, 60)];
            [messegeBad.layer setBorderColor:[[UIColor grayColor] CGColor]];
            [messegeBad.layer setBorderWidth:1];
            [cell.contentView addSubview:messegeBad];
            
            badPointTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 0, Main_Screen_Width-50, 60)];
            badPointTextView.font = [UIFont systemFontOfSize:14.];
            badPointTextView.delegate = self;
            badPointTextView.alpha = 0.5;
            badPointTextView.tag = 102;
            badPointTextView.text = @"请输入作业不足之处";
            [messegeBad addSubview:badPointTextView];

            UIButton * commitBt = [[UIButton alloc] initWithFrame:CGRectMake(10, 330, Main_Screen_Width-40, 60)];
            [commitBt setImage:[UIImage imageNamed:@"xianXiPiYue.png"] forState:UIControlStateNormal];
            [commitBt addTarget:self action:@selector(commitResource) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:commitBt];
        }else//显示评语
        {
            
            //老师评语
            float PingYuHeight = 0;
            float markBadHeight = 0;
            UIImageView * imagePingYu = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
            imagePingYu.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",@"laoshiPingyu.png"]];
            [cell.contentView addSubview:imagePingYu];
            
            UILabel * lable2 = [[UILabel alloc] initWithFrame:CGRectMake(50, 10,Main_Screen_Width-80, 30)];
            lable2.text = @"老师评语";
            [cell.contentView addSubview:lable2];
            
            if(![teacherRemarkDic isKindOfClass:[NSNull class]])
            {
                if ([[teacherRemarkDic objectForKey:@"rate"] isKindOfClass:[NSNull class]]) {
                    UIImageView * image = [[UIImageView alloc]initWithFrame:CGRectMake(Main_Screen_Width-110, 10, 70,28 ) ];
                    image.image = [UIImage imageNamed:@"weiYue.png"];
                    [cell.contentView addSubview:image];
                }else{
                    UIButton * rateBUtton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    rateBUtton.frame = CGRectMake(Main_Screen_Width-110,10, 70,28 );
                    rateBUtton.layer.cornerRadius = 15 ;
                    rateBUtton.userInteractionEnabled = NO;
                    [rateBUtton setTitle:[publicRequest rateTostring:[teacherRemarkDic objectForKey:@"rate"]] forState:UIControlStateNormal];
                    rateBUtton.backgroundColor = [UIColor colorWithRed:76/255. green:197/255. blue:36/255. alpha:1.];
                    [rateBUtton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    rateBUtton.titleLabel.font = [UIFont systemFontOfSize:16.];
                    [cell.contentView addSubview:rateBUtton];
                }
            }
            if ([[teacherRemarkDic objectForKey:@"remark"] isKindOfClass:[NSNull class]]) {
                
            }else {
                NSString *markGood;
                NSString *markBad;
                NSRange range1Start = [[teacherRemarkDic objectForKey:@"remark"] rangeOfString:@"精彩点:"];
                NSRange range2Start = [[teacherRemarkDic objectForKey:@"remark"] rangeOfString:@"可改善之处:"];
                
                if (range1Start.location!=NSNotFound &&range2Start.location!=NSNotFound){
                    
                    markGood = [[teacherRemarkDic objectForKey:@"remark"] substringWithRange:NSMakeRange(range1Start.location+4, range2Start.location-4)];
                    
                    markBad = [[teacherRemarkDic objectForKey:@"remark"] substringFromIndex:range2Start.location+6];
                }else if(range1Start.location!=NSNotFound &&range2Start.location == NSNotFound)
                {
                    markGood = [[teacherRemarkDic objectForKey:@"remark"] substringFromIndex:range1Start.location+4] ;
                    
                }else if (range1Start.location==NSNotFound &&range2Start.location != NSNotFound)
                {
                    markBad = [[teacherRemarkDic objectForKey:@"remark"] substringFromIndex:range2Start.location+6];
                }
                
                if (markGood.length>0) {
                     PingYuHeight  = [publicRequest lableSizeWidth:Main_Screen_Width-90 content:markGood] ;
                    UILabel * PingYuLable = [[UILabel alloc] initWithFrame:CGRectMake(50,40 , Main_Screen_Width-40-50,PingYuHeight)];
                    PingYuLable.text =[NSString stringWithFormat:@"精彩点：%@",markGood];
                    PingYuLable.lineBreakMode = NSLineBreakByWordWrapping;
                    PingYuLable.numberOfLines = 0;
                    PingYuLable.font = [UIFont systemFontOfSize:14.];
                    PingYuLable.alpha = 0.5 ;
                    [cell.contentView addSubview:PingYuLable];
                }
                if (markBad.length >0) {
                    markBadHeight =[publicRequest lableSizeWidth:Main_Screen_Width-90 content:markBad] ;
                    UILabel * badLable = [[UILabel alloc] initWithFrame:CGRectMake(50,40+PingYuHeight , Main_Screen_Width-40-50,markBadHeight)];
                    badLable.text = [NSString stringWithFormat:@"可改善之处：%@",markBad];
                    badLable.lineBreakMode = NSLineBreakByWordWrapping;
                    badLable.numberOfLines = 0;
                    badLable.font = [UIFont systemFontOfSize:14.];
                    badLable.alpha = 0.5 ;
                    [cell.contentView addSubview:badLable];
                    
              }
            }
            //老师语音留言
            UIImageView * imageYuYin = [[UIImageView alloc] initWithFrame:CGRectMake(10,40+PingYuHeight +markBadHeight+5, 30, 30)];
            imageYuYin.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",@"yuyinLiuyan.png"]];
            [cell.contentView addSubview:imageYuYin];
            
            UILabel * lable3 = [[UILabel alloc] initWithFrame:CGRectMake(50,10 + PingYuHeight +35+markBadHeight ,Main_Screen_Width-40 -50, 30)];
            lable3.text = @"老师语音留言";
            [cell.contentView addSubview:lable3];
            
            if (teachermarkMp3Str.length > 0) {
                
                UIView * View = [[UIView alloc] initWithFrame:CGRectMake(10,10+PingYuHeight+markBadHeight +35+35, Main_Screen_Width-40, 100)];
                View.backgroundColor = [UIColor colorWithRed:235/255. green:235/255. blue:235/255. alpha:1.];
                [cell.contentView addSubview:View];
                
                self.RemarkplayMusicButton = [[UIButton alloc] initWithFrame:CGRectMake(View.frame.size.width/2-30, 15, 60, 60)];
                [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
                [self.RemarkplayMusicButton addTarget:self action:@selector(playRemarkMusic:) forControlEvents:UIControlEventTouchUpInside];
                [View addSubview:self.RemarkplayMusicButton];
                
            }
        }
    
    }
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section ==1) {
        if ([[homeWorkDic objectForKey:@"state"] isEqualToString:@"init"]) {
            return 410;
        }
        int remarkHeight = 0;
        if (teachermarkMp3Str.length >0) {
            remarkHeight = 90 ;
        }
        
        float  PingYuHeight  = [publicRequest lableSizeWidth:Main_Screen_Width-90 content:[teacherRemarkDic objectForKey:@"remark"]] ;
        return  100+PingYuHeight+remarkHeight;
    }
    int  imageheight = 0 ;
    int  mp3Height = 0 ;
    int  mp4Height = 0 ;
    if (imageUrlArr.count>0)
        imageheight = 110 ;
    if (mp3UrlArr.count >0)
        mp3Height = 125;
    if(mp4UrlArr.count > 0)
        mp4Height = 105;
    float titleLableSizeHeight= [publicRequest lableSizeWidth:Main_Screen_Width-40 content:[homeWorkDic objectForKey:@"title"]] ;
    float contentLableSizeHeight= [publicRequest lableSizeWidth:Main_Screen_Width-40 content:[homeWorkDic objectForKey:@"description"]] ;
    
    return 80+titleLableSizeHeight+contentLableSizeHeight+mp3Height +imageheight + mp4Height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    [goodPointTextView resignFirstResponder];
    [badPointTextView resignFirstResponder];
}

- ( CGFloat )tableView:( UITableView *)tableView heightForHeaderInSection:( NSInteger )section

{  if(section ==0 )
    return 0;
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

-(void)rateChoose:(UIButton *)sender
{
    rateArr = [[NSArray alloc] init];
    rateArr = [NSArray arrayWithObjects:@"E", @"D", @"C", @"B", @"A", nil];
    if(dropDown == nil) {
        CGFloat f = 150;
        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :rateArr];
        dropDown.delegate = self;
    }
    else {
        [dropDown hideDropDown:sender];
        dropDown = nil;
    }
}

- (void) niDropDownDelegateMethod: (NSString *) rateString rateInt:(int)rateInt {
    [rateBt setTitle:[NSString stringWithFormat:@"评分: %@",rateString]forState:UIControlStateNormal];
    dropDown = nil;
    rate = 0 ;
    rate = rateInt;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.tag ==101) {
        
        if ( [goodPointTextView.text isEqualToString:@"请输入作业精彩点"]) {
            goodPointTextView.text = @"";
        }
    }else
    {
        if ( [badPointTextView.text isEqualToString:@"请输入作业不足之处"]) {
            badPointTextView.text = @"";
        }
    }
    int offset = 216.0- 64;//键盘高度216
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
     self.view.frame =CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
    return YES;
}
#pragma mark - palyrecord

-(void)record:(UIButton *)sender
{
    if(!self.isRecording)
    {
        if ([_streamer isPlaying]) {
            [_streamer pause];
            [self.playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        }
        stopTimer = [NSTimer scheduledTimerWithTimeInterval:180 target:self selector:@selector(stoprecord) userInfo:nil repeats:NO];
        shortTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(shortTime) userInfo:nil repeats:NO];
        shortTime = 0;
        
        NSLog(@"正在录音......");
        session = [AVAudioSession sharedInstance];
        //        session.delegate = self;
        NSError *sessionError;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        if(session == nil)
            NSLog(@"Error creating session: %@", [sessionError description]);
        else
            [session setActive:YES error:nil];
        //录音设置
        NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
        //录音格式 无法使用
        [settings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
        //采样率
        [settings setValue :[NSNumber numberWithFloat:22050.0] forKey: AVSampleRateKey];//44100.0
        //通道数
        [settings setValue :[NSNumber numberWithInt:2] forKey: AVNumberOfChannelsKey];
        //线性采样位数
        [settings setValue :[NSNumber numberWithInt:16] forKey: AVLinearPCMBitDepthKey];
        //音频质量,采样质量
        [settings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
        
        self.isRecording = YES;
        [self.recordButton setImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateNormal];
        [self.playRecord setEnabled:NO];
        
        recorder = [[AVAudioRecorder alloc] initWithURL:recordedFile settings:nil error:nil];
        [recorder prepareToRecord];
        [recorder record];
        player = nil;
        
    }
    else
    {
        [self stoprecord];
    }
}
    
-(void)shortTime
{
    shortTime = 1;
    [stopTimer invalidate];
    stopTimer=nil;
}
    
-(void)stoprecord
{
    //取消录音
    if (shortTime ==1) {
        NSLog(@"录音结束......");
        self.isRecording = NO;
        record = YES;
        [self.recordButton setImage:[UIImage imageNamed:@"voice.png"] forState:UIControlStateNormal];
        [self.playRecord setEnabled:YES];
        self.isRecording = NO;
        [recorder stop];
        if (recorder) {
            recorder = nil;
            AVAudioSession * audioSession = [AVAudioSession sharedInstance];
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: nil];
            
            UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
            AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
            AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
            NSError *playerError;
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:recordedFile error:&playerError];
            if (player == nil)
            {
                NSLog(@"ERror creating player: %@", [playerError description]);
            }
            player.delegate = self;
        }
        
    }else
    {
        [stopTimer invalidate];
        stopTimer=nil;
        
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.labelText = @"录制时间少于4秒请重新录制";
        [HUD hide:YES afterDelay:1];
        [self.playButton setEnabled:NO];
        [self.recordButton setImage:[UIImage imageNamed:@"voice.png"] forState:UIControlStateNormal];
        [recorder stop];
        self.isRecording = NO;
    }
}

-(void)playRecord:(UIButton *)sender
{
    if([player isPlaying])
    {
        [player pause];
        [self.recordButton setEnabled:YES];
        [self.playRecord setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        
    }else
    {
        if ([_streamer isPlaying]) {
            [_streamer pause];
            [self.playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        }
        if ([_RemarkStreamer isPlaying]) {
            [_RemarkStreamer pause];
            [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        }
        [player play];
        [self.recordButton setEnabled:NO];
        [self.playRecord setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.recordButton setEnabled:YES];
     self.player = nil;
    [self.playRecord setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
}

- ( BOOL )audio_PCMtoMP3
{
    NSString *cafFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/downloadFile.caf"];
    mp3FilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/downloadFile.mp3"];
    NSFileManager* fileManager=[NSFileManager defaultManager];
    if([fileManager removeItemAtPath:mp3FilePath error:nil])
    {
        NSLog(@"已经删除caf ");
    }
    @try {
        int read, write;
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 22050.0);
        lame_set_VBR(lame, vbr_default);
        
        lame_init_params(lame);
        // mp3压缩参数
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    return YES;
}
    
    
#pragma mark -palyPaperWork
-(void)playMusic:(UIButton * )sender
{
    if (!_streamer) {
        self.streamer = [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:[mp3UrlArr objectAtIndex:0]]];
         _progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playbackStateChanged:)
                                                     name:ASStatusChangedNotification
                                                   object:_streamer];
    }
    if (![_streamer isPlaying]) {
        if ([_RemarkStreamer isPlaying]) {
            [_RemarkStreamer pause];
            [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        }
        [_streamer start];
        
        [playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        
    }
    else {
        [_streamer pause];
        [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }
}

- (void)playbackStateChanged:(NSNotification *)notification
{
    if ([_streamer isWaiting])
    {
        [playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        
    } else if ([_streamer isIdle]) {
        [_streamer stop];
        _streamer = nil;
        // remove notification observer for streamer
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:ASStatusChangedNotification
                                                      object:_streamer];
        
        [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        
    } else if ([_streamer isPaused]) {
        //        [_streamer pause];
        [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        
    } else if ([_streamer isPlaying] || [_streamer isFinishing]) {
        
        [playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        
    } else {
        
    }
    
}

-(void)update
{
    self.progressSlider.value = (_streamer.progress/_streamer.duration)*100;
    if (_streamer.progress <= _streamer.duration ) {
        int allMin = (int)_streamer.duration/60;
        int allSec = (int)_streamer.duration%60;
        timeLable.text = [NSString stringWithFormat:@"%d:%d",allMin,allSec];
    }
}

-(void)seek
{
    double seekPoint = self.progressSlider.value;
    [_streamer seekToTime:seekPoint];
}



//play  remark liuyan
///---------------------------------------
-(void)playRemarkMusic:(UIButton * )sender
{
    
    if (!_RemarkStreamer) {
        _RemarkStreamer= [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:teachermarkMp3Str]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playRemarkbackStateChanged:)
                                                     name:ASStatusChangedNotification
                                                   object:_RemarkStreamer];
    }
    if (![_RemarkStreamer isPlaying]) {
        [_RemarkStreamer start];
        
        [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        
        if ([_streamer isPlaying]) {
            [_streamer pause];
            [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        }
    }
    else {
        [_RemarkStreamer pause];
        [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }
}

- (void)playRemarkbackStateChanged:(NSNotification *)notification
{
    if ([_RemarkStreamer isWaiting])
    {
        [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        
    } else if ([_RemarkStreamer isIdle]) {
        [_RemarkStreamer stop];
        _RemarkStreamer = nil;
        // remove notification observer for streamer
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:ASStatusChangedNotification
                                                      object:_RemarkStreamer];
        
        [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        
    } else if ([_RemarkStreamer isPaused]) {
        //        [_streamer pause];
        [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        
    } else if ([_RemarkStreamer isPlaying] || [_RemarkStreamer isFinishing]) {
        
        [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        
    } else {
        
    }
    
}


-(UIView *)drawPlayViewY:(int)y
{
    UIView * playView = [[UIView alloc] initWithFrame:CGRectMake(10,y, Main_Screen_Width-40, 100)];
    playView.backgroundColor = [UIColor colorWithRed:235/255. green:235/255. blue:235/255. alpha:1.];
    
    UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(playView.frame.size.width/2-50, 5, 100, 20)];
    titleLable.textColor = [UIColor greenColor];
    titleLable.text = @"课间试听";
    titleLable.font = [UIFont systemFontOfSize:14.];
    titleLable.textAlignment = NSTextAlignmentCenter;
    [playView addSubview:titleLable];
    
    playButton = [[UIButton alloc] initWithFrame:CGRectMake(playView.frame.size.width/2-25, 30, 60, 60)];
    [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    playButton.tag = 1;
    [playButton addTarget:self action:@selector(playMusic:) forControlEvents:UIControlEventTouchUpInside];
    [playView addSubview:playButton];
    
    
    UIButton *leftBt = [[UIButton alloc] initWithFrame:CGRectMake(playView.frame.size.width/2 -80, 40, 40, 40)];
    leftBt.tag =2 ;
    [leftBt setImage:[UIImage imageNamed:@"left.png"] forState:UIControlStateNormal];
    [leftBt addTarget:self action:@selector(playMusic:) forControlEvents:UIControlEventTouchUpInside];
    [playView addSubview:leftBt];
    
    UIButton *rightBt = [[UIButton alloc] initWithFrame:CGRectMake(playView.frame.size.width/2 +50, 40, 40, 40)];
    rightBt.tag =3 ;
    [rightBt setImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
    [rightBt addTarget:self action:@selector(playMusic:) forControlEvents:UIControlEventTouchUpInside];
    [playView addSubview:rightBt];
    
    return playView;
}

- (void) tapImage:(UITapGestureRecognizer *)tap
{
    int count = imageUrlArr.count;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        NSString *url = [imageUrlArr[i] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:url]; // 图片路径
        //        photo.srcImageView = imageViewArr[i]; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = tap.view.tag; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}


#pragma mark- playVideo

-(void)initMpMOviePlayerPapers:( UIButton  *)sender
{
    [_streamer pause];
    [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    if ([_RemarkStreamer isPlaying]) {
        [_RemarkStreamer pause];
        [self.RemarkplayMusicButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }
    
    MPMoviePlayerViewController  *moviePlayer =[[ MPMoviePlayerViewController alloc ]  initWithContentURL :[NSURL URLWithString:[mp4UrlArr objectAtIndex:sender.tag]]];
    [self createMPPlayerController:moviePlayer];
}

- ( void )createMPPlayerController:( MPMoviePlayerViewController  *)moviePlayer {
    [moviePlayer. moviePlayer   prepareToPlay ];
    [ self   presentMoviePlayerViewControllerAnimated :moviePlayer]; // 这里是presentMoviePlayerViewControllerAnimated
    
    [moviePlayer. moviePlayer   setControlStyle : MPMovieControlStyleFullscreen ];
    
    [moviePlayer. view   setBackgroundColor :[ UIColor   clearColor ]];
    
    [moviePlayer. view   setFrame : self . view . bounds ];
    
    [[ NSNotificationCenter   defaultCenter ]  addObserver : self
     
                                                  selector : @selector (movieFinishedCallback:)
     
                                                      name : MPMoviePlayerPlaybackDidFinishNotification
     
                                                    object :moviePlayer. moviePlayer ];
    
    
}

-( void )movieStateChangeCallback:( NSNotification *)notify  {
    
    //点击播放器中的播放/ 暂停按钮响应的通知
}

-( void )movieFinishedCallback:( NSNotification *)notify{
    
    // 视频播放完或者在presentMoviePlayerViewControllerAnimated下的Done按钮被点击响应的通知。
    
    MPMoviePlayerController * theMovie = [notify  object ];
    
    [[ NSNotificationCenter   defaultCenter ]  removeObserver : self
     
                                                         name : MPMoviePlayerPlaybackDidFinishNotification
     
                                                       object :theMovie];
    
    [ self   dismissMoviePlayerViewControllerAnimated ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
