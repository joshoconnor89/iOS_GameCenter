//
//  ViewController.m
//  GKDemo
//
//  Created by Gabriel Theodoropoulos on 10/2/14.
//  Copyright (c) 2014 AppCoda. All rights reserved.
//

#import "ViewController.h"
#import "CustomActionSheet.h"


#define additionsPerLevel 5

@interface ViewController ()

// This object that will be used to count the 60 seconds of each level.
@property (nonatomic, strong) NSTimer *gameTimer;

// It will be used to display the Game Center related options and handle the user selection in a block.
@property (nonatomic, strong) CustomActionSheet *customActionSheet;

// These two member variables that will store the operand values of the addition.
@property (nonatomic) int operand1;
@property (nonatomic) int operand2;

// The timer value.
@property (nonatomic) int timerValue;

// The current level.
@property (nonatomic) int level;

// The current round of a level.
@property (nonatomic) int currentAdditionCounter;

// The player's score. Its type is int64_t so as to match the expected type by the respective method of GameKit.
@property (nonatomic) int64_t score;

// The number of remaining "lives" in the game.
@property (nonatomic) int lives;

// A flag indicating whether the Game Center features can be used after a user has been authenticated.
@property (nonatomic) BOOL gameCenterEnabled;

// This property stores the default leaderboard's identifier.
@property (nonatomic, strong) NSString *leaderboardIdentifier;



// This method is used to set the initial values to all member variables.
-(void)initValues;


// When it's called, the timerValue member variable gets its initial value, which is 0, and the timer
// is re-scheduled in order to start counting the time for a new level.
-(void)startTimer;


// It updates the time label on the view with the current timer value.
-(void)updateTimerLabel:(NSTimer *)timer;


// It creates a new ramdom addition operation and shows is to the lblAddition label, as well as all the three
// possible answers.
-(void)createAddition;


// It updates the level, both internally and visually.
-(void)updateLevelLabel;


// It sets the initial value to the lives member variable and makes visible all "life" images.
-(void)initLives;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self initValues];
    
    _gameCenterEnabled = NO;
    _leaderboardIdentifier = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction method implementation

- (IBAction)startStopGame:(id)sender {
    // If the bbItemPlay bar button item's title is equal to Start, then by tapping it a new game should be started.
    // Otherwise, just stop the game.
    if ([_bbItemPlay.title isEqualToString:@"Start"]) {
        // Set the initial value to all properties.
        [self initValues];
        
        // Start the timer.
        if (_gameTimer != nil) {
            _gameTimer = nil;
        }
        [self startTimer];
        
        // Create a random addition.
        [self createAddition];
        
        // Make all lives available to the player.
        [self initLives];
        
        // Update the level label and the level counter.
        [self updateLevelLabel];
        
        // Set the initial score value to the respective label.
        [_lblScore setText:@"0"];
        
        // Make all buttons visible.
        _btnAnswer1.hidden = NO;
        _btnAnswer2.hidden = NO;
        _btnAnswer3.hidden = NO;
        
        // Change the button's title to Stop.
        [_bbItemPlay setTitle:@"Stop"];
    }
    else{
        // Stop the timer.
        [_gameTimer invalidate];
        
        // Hide all answer buttons and set an empty string as the text of the addition label.
        _btnAnswer1.hidden = YES;
        _btnAnswer2.hidden = YES;
        _btnAnswer3.hidden = YES;
        [_lblAddition setText:@""];
        
        // Set the button's title to Start.
        [_bbItemPlay setTitle:@"Start"];
    }
}


- (IBAction)handleAnswer:(id)sender {
    // Get the sender's title and check if it matches to the correct result.
    int answer = [[(UIButton *)sender titleForState:UIControlStateNormal] intValue];
    
    // Declare and init a flag that will indicate whether the game should continue after a
    // player selects wrong answer.
    BOOL shouldContinue = YES;
    
    if (answer == _operand1 + _operand2) {
        // In case of a correct answer, then add 10 more points to the score and update
        // the lblScore label.
        _score += 10;
        [_lblScore setText:[NSString stringWithFormat:@"%lld", _score]];
    }
    else{
        // If the player select a wrong answer, then decrease the available amount of lives by one.
        _lives--;
        
        // Next, depending on the number of the remaining lives hide any unnecessary icons to reflect
        // the remaining lives to the player.
        switch (_lives) {
            case 2:
                _imgLife3.hidden = YES;
                break;
            case 1:
                _imgLife2.hidden = YES;
                break;
            case 0:
                _imgLife1.hidden = YES;
                break;
                
            default:
                break;
        }
        
        // If no more lives have been left, the game must stop.
        if (_lives == 0) {
            // Show a "Game Over" message.
            UIAlertView *gameOverAlert = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:@"Game Over"
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"Okay", nil];
            [gameOverAlert show];
            
            // Indicate that the game should not continue.
            shouldContinue = NO;
            
            // Hide any unnecessary controls.
            [self startStopGame:nil];
        }
        
    }
    
    // The next part will be executed only if the game is still on.
    if (shouldContinue) {
        // Create a new random addition.
        [self createAddition];
        
        // Increase the round counter value by one.
        _currentAdditionCounter++;
        
        // If the counter becomes equal to the allowed additions per level, then set its initial value,
        // update the level and restart the timer.
        if (_currentAdditionCounter == additionsPerLevel) {
            _currentAdditionCounter = 0;
            [self updateLevelLabel];
            
            [_gameTimer invalidate];
            _gameTimer = nil;
            
            [self startTimer];
        }
    }
}

