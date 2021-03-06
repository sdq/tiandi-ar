//
//  ARViewController.h
//  ZKY
//
//  Created by tongji on 1/18/14.
//  Copyright (c) 2014 tongji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVSpeechSynthesis.h>
#import "ARView.h"
#import "POI.h"
#import "POIview.h"
#import "GIFview.h"
#import "MOVview.h"

@interface ARViewController : UIViewController
{
    NSArray *poiData;
    NSInteger cameraMode;
}
@property (weak, nonatomic) IBOutlet ARView *arview;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraBotton;

- (IBAction)SwitchBackAndFrontCamera:(UIButton *)sender;
- (IBAction)takePhoto:(UIButton *)sender;

@end
