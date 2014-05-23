//
//  InfoView.m
//  ZKY
//
//  Created by tongji on 3/11/14.
//  Copyright (c) 2014 tongji. All rights reserved.
//

#import "InfoView.h"

@implementation InfoView

@synthesize InfoText;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect labelRect = CGRectMake(5, 5, 315, 25);
        InfoText = [[UILabel alloc] initWithFrame:labelRect];
        InfoText.textColor = [UIColor whiteColor];
        [InfoText setFont:[UIFont fontWithName:@"Helvetica" size:20]];
        InfoText.lineBreakMode = UILineBreakModeWordWrap;
        InfoText.numberOfLines = 0;
        [self addSubview:InfoText];

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