- (IBAction)showGCOptions:(id)sender {
    // Allow the action sheet to be displayed if only the gameCenterEnabled flag is true, meaning if only
    // a player has been authenticated.
    if (_gameCenterEnabled) {
        if (_customActionSheet != nil) {
            _customActionSheet = nil;
        }
        
        // Create a CustomActionSheet object and handle the tapped button in the completion handler block.
        _customActionSheet = [[CustomActionSheet alloc] initWithTitle:@""
                                                             delegate:nil
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"View Leaderboard", @"View Achievements", @"Reset Achievements", nil];
        [_customActionSheet showInView:self.view
                 withCompletionHandler:^(NSString *buttonTitle, NSInteger buttonIndex) {
                     
                     
                 }];
    }
}


#pragma mark - Private method implementation


-(void)initValues{
    // Set the initial values to all member variables.
    _timerValue = 0;
    _level = 0;
    _currentAdditionCounter = 0;
    _score = 0;
    _lives = 3;
}


-(void)startTimer{
    // Set the initial value to the timerValue property and start the timer.
    if (_gameTimer == nil) {
        _timerValue = 0;
        
        _gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateTimerLabel:)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    
}


-(void)updateTimerLabel:(NSTimer *)timer{
    // Increase the timer value and set it to the lblTime label.
    _timerValue++;
    
    [_lblTime setText:[NSString stringWithFormat:@"%d", _timerValue]];
    
    // If the timerValue value becomes greater than 60 then end the game.
    if (_timerValue > 60) {
        // Show a "Time is Up" message.
        UIAlertView *gameOverAlert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"Time is Up"
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Okay", nil];
        [gameOverAlert show];
        
        // Hide any unnecessary controls.
        [self startStopGame:nil];
    }
}


-(void)createAddition{
    // Generate two random integer numbers.
    _operand1 = arc4random() % 101;
    _operand2 = arc4random() % 21;
    
    // Create the addition string and set it to the lblAddition label.
    [_lblAddition setText:[NSString stringWithFormat:@"%d + %d", _operand1, _operand2]];
    
    // Calculate the correct result.
    int correctResult = _operand1 + _operand2;
    
    // Produce two more random results.
    int randomResult1 = arc4random() % 121;
    int randomResult2 = arc4random() % 121;
    
    // Pick randomly the button on which the correct answer will appear.
    int randomButton = arc4random() % 3;
    
    switch (randomButton) {
        case 0:
            [_btnAnswer1 setTitle:[NSString stringWithFormat:@"%d", correctResult] forState:UIControlStateNormal];
            [_btnAnswer2 setTitle:[NSString stringWithFormat:@"%d", randomResult1] forState:UIControlStateNormal];
            [_btnAnswer3 setTitle:[NSString stringWithFormat:@"%d", randomResult2] forState:UIControlStateNormal];
            break;
        case 1:
            [_btnAnswer1 setTitle:[NSString stringWithFormat:@"%d", randomResult1] forState:UIControlStateNormal];
            [_btnAnswer2 setTitle:[NSString stringWithFormat:@"%d", correctResult] forState:UIControlStateNormal];
            [_btnAnswer3 setTitle:[NSString stringWithFormat:@"%d", randomResult2] forState:UIControlStateNormal];
            break;
        case 2:
            [_btnAnswer1 setTitle:[NSString stringWithFormat:@"%d", randomResult1] forState:UIControlStateNormal];
            [_btnAnswer2 setTitle:[NSString stringWithFormat:@"%d", randomResult2] forState:UIControlStateNormal];
            [_btnAnswer3 setTitle:[NSString stringWithFormat:@"%d", correctResult] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}


-(void)updateLevelLabel{
    // Increase the level counter by 1 and show it to the level label.
    _level++;
    [_lblLevel setText:[NSString stringWithFormat:@"Level %d", _level]];
}


-(void)initLives{
    // Set the initial value to the lives property and make all images visible.
    _lives = 3;
    
    _imgLife1.hidden = NO;
    _imgLife2.hidden = NO;
    _imgLife3.hidden = NO;
}

@end
