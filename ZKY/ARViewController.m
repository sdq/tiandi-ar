//
//  ARViewController.m
//  ZKY
//
//  Created by tongji on 1/18/14.
//  Copyright (c) 2014 tongji. All rights reserved.
//

#import "ARViewController.h"

@interface ARViewController ()

@end

@implementation ARViewController

@synthesize arview;

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
    
    //voice
//    AVSpeechSynthesizer *av = [[AVSpeechSynthesizer alloc]init];
//    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:@"进入增强现实模式"]; //需要转换的文本
//    utterance.rate = 0.3;
//    [av speakUtterance:utterance];
    
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
    
    NSMutableArray *poiNames = [[NSMutableArray alloc] init];
    NSMutableArray *Img = [[NSMutableArray alloc] init];
    float poiCoords[numPois][2];
    NSInteger belongTo[numPois];
    
    for (int i = 0; i < numPois; i++) {
        [poiNames addObject:[[poiData objectAtIndex:i] objectForKey:@"name"]];
        [Img addObject:[[poiData objectAtIndex:i] objectForKey:@"image"]];
        poiCoords[i][0] = [[[poiData objectAtIndex:i] objectForKey:@"x"] floatValue];
        poiCoords[i][1] = [[[poiData objectAtIndex:i] objectForKey:@"y"] floatValue];
        belongTo[i] = [[[poiData objectAtIndex:i] objectForKey:@"belongto"] integerValue];
    }
    
    //int numPois = sizeof(poiCoords) / sizeof(CGPoint);
    
	NSMutableArray *POIs = [NSMutableArray arrayWithCapacity:numPois+2];
	for (int i = 0; i < numPois; i++) {
        POIview *poiview = [[POIview alloc] initWithFrame:CGRectMake(0, 0, 140, 50)];
        poiview.POItitle.text = poiNames[i];
        [poiview.POIback setImage:[UIImage imageNamed:Img[i]]];
        
//		UILabel *label = [[UILabel alloc] init];
//		label.adjustsFontSizeToFitWidth = NO;
//		label.opaque = NO;
//		label.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.5f];
//		label.center = CGPointMake(200.0f, 200.0f);
//		label.textAlignment = UITextAlignmentCenter;
//		label.textColor = [UIColor whiteColor];
//		label.text = [NSString stringWithCString:poiNames[i] encoding:NSASCIIStringEncoding];
//		CGSize size = [label.text sizeWithFont:label.font];
//		label.bounds = CGRectMake(0.0f, 0.0f, size.width, size.height);
        
        CGPoint poiPoint = {poiCoords[i][0],poiCoords[i][1]};
		POI *poi = [POI POIWithView:poiview at:poiPoint belongto:belongTo[i]];
		[POIs insertObject:poi atIndex:i];
	}
    
    /**
     * MOV
     **/
    CGRect movFrame = CGRectMake(0,0,320,280);
    CGPoint movPoint = {40,750};
    MOVview *movView = [[MOVview alloc] initWithFrame:movFrame];
    [movView setBackgroundColor:[UIColor clearColor]];
    
    POI *mov1 = [POI POIWithView:movView at:movPoint belongto:4];
    [POIs insertObject:mov1 atIndex:numPois];
    
    /**
     * GIF
     **/
    CGRect frame = CGRectMake(0,0,140,140);
    frame.size = [UIImage imageNamed:@"flower.gif"].size;
    GIFview *gifview = [[GIFview alloc] initWithFrame:frame withGifName:@"flower"];
    CGPoint gifPoint = {40,841};
    
    POI *gif1 = [POI POIWithView:gifview at:gifPoint belongto:4];
    [POIs insertObject:gif1 atIndex:numPois+1];
    
    //set POIs
	[arview setPOIs:POIs];
    
    //arview initialize
    [arview initialize];
    [arview start];
    
    [movView.movie play];
}

- (void)viewWillAppear:(BOOL)animated
{
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
