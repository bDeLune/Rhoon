#import <AVFoundation/AVFoundation.h>
#import "BalloonViewController.h"
#import "Balloon.h"
#import "CAKeyframeAnimation+AHEasing.h"
#import "EasingDeclarations.h"
#import "easing.h"
#import "GCDQueue.h"
#define NUM_BALLS  8
#define BALL_RADIUS  80
#define BALLOON_RADIUS  30

@interface BalloonViewController ()<UICollisionBehaviorDelegate>
{
    CGPoint  topPoint;
    NSMutableArray *activeBallsForPower;
    int ballGameCount;
    AVAudioPlayer *audioPlayer;
    BOOL muteAudio;
    int  selectedGameBallCount;
    int  selectedSpeedSetting;
    float timeCounter;
    NSTimer* _timer;
    BOOL isaccelerating;
    int currentBall;
    NSDate* start;
}
@property(nonatomic,strong)  NSMutableArray  *balls;
@property(nonatomic,strong)  NSMutableArray  *emptyBalloons;
@property(nonatomic,strong) NSMutableArray  *animators;
@property int currentBallININdex;

@end

@implementation BalloonViewController


- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    // Lighten the tint color when the view is in contact with a boundary.
    [(UIView*)item setTintColor:[UIColor lightGrayColor]];
}

//| ----------------------------------------------------------------------------
//  This method is called when square1 stops contacting a collision boundary.
//  In this demo, the only collision boundary is the bounds of the reference
//  view (self.view).
//
/**- (void)collisionBehavior:(UICollisionBehavior*)behavior endedContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier
{
    // Restore the default color when ending a contcact.
    [(UIView*)item setTintColor:[UIColor darkGrayColor]];
    NSLog(@"in");
    NSLog(@"INdex == %i",self.currentBallININdex);
    [[GCDQueue highPriorityGlobalQueue]queueBarrierBlock:^{
        
            [[GCDQueue mainQueue]queueBlock:^{
                self.currentBallININdex++;
                if (self.currentBallININdex<[self.balls count]) {

                [self animateBallStart:[self.balls objectAtIndex:self.currentBallININdex]];
                }
                
            } afterDelay:0.1];
    }];
}**/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame{
    self=[super init];
    if (self) {
        //887 * 100
        
        NSLog(@"balloon game ini with frame"); 
        
        UIView  *view=[[UIView alloc]initWithFrame:frame];
        self.view=view;
        self.view.backgroundColor=[UIColor  clearColor];
        self.balls=[NSMutableArray new];
        self.animators=[NSMutableArray new];
        
        selectedGameBallCount = 3;
        
        //check change
        self.view.layer.zPosition = 3;

        
        
        // Set the timing functions that should be used to calculate interpolation between the first two keyframes
       // [self makeBalls];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame withBallCount:(int)ballCount{
    self=[super init];
    if (self) {
        //887 * 100
        
        NSLog(@"balloon game ini with frame and ballcount %d",ballCount );
        
        UIView  *view=[[UIView alloc]initWithFrame:frame];
        self.view=view;
        self.view.backgroundColor=[UIColor  clearColor];
        self.balls=[NSMutableArray new];
        
        self.emptyBalloons=[NSMutableArray new];
        self.animators=[NSMutableArray new];
        selectedGameBallCount = ballCount;
        
        //check change
        self.view.layer.zPosition = 3;
        // Set the timing functions that should be used to calculate interpolation between the first two keyframes
        // [self makeBalls];
    }
    return self;
}

-(void)makeBalls
{
    self.currentBallININdex=0;
   __block int  startx=0;
   // __block int  emptyBalloonstartx=0;
    
    for (int i=0; i<selectedGameBallCount; i++) {           //change: make balls here
        
        Balloon *balloon=[[Balloon alloc]initWithFrame:CGRectMake(startx, 0, BALLOON_RADIUS, BALLOON_RADIUS)];
        BOOL allowAnimate = 1;
        
        if (_currentGameType == gameTypeTest || _currentGameType == gameTypeImage ){
            allowAnimate = 0;
        }
        
        [balloon setSpeed:selectedSpeedSetting allowAnimate: allowAnimate];
        [self.balls addObject:balloon];
        balloon.gaugeHeight=self.view.bounds.size.height;
        balloon.delegate=self;
        // [self addFallAnimationForLayer:ball.layer];
        [self.view addSubview:balloon];
        startx+=BALLOON_RADIUS+6;
    }
    
    
    NSLog(@"Creating Balls");
    
    [self animateBallStart];
   // [self animateBallStart:[self.balls objectAtIndex:self.currentBallININdex]];
}

-(void)animateBallStart
{
    for (ItemCount i=0; i<[self.balls count]; i++) {
        
        //NSLog(@"ANIMATE BALL START i %lu", i);
        //NSLog(@"[self.balls count] %lu", (unsigned long)[self.balls count]);
        Balloon  *ball=[self.balls objectAtIndex:i];
        ball.alpha=0;
        //[[GCDQueue mainQueue]queueBlock:^{
        CALayer *layer= ball.layer;
        [CATransaction begin];
        [CATransaction setValue:[NSNumber numberWithFloat:0.750] forKey:kCATransactionAnimationDuration];
        CGPoint targetCenter=CGPointMake(ball.center.x,self.view.bounds.size.height-BALL_RADIUS/2 );
        ball.animation = [self dockBounceAnimationWithIconHeight:150];
        ball.targetPoint=targetCenter;
        [ball.animation setDelegate:ball];
        ball.animation.beginTime = CACurrentMediaTime()+(0.1*i); ///WAS 0.1
        [layer addAnimation:ball.animation forKey:@"position"];
        [CATransaction commit];
        [ball setCenter:targetCenter];
    }
  ///   NSLog(@"COMPLETED ANIMATION!");
}

-(void)reset
{
    //remove
    NSLog(@"BIG RESET");
    @try
    {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"Croquet ball drop bounce cement_BLASTWAVEFX_29317" ofType:@"wav"];
        NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
        NSError *error = nil;
        audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                    error:&error];
        [audioPlayer setNumberOfLoops:1];
        [audioPlayer prepareToPlay];
        audioPlayer.volume=0.3;
        
        NSLog(@"SOUND: reset all %hhd", muteAudio);
        
        if (muteAudio == 1){
            NSLog(@"AUDIO MUTED");
        }else{
             [audioPlayer play];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"COULDNT PLAY AUDIO FILE  - %@", exception.reason);
    }
    
    for (Balloon *ball in self.balls) {
     // NSLog(@"STOPPING BALLS");
        [ball stop];
        [ball blowingEnded];
        [ball removeFromSuperview];
    }
    
    NSLog(@"REMOVE ALL BALLS");
    [self.balls removeAllObjects];
    [self makeBalls];
}

