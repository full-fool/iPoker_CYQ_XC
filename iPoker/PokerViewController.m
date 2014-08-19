//
//  PokerViewController.m
//  iPoker
//
//  Created by Chaos on 14-8-14.
//  Copyright (c) 2014年 pku. All rights reserved.
//
#import "PokerViewController.h"
#import "PokerGame.h"
#import "NSDictionary+JSONCategories.h"
#import "AppDelegate.h"
//#import "EmitterView.h"

@interface PokerViewController ()
#define interval @"0.1"
@end
@implementation PokerViewController{
    BOOL gamestart;
    UIImageView *newCard;
    NSInteger HandCardNum;
    NSInteger CardsNum;
    NSMutableArray *HandCards;
    NSMutableArray *SelectedHandCards;
    NSMutableArray *LastOutCards;
    NSMutableArray *TotalOutCards;
    NSMutableArray *viewCreated;
    UIPanGestureRecognizer *panGesture;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //    self.game = [[PokerGame alloc] initAsServer:YES toHost:@"localhost"];
    UIImage *img =[UIImage imageNamed:@"background.jpg"];   //set the background image;
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:img]];
    
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];

    if(appDelegate.isServer)
        self.game = [[PokerGame alloc] initAsServer:YES toHost:@"localhost"];
    else
    {
        self.game = [[PokerGame alloc] initAsServer:NO toHost:appDelegate.IPAddress];
        self.startButton.enabled = FALSE;

    }
    gamestart = false;
    self.passButton.enabled = FALSE;
    self.sortButton.enabled = FALSE;
    self.Deck.enabled = FALSE;
    self.shuffleButon.enabled = FALSE;  //disable these buttons before the game;
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(checkEvent) object:interval];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperation:operation];
}

//initializer of the UI, nothing to do with the model.
-(void)gameinitialize{
    self.startview.alpha = 0.0;  //hide the startview before the game;
    self.startview.image = [UIImage imageNamed:@"gamestart.png"];
    self.startview.layer.zPosition = 9999;
    
    HandCardNum = 0;
    CardsNum = 0;
    HandCards = [[NSMutableArray alloc] initWithObjects:newCard, nil];
    SelectedHandCards = [[NSMutableArray alloc] initWithObjects:newCard, nil];
    LastOutCards = [[NSMutableArray alloc] initWithObjects:newCard, nil];
    TotalOutCards = [[NSMutableArray alloc] initWithObjects:newCard, nil];
    viewCreated = [[NSMutableArray alloc] initWithObjects:newCard, nil];
    [HandCards removeAllObjects];
    [SelectedHandCards removeAllObjects];
    [LastOutCards removeAllObjects];
    [TotalOutCards removeAllObjects];
    [viewCreated removeAllObjects];   //just initialize these arrays;
    
    CGRect rect = CGRectMake(16,139,75,105);
    newCard= [[UIImageView alloc] initWithFrame:rect];
    newCard.tag = CardsNum ++;
    [viewCreated addObject: newCard];
    //emitterView = [[EmitterView alloc]initWithFrame:rect];
    //[newCard addSubview:emitterView];
    [newCard setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [newCard setImage:[UIImage imageNamed:@"cardback"]];
    newCard.userInteractionEnabled = YES;
    [self.view addSubview:newCard];
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
    [panGesture setMaximumNumberOfTouches:1];
    [panGesture setMinimumNumberOfTouches:1];
    panGesture.delaysTouchesEnded = NO;
    [newCard addGestureRecognizer:panGesture];   //initialize the first view in deck and add pangesture;
    
    //tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    //[tapGesture setNumberOfTapsRequired:1];
}

-(NSString*)findimagewithsuit:(NSInteger)suit withrank:(NSInteger)rank { //return image name according to suit and rank of the card;
    NSString *suitName[4] = {@"diamonds_",@"hearts_",@"clubs_",@"spades_"};
    NSString *rankName[16] = {@"",@"ace",@"two",@"three",@"four",@"five",@"six",@"seven",@"eight",@"nine",@"ten",@"jack",@"queen",@"king",@"joker_small",@"joker_big"};
    if(rank < 14)
        return [[NSString alloc] initWithFormat:@"%@%@",suitName[suit],rankName[rank]];
    else return rankName[rank];
}
-(void) sortcards:(NSMutableArray*)cards
{
    for(NSInteger i = 0;i < [cards count]; i ++)
    {
        for(NSInteger j = i + 1; j < [cards count]; j ++)
        {
            UIImageView *img1 = [cards objectAtIndex:i];
            UIImageView *img2 = [cards objectAtIndex:j];
            if(img1.tag > img2.tag)
                [cards exchangeObjectAtIndex:i withObjectAtIndex:j];
        }
    }
    return;
}
- (void)panDetected:(UIPanGestureRecognizer*)gestureRecognizer{
    switch ([gestureRecognizer state]) {
        case UIGestureRecognizerStateBegan:
            [self panBegan:gestureRecognizer];
            break;
        case UIGestureRecognizerStateChanged:
            [self panMoved:gestureRecognizer];
            break;
        case UIGestureRecognizerStateEnded:
            [self panEnded:gestureRecognizer];    //register handling functions;
            break;
        default:
            break;
    }
}

- (void)tapupDetected:(UITapGestureRecognizer*)gestureRecognizer{
    NSLog(@"tap up detected!!");
    [gestureRecognizer.view setCenter:CGPointMake(gestureRecognizer.view.center.x,gestureRecognizer.view.center.y - 18)];  //move up the view;
    [gestureRecognizer.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapdownDetected:)]];   //register tap-down pangesture;
    [SelectedHandCards addObject:gestureRecognizer.view];   //add into selectedhandcards;
    [gestureRecognizer.view removeGestureRecognizer:gestureRecognizer];  //remove tap-up pangesture;
}

