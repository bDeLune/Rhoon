#import <Foundation/Foundation.h>

typedef enum gameType
{
    gameTypeBalloon,
    gameTypeImage,
    gameTypeDuo,
    gameTypeTest
}gameType;

typedef enum
{
    gameDifficultyEasy,
    gameDifficultMedium,
    gameDifficultyHard
}gameDifficulty;

@class AbstractGame;
@protocol GameProtocol <NSObject>
-(void)gameEnded:(AbstractGame*)game;
-(void)gameStarted:(AbstractGame*)game;
-(void)gameWon:(AbstractGame*)game;
@end

@interface AbstractGame : NSObject
{
    NSTimer  *timer;
    NSDate   *startdate;
}
@property(nonatomic,unsafe_unretained)id<GameProtocol>delegate;
@property  int currentBall;
@property  int totalBalls;
@property BOOL  saveable;
-(void)startGame;
-(void)endGame;
-(int)nextBall;
-(void)setBallCount;
@property float time;
-(void)startTimer;
-(void)killTimer;
@end