-(void)resetwithBallCount:(int)ballCount
{
    //remove
    selectedGameBallCount = ballCount;
    
    NSLog(@"BIG RESET with ballcount");
    @try
    {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"Croquet ball drop bounce cement_BLASTWAVEFX_29317" ofType:@"wav"];
        NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
        NSError *error = nil;
        audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                    error:&error];
        [audioPlayer setNumberOfLoops:1];
        [audioPlayer prepareToPlay];
        audioPlayer.volume=0.3;
        
        NSLog(@"SOUND: reset all %hhd", muteAudio);
        
        if (muteAudio == 1){
            NSLog(@"AUDIO MUTED");
        }else{
            [audioPlayer play];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"COULDNT PLAY AUDIO FILE  - %@", exception.reason);
    }
    
    for (Balloon *ball in self.balls) {
        // NSLog(@"STOPPING BALLS");
        [ball stop];
        [ball blowingEnded];
        [ball removeFromSuperview];
    }
    
    NSLog(@"REMOVE ALL BALLS");
    [self.balls removeAllObjects];
    [self makeBalls];
}

- (CAKeyframeAnimation *)dockBounceAnimationWithIconHeight:(CGFloat)iconHeight
{
    //NSLog(@"beginning animation");
    CGFloat factors[32] = {0, 32, 60, 83, 100, 114, 124, 128, 128, 124, 114, 100, 83, 60, 32,
        0, 24, 42, 54, 62, 64, 62, 54, 42, 24, 0, 18, 28, 32, 28, 18, 0};
    
    NSMutableArray *values = [NSMutableArray array];
    
    for (int i=0; i<32; i++)
    {
        CGFloat positionOffset = factors[i]/128.0f * iconHeight;
        
        CATransform3D transform = CATransform3DMakeTranslation(0, -positionOffset, 0);
        [values addObject:[NSValue valueWithCATransform3D:transform]];
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.repeatCount = 1;
    animation.duration = 32.0f/30.0f;///32.0f/30.0f;
    animation.fillMode = kCAFillModeForwards;
    animation.values = values;
    animation.removedOnCompletion = YES; // final stage is equal to starting stage
    animation.autoreverses = NO;
    //NSLog(@"ending animation");
    
    return animation;
}

-(void)pushBallsWithVelocity:(float)velocity
{
    
    //change: remove+g
    float maxVelocity=30;
    
    NSString * difficulty=[[NSUserDefaults standardUserDefaults]objectForKey:@"difficulty"];
    
   // NSLog(@"PUSHING BALLS - - -  NSString DIFFICULTY IS %@", difficulty);
    
    int difficultyAsInt = [difficulty intValue];
    
    switch (difficultyAsInt) {
        case 0:
            maxVelocity=15;
            NSLog(@"POWER small");
           break;
        case 1:
            maxVelocity=50;
            NSLog(@"POWER medium");
           break;
        case 2:
            maxVelocity=65;
            NSLog(@"POWER hard");
          break;
            
        default:
            break;
    }
    
    if (velocity>maxVelocity) {
        velocity=maxVelocity;
    }
    
    int  perBall=maxVelocity/selectedGameBallCount;
    float perBallCount=0;
    int numberOfBallsToMove=(velocity/maxVelocity)*selectedGameBallCount;
    
    for (int i=0; i<numberOfBallsToMove; i++) {
        if (perBallCount<=maxVelocity) {
            //NSLog(@" inner BLOWING began  %d!!!", i);
            Balloon  *ball=[self.balls objectAtIndex:i];
            [ball blowingBegan];
            [ball setForce:velocity*80];
            perBallCount+=perBall;
        }
    }
    
    for (int i=numberOfBallsToMove; i<[self.balls count]; i++) {
        Balloon  *ball=[self.balls objectAtIndex:i];
        //NSLog(@" inner BLOWING ENDED  %d!!!", i);
        [ball blowingEnded];
    }
     //NSLog(@"BLOWING ENDED maxvelocity %f!!!", maxVelocity);
}

-(void)blowStarted: (int)currentBallNo atSpeed:(int)speed{
   // NSLog(@"BLOWBGGG! started timer");
    isaccelerating=YES;
    currentBall = currentBallNo;
    selectedSpeedSetting = speed;
    
    if (self.currentGameType == gameTypeTest || self.currentGameType == gameTypeImage){
        return;
    }
    
    
    timeCounter = 0;
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
        
        start = [NSDate date];
        // do stuff...
       
    }
}

