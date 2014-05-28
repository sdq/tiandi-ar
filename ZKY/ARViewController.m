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
@synthesize takePhotoButton;

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
    CGRect frame = CGRectMake(0,0,140,140);
    frame.size = [UIImage imageNamed:@"test.gif"].size;
    GIFview *gifview = [[GIFview alloc] initWithFrame:frame withGifName:@"test"];
    CGPoint gifPoint = {40,841};
    
    NSArray *gifBelongtoArray = [NSArray arrayWithObjects: [NSNumber numberWithInt:4], nil];
    POI *gif1 = [POI POIWithView:gifview at:gifPoint belongtoArray:gifBelongtoArray];
    [POIs insertObject:gif1 atIndex:numPois];
    
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
    UIImageWriteToSavedPhotosAlbum([arview takeScreenshot], nil, nil,nil);
}

@end
