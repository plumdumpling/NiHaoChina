//
//  MurmelScene.m
//  NiHaoChina
//
//  Created by Leslie on 23.06.14.
//  Copyright (c) 2014 Leslie Zimmermann. All rights reserved.
//

#import "MurmelScene.h"
#import "MurmelGame.h"


#define skMurmelSize CGSizeMake(40, 40)
#define skMurmelName @"Murmel"
#define skMurmelImageName @"MurmelGrafik"

#define skWallSize CGSizeMake(320, 8)

#define skWallImageName @"bricks"
#define skHoleImageName @"hole"

typedef enum BlockType {
    WallBlock,
    Hole
} BlockType;

static const uint32_t category1     =  0x1 << 0;
static const uint32_t category2     =  0x1 << 1;
static const uint32_t category3     =  0x1 << 2;
static const uint32_t category4     =  0x1 << 3;
static const uint32_t category5     =  0x1 << 4;
static const uint32_t category6     =  0x1 << 5;

@interface MurmelScene () {
    NSInteger _counter;
    NSString *_key;
    NSMutableArray *_wordsDE;
    NSMutableArray *_wordsCN;
    NSMutableArray *_categoriesDE;
    NSMutableArray *_categoriesCN;
    NSMutableArray *_ton;
}

@end


@implementation MurmelScene

- (id)initWithSize:(CGSize)size andKey:(NSString *)key
{
    if (self = [super initWithSize:size]) {
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background.png"];
        background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:background];
        
        _counter = 5;

        _key = key;
        [self getJsonDataForDialogueKey:_key];
        
        if ([_key isEqualToString:@"1.4"]) {
            int r;
            while ([_wordsDE count]>6) {
                r = arc4random()%5;
                [_wordsDE removeObjectAtIndex:r];
                [_wordsCN removeObjectAtIndex:r];
            }
            
            _categoriesDE = [[NSMutableArray alloc] initWithArray:@[@1,@2,@3,@4,@5,@6]];
            _categoriesCN = [[NSMutableArray alloc] initWithArray:@[@1,@2,@3,@4,@5,@6]];
            self.part = 6;
        }
        else if ([_key isEqualToString:@"1.2"]) {
            self.part = 0;
        }
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        [self createContent];
    }
    
    return self;
}

- (void)didMoveToView:(SKView *)view
{
    self.motionManager = [[CMMotionManager alloc] init];
    [self.motionManager startAccelerometerUpdates];
}

- (void)createContent
{
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    
    NSString *fileName = @"ding";
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/%@.mp3", [[NSBundle mainBundle] resourcePath], fileName];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    self.audioPlayer.numberOfLoops = 0;
    
    if ([_key isEqualToString:@"1.4"]) {
        [self setupGradient];
        [self setupTextWithCollisionZone];
        [self setupWalls];
        [self setupMurmelForCategory:[self getCategory]];
    }
    else if ([_key isEqualToString:@"1.2"]) {
        [self setupTonWithCollisionZone];
        [self setupLabel];
        [self setupMurmel];
    }
}

- (uint32_t)getCategory
{
    switch ([_categoriesDE[_counter] integerValue]) {
        case 1:
            return category1;
            break;
        case 2:
            return category2;
            break;
        case 3:
            return category3;
            break;
        case 4:
            return category4;
            break;
        case 5:
            return category5;
            break;
        case 6:
            return category6;
            break;
        default:
            return (uint32_t)nil;
            break;
    }
}

#pragma mark - Setup Text With Collision Zone

- (void)setupTextWithCollisionZone
{
    [self shuffle:_wordsDE and:_categoriesDE];
    [self shuffle:_wordsCN and:_categoriesCN];
    
    for (int n=0; n<6; n++) {
        switch ([_categoriesCN[n] integerValue]) {
            case 1:
                [self addCollisionZoneAtPosition:CGPointMake(1024-skWallSize.width/8, (n*88)+skWallSize.height/2+50) forCategory:category1];
                break;
            case 2:
                [self addCollisionZoneAtPosition:CGPointMake(1024-skWallSize.width/8, (n*88)+skWallSize.height/2+50) forCategory:category2];
                break;
            case 3:
                [self addCollisionZoneAtPosition:CGPointMake(1024-skWallSize.width/8, (n*88)+skWallSize.height/2+50) forCategory:category3];
                break;
            case 4:
                [self addCollisionZoneAtPosition:CGPointMake(1024-skWallSize.width/8, (n*88)+skWallSize.height/2+50) forCategory:category4];
                break;
            case 5:
                [self addCollisionZoneAtPosition:CGPointMake(1024-skWallSize.width/8, (n*88)+skWallSize.height/2+50) forCategory:category5];
                break;
            case 6:
                [self addCollisionZoneAtPosition:CGPointMake(1024-skWallSize.width/8, (n*88)+skWallSize.height/2+50) forCategory:category6];
                break;
            default:
                break;
        }

        for (int m=0; m<2; m++) {
            switch (m) {
                case 0:
                    [self addText:_wordsDE[n] withName:[NSString stringWithFormat:@"de-%d", n] atPosition:CGPointMake(30, (n*88)+37) withAlignment:SKLabelHorizontalAlignmentModeLeft];
                    break;
                    
                case 1:
                    [self addText:_wordsCN[n] withName:[NSString stringWithFormat:@"cn-%d", n] atPosition:CGPointMake(1024-30, (n*88)+37) withAlignment:SKLabelHorizontalAlignmentModeRight];
                    break;
                    
                default:
                    break;
            }
        }
    }
}

