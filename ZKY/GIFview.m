//
//  GIFview.m
//  ZKY
//
//  Created by tongji on 2/17/14.
//  Copyright (c) 2014 tongji. All rights reserved.
//

#import "GIFview.h"
#import "AnimatedGif.h"

@implementation GIFview

- (id)initWithFrame:(CGRect)frame withGifName:(NSString*)gifName
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];

        NSURL *Url =[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:gifName ofType:@"gif"]];
        UIImageView * AnimationGif = 	[AnimatedGif getAnimationForGifAtUrl: Url];
        [self addSubview:AnimationGif];
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
