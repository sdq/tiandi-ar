//
//  POI.h
//  ZKY
//
//  Created by tongji on 1/18/14.
//  Copyright (c) 2014 tongji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POI : NSObject{
    @public CGPoint location;
    @public int belongToLocation;//the ar info will display only in the specific location
    @public NSArray *belogToLocationArray;
    @public BOOL shakedOrNot;
}

@property (nonatomic, strong) UIView *view;


+ (POI *)POIWithView:(UIView *)view at:(CGPoint)location;
+ (POI *)POIWithView:(UIView *)view at:(CGPoint)location belongto:(int)belongto;
+ (POI *)POIWithView:(UIView *)view at:(CGPoint)location belongtoArray:(NSArray *)belongtoArray;
+ (POI *)POIWithView:(UIView *)view at:(CGPoint)location belongtoArray:(NSArray *)belongtoArray shakedOrNot:(BOOL)shakedOrNot;


@end