- (void)addText:(NSString *)text withName:(NSString *)name atPosition:(CGPoint)position withAlignment:(SKLabelHorizontalAlignmentMode)alignment
{
    SKLabelNode *label = [[SKLabelNode alloc] init];
    [label setPosition:position];
    [label setHorizontalAlignmentMode:alignment];
    [label setText:text];
    [label setFontSize:25];
    
    if ([name isEqualToString:@"de-5"]) {
        [label setFontColor:[UIColor whiteColor]];
    }
    else {
        [label setFontColor:[UIColor colorWithRed:0.83 green:0.55 blue:0.27 alpha:1.0]];
    }
    
    label.name = name;
    
    [self addChild:label];
}

- (void)addCollisionZoneAtPosition:(CGPoint)position forCategory:(uint32_t)category
{
    SKNode *collisionZone = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(skWallSize.width/4, 100)];
    collisionZone.name = @"CollisionZone";
    collisionZone.position = position;
    collisionZone.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(skWallSize.width/4, 100)];
    collisionZone.physicsBody.dynamic = NO;
    collisionZone.physicsBody.categoryBitMask = category;
    collisionZone.physicsBody.contactTestBitMask = category;
    collisionZone.physicsBody.collisionBitMask = category;
    
    [self addChild:collisionZone];
}

#pragma mark Shuffle Arrays

- (void)shuffle:(NSMutableArray *)arrayA and:(NSMutableArray *)arrayB
{
    NSUInteger count = [arrayA count];
    for (NSUInteger i=0; i<count; ++i) {
        NSInteger n = arc4random_uniform(count-i)+i;
        [arrayA exchangeObjectAtIndex:i withObjectAtIndex:n];
        [arrayB exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

#pragma mark - Setup Ton With Collision Zone

- (void)setupTonWithCollisionZone
{
    [self shuffle:_wordsCN and:_ton];
    
    SKLabelNode *tonLabel;
    SKNode *collisionZone;
    
    for (int n=0; n<4; n++) {
        tonLabel = [[SKLabelNode alloc] init];
        [tonLabel setFontSize:30];
        [tonLabel setFontColor:[UIColor colorWithRed:0.83 green:0.55 blue:0.27 alpha:1.0]];
        tonLabel.name = @"ton";
        
        collisionZone = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(100, 50)];
        collisionZone.name = @"CollisionZone";
        collisionZone.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(100, 50)];
        collisionZone.physicsBody.dynamic = NO;
        uint32_t category;
        
        [self addChild:collisionZone];
        switch (n) {
            case 0:
                [tonLabel setText:@"3. Ton"];
                [tonLabel setPosition:CGPointMake(50, 50)];
                [tonLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];

                collisionZone.position = CGPointMake(50, 25);
                category = category3;
                break;
            case 1:
                [tonLabel setText:@"4. Ton"];
                [tonLabel setPosition:CGPointMake(974, 50)];
                [tonLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeRight];

                collisionZone.position = CGPointMake(974, 25);
                category = category4;
                break;
            case 2:
                [tonLabel setText:@"1. Ton"];
                [tonLabel setPosition:CGPointMake(50, 498)];
                [tonLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];

                collisionZone.position = CGPointMake(50, 523);
                category = category1;
                break;
            case 3:
                [tonLabel setText:@"2. Ton"];
                [tonLabel setPosition:CGPointMake(974, 498)];
                [tonLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeRight];

                collisionZone.position = CGPointMake(974, 523);
                category = category2;
                break;
            default:
                break;
        }

        collisionZone.physicsBody.categoryBitMask = category;
        collisionZone.physicsBody.contactTestBitMask = category;
        collisionZone.physicsBody.collisionBitMask = category;

        [self addChild:tonLabel];
    }
    
    collisionZone = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(1024, 240)];
    collisionZone.name = @"CollisionZone";
    collisionZone.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(1024, 240)];
    collisionZone.position = CGPointMake(512, 648);
    [self addChild:collisionZone];
}

#pragma mark - Setup Background Gradient Murmel

