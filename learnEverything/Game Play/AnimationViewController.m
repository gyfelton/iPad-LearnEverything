//
//  AnimationViewController.m
//  learnEverything
//
//  Created by Yuanfeng on 12-06-28.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AnimationViewController.h"

@implementation AnimationViewController
@synthesize score = _score;
@synthesize isSinglePlayerMode = _isSinglePlayerMode;

- (id)initInSinglePlayerMode:(BOOL)singlePlayer
{
    self = [super initWithNibName: singlePlayer ? @"AnimationViewController_SinglePlayer" : @"AnimationViewController_TwoPlayers" bundle:nil];
    if (self) {
        // Custom initializations
        _isSinglePlayerMode = singlePlayer;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (NSMutableArray*)_animatedImagesHelperWithName:(NSString*)name numberOfFrames:(NSInteger)frames repeatLastImage:(BOOL)repeat
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:frames];
    for (int i=1; i<=frames; i++) {
        NSString *fileName = [NSString stringWithFormat:@"%@%d", name, i];
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (!image) {
            NSLog(@"ERROR! cannot load image %@", name);
        } else
        {
            [array addObject:image];
        }
    }
    if (repeat) {
        for (int i = 0; i < 10; i++) {
            [array addObject:[array lastObject]];
        }
    }
    return array;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //left_hero.animationImages = [self _animatedImagesHelperWithName:@"animation" numberOfFrames:15 repeatLastImage:YES];
    //left_hero.animationRepeatCount = 1;
    //left_hero.animationDuration = 1.0f;
    
    _right_flame.animationImages = [self _animatedImagesHelperWithName:@"flame" numberOfFrames:2 repeatLastImage:NO];
    _right_flame.animationDuration = 0.2f;
    
    _left_bo.animationImages = [self _animatedImagesHelperWithName:@"left_bo" numberOfFrames:2 repeatLastImage:NO];
    _left_bo.animationDuration = 0.2f;
    
    _score = 0;
}

- (void)stopShieldAnimationAndStartFlame
{
    [_right_flame startAnimating];
    [_left_bo startAnimating];
//    [left_hero stopAnimating];
//    left_hero.image = [UIImage imageNamed:@"animation15"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self stopShieldAnimationAndStartFlame];
//    [left_hero startAnimating];
//    [self performSelector:@selector(stopShieldAnimationAndStartFlame) withObject:nil afterDelay:1.2f];
}

- (void)viewDidUnload
{
    left_hero = nil;
    _right_flame = nil;
    _left_bo = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return NO;
}

- (void)setScore:(CGFloat)s
{
//    //Total length 772
//    //Initial length 224
//    if (s >= 0 && s<= 1) {
//        
//        CGFloat newXOrigin = (_score * 772.0f) + 100;
//        NSLog(@"%f score:%f", newXOrigin, _score);
//        _shield.frame = CGRectMake(newXOrigin, _shield.frame.origin.y, _shield.frame.size.width, _shield.frame.size.height);
//    }
    CGFloat left_factor = 1;
    CGFloat right_factor = 1;
    CGFloat offsetAmound = self.isSinglePlayerMode ? 15 : 10;
    if (s>0) {
        left_factor = (_left_bo.frame.size.width+offsetAmound)/_left_bo.frame.size.width;
    } else
    {
        left_factor = (_left_bo.frame.size.width-offsetAmound)/_left_bo.frame.size.width;
    }
    
    CGFloat leftNewWidth = _left_bo.frame.size.width*left_factor;
    CGFloat rightNewWidth = (self.isSinglePlayerMode ? 759 : 566) - leftNewWidth;
    right_factor = rightNewWidth/_right_flame.frame.size.width;
    
    [UIView animateWithDuration:0.2f animations:^{
        //left bo
        CGPoint origin = CGPointMake(_left_bo.frame.origin.x, _left_bo.frame.origin.y-(_left_bo.frame.size.height*left_factor-_left_bo.frame.size.height)/2);
        _left_bo.frame = CGRectMake(origin.x, origin.y, _left_bo.frame.size.width*left_factor, _left_bo.frame.size.height*left_factor);
        
        //right flame
        origin = CGPointMake(_right_flame.frame.origin.x-_right_flame.frame.size.width*(right_factor-1.0f), _right_flame.frame.origin.y-(_right_flame.frame.size.height*right_factor-_right_flame.frame.size.height)/2);
        _right_flame.frame = CGRectMake(origin.x, origin.y, _right_flame.frame.size.width*right_factor, _right_flame.frame.size.height*right_factor);
    }];
}
@end
