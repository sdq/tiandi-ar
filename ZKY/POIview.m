//
//  POIview.m
//  ZKY
//
//  Created by tongji on 1/21/14.
//  Copyright (c) 2014 tongji. All rights reserved.
//

#import "POIview.h"

@implementation POIview

@synthesize POIback;
@synthesize POItitle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        CGRect imageViewRect = CGRectMake(0, 0, 140, 50);
        POIback = [[UIImageView alloc] initWithFrame:imageViewRect];
        [self addSubview:POIback];
        
        CGRect labelRect = CGRectMake(45, 0, 80, 20);
        POItitle = [[UILabel alloc] initWithFrame:labelRect];
        POItitle.textColor = [UIColor whiteColor];
        [POItitle setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        POItitle.lineBreakMode = UILineBreakModeWordWrap;
        POItitle.numberOfLines = 0;
        [self addSubview:POItitle];
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