- (void)setupGradient
{
    SKNode *gradient = [SKSpriteNode spriteNodeWithImageNamed:@"murmelVerlauf.png"];
    gradient.name = @"gradient";
    gradient.position = CGPointMake(0, (_counter*88)+47);
    
    [self addChild:gradient];

    self.gradient = (SKSpriteNode *)[self childNodeWithName:@"gradient"];
}

#pragma mark - Setup Murmel 1.4

- (void)setupMurmelForCategory:(uint32_t)category
{
    self.part--;
    
    SKNode *murmel = [SKSpriteNode spriteNodeWithImageNamed:skMurmelImageName];
    murmel.position = CGPointMake(20+skMurmelSize.width/2, (_counter*88)+skMurmelSize.height/2+30);
    murmel.name = skMurmelName;
    
    murmel.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:skMurmelSize.width/2];
    murmel.physicsBody.dynamic = YES;
    murmel.physicsBody.mass = 0.3;
    murmel.physicsBody.categoryBitMask = category;
    murmel.physicsBody.contactTestBitMask = category;
    murmel.physicsBody.collisionBitMask = category;
    
    [self addChild:murmel];
    
    self.myMurmel = (SKSpriteNode *)[self childNodeWithName:skMurmelName];
}

#pragma mark - Setup Murmel 1.2

- (void)setupMurmel
{
    SKNode *murmel = [SKSpriteNode spriteNodeWithImageNamed:skMurmelImageName];
    murmel.position = CGPointMake(512, 300);
    murmel.name = skMurmelName;
    
    murmel.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:skMurmelSize.width/2];
    murmel.physicsBody.dynamic = YES;
    murmel.physicsBody.mass = 0.3;
    
    uint32_t category;
    switch ([_ton[self.part] integerValue]) {
        case 1:
            category = category1;
            break;
        case 2:
            category = category2;
            break;
        case 3:
            category = category3;
            break;
        case 4:
            category = category4;
            break;
        default:
            break;
    }
    murmel.physicsBody.categoryBitMask = category;
    murmel.physicsBody.contactTestBitMask = category;
    murmel.physicsBody.collisionBitMask = category;
    
    [self addChild:murmel];
    
    self.myMurmel = (SKSpriteNode *)[self childNodeWithName:skMurmelName];
}

#pragma mark - Setup Center Label

- (void)setupLabel
{
    self.centerLabel = [[SKLabelNode alloc] init];
    [self.centerLabel setPosition:CGPointMake(512, 290)];
    [self.centerLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    [self.centerLabel setText:_wordsCN[self.part]];
    [self.centerLabel setFontSize:35];
    [self.centerLabel setFontName:@"Shojumaru-Regular"];
    [self.centerLabel setFontColor:[UIColor colorWithRed:0.83 green:0.55 blue:0.27 alpha:1.0]];
    
    self.centerLabel.name = @"centerlabel";
    
    [self addChild:self.centerLabel];
}

#pragma mark - Update

-(void)update:(CFTimeInterval)currentTime {
    CMAccelerometerData *data = self.motionManager.accelerometerData;
    if (fabs(data.acceleration.x) > 0.2 || fabs(data.acceleration.y) > 0.2) {
        [self.myMurmel.physicsBody applyForce:CGVectorMake(80 * data.acceleration.y, -80 * data.acceleration.x)];
    }
}

#pragma mark - Setup Walls

- (void)setupWalls
{
    CGPoint position;
    CGSize size;
    
    for (int n=0; n<7; n++) {
        for (int m=0; m<2; m++) {
            if ((n<=0 && m<=0) || (n>=6 && m<=0)) {
                position = CGPointMake(0, (n*88)+skWallSize.height/2);
                size = CGSizeMake(2048, skWallSize.height);
                [self addWallWithSize:size atPosition:position];
            }
            else if (m<=0) {
                position = CGPointMake(skWallSize.width/2, (n*88)+skWallSize.height/2);
                [self addWallWithSize:skWallSize atPosition:position];
            }
            else if (m>=1 && n>0 && n<6) {
                position = CGPointMake(1024-skWallSize.width/2, (n*88)+skWallSize.height/2);
                [self addWallWithSize:skWallSize atPosition:position];
            }
        }
    }
}

- (void)addWallWithSize:(CGSize)size atPosition:(CGPoint)position
{
    SKNode *wall = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:0.83 green:0.55 blue:0.27 alpha:1.0] size:size];
    
    wall.name = @"WallBlock";
    wall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
    wall.physicsBody.dynamic = NO;
    wall.position = position;
    
    [self addChild:wall];
}


