//
//  GameScene.m
//  Swimmy Fish
//
//  Created by Ryan Wahle on 10/29/14.
//  Copyright (c) 2014 Ryan Wahle. All rights reserved.
//

#import "GameScene.h"
#import "GameOverScene.h"
#import "CharacterMain.h"
#import "Seaweed.h"
#import "EnemyJellyFish.h"
#import "EnemyTurtle.h"
#import "EnemySwordfish.h"

@implementation GameScene
{
    SKNode *gamePlayNode;
    CharacterMain *characterMain;
    SKAction *sfxSwimUp;
    
    NSInteger seaweedCurrentPosition;
    
    SKSpriteNode *buttonWhackSpriteNode;
    
    SKSpriteNode *buttonPauseSpriteNode;
    SKLabelNode *pausedLabelNode;
    
    NSInteger cameraMovementCounter;
    
    SKLabelNode *playerWhackScoreLabel;
    NSInteger playerWhackScore;
}

-(void)didMoveToView:(SKView *)view {
    // Setup your scene here //
    
    self.backgroundColor = [SKColor colorWithRed:0.4f green:0.6f blue:1.0f alpha:1.0f];
    
    gamePlayNode = [SKNode node];
    gamePlayNode.position = CGPointZero;
    [self addChild:gamePlayNode];
    
    
    
    // Setup the players score //
    
    playerWhackScore = 0;
    
    playerWhackScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
    playerWhackScoreLabel.text = @"Whack Score: 0";
    playerWhackScoreLabel.fontColor = [SKColor yellowColor];
    playerWhackScoreLabel.fontSize = 20;
    playerWhackScoreLabel.position = CGPointMake(playerWhackScoreLabel.frame.size.width / 2, self.size.height - playerWhackScoreLabel.frame.size.height);
    playerWhackScoreLabel.zPosition = 99;
    [self addChild:playerWhackScoreLabel];
    
    
    
    // Setup the Physics //
    
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity = CGVectorMake(0, -4);
    
    SKNode *worldBottomBoundryNode = [SKNode node];
    worldBottomBoundryNode.position = CGPointZero;
    worldBottomBoundryNode.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0, 10) toPoint:CGPointMake(self.frame.size.width, 10)];
    worldBottomBoundryNode.physicsBody.categoryBitMask = seaweedCategory;
    [self addChild:worldBottomBoundryNode];
    
    SKNode *worldTopBoundryNode = [SKNode node];
    worldTopBoundryNode.position = CGPointZero;
    worldTopBoundryNode.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0, self.size.height - 10) toPoint:CGPointMake(self.frame.size.width, self.frame.size.height - 10)];
    worldTopBoundryNode.physicsBody.categoryBitMask = seaweedCategory;
    [self addChild:worldTopBoundryNode];
    
    
    
    // Setup the fish whack button //
    
    buttonWhackSpriteNode = [SKSpriteNode spriteNodeWithImageNamed:@"buttonWhack"];
    buttonWhackSpriteNode.position = CGPointMake((buttonWhackSpriteNode.size.width / 2), buttonWhackSpriteNode.size.height / 2);
    buttonWhackSpriteNode.zPosition = 99;
    [self addChild:buttonWhackSpriteNode];
    
    
    
    // Setup the pause button //
    buttonPauseSpriteNode = [SKSpriteNode spriteNodeWithImageNamed:@"buttonPause"];
    buttonPauseSpriteNode.xScale = .5;
    buttonPauseSpriteNode.yScale = .5;
    buttonPauseSpriteNode.alpha = .75;
    buttonPauseSpriteNode.position = CGPointMake(self.size.width - (buttonPauseSpriteNode.size.width / 2), self.size.height - (buttonPauseSpriteNode.size.height / 2));
    buttonPauseSpriteNode.zPosition = 99;
    [self addChild:buttonPauseSpriteNode];
    
    pausedLabelNode = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
    pausedLabelNode.text = @"Game Paused";
    pausedLabelNode.fontColor = [SKColor yellowColor];
    pausedLabelNode.fontSize = 50;
    pausedLabelNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    
    
    // Setup the main character fish //
    
    characterMain = [[CharacterMain alloc] initWithCharacter];
    characterMain.position = CGPointMake(100, 100);
    [gamePlayNode addChild:characterMain];
    
    
    
    // Setup the spawning of new enemy fish //
    
    SKAction *spawnEnemy = [SKAction sequence:@[
                                                [SKAction performSelector:@selector(spawnNewEnemy) onTarget:self],
                                                [SKAction waitForDuration:1.5]
                                                ]];
    [self runAction:[SKAction repeatActionForever:spawnEnemy]];
    
    
    
    // Setup the seaweed //
    
    seaweedCurrentPosition = 0;
    [self addNewSeaweed];
    [self addNewSeaweed];
    [self addNewSeaweed];
    
    
    
    // Preload the SFX //
    
    sfxSwimUp = [SKAction playSoundFileNamed:@"swim.mp3" waitForCompletion:NO];
}

