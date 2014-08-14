//
//  ViewController.m
//  iPoker
//
//  Created by 崔 逸卿 on 14-8-13.
//  Copyright (c) 2014年 pku. All rights reserved.
//

#import "ViewController.h"
#import "PokerViewController.h"
#import "PokerGame.h"
#import "AppDelegate.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UITextField *nickNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *IPTextField;
@property (nonatomic, assign) id currentResponder;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UITextField appearance] setTintColor:[UIColor blueColor]];
    // Do any additional setup after loading the view.
    UIImage*img =[UIImage imageNamed:@"background.jpg"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:img]];
    
    self.nickNameTextField.placeholder = @"昵称";
    self.IPTextField.placeholder = @"主机 IP";
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignOnTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:singleTap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)switchToPokerViewWithGame:(PokerGame *)game
{
    PokerViewController *pokerView = [[PokerViewController alloc] init];
    pokerView.game = game;
    [self.navigationController pushViewController:pokerView animated:YES];
}

- (IBAction)createGame:(id)sender
{
    NSLog(@"%@", self.nickNameTextField.text);
    NSLog(@"%@", self.IPTextField.text);
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    appDelegate.nickName = self.nickNameTextField.text;
    appDelegate.IPAddress = self.IPTextField.text;
    
    PokerGame *game = [[PokerGame alloc] initAsServer:YES toHost:@"localhost"];
    [self switchToPokerViewWithGame:game];
}


- (IBAction)joinGame:(id)sender
{
    PokerGame *game = [[PokerGame alloc] initAsServer:NO toHost:self.IPTextField.text];
    [self switchToPokerViewWithGame:game];
}

- (BOOL) textFieldShouldReturn:(UITextField *)theTextField
{
    if(theTextField == self.IPTextField || self.nickNameTextField){
        [theTextField resignFirstResponder];
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"hello");
    self.currentResponder = textField;
}

- (void)resignOnTap:(id)iSender {
    [[self view] endEditing:YES];
    [self.currentResponder resignFirstResponder];
}

@end