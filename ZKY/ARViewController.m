//
//  ARViewController.m
//  ZKY
//
//  Created by tongji on 1/18/14.
//  Copyright (c) 2014 tongji. All rights reserved.
//

#import "ARViewController.h"
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSInteger, myCameraMode)
{
    backCameraMode,
    frontCameraMode
};

@interface ARViewController ()

@end

@implementation ARViewController

@synthesize arview;
@synthesize takePhotoButton,switchCameraBotton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //preparation
    cameraMode = backCameraMode;
    takePhotoButton.hidden = YES;
    
    //shake
    [[UIApplication sharedApplication]setApplicationSupportsShakeToEdit:YES];
    [self becomeFirstResponder];
    
    //load plist of coordinates
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *plistURL = [bundle URLForResource:@"POI" withExtension:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    NSMutableArray *tmpDataArray = [[NSMutableArray alloc] init];
    for (int j=0; j<[dictionary count]; j++) {
        NSString *key = [[NSString alloc] initWithFormat:@"%i", j];
        NSDictionary *tmpDic = [dictionary objectForKey:key];
        [tmpDataArray addObject:tmpDic];
    }
    poiData = [tmpDataArray copy];
    NSUInteger numPois = [poiData count];
    
	NSMutableArray *POIs = [NSMutableArray arrayWithCapacity:numPois];
	for (int i = 0; i < numPois; i++) {
        
        UIImage *ImageName = [UIImage imageNamed:[[poiData objectAtIndex:i] objectForKey:@"image"]];
        //直接以图片大小为基础，调整scale比列传入POIview中
        float scale = 1.5;
        CGRect imageRect = CGRectMake(0, 0, ImageName.size.width/scale, ImageName.size.height/scale);
        
        if (ImageName.size.height>200) {
            imageRect=CGRectMake(0, 160, ImageName.size.width/scale, ImageName.size.height/scale);
        }
        
        POIview *poiview = [[POIview alloc] initWithFrame:imageRect];
        poiview.POItitle.text = [[poiData objectAtIndex:i] objectForKey:@"name"];
        [poiview.POIback setImage:ImageName];

        CGPoint poiPoint = {[[[poiData objectAtIndex:i] objectForKey:@"x"] floatValue]+100,
                            [[[poiData objectAtIndex:i] objectForKey:@"y"] floatValue]+80};
        
		POI *poi = [POI POIWithView:poiview at:poiPoint belongtoArray:[[poiData objectAtIndex:i] objectForKey:@"belongto"]];
        
		[POIs insertObject:poi atIndex:i];
	}
    
    /**
     * MOV
     **/
//    CGRect movFrame = CGRectMake(0,0,320,280);
//    CGPoint movPoint = {40,750};
//    MOVview *movView = [[MOVview alloc] initWithFrame:movFrame];
//    [movView setBackgroundColor:[UIColor clearColor]];
//    
//    POI *mov1 = [POI POIWithView:movView at:movPoint belongto:4];
//    [POIs insertObject:mov1 atIndex:numPois];
    
    /**
     * GIF
     **/
    
    /**first point**/
    CGRect frame = CGRectMake(0,0,70,70);
    frame.size = [UIImage imageNamed:@"xingxing1.gif"].size;
    GIFview *gifview1_1 = [[GIFview alloc] initWithFrame:frame withGifName:@"xingxing1"];
    CGPoint gifPoint1 = {474,380};
    
    NSArray *gifBelongtoArray1 = [NSArray arrayWithObjects: [NSNumber numberWithInt:1], nil];
    POI *gif1_1 = [POI POIWithView:gifview1_1 at:gifPoint1 belongtoArray:gifBelongtoArray1 shakedOrNot:NO];
    [POIs insertObject:gif1_1 atIndex:numPois];
    
    
    frame.size = [UIImage imageNamed:@"xingxing2.gif"].size;
    GIFview *gifview1_2 = [[GIFview alloc] initWithFrame:frame withGifName:@"xingxing2"];
    
    POI *gif1_2 = [POI POIWithView:gifview1_2 at:gifPoint1 belongtoArray:gifBelongtoArray1 shakedOrNot:YES];
    [POIs insertObject:gif1_2 atIndex:numPois+1];
    
    /**second point**/
    frame.size = [UIImage imageNamed:@"cook.gif"].size;
    GIFview *gifview2_1 = [[GIFview alloc] initWithFrame:frame withGifName:@"cook"];
    CGPoint gifPoint2 = {82,275};
    
    NSArray *gifBelongtoArray2 = [NSArray arrayWithObjects: [NSNumber numberWithInt:2], nil];
    POI *gif2_1 = [POI POIWithView:gifview2_1 at:gifPoint2 belongtoArray:gifBelongtoArray2 shakedOrNot:NO];
    [POIs insertObject:gif2_1 atIndex:numPois];
    
    /**third point**/
    frame.size = [UIImage imageNamed:@"tree.gif"].size;
    GIFview *gifview3_1 = [[GIFview alloc] initWithFrame:frame withGifName:@"tree"];
    CGPoint gifPoint3 = {420,1076};
    
    NSArray *gifBelongtoArray3 = [NSArray arrayWithObjects: [NSNumber numberWithInt:3], nil];
    POI *gif3_1 = [POI POIWithView:gifview3_1 at:gifPoint3 belongtoArray:gifBelongtoArray3 shakedOrNot:NO];
    [POIs insertObject:gif3_1 atIndex:numPois];
    
    //set POIs
	[arview setPOIs:POIs];
    
    //arview initialize
    [arview initialize];
    [arview start];
    
    //[movView.movie play];
}

- (void)viewWillAppear:(BOOL)animated
{
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)SwitchBackAndFrontCamera:(UIButton *)sender {
    switch (cameraMode) {
        case backCameraMode:
            takePhotoButton.hidden = NO;
            [arview startFrontCameraMode];
            cameraMode = frontCameraMode;
            break;
            
        case frontCameraMode:
            takePhotoButton.hidden = YES;
            [arview stopFrontCameraMode];
            cameraMode = backCameraMode;
            break;
            
        default:
            takePhotoButton.hidden = NO;
            [arview startFrontCameraMode];
            cameraMode = frontCameraMode;
            break;
    }
}

#pragma mark - take photo

- (IBAction)takePhoto:(UIButton *)sender {
    [arview takeScreenshot];
}

#pragma mark -
#pragma mark shake
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"begin shake");
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"stop");
    [arview setShakeOrNot:YES];
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"shake" message:@"why?" delegate:self cancelButtonTitle:@"fuck" otherButtonTitles:@"shit", nil];
//    [alertView show];
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"cancel");
}

@end
