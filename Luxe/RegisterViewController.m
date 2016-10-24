//
//  RegisterViewController.m
//  Luxe
//
//  Created by Alex Vickers on 8/10/16.
//
//

#import "RegisterViewController.h"
#import "SWRevealViewController.h"
#import "LuxeService.h"

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
   [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                 forBarMetrics:UIBarMetricsDefault];
   self.navigationController.navigationBar.shadowImage = [UIImage new];
   self.navigationController.navigationBar.translucent = YES;
   self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
   self.navigationController.view.backgroundColor = [UIColor clearColor];
   self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];

   SWRevealViewController *revealViewController = self.revealViewController;
   if( revealViewController ) {
      
      // set target for action of selecting sidebar button
      [self.sidebarButton setTarget: self.revealViewController];
      
      // reveal side menu if action button selected
      [self.sidebarButton setAction: @selector( revealToggle: )];
      
      // allow user to swipe to bring menu item in/out
      [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
   }
   
   [self setUpRegisterView];
   
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   [textField resignFirstResponder];
   
   return YES;
}

- (void)setUpRegisterView
{
   self.emailTextField.delegate = self;
   self.passwordTextField.delegate = self;
   self.repeatPasswordTextField.delegate = self;
   
   self.registerView.hidden = NO;
  
   
   NSAttributedString *emailPlaceholderString = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.690  green:0.722  blue:0.761 alpha:1] }];
   self.emailTextField.attributedPlaceholder = emailPlaceholderString;
   
   NSAttributedString *passwordPlaceholderString = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.690  green:0.722  blue:0.761 alpha:1] }];
   self.passwordTextField.attributedPlaceholder = passwordPlaceholderString;
   
   NSAttributedString *repeatPasswordPlaceholderString = [[NSAttributedString alloc] initWithString:@"Repeat Password" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.690  green:0.722  blue:0.761 alpha:1] }];
   self.repeatPasswordTextField.attributedPlaceholder = repeatPasswordPlaceholderString;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didHitRegister:(id)sender
{
   [self hideRegisterView];
   [self showWaitUI];
   NSString *email = self.emailTextField.text;
   NSString *password = self.passwordTextField.text;
   NSString *repeatPassword = self.repeatPasswordTextField.text;
   NSString *whitespaceChecker = [self.passwordTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
   
   if(!email.length) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Email"
                                                      message:@"Please enter a valid email!"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      
      [alert show];
      
      [self hideWaitUI];
      [self showRegisterView];
   } else if(!password.length) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Password"
                                                      message:@"Please enter a valid password!"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      
      [alert show];
      
      [self hideWaitUI];
      [self showRegisterView];
   } else if(password.length != whitespaceChecker.length) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Password"
                                                      message:@"Please do not use spaces in your password."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      
      [alert show];
      
      [self hideWaitUI];
      [self showRegisterView];
   } else if(![self isPasswordValid:password]) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Password"
                                                      message:@"Please enter a valid password."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      
      [alert show];
      
      [self hideWaitUI];
      [self showRegisterView];
   } else if(password.length != repeatPassword.length) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Password"
                                                      message:@"The passwords do not match."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      
      [alert show];
      
      [self hideWaitUI];
      [self showRegisterView];
   } else {
      __weak typeof(self) weakSelf = self;
      LuxeService *service = [LuxeService sharedInstance];
      
      //URL temp
      NSURL *URL = [NSURL URLWithString:@"http://luxelimousineservices.com/"];
      [service registerNewUserWithName:email password:password serverURL:URL success:^(NSData *data) {
         [weakSelf hideWaitUI];
         [weakSelf.delegate registerViewControllerSucceeded:self];
         
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Successful!"
                                                         message:@"You have successfully registered."
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
         
         [alert show];
         
         [self showRegisterView];
      } failure:^(NSError *error) {
         [weakSelf hideWaitUI];
         
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Failed"
                                                         message:error.localizedDescription
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
         [alert show];
         
         [self showRegisterView];
      }];
   }
}

- (void) hideRegisterView {
   self.registerView.hidden = YES;
}

- (void) showRegisterView {
   self.registerView.hidden = NO;
}

- (void) showWaitUI {
   self.waitView.hidden = NO;
}

- (void) hideWaitUI {
   self.waitView.hidden = YES;
}

- (BOOL)isPasswordValid:(NSString*)password
{
   NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"^.*(?=.{6,})(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).*$" options:0 error:nil];
   return [regex numberOfMatchesInString:password options:0 range:NSMakeRange(0, [password length])] > 0;
}

@end
