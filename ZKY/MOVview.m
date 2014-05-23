//
//  MOVview.m
//  ZKY
//
//  Created by 史 丹青 on 14-5-4.
//  Copyright (c) 2014年 tongji. All rights reserved.
//

#import "MOVview.h"


@implementation MOVview

@synthesize movie;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //视频文件路径
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Star" ofType:@"mov"];
        //视频URL
        NSURL *url = [NSURL fileURLWithPath:path];
        
        //视频播放对象
        movie = [[MPMoviePlayerController alloc] initWithContentURL:url];
        [movie.view setFrame:self.bounds];
        movie.initialPlaybackTime = -1;
        [self addSubview:movie.view];
        // 注册一个播放结束的通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(myMovieFinishedCallback:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:movie];
    }
    return self;
}

#pragma mark -------------------视频播放结束委托--------------------

/*
 @method 当视频播放完毕释放对象
 */
-(void)myMovieFinishedCallback:(NSNotification*)notify
{
    //视频播放对象
    MPMoviePlayerController* theMovie = [notify object];
    //销毁播放通知
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:theMovie];
    [theMovie.view removeFromSuperview];
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
