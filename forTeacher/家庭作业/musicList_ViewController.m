//
//  musicList_ViewController.m
//  afterShoolForTeacher
//
//  Created by susu on 15/4/22.
//  Copyright (c) 2015年 susu. All rights reserved.
//

#import "musicList_ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>
//#import "TSLibraryImport.h"x
@interface musicList_ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView * classTableView;
@property (nonatomic,retain) NSMutableArray *items;         //存放本地歌曲
@property (nonatomic,retain) MPMusicPlayerController *mpc;
@end

@implementation musicList_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationItem.title = @"音频列表";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    self.edgesForExtendedLayout = UIRectEdgeNone;
  
    self.items = [NSMutableArray array];
         //监听歌曲播放完成的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil];
//       [self chooseMp3];

    
    
//    [progressView setProgress:0.f];
//    
//    AVAudioSession* session = [AVAudioSession sharedInstance];
//    NSError* error = nil;
//    if(![session setCategory:AVAudioSessionCategoryPlayback error:&error]) {
//        NSLog(@"Couldn't set audio session category: %@", error);
//    }
//    if(![session setActive:YES error:&error]) {
//        NSLog(@"Couldn't make audio session active: %@", error);
//    }
}
//
//- (void)progressTimer:(NSTimer*)timer {
//    TSLibraryImport* export = (TSLibraryImport*)timer.userInfo;
//    switch (export.status) {
//        case AVAssetExportSessionStatusExporting:
//        {
//            NSTimeInterval delta = [NSDate timeIntervalSinceReferenceDate] - startTime;
//            float minutes = rintf(delta/60.f);
//            float seconds = rintf(fmodf(delta, 60.f));
//            [elapsedLabel setText:[NSString stringWithFormat:@"%2.0f:%02.0f", minutes, seconds]];
//            [progressView setProgress:export.progress];
//            break;
//        }
//        case AVAssetExportSessionStatusCancelled:
//        case AVAssetExportSessionStatusCompleted:
//        case AVAssetExportSessionStatusFailed:
//            [timer invalidate];
//            break;
//        default:
//            break;
//    }
//}
//
//- (void)exportAssetAtURL:(NSURL*)assetURL withTitle:(NSString*)title {
//    
//    // create destination URL
//    NSString* ext = [TSLibraryImport extensionForAssetURL:assetURL];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSURL* outURL = [[NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:title]] URLByAppendingPathExtension:ext];
//    // we're responsible for making sure the destination url doesn't already exist
//    [[NSFileManager defaultManager] removeItemAtURL:outURL error:nil];
//    
//    // create the import object
//    TSLibraryImport* import = [[TSLibraryImport alloc] init];
//    startTime = [NSDate timeIntervalSinceReferenceDate];
//    NSTimer* timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(progressTimer:) userInfo:import repeats:YES];
//    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
//    [import importAsset:assetURL toURL:outURL completionBlock:^(TSLibraryImport* import) {
//        /*
//         * If the export was successful (check the status and error properties of
//         * the TSLibraryImport instance) you know have a local copy of the file
//         * at `outURL` You can get PCM samples for processing by opening it with
//         * ExtAudioFile. Yay!
//         *
//         * Here we're just playing it with AVPlayer
//         */
//        if (import.status != AVAssetExportSessionStatusCompleted) {
//            // something went wrong with the import
//            NSLog(@"Error importing: %@", import.error);
//            [import release];
//            import = nil;
//            return;
//        }
//        
//        // import completed
//        [import release];
//        import = nil;
//        if (!player) {
//            player = [[AVPlayer alloc] initWithURL:outURL];
//        } else {
//            [player pause];
//            [player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:outURL]];
//        }
//        [player play];
//    }];
//}
//
//- (void)mediaPicker:(MPMediaPickerController *)mediaPicker
//  didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
//    [self dismissModalViewControllerAnimated:YES];
//    for (MPMediaItem* item in mediaItemCollection.items) {
//        NSString* title = [item valueForProperty:MPMediaItemPropertyTitle];
//        NSURL* assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
//        if (nil == assetURL) {
//            /**
//             * !!!: When MPMediaItemPropertyAssetURL is nil, it typically means the file
//             * in question is protected by DRM. (old m4p files)
//             */
//            return;
//        }
//        [self exportAssetAtURL:assetURL withTitle:title];
//    }
//}
//
//- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
//    [self dismissModalViewControllerAnimated:YES];
//}
//
//- (void)didReceiveMemoryWarning {
//    // Releases the view if it doesn't have a superview.
//    [super didReceiveMemoryWarning];
//    
//    // Release any cached data, images, etc that aren't in use.
//}
//
//- (void)viewDidUnload {
//    // Release any retained subviews of the main view.
//    // e.g. self.myOutlet = nil;
//}
//
//- (void)showMediaPicker {
//    /*
//     * ???: Can we filter the media picker so we don't see m4p files?
//     */
//    MPMediaPickerController* mediaPicker = [[[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic] autorelease];
//    mediaPicker.delegate = self;
//    [self presentModalViewController:mediaPicker animated:YES];
//}
//
//- (IBAction)pickSong:(id)sender {
//    [self showMediaPicker];
//}
//
//-(void)initTableView
//{
//    UIView *view = [UIView new];
//    view.backgroundColor = [UIColor clearColor];
//    self.classTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width-20,Main_Screen_Height-64-59)style:UITableViewStylePlain];
//    self.classTableView.backgroundColor = [UIColor colorWithRed:247/255. green:247/255. blue:247/255. alpha:1.];
//    self.classTableView.layer.cornerRadius = 8 ;
//    self.classTableView.delegate =self;
//    self.classTableView.dataSource = self;
//    [self.classTableView setTableFooterView:view];
//    [self.view addSubview: self.classTableView];
//}
//
//-(void)reload{
//   //音乐播放完成刷新table
//    [self.classTableView reloadData];
//}
//
//-(void)chooseMp3
//{
//    //获得query，用于请求本地歌曲集合
//    MPMediaQuery *query = [MPMediaQuery songsQuery];
//    //循环获取得到query获得的集合
//    for (MPMediaItemCollection *conllection in query.collections) {
//        //MPMediaItem为歌曲项，包含歌曲信息
//        for (MPMediaItem *item in conllection.items) {
//            [self.items addObject:item];
//        }
//    }
//    //通过歌曲items数组创建一个collection
//    MPMediaItemCollection *mic = [[MPMediaItemCollection alloc] initWithItems:self.items];
//    //获得应用播放器
//    self.mpc = [MPMusicPlayerController applicationMusicPlayer];
//    //开启播放通知，不开启，不会发送歌曲完成，音量改变的通知
//    [self.mpc beginGeneratingPlaybackNotifications];
//    //设置播放的集合
//    [self.mpc setQueueWithItemCollection:mic];
//    
//      [self initTableView];
//}
//
//
//
//#pragma mark - Table view data source
//
// - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
// {
//         return self.items.count;
//     }
//
// - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
// {
//     
//     static NSString *tableSampleIdentifier = @"TableSampleIdentifier";
//     UITableViewCell * cell =  [tableView dequeueReusableCellWithIdentifier:tableSampleIdentifier];
//     [cell removeFromSuperview];
//     if (cell ==nil) {
//         
//         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableSampleIdentifier];
//     }else
//     {
//         [cell removeFromSuperview];
//         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableSampleIdentifier];
//     }
//
//     MPMediaItem *item = self.items[indexPath.row];
//     //获得专辑对象
//     MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
//    //专辑封面
//     UIImage *img = [artwork imageWithSize:CGSizeMake(100, 100)];
//     if (!img) {
//             img = [UIImage imageNamed:@"musicImage.png"];
//        }
//     cell.imageView.image = img;
//     cell.textLabel.text = [item valueForProperty:MPMediaItemPropertyTitle];         //歌曲名称
//     cell.detailTextLabel.text = [item valueForProperty:MPMediaItemPropertyArtist];  //歌手名称
//     if (self.mpc.nowPlayingItem == self.items[indexPath.row]) {
//             cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//         }else{
//                 cell.accessoryType = UITableViewCellAccessoryNone;
//             }
//
//
//     return cell;
//}
//
//
// #pragma mark - Table view delegate
//
// - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
// {
//         [self.classTableView deselectRowAtIndexPath:indexPath animated:NO];
//         //设置播放选中的歌曲
//         [self.mpc setNowPlayingItem:self.items[indexPath.row]];
//         [self.mpc play];
//    
//         [self.classTableView reloadData];
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

@end
