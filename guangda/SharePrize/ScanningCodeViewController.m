//
//  ScanningCodeViewController.m
//  guangda
//
//  Created by Ray on 15/7/17.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "ScanningCodeViewController.h"
#import "ZBarSDK.h"
#define ZBarOrientationMaskAll \
(ZBarOrientationMask(UIInterfaceOrientationPortrait) | \
ZBarOrientationMask(UIInterfaceOrientationPortraitUpsideDown) | \
ZBarOrientationMask(UIInterfaceOrientationLandscapeLeft) | \
ZBarOrientationMask(UIInterfaceOrientationLandscapeRight))

@interface ScanningCodeViewController ()<ZBarReaderViewDelegate,ZBarReaderDelegate>
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
    UIImageView * line;
    UIImageView * centerImageView;
    ZBarReaderView *readerView;
    ZBarCameraSimulator *cameraSim;
    UIImageView *resultImage;
    UITextView *resultText;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *codeLabel;
@property (strong, nonatomic) IBOutlet UIView *headView;

@end

@implementation ScanningCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    //以下是绘制一个ZBarReader的整个过程，这里遇到许多的问题，值得深究。+——————————————————————————————————————————————————————————————————————————————————————————————
    //中间的框框，四角
    //    CGRect rect = [[UIScreen mainScreen] bounds];
    CGRect imageViewRect = self.imageView.frame;
    centerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(35, 93, imageViewRect.size.width-10, imageViewRect.size.height-10)];
    centerImageView.image = [UIImage imageNamed:@"Bar code scanning"];
    self.view.backgroundColor = [UIColor blackColor];
    
    upOrdown = NO;
    num =0;
    line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageViewRect.size.width-10, 4)];
    line.image = [UIImage imageNamed:@"scanning line"];
    
    //这里用于设置line走完整个框框的时间。
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(scanningAnimation) userInfo:nil repeats:YES];
    readerView = [[ZBarReaderView alloc]init];
    
    readerView.frame =self.view.frame;
    
    readerView.readerDelegate = self;
    //关闭闪光灯
    readerView.torchMode = 0;
    //扫描区域
    CGRect scanMaskRect = CGRectMake(0,64, readerView.frame.size.width, readerView.frame.size.height);
    
    //处理模拟器
    if (TARGET_IPHONE_SIMULATOR) {
        ZBarCameraSimulator *cameraSimulator
        = [[ZBarCameraSimulator alloc]initWithViewController:self];
        cameraSimulator.readerView = readerView;
    }
    [self.view addSubview:readerView];
    //扫描区域计算
    readerView.scanCrop = [self getScanCrop:scanMaskRect readerViewBounds:readerView.bounds];
    
    [readerView start];
    [centerImageView addSubview:line];
    //imageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:centerImageView];
    //imageView.alpha=0.8;
    //imageView.layer.borderColor = [UIColor redColor].CGColor;
    //imageView.layer.borderWidth=2.0;
    //[self.view bringSubviewToFront:line];
    
    
    //以下是用于使二维码扫描的样式更加美观，提升用户体验
    UIView* maskViewUp =[[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, centerImageView.frame.origin.y)];
    
    [maskViewUp setBackgroundColor:[UIColor blackColor]];
    
    maskViewUp.alpha= 0.4;
    
    
    
    UIView* maskViewDown =[[UIView alloc]initWithFrame:CGRectMake(0,centerImageView.frame.origin.y+centerImageView.frame.size.height,self.view.frame.size.width,self.view.frame.size.height-centerImageView.frame.origin.y-centerImageView.frame.size.height)];
    
    [maskViewDown setBackgroundColor:[UIColor blackColor]];
    
    maskViewDown.alpha= 0.4;
    
    
    
    UIView* maskViewLeft =[[UIView alloc]initWithFrame:CGRectMake(0,centerImageView.frame.origin.y,centerImageView.frame.origin.x,centerImageView.frame.size.height)];
    
    [maskViewLeft setBackgroundColor:[UIColor blackColor]];
    
    maskViewLeft.alpha= 0.4;
    
    
    
    UIView* maskViewRight =[[UIView alloc]initWithFrame:CGRectMake(centerImageView.frame.origin.x+centerImageView.frame.size.width, centerImageView.frame.origin.y, self.view.frame.size.width-centerImageView.frame.origin.x-centerImageView.frame.size.width, centerImageView.frame.size.height)];
    
    [maskViewRight setBackgroundColor:[UIColor blackColor]];
    
    maskViewRight.alpha= 0.4;
    
    
    [self.view addSubview:maskViewUp];
    
    [self.view addSubview:maskViewDown];
    
    [self.view addSubview:maskViewLeft];
    
    [self.view addSubview:maskViewRight];
    
    
    [self.view bringSubviewToFront:self.headView];
    [self.view bringSubviewToFront:self.codeLabel];
    [self.view bringSubviewToFront:self.imageView];
}

-(CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds
{
    CGFloat x,y,width,height;
    
    x = rect.origin.x / readerViewBounds.size.width;
    y = rect.origin.y / readerViewBounds.size.height;
    width = rect.size.width / readerViewBounds.size.width;
    height = rect.size.height / readerViewBounds.size.height;
    
    return CGRectMake(x, y, width, height);
}

- (void)readerView:(ZBarReaderView *)theReaderView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{
    for (ZBarSymbol *symbol in symbols) {
        NSLog(@"%@", symbol.data);
        self.codeLabel.text = symbol.data;
        
        break;
        
    }
}

-(void)scanningAnimation
{
//    if (upOrdown == NO) {
    num ++;
    int lineHeight=2;
    line.frame = CGRectMake(0, lineHeight*num, centerImageView.frame.size.width, lineHeight);
    if (lineHeight*num >= centerImageView.frame.size.height-lineHeight) {
        num=0;
//        upOrdown = YES;
    }
}

- (IBAction)redBarCodeFromLib:(id)sender {
    
    ZBarReaderController *reader = [ZBarReaderController new];
    reader.readerDelegate = self;
    reader.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; // Set ZbarReaderController point to the local album
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    [self presentViewController:reader animated:YES completion:nil];
}

- (void) imagePickerController: (UIImagePickerController *) reader
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    self.codeLabel.text = symbol.data;
    self.imageView.image = [info objectForKey: UIImagePickerControllerOriginalImage];
    [self.view bringSubviewToFront:self.imageView];
    [reader dismissViewControllerAnimated:NO completion:nil];
    
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) orient
{
    return(NO);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