//similar to tapupDetected()
- (void)tapdownDetected:(UITapGestureRecognizer*)gestureRecognizer{
    NSLog(@"tap down detected!!");
    [gestureRecognizer.view setCenter:CGPointMake(gestureRecognizer.view.center.x,gestureRecognizer.view.center.y + 18)];
    [gestureRecognizer.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapupDetected:)]];
    [SelectedHandCards removeObject:gestureRecognizer.view];
    [gestureRecognizer.view removeGestureRecognizer:gestureRecognizer];
}

- (void)swipeupDetected:(UISwipeGestureRecognizer*)gestureRecognizer{
    NSLog(@"swipe up detected!!");
    if(gestureRecognizer.direction == UISwipeGestureRecognizerDirectionUp || gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight){
        //only when swipe direction is up or right then go on;
        NSUInteger selectedNum = SelectedHandCards.count;
        [self sortcards:SelectedHandCards];
        [UIView animateWithDuration:0.5 animations:^{
            if([LastOutCards count] != 0)
                //move last-out cards to total-out cards;
            {
                for(NSInteger k = [TotalOutCards count] - 1;k >= 0; k --)
                {
                    [UIView animateWithDuration:0.4 animations:^{
                        UIImageView *view = [TotalOutCards objectAtIndex:k];
                        view.center = CGPointMake(self.Deck.center.x, 73);
                        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:view cache:YES];
                        [view setImage:[UIImage imageNamed:@"cardback"]];//set background image for the card view;
                    }];
                }
                [TotalOutCards removeAllObjects];
                for(int i = 0;i < LastOutCards.count; ++ i)
                    [TotalOutCards addObject:[LastOutCards objectAtIndex:i]];
                for(int i = 0;i < TotalOutCards.count; ++ i)
                    ((UIView *)[TotalOutCards objectAtIndex:i]).center = CGPointMake(((UIView *)[TotalOutCards objectAtIndex:i]).center.x, 73);
                
                NSMutableArray *cards = [[NSMutableArray alloc] init];
                PokerDeck *deck = [self.game.decks objectForKey:@"deck-2"];
                for(NSInteger k = 0;k < [LastOutCards count];k ++)
                {
                    PokerCard *card = [deck removeCardAtTag:((UIImageView *)[LastOutCards objectAtIndex:k]).tag];
                    [[self.game.decks objectForKey:@"deck-3"] insertCard:card atIndex:0];
                    [cards addObject:card];
                }
                [self.game moveCards:cards toDeck:[self.game.decks objectForKey:@"deck-3"]atIndex:0];
                [LastOutCards removeAllObjects];
            }
            if(114 + self.Deck.frame.size.width / 3 * (SelectedHandCards.count - 1) > 218){  //too many views so that reducing the distance between views of last-out cards is needed;
                NSUInteger distance = (218 - 114)/(SelectedHandCards.count - 1); //calculate new distance;
                for(int i = 0;i < selectedNum; ++ i)
                {
                    [[SelectedHandCards objectAtIndex:i] setCenter:CGPointMake(151.5 + distance * i, 191.5)];
                    [HandCards removeObject:[SelectedHandCards objectAtIndex:i]];
                    //if(i != 0)
                    //    ((UIView *)[SelectedHandCards objectAtIndex:i]).layer.zPosition = ((UIView *)LastOutCards.lastObject).layer.zPosition + 1;
                    [LastOutCards addObject:[SelectedHandCards objectAtIndex:i]];
                    HandCardNum --;
                }
            }
            else{  //few views added,just put them to the end;
                for(int i = 0;i < selectedNum; ++ i)
                {
                    [[SelectedHandCards objectAtIndex:i] setCenter:CGPointMake(151.5 + self.Deck.frame.size.width / 3 * i, 191.5)];
                    [HandCards removeObject:[SelectedHandCards objectAtIndex:i]];
                    //if(i != 0)
                    //    ((UIView *)[SelectedHandCards objectAtIndex:i]).layer.zPosition = ((UIView *)LastOutCards.lastObject).layer.zPosition + 1;
                    [LastOutCards addObject:[SelectedHandCards objectAtIndex:i]];
                    HandCardNum --;
                }
            }
            if(self.Deck.center.x + self.Deck.frame.size.width / 3 * (HandCardNum - 1) > [[UIScreen mainScreen] bounds].size.width - self.Deck.center.x) //rearrange views of handcards;
            {
                NSUInteger distance = ([[UIScreen mainScreen] bounds].size.width - 2 * self.Deck.center.x) / (HandCardNum - 1);
                for(int i = 0;i < HandCardNum; ++ i)
                    [[HandCards objectAtIndex:i] setCenter:CGPointMake(self.Deck.center.x + distance * i, 420)];
            }
            else{
                for(int i = 0;i < HandCardNum; ++ i)
                    [[HandCards objectAtIndex:i] setCenter:CGPointMake(self.Deck.center.x + self.Deck.frame.size.width / 3 * i, 420)];
            }
            NSMutableArray *cards = [[NSMutableArray alloc] init];
            PokerDeck *deck = [self.game.decks objectForKey:@"deck-1"];
            for(NSInteger k = 0;k < [SelectedHandCards count];k ++)
            {
                PokerCard *card = [deck removeCardAtTag:((UIImageView *)[SelectedHandCards objectAtIndex:k]).tag];
                [[self.game.decks objectForKey:@"deck-2"] insertCard:card atIndex:0];
                [cards addObject:card];
            }
            [self.game moveCards:cards toDeck:[self.game.decks objectForKey:@"deck-2"]atIndex:0];
        } completion:^(BOOL finish){
            if(finish == true){
                for(int i = 0;i < LastOutCards.count; ++ i)
                {
                    for(UIGestureRecognizer * tmp in [((UIView *)[LastOutCards objectAtIndex:i]) gestureRecognizers])
                        [((UIView *)[LastOutCards objectAtIndex:i]) removeGestureRecognizer:tmp];
                    [((UIView *)[LastOutCards objectAtIndex:i]) addGestureRecognizer:[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedownDetected:)]];  //remove swipe-up pangesture and add swipe-down pangesture for new last-out cards;
                }
            }
        }
         ];
        [SelectedHandCards removeAllObjects];
    }
}

