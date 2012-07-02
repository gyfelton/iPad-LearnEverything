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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    left_hero.animationImages = [self _animatedImagesHelperWithName:@"animation" numberOfFrames:15 repeatLastImage:YES];
    left_hero.animationRepeatCount = 1;
    left_hero.animationDuration = 1.0f;
    
    _right_flame.animationImages = [self _animatedImagesHelperWithName:@"flame" numberOfFrames:2 repeatLastImage:NO];
    _right_flame.animationDuration = 0.2f;
    _right_flame.hidden = YES;
    
    _score = 0.245f;
}

- (void)stopShieldAnimationAndStartFlame
{
    _right_flame.hidden = NO;
    [_right_flame startAnimating];
    [left_hero stopAnimating];
    left_hero.image = [UIImage imageNamed:@"animation15"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [left_hero startAnimating];
    [self performSelector:@selector(stopShieldAnimationAndStartFlame) withObject:nil afterDelay:1.2f];
}

- (void)viewDidUnload
{
    left_hero = nil;
    _right_flame = nil;
    _shield = nil;
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
    //Total length 772
    //Initial length 224
    if (s >= 0 && s<= 1) {
        _score = s;
        
        CGFloat newXOrigin = (_score * 772.0f) + 100;
        NSLog(@"%f score:%f", newXOrigin, _score);
        _shield.frame = CGRectMake(newXOrigin, _shield.frame.origin.y, _shield.frame.size.width, _shield.frame.size.height);
    }
}
@end
