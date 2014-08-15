//
//  PokerViewController.h
//  iPoker
//
//  Created by Chaos on 14-8-14.
//  Copyright (c) 2014年 pku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PokerGame.h"
@interface PokerViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *startview;
@property (strong, nonatomic) IBOutlet UIButton *Deck;
@property (strong, nonatomic) IBOutlet UIView *DeskView;
@property (strong, nonatomic) PokerGame *game;
- (IBAction)getNewCard:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UIButton *passButton;
@property (strong, nonatomic) IBOutlet UIButton *shuffleButon;
@property (strong, nonatomic) IBOutlet UIButton *sortButton;
@property (strong, nonatomic) IBOutlet UILabel *TotalCardsArea;
@property (strong, nonatomic) IBOutlet UILabel *LastCardsArea;

- (IBAction)Sort:(id)sender;
- (IBAction)PASS:(id)sender;
- (IBAction)shuffle:(id)sender;


@end
