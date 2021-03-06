//
//  MyScene.m
//  Clock
//
//  Created by Johan Mattsson on 14/12/13.
//  Copyright (c) 2013 Johan Mattsson. All rights reserved.
//

#import "MyScene.h"
#import <tgmath.h>

@interface MyScene ()

@property (nonatomic, strong) SKSpriteNode *minuteIndex;
@property (nonatomic, strong) SKSpriteNode *hourIndex;
@property (nonatomic, strong) SKSpriteNode *secoundIndex;

@property (nonatomic, assign) CFTimeInterval lastUpdateTime;

@end

CGFloat const radius = 150.0f;
CGFloat const heightSecoundIndex = 130.0f;
CGFloat const heightMinuteIndex = 165.0f;
CGFloat const widthOfIndex = 10.0f;

CGFloat const anchorPointX = 0.5f;
CGFloat const anchorPointY = 0.15f;

#define SECOUND_INDEX_COLOR [SKColor redColor]
#define INDEX_COLOR [SKColor blackColor]

@implementation MyScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithWhite:0.93 alpha:1.0];
        [self setupClockFace];
        [self setupIndexes];
        [self setupIndexActionsThatWillRunForever];
        [self moveIndexesToCurrentTime:[self currentLocalizedTime]];
    }
    return self;
}

- (CGFloat)currentLocalizedTime {
    CFTimeZoneRef systemTimeZone = CFTimeZoneCopySystem();
    double current = CFAbsoluteTimeGetCurrent();
    CFRelease(systemTimeZone);
    return current + CFTimeZoneGetSecondsFromGMT(systemTimeZone, current);
}

- (void)setupIndexes {
    CGSize minuteIndexSize = CGSizeMake(widthOfIndex, heightMinuteIndex);
    CGSize hourIndexSize = CGSizeMake(widthOfIndex, 100);
    CGSize secoundsIndexSize = CGSizeMake(5, heightSecoundIndex);
    
    self.hourIndex = [self rectOfSize:hourIndexSize withBackgroundColor:INDEX_COLOR];
    self.minuteIndex = [self rectOfSize:minuteIndexSize withBackgroundColor:INDEX_COLOR];
    self.secoundIndex = [self rectOfSize:secoundsIndexSize withBackgroundColor:SECOUND_INDEX_COLOR];
    
    [self setupSecoundIndexCircles];
    
    // This is the order of appearance
    [self insertChild:self.hourIndex atIndex:0];
    [self insertChild:self.minuteIndex atIndex:1];
    [self insertChild:self.secoundIndex atIndex:2];
}

- (void)setupSecoundIndexCircles {
    NSUInteger secoundTopCircleRadius = 15;
    SKTexture *topCircle = [SKTexture textureWithImage:[self circleImageWithRadius:secoundTopCircleRadius inColor:SECOUND_INDEX_COLOR]];
    SKSpriteNode *node = [[SKSpriteNode alloc] initWithTexture:topCircle];
    CGFloat tipOfSecoundIndex = heightSecoundIndex * ( 1 - anchorPointY);
    
    node.position = CGPointMake(0, tipOfSecoundIndex);
    [self.secoundIndex addChild:node];
}

- (void)setupIndexActionsThatWillRunForever {
    SKAction *action = [SKAction rotateByAngle:-2*M_PI duration:60.0];
    [SKAction repeatActionForever:action];
    [self.secoundIndex runAction:[SKAction repeatActionForever:action]];
    
    // change the duration to 1 hour
    action.duration = 60*60;
    [self.minuteIndex runAction:[SKAction repeatActionForever:action]];
    
    // Change the duration to 12 hours
    action.duration = 60*60*12;
    [self.hourIndex runAction:[SKAction repeatActionForever:action]];
}