//similar to swipeupDetected();
- (void)swipedownDetected:(UISwipeGestureRecognizer*)gestureRecognizer{
    NSLog(@"swipe down detected!!");
    if(gestureRecognizer.direction == UISwipeGestureRecognizerDirectionDown || gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight){
        for(UIImageView *view in LastOutCards)
            [HandCards addObject:view];
        [self sortcards:HandCards];
        HandCardNum = [HandCards count];
        [UIView animateWithDuration:0.5 animations:^{
            NSUInteger distance = self.Deck.frame.size.width / 3;
            if(self.Deck.center.x + self.Deck.frame.size.width / 3 * (HandCardNum - 1) > [[UIScreen mainScreen] bounds].size.width - self.Deck.center.x) //too many views so that reducing the distance between views of handcards is needed;
                distance = ([[UIScreen mainScreen] bounds].size.width - 2 * self.Deck.center.x) / (HandCardNum - 1);
            for(int i = 0;i < HandCardNum; ++ i)
                [[HandCards objectAtIndex:i] setCenter:CGPointMake(self.Deck.center.x + distance * i, 420)];
            for(int i = 0; i < HandCards.count; ++ i){
                //if(i > 0)
                //    ((UIView *)[HandCards objectAtIndex:i]).layer.zPosition = ((UIView *)[HandCards objectAtIndex:i - 1]).layer.zPosition + 1;
                for(UIGestureRecognizer * tmp in [((UIView *)[HandCards objectAtIndex:i]) gestureRecognizers])
                    [((UIView *)[HandCards objectAtIndex:i]) removeGestureRecognizer:tmp];
                [((UIView *)[HandCards objectAtIndex:i]) addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapupDetected:)]];
                [((UIView *)[HandCards objectAtIndex:i]) addGestureRecognizer:[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeupDetected:)]];
                //NSLog(@"%f",((UIView *)[HandCards objectAtIndex:i]).layer.zPosition);
            }
            NSMutableArray *cards = [[NSMutableArray alloc] init];
            PokerDeck *deck = [self.game.decks objectForKey:@"deck-2"];
            for(NSInteger k = 0;k < [LastOutCards count];k ++)
            {
                PokerCard *card = [deck removeCardAtTag:((UIImageView *)[LastOutCards objectAtIndex:k]).tag];
                [[self.game.decks objectForKey:@"deck-1"] insertCard:card atIndex:0];
                [cards addObject:card];
            }
            [self.game moveCards:cards toDeck:[self.game.decks objectForKey:@"deck-1"]atIndex:0];
        } completion:^(BOOL finish){
            [LastOutCards removeAllObjects];
            [SelectedHandCards removeAllObjects];
        }
         ];
    }
}

