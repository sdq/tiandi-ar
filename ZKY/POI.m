//
//  POI.m
//  ZKY
//
//  Created by tongji on 1/18/14.
//  Copyright (c) 2014 tongji. All rights reserved.
//

#import "POI.h"

@implementation POI

@synthesize view;

- (id)init
{
    self = [super init];
    if (self) {
        view = nil;
        location.x = 0;
        location.y = 0;
    }
    return self;
}

+ (POI *)POIWithView:(UIView *)view at:(CGPoint)location{
    POI *poi = [[POI alloc] init];
    poi.view = view;
    poi->location = location;
    poi->shakedOrNot = NO;
    return poi;
}

+ (POI *)POIWithView:(UIView *)view at:(CGPoint)location belongto:(int)belongto{
    POI *poi = [[POI alloc] init];
    poi.view = view;
    poi->location = location;
    poi->belongToLocation = belongto;
    poi->shakedOrNot = NO;
    return poi;
}

+ (POI *)POIWithView:(UIView *)view at:(CGPoint)location belongtoArray:(NSArray *)belongtoArray{
    POI *poi = [[POI alloc] init];
    poi.view =view;
    poi->location=location;
    poi->belogToLocationArray = belongtoArray;
    poi->shakedOrNot = NO;
    return poi;
}

+ (POI *)POIWithView:(UIView *)view at:(CGPoint)location belongtoArray:(NSArray *)belongtoArray shakedOrNot:(BOOL)shakedOrNot{
    POI *poi = [[POI alloc] init];
    poi.view =view;
    poi->location=location;
    poi->belogToLocationArray = belongtoArray;
    poi->shakedOrNot = shakedOrNot;
    return poi;
}


@end
