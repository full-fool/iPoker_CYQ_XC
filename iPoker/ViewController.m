//  ViewController.m


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
}

///called when the user of server device touches the "创建游戏" button
- (IBAction)createGame:(id)sender
{
    NSLog(@"%@", self.nickNameTextField.text);
    NSLog(@"%@", self.IPTextField.text);
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    appDelegate.nickName = self.nickNameTextField.text;
    appDelegate.IPAddress = self.IPTextField.text;
    appDelegate.isServer = YES;
    if(appDelegate.nickName == nil || [appDelegate.nickName  isEqual: @""])
    {
        NSLog(@"No NickName!");
    }
    else if(appDelegate.IPAddress == nil || [appDelegate.IPAddress  isEqual: @""])
    {
        NSLog(@"No IPAddress!");
    }
    else {
        NSLog(@"%@ create game %@.",appDelegate.nickName,appDelegate.IPAddress);
    }

}


///called when the user of client device touches the "加入游戏" button
- (IBAction)joinGame:(id)sender
{
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    appDelegate.nickName = self.nickNameTextField.text;
    appDelegate.IPAddress = self.IPTextField.text;
    appDelegate.isServer = NO;
    if(appDelegate.nickName == nil || [appDelegate.nickName  isEqual: @""])
    {
        NSLog(@"No NickName!");
    }
    else if(appDelegate.IPAddress == nil || [appDelegate.IPAddress  isEqual: @""])
    {
        NSLog(@"No IPAddress!");
    }
    else {
        NSLog(@"%@ join game %@.",appDelegate.nickName,appDelegate.IPAddress);
    }
}

///called before the textField return
- (BOOL) textFieldShouldReturn:(UITextField *)theTextField
{
    if(theTextField == self.IPTextField || self.nickNameTextField){
        [theTextField resignFirstResponder];
    }
    return YES;
}

///called when touch begins
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

///called when user touches the TextField
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentResponder = textField;
}

///called when user touches field in screen other than TextField
- (void)resignOnTap:(id)iSender {
    [[self view] endEditing:YES];
    [self.currentResponder resignFirstResponder];
}

@end