//
//  ViewController.h
//  GKDemo
//
//  Created by Gabriel Theodoropoulos on 10/2/14.
//  Copyright (c) 2014 AppCoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lblScore;
@property (weak, nonatomic) IBOutlet UILabel *lblLevel;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblAddition;
@property (weak, nonatomic) IBOutlet UIButton *btnAnswer1;
@property (weak, nonatomic) IBOutlet UIButton *btnAnswer2;
@property (weak, nonatomic) IBOutlet UIButton *btnAnswer3;
@property (weak, nonatomic) IBOutlet UIImageView *imgLife1;
@property (weak, nonatomic) IBOutlet UIImageView *imgLife2;
@property (weak, nonatomic) IBOutlet UIImageView *imgLife3;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bbItemPlay;


- (IBAction)startStopGame:(id)sender;
- (IBAction)handleAnswer:(id)sender;
- (IBAction)showGCOptions:(id)sender;

@end