-(void)spawnNewEnemy {
    switch ([self getRandomNumberBetweenMinimum:1 andMaximum:4]) {
        case 1: {
            EnemyTurtle *newTurtle = [[EnemyTurtle alloc] initWithTurtle];
            
            newTurtle.position = CGPointMake( -(gamePlayNode.position.x) + self.size.width + 100,
                                             [self getRandomNumberBetweenMinimum:newTurtle.size.height andMaximum:self.size.height - newTurtle.size.height]);
            
            [gamePlayNode addChild:newTurtle];
            break;
        }
        
        case 2: {
            EnemySwordfish *newSwordfish = [[EnemySwordfish alloc] initWithSwordfish];
            
            newSwordfish.position = CGPointMake( -(gamePlayNode.position.x) + self.size.width + 100,
                                                [self getRandomNumberBetweenMinimum:newSwordfish.size.height andMaximum:self.size.height - newSwordfish.size.height]);
            
            [gamePlayNode addChild:newSwordfish];
            break;
        }
        
        case 3:
        case 4: {
            EnemyJellyFish *jellyFish = [[EnemyJellyFish alloc] initWithJellyFish];
            jellyFish.position = CGPointMake( -(gamePlayNode.position.x) + self.size.width + 100, 250);
            [gamePlayNode addChild:jellyFish];
            break;
        }
    }
}

-(NSInteger)getRandomNumberBetweenMinimum:(NSInteger)minimum andMaximum:(NSInteger)maximum
{
    return minimum + arc4random() % (maximum - minimum);
}

-(void)addNewSeaweed {
    Seaweed *seaweedBottom = [[Seaweed alloc] initWithSeaweedBottom];
    seaweedBottom.position = CGPointMake(seaweedCurrentPosition + 200, seaweedBottom.size.height / 2);
    [gamePlayNode addChild:seaweedBottom];
    
    Seaweed *seaweedTop = [[Seaweed alloc] initWithSeaweedTop];
    seaweedTop.position = CGPointMake(seaweedCurrentPosition + 400, self.frame.size.height - (seaweedTop.size.height / 2));
    [gamePlayNode addChild:seaweedTop];
    
    seaweedCurrentPosition = seaweedCurrentPosition + 400;
}

-(void)pauseGame:(BOOL)shouldPause {
    if (shouldPause) {
        gamePlayNode.paused = YES;
        gamePlayNode.alpha = .5;
        
        self.physicsWorld.speed = 0;
        
        [buttonWhackSpriteNode removeFromParent];
        
        buttonPauseSpriteNode.alpha = 1;
        
        [self addChild:pausedLabelNode];
    } else {
        gamePlayNode.paused = NO;
        gamePlayNode.alpha = 1;
        
        self.physicsWorld.speed = 1;
        
        [self addChild:buttonWhackSpriteNode];
        
        buttonPauseSpriteNode.alpha = .75;
        
        [pausedLabelNode removeFromParent];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    if (gamePlayNode.paused) {
        if ([buttonPauseSpriteNode containsPoint:location]) {
            [self pauseGame:NO];
        }
    } else {
        if ([buttonWhackSpriteNode containsPoint:location]) {
            [characterMain whack];
        } else if ([buttonPauseSpriteNode containsPoint:location]) {
            [self pauseGame:YES];
        } else {
            [characterMain runAction:sfxSwimUp];
            [characterMain.physicsBody setVelocity:CGVectorMake(0, 0)];
            [characterMain.physicsBody applyImpulse:CGVectorMake(150, 300)];
        }
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    if ((contact.bodyA.categoryBitMask == mainCharacterCategory) && (contact.bodyB.categoryBitMask == enemyCategory)) {
    
        if (characterMain.hasActions) {
            SKSpriteNode *enemyFishCollidedWith = (SKSpriteNode *)contact.bodyB.node;
            [enemyFishCollidedWith removeFromParent];
            playerWhackScore = playerWhackScore + 1;
        } else {
            // Game Over
            GameOverScene *gameOverScene = [GameOverScene sceneWithSize:self.size];
            gameOverScene.playerWhackScore = playerWhackScore;
            
            [self.view presentScene:gameOverScene transition:[SKTransition doorsCloseHorizontalWithDuration:0.5]];
        }
    }
}

-(void)didSimulatePhysics {
    // Update the camera to follow the main fish and also spawn new seaweed if the main fish has traveled more than half the screen size //
    
    NSInteger lastCameraPositionX;
    NSInteger cameraMovementDifference;
    
    lastCameraPositionX = gamePlayNode.position.x;
    gamePlayNode.position = CGPointMake(200 - characterMain.position.x, 0);
    
    cameraMovementDifference = gamePlayNode.position.x - lastCameraPositionX;
    cameraMovementCounter = cameraMovementCounter - cameraMovementDifference;
    
    if (cameraMovementCounter > (self.frame.size.width / 2)) {
        cameraMovementCounter = 0;
        [self addNewSeaweed];
    }
}

-(void)update:(NSTimeInterval)currentTime {
    playerWhackScoreLabel.text = [NSString stringWithFormat:@"Whack Score: %ld", (long)playerWhackScore];
}


@end