#pragma mark - Collision Murmel Text-Collision-Zone

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if (contact.bodyA.categoryBitMask == contact.bodyB.categoryBitMask) {
        if ([_key isEqualToString:@"1.4"]) {
            if (self.part==_counter) _counter--;
            
            if (_counter<0) {
                // end
                SKNode *check;
                
                for (int i=0; i<2; i++) {
                    check = [SKSpriteNode spriteNodeWithImageNamed:@"btnYes.png"];
                    
                    if (i==0) check.position = [self childNodeWithName:skMurmelName].position;
                    else check.position = CGPointMake([self childNodeWithName:skMurmelName].position.x-824, ((_counter+1)*88)+50);
                    
                    check.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:skMurmelSize.width/2];
                    check.physicsBody.dynamic = YES;
                    check.physicsBody.mass = 0.3;
                    [self addChild:check];
                }
                
                [[self childNodeWithName:skMurmelName] removeFromParent];
                [[self childNodeWithName:@"gradient"] removeFromParent];
                
                SKLabelNode *prevLabel = (SKLabelNode *)[self childNodeWithName:[NSString stringWithFormat:@"de-%ld", (long)_counter+1]];
                [prevLabel setFontColor:[UIColor colorWithRed:0.83 green:0.55 blue:0.27 alpha:1.0]];
                
                [self.parentViewController endOfGame];
            }
            else {
                // next part
                SKNode *check;
                
                for (int i=0; i<2; i++) {
                    check = [SKSpriteNode spriteNodeWithImageNamed:@"btnYes.png"];
                    
                    if (i==0) check.position = [self childNodeWithName:skMurmelName].position;
                    else check.position = CGPointMake([self childNodeWithName:skMurmelName].position.x-824, ((_counter+1)*88)+50);
                    
                    check.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:skMurmelSize.width/2];
                    check.physicsBody.dynamic = YES;
                    check.physicsBody.mass = 0.3;
                    [self addChild:check];
                }
                
                [[self childNodeWithName:skMurmelName] removeFromParent];
                [self setupMurmelForCategory:[self getCategory]];
                
                [self childNodeWithName:@"gradient"].position = CGPointMake(0, (_counter*88)+50);
                
                SKLabelNode *prevLabel = (SKLabelNode *)[self childNodeWithName:[NSString stringWithFormat:@"de-%ld", (long)_counter+1]];
                [prevLabel setFontColor:[UIColor colorWithRed:0.83 green:0.55 blue:0.27 alpha:1.0]];
                SKLabelNode *currentLabel = (SKLabelNode *)[self childNodeWithName:[NSString stringWithFormat:@"de-%ld", (long)_counter]];
                [currentLabel setFontColor:[UIColor whiteColor]];

                [self.audioPlayer play];
            }
        }
        else if ([_key isEqualToString:@"1.2"]) {
            if (self.part+1<[_wordsCN count]) {
                // next part
                SKNode *check = [SKSpriteNode spriteNodeWithImageNamed:@"btnYes.png"];
                check.position = CGPointMake(512, 300);
                check.name = @"check";
                [self addChild:check];
                
                [[self childNodeWithName:skMurmelName] removeFromParent];
                [self performSelector:@selector(nextPart) withObject:nil afterDelay:2];

                [self.audioPlayer play];
            }
            else {
                // end
                [[self childNodeWithName:skMurmelName] removeFromParent];
                [self.centerLabel removeFromParent];
                [self.parentViewController endOfGame];
            }
        }
    }
}

- (void)nextPart
{
    self.part++;
    
    self.centerLabel.text = _wordsCN[self.part];
    
    [[self childNodeWithName:@"check"] removeFromParent];
    
    [self setupMurmel];
}

#pragma mark Json Data

- (void)getJsonDataForDialogueKey:(NSString *)key
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"murmelspiel" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSError* error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:kNilOptions
                                                error:&error];
    
    if (!json) {
        NSLog(@"no json data received");
    }
    else{
        NSArray *array = [json objectForKey:key];
        NSDictionary *tempDict = [[NSDictionary alloc] init];
        
        if ([_key isEqualToString:@"1.4"]) {
            _wordsDE = [[NSMutableArray alloc] init];
            _wordsCN = [[NSMutableArray alloc] init];
        }
        else if ([_key isEqualToString:@"1.2"]) {
            _wordsCN = [[NSMutableArray alloc] init];
            _ton = [[NSMutableArray alloc] init];
        }
        
        for (int i=0; i<[array count]; i++) {
            tempDict = array[i];

            if ([_key isEqualToString:@"1.4"]) {
                [_wordsDE addObject:[tempDict objectForKey:@"de"]];
                [_wordsCN addObject:[tempDict objectForKey:@"cn"]];
            }
            else if ([_key isEqualToString:@"1.2"]) {
                [_wordsCN addObject:[tempDict objectForKey:@"cn"]];
                [_ton addObject:[tempDict objectForKey:@"ton"]];
            }
        }
    }
}


@end
