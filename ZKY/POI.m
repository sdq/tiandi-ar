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
    return poi;
}

+ (POI *)POIWithView:(UIView *)view at:(CGPoint)location belongto:(int)belongto{
    POI *poi = [[POI alloc] init];
    poi.view = view;
    poi->location = location;
    poi->belongToLocation = belongto;
    return poi;
}

+ (POI *)POIWithView:(UIView *)view at:(CGPoint)location belongtoArray:(NSArray *)belongtoArray{
    POI *poi = [[POI alloc] init];
    poi.view =view;
    poi->location=location;
    poi->belogToLocationArray = belongtoArray;
    return poi;
}

//为了测试pull request，可以通知你，我做出了修改，由你来决定是否采纳


@end
