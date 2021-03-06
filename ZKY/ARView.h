//
//  ARView.h
//  ZKY
//
//  Created by tongji on 1/18/14.
//  Copyright (c) 2014 tongji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import "POI.h"
#import "MapView.h"
#import "InfoView.h"



@interface ARView : UIView < CLLocationManagerDelegate >
{
    AVCaptureStillImageOutput *stillImageOutput;
}

- (void)initialize;
- (void)start;
- (void)stop;
- (void)startFrontCameraMode;
- (void)stopFrontCameraMode;

- (void)takeScreenshot;

- (void)setShakeOrNot:(BOOL)yesOrNot;

- (void)setPOIs:(NSArray *)pois;

@end