-(void)blowEnded{
   // NSLog(@"BLOWEEEE ended timer!");
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
    isaccelerating=NO;
}

- (void)timerFired:(NSTimer *)timer{
    
    timeCounter += .01;
    NSTimeInterval timeElapsed = [start timeIntervalSinceNow];
    int percentageComplete = (fabs(timeElapsed)/selectedSpeedSetting)*100;
    Balloon  *ball=[self.balls objectAtIndex: currentBall];
    
    if (percentageComplete > 0 && percentageComplete < 12.5){
        ball.currentBalloonImage.image = [UIImage imageNamed:@"Balloon1"];
    }else if (percentageComplete > 12.5 && percentageComplete < 25){
        ball.currentBalloonImage.image = [UIImage imageNamed:@"Balloon2"];
    }else if (percentageComplete > 25 && percentageComplete < 37.5){
        ball.currentBalloonImage.image = [UIImage imageNamed:@"Balloon3"];
    }else if(percentageComplete > 50 && percentageComplete < 62.5){
        ball.currentBalloonImage.image = [UIImage imageNamed:@"Balloon4"];
    }else if(percentageComplete > 62.5 && percentageComplete < 75){
        ball.currentBalloonImage.image = [UIImage imageNamed:@"Balloon5"];
    }else if(percentageComplete > 75 && percentageComplete < 87.5){
        ball.currentBalloonImage.image = [UIImage imageNamed:@"Balloon6"];
    }else if(percentageComplete > 87.5 && percentageComplete < 100){
        ball.currentBalloonImage.image = [UIImage imageNamed:@"Balloon7"];
    }else if(percentageComplete >= 100){
        ball.currentBalloonImage.image = [UIImage imageNamed:@"Balloon8"];
    }
}

-(void)playHitTop
{
    NSLog(@"BALLS HITTING TOP");
    @try {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"IMPACT RING METAL DESEND 01" ofType:@"wav"];
        NSData *fileData = [NSData dataWithContentsOfFile:soundPath];
        NSError *error = nil;
        audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                    error:&error];
        [audioPlayer prepareToPlay];
        audioPlayer.volume=0.3;
        
        NSLog(@"SOUND:AUDIO HIT TOP");
        if (muteAudio == 1){
            NSLog(@"AUDIO MUTED");
        }else{
            [audioPlayer play];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"COULDNT PLAY AUDIO FILE  - %@", exception.reason);
    }
}

-(void)ballReachedFinalTarget:(Balloon *)ball

{
    [self playHitTop];
    ballGameCount++;
    
  if (self.currentGameType==gameTypeBalloon)
   {
              NSLog(@"COMPLETED balloon MODE");
   }
}


-(void)setAudioMute: (BOOL) muteSetting{
    NSLog(@"setting inner audio mute %hhd", muteSetting);
    muteAudio = muteSetting;
}

@end
