//
//  MapView.m
//  ZKY
//
//  Created by tongji on 2/11/14.
//  Copyright (c) 2014 tongji. All rights reserved.
//

#import "MapView.h"

@implementation MapView

@synthesize Map;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect imageViewRect = CGRectMake(0, 0, 280, 450);
        Map = [[UIImageView alloc] initWithFrame:imageViewRect];
        [self addSubview:Map];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