- (void)setupClockFace {
    CGFloat midX = CGRectGetMidX(self.frame);
    CGFloat midY = CGRectGetMidY(self.frame);
    
    // Setup the background
    SKTexture *backgroundTexture = [SKTexture textureWithImage:[self circleImageWithRadius:radius + 5 inColor:[UIColor whiteColor]]];
    SKSpriteNode *background = [[SKSpriteNode alloc] initWithTexture:backgroundTexture];
    background.position = CGPointMake(midX, midY);
    [self addChild:background];
    
    // setup each individual minute display line
    for (NSUInteger i = 0; i < 60; i++) {
        CGFloat width = i % 5 == 0 ? 10 : 3;
        CGFloat height = i % 5 == 0 ? 20 : 6;
        SKSpriteNode *node = [[SKSpriteNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(width, height)];
        
        CGFloat angle = (2 * M_PI) / 60.0 * i;
        
        SKAction *rotation = [SKAction rotateByAngle:angle - M_PI_2 duration:0];
        [node runAction:rotation];
        
        node.anchorPoint = CGPointMake(0.5, 1.0);
        CGFloat pointX = cosf(angle) * radius + midX;
        CGFloat pointY = sinf(angle) * radius + midY;
        node.position = CGPointMake(pointX, pointY);
        [self addChild:node];
    }
}

- (UIImage*)circleImageWithRadius:(NSUInteger)radius inColor:(UIColor*)color {
    CGFloat diameter = radius * 2;
    UIGraphicsBeginImageContext(CGSizeMake(diameter, diameter));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGRect circleFrame = CGRectMake(0, 0, diameter, diameter);
    CGContextFillEllipseInRect(context, circleFrame);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (SKSpriteNode*)rectOfSize:(CGSize)size withBackgroundColor:(SKColor*)color {
    SKSpriteNode *node = [[SKSpriteNode alloc] initWithColor:color size:size];
    node.anchorPoint = CGPointMake(anchorPointX, anchorPointY);
    node.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    return node;
}

- (void)moveIndexesToCurrentTime:(CFTimeInterval)currentTime {
    SKAction *secoundAction = [SKAction rotateByAngle:[self currentAngleInRadiansForSecoundsIndex:currentTime] duration:0];
    SKAction *minuteAction = [SKAction rotateByAngle:[self currentAngleInRadiansForMinuteIndex:currentTime] duration:0];
    SKAction *hourAction = [SKAction rotateByAngle:[self currentAngleInRadiansForHourIndex:currentTime] duration:0];
    
    [self.secoundIndex runAction:secoundAction];
    [self.minuteIndex runAction:minuteAction];
    [self.hourIndex runAction:hourAction];
}

- (CGFloat)currentAngleInRadiansForSecoundsIndex:(CFTimeInterval)currentTime {
    return [self secoundIndexAngelFromTimeDiff:fmodf(currentTime, 60)];
}

- (CGFloat)currentAngleInRadiansForMinuteIndex:(CFTimeInterval)currentTime {
    return [self minuteIndexAngelFromTimeDiff:fmodf(currentTime, 60*60)];
}

- (CGFloat)currentAngleInRadiansForHourIndex:(CFTimeInterval)currentTime {
    return [self hourIndexAngelFromTimeDiff:fmodf(currentTime, 60*60*24)];
}

- (CGFloat)secoundIndexAngelFromTimeDiff:(CFTimeInterval)timeDiff {
    NSUInteger timeInSec = timeDiff;
    CGFloat fixedTime = ceilf((timeDiff - timeInSec) * 100 / 60) + timeInSec;
    return (-2*M_PI) / 60.0 * fixedTime;
}

- (CGFloat)minuteIndexAngelFromTimeDiff:(CFTimeInterval)timeDiff {
    return [self secoundIndexAngelFromTimeDiff:timeDiff] / 60.0;
}

- (CGFloat)hourIndexAngelFromTimeDiff:(CFTimeInterval)timeDiff {
    return [self minuteIndexAngelFromTimeDiff:timeDiff] / 12.0;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called on every frame */
}

@end