//called when the card starts moving
- (void)panBegan:(UIPanGestureRecognizer*)gestureRecognizer{

}

//called when the card is moving
- (void)panMoved:(UIPanGestureRecognizer*)recognizer{
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

//called when the card ends moving, user's finger lift up
- (void)panEnded:(UIPanGestureRecognizer*)gestureRecognizer{
    if(newCard.center.x > self.Deck.center.x + self.Deck.frame.size.width / 2 || newCard.center.x < self.Deck.center.x - self.Deck.frame.size.width / 2 || newCard.center.y > self.Deck.center.y + self.Deck.frame.size.height / 2 || newCard.center.y < self.Deck.center.y - self.Deck.frame.size.height / 2)
    {    //if the selected view is moved off the deck then go on;
        HandCardNum ++;
        [HandCards addObject:newCard];
        //NSLog(@"%f",newCard.layer.zPosition);
        [UIView animateWithDuration:0.5 animations:^{
            NSUInteger xLocation = self.Deck.center.x;
            if(xLocation + self.Deck.frame.size.width / 3 * (HandCardNum - 1) > [[UIScreen mainScreen] bounds].size.width - self.Deck.center.x) //too many views so that reducing the distance between views of handcards is needed;
            {
                NSUInteger distance = ([[UIScreen mainScreen] bounds].size.width - 2 * self.Deck.center.x) / (HandCardNum - 1);
                for(int i = 0;i < HandCardNum - 1; ++ i)
                    [[HandCards objectAtIndex:i] setCenter:CGPointMake(xLocation + distance * i, 420)];
                xLocation += distance * (HandCardNum - 1);
            }
            else  //few views,just put new card to the end;
                xLocation += self.Deck.frame.size.width / 3 * (HandCardNum - 1);
            [newCard setCenter:CGPointMake(xLocation, 420)];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:newCard cache:YES];
            NSMutableArray *cards = [[NSMutableArray alloc] init];
            PokerDeck* deck  = [self.game.decks objectForKey:@"deck-0"];
            PokerCard *card = [deck removeCardAtIndex:0];
            [newCard setImage:[UIImage imageNamed:[self findimagewithsuit:card.suit withrank:card.rank]]];//set background image for the card view;
            card.tag = newCard.tag;
            [[self.game.decks objectForKey:@"deck-1"] insertCard:card atIndex:0];//insert into handdeck;
            [cards addObject:card];
            [self.game moveCards:cards toDeck:[self.game.decks objectForKey:@"deck-1"] atIndex:0];//send message to host;
        } completion:^(BOOL finish){
            //[UIView beginAnimations:@"animation" context:nil];
            //[UIView setAnimationDuration:0.5];
            //[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            //[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:newCard cache:YES];
            //[UIView commitAnimations];
            CGRect rect = CGRectMake(16,139,75,105);
            [[HandCards lastObject] removeGestureRecognizer:panGesture];
            [[HandCards lastObject] addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapupDetected:)]];
            [[HandCards lastObject] addGestureRecognizer:[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeupDetected:)]];
           
            if(![[self.game.decks objectForKey:@"deck-0"] isEmpty]){
                newCard= [[UIImageView alloc] initWithFrame:rect];
                newCard.tag = CardsNum ++;
                [viewCreated addObject: newCard];
                [newCard setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
                [newCard setImage:[UIImage imageNamed:@"cardback"]];
                newCard.userInteractionEnabled = YES;
                [self.view addSubview:newCard];
                [newCard addGestureRecognizer:panGesture];
            }
            else{   //basedeck is empty,then hide the deck button;
                self.Deck.enabled = false;
                self.Deck.alpha = 0;
            }
        }
         ];
    }
    else {  // if the view moved a little
        [UIView animateWithDuration:0.2 animations:^{
            [newCard setCenter:CGPointMake(53.5, 191.5)];  // move it back to deck;
        } completion:nil
         ];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startGame:(id)sender
{
    if(!gamestart){
        [self gameinitialize];
        [self.game begin];
        self.passButton.enabled = TRUE;
        self.sortButton.enabled = TRUE;
        self.Deck.enabled = TRUE;
        self.shuffleButon.enabled = TRUE;
        [self.game allocDeck];
        [self.game allocDeck];  //deck-0:basedeck,deck-1:handdeck,deck-2:last-out deck,deck-3:total-out deck;
        //[UIView animateWithDuration:5 animations:^{
        //[_startButton setTitle:@"" forState:normal];
        //[_startButton setCenter:CGPointMake(162, 207)];
        //self.startview.alpha = 1.0;
        //[_startButton setBackgroundImage:[UIImage imageNamed:@"gamestart.png"]forState:normal];
        //} completion:nil];
        
        [UIView animateWithDuration:0.5 animations:^{   //display the startview;
            self.startview.alpha = 1.0;
        } completion:^(BOOL finish){
            [UIView animateWithDuration:1.0 animations:^{
                self.startview.alpha = 0.0;
            } completion:^(BOOL finish){
                //[_startButton setEnabled:false];
                [_startButton setTitle:@"下一局" forState:UIControlStateNormal];
                [_startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                gamestart = true;  //change start button
                [_TotalCardsArea removeFromSuperview];
                [_LastCardsArea removeFromSuperview];   //remove TotalCardsArea and LastCardsArea;
                //[_TotalCardsArea.layer setOpacity:0];
                //[_LastCardsArea.layer setOpacity:0];
            }];
        }];
    }
    else {
        [self.game reset];
        self.Deck.alpha = 1.0;
        for(NSUInteger i = 0; i < [viewCreated count]; ++ i)
            [[viewCreated objectAtIndex:i] removeFromSuperview];
        [HandCards removeAllObjects];
        [SelectedHandCards removeAllObjects];
        [viewCreated removeAllObjects];
        [LastOutCards removeAllObjects];
        [_startButton setTitle:@"开始游戏" forState:UIControlStateNormal];
        [_startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        gamestart = false;
        self.passButton.enabled = FALSE;
        self.sortButton.enabled = FALSE;
        self.Deck.enabled = FALSE;
        self.shuffleButon.enabled = FALSE;
    }
}

- (UIImageView *)GetViewWithTag:(NSInteger)tag in:(NSMutableArray *)cards{
    for(UIImageView *view in cards)
    {
        if(view.tag == tag)
            return view;
        else continue;
    }
    return nil;
}
- (void)UpdateGame:(PokerPlayer *)player movecards:(NSArray *)cards toDeck:(PokerDeck *)deck atIndex:(NSInteger) index{
    PokerDeck *basedeck = [self.game.decks objectForKey:@"deck-0"];
    PokerDeck *totaloutdeck = [self.game.decks objectForKey:@"deck-3"];
    if([deck.ID  isEqual: @"deck-1"])
    {
        if([cards count] == 1)
        {
            NSDictionary *dict = [NSDictionary dictionaryWithString:[cards objectAtIndex:0]];
            NSString *cardID = [dict valueForKey:@"ID"];
            PokerCard *card = [self.game getCardWithId:cardID];
            if([basedeck HaveCard:card])
              [basedeck removeCard:card];//If someone get a card from basedeck,remove it from model;
            else if([totaloutdeck HaveCard:card])
            {
                for(UIImageView * view in TotalOutCards)
                {
                    [view removeFromSuperview];
                    [totaloutdeck removeCardAtTag:view.tag];
                }
                [TotalOutCards removeAllObjects];
            }
            else
                NSLog(@"No card for id %@!",card.ID);
        }
        else
        {
            for(UIImageView * view in TotalOutCards)
            {
                [view removeFromSuperview];
                [totaloutdeck removeCardAtTag:view.tag];
            }
            [TotalOutCards removeAllObjects];//If some one get back its lastoutcards,remove them from totaloutcards;
        }
    }
    else if([deck.ID  isEqual: @"deck-2"])//some one plays some cards
    {
        for(NSInteger k = [TotalOutCards count] - 1;k >= 0; k --)
        {
            [UIView animateWithDuration:0.4 animations:^{
                UIImageView *view = [TotalOutCards objectAtIndex:k];
                view.center = CGPointMake(self.Deck.center.x, 73);
                [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:view cache:YES];
                [view setImage:[UIImage imageNamed:@"cardback"]];//set background image for the card view;
            }];
        }
        [TotalOutCards removeAllObjects];//first,move totaloutcards to discard deck;
        for(NSString *str in cards)
        {
            NSDictionary *dict = [NSDictionary dictionaryWithString:str];
            NSString *cardID = [dict valueForKey:@"ID"];
            PokerCard *card = [self.game getCardWithId:cardID];
            CGRect rect = CGRectMake(16,139,75,105);
            UIImageView *newview = [[UIImageView alloc] initWithFrame:rect];
            [newview setImage:[UIImage imageNamed:[self findimagewithsuit:card.suit withrank:card.rank]]];
            [newview setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
            [TotalOutCards addObject:newview];
            [viewCreated addObject:newview];
            [self.view addSubview:newview];
        }//create these cards' views and add them to totaloutcards;
        if(114 + self.Deck.frame.size.width / 3 * (TotalOutCards.count - 1) > 218){  //too many views so that reducing the distance between views of last-out cards is needed;
            NSUInteger distance = (218 - 114)/(TotalOutCards.count - 1); //calculate new distance;
            for(int i = 0;i < TotalOutCards.count; ++ i)
                [[TotalOutCards objectAtIndex:i] setCenter:CGPointMake(151.5 + distance * i, 73)];
        }
        else{  //few views added,just put them to the end;
            for(int i = 0;i < TotalOutCards.count; ++ i)
                [[SelectedHandCards objectAtIndex:i] setCenter:CGPointMake(151.5 + self.Deck.frame.size.width / 3 * i, 73)];
        }//arrange new views in totaloutcards;
    }
    else if([deck.ID  isEqual: @"deck-3"])
        return;//nothing to do
}
/// Check event queue status
- (void)checkEvent
{
    while(true){
    NSMutableArray *queue = self.game.eventQueue;
    NSString *event = nil;
    @synchronized(queue) {
        if ([queue count] == 0)
            continue;
        NSLog(@"the queue is not empty, it has %lu events", (unsigned long)[queue count]);
        event = [queue firstObject];
        [queue removeObjectAtIndex:0];
    }
    NSDictionary *dict = [NSDictionary dictionaryWithString:event];
    NSString *action = [dict valueForKey:@"action"];
    NSString *playerID = [dict valueForKey:@"playerID"];
    PokerPlayer *player = [self.game getPlayerWithId:playerID];
    NSLog(@"in checkevent, the action is %@ and playerID is %@", action, playerID);
    if(self.game.player.ID == playerID && playerID != NULL)
        continue;
    if ([action isEqualToString:@"moveCards"]) {
        [self UpdateGame:player movecards:[dict valueForKey:@"cards"] toDeck:[self.game getDeckWithId:[dict valueForKey:@"deckID"]] atIndex:[[dict valueForKey:@"index"] intValue]];
    }
    else if ([action isEqualToString:@"init"]) {
        if(!self.game.isServer)
            [self startGame:nil];
        //[self.game didInitWithDictionary:dict];
    } else if ([action isEqualToString:@"allocPID"]) {
        //NSLog(@"in checkevent, the action is exactly allocPID")
        [self.game didAllocPID:event];
    } else if ([action isEqualToString:@"shuffle"]) {
        [self.game shuffle:[self.game.decks objectForKey:@"deck-0"]];
        //PokerDeck *deck = [self.game getDeckWithId:[dict valueForKey:@"deckID"]];
        //[self.game didPlayer:player shuffleDeck:deck];
    } else if ([action isEqualToString:@"sort"]) {
        return;
        //PokerDeck *deck = [self.game getDeckWithId:[dict valueForKey:@"deckID"]];
        //[self.game didPlayer:player sortDeck:deck];
    }else if ([action isEqualToString:@"pass"]) {
        return;
        //PokerDeck *deck = [self.game getDeckWithId:[dict valueForKey:@"deckID"]];
        //[self.game didPlayer:player sortDeck:deck];
    }
    else {
        //@throw [[NSException alloc] initWithName:@"NotValidAction" reason:nil userInfo:nil];
    }
       
        
       // NSLog(@"test");
    }
}

- (IBAction)Sort:(id)sender {  //only sort handcards;
    PokerDeck *deck =[self.game.decks objectForKey:@"deck-1"];
    [deck sort];
    for(NSInteger i = 0;i < HandCards.count;i ++){
        [((UIImageView *)[HandCards objectAtIndex:i]) setImage:[UIImage imageNamed:[self findimagewithsuit:[deck getCardAtIndex:i].suit withrank:[deck getCardAtIndex:i].rank]]];
    }
    [self.game sort:deck];
}

- (IBAction)PASS:(id)sender {
    [self.game pass];
}

- (IBAction)shuffle:(id)sender {
    PokerDeck *deck = [self.game.decks objectForKey:@"deck-0"];
    [deck shuffle];
    [self.game shuffle:deck];
}
@end
