//
//  LoginViewController.m
//  Luxe
//
//  Created by Alex Vickers on 3/16/16.
//
//

#import "LoginViewController.h"
#import "SWRevealViewController.h"
#import "LuxeService.h"
#import "LuxeUser.h"

@implementation LoginViewController

#pragma mark - View Setup
- (void) viewDidLoad
{
   LuxeService *service = [LuxeService sharedInstance];
   /*
   CGRect r = [[self.navigationController view] frame];
   r.origin = CGPointMake(0.0f, -20.0f);
   r.size = CGSizeMake(r.size.width, r.size.height+20.0f);
   [[self.navigationController view] setFrame:r];
   */
   
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

   if([service isUserSignedIn]) {
      NSString *currentUserName = [service currentUser].publicID;
      [self setupLogoutButton];
      [self showWaitUI];
      [self hideLoginView];
      
      [service getTripHistory:currentUserName success:^(NSData *data) {
         [self hideWaitUI];
         [self loadAccountViewWithTrips:data];
      } failure:^(NSError *error) {
         [self hideWaitUI];
         
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Get Trip History"
                                                         message:error.localizedDescription
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
         
         [alert show];

      }];
      
   } else {
      [self showLoginView];
   }
}

#pragma mark - Actions

- (IBAction)didTapLogoutButton:(id)sender
{
   [self hideAccountView];
   [self showWaitUI];
   __weak typeof(self) weakSelf = self;
   LuxeService *service = [LuxeService sharedInstance];
   NSURL *URL = [NSURL URLWithString:@"http://luxelimousineservices.com/"];

   [service signOutUserWithURL:URL success:^{
      [weakSelf hideWaitUI];
      [weakSelf.delegate loginViewControllerSucceeded:weakSelf];
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout Successful!"
                                                      message:@"You have successfully logged out."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      
      [alert show];
      [self removeAccountView];
      [self viewDidLoad];

   } failure:^(NSError *error) {
      [weakSelf hideWaitUI];
      [self showAccountView];
      
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Sign-out"
                                                      message:error.localizedDescription
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      
      [alert show];
   }];
}

- (IBAction)didTapLoginButton:(id)sender
{
   [self hideLoginView];
   [self showWaitUI];
   
   __weak typeof(self) weakSelf = self;
   LuxeService *service = [LuxeService sharedInstance];
   
   //URL temp
   NSURL *URL = [NSURL URLWithString:@"http://luxelimousineservices.com/"];
   NSString *userName = @"";
   NSString *password = @"";
   
   [service signInWithUserName:userName password:password serverURL:URL success:^(LuxeUser *user) {
      [weakSelf hideWaitUI];
      [weakSelf.delegate loginViewControllerSucceeded:weakSelf];
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Successful!"
                                                      message:@"You have successfully logged in."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];

      [alert show];
      [self hideLoginView];
      [self viewDidLoad];

   } failure:^(NSError *error) {
      [weakSelf hideWaitUI];
      [self showLoginView];
      
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Sign-in"
                                                      message:error.localizedDescription
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      
      [alert show];
   }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   [textField resignFirstResponder];
   
   return YES;
}

#pragma mark - Private helpers
- (void)setupLogoutButton
{
   [self.logoutButton setTarget: self];
   [self.logoutButton setAction: @selector(didTapLogoutButton: )];
   
   [self.logoutButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIFont fontWithName:@"Circular" size:18.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
   [self.logoutButton setTitle:@"Logout"];
}

- (void)showWaitUI
{
   self.waitView.hidden = NO;
}

- (void)hideWaitUI
{
   self.waitView.hidden = YES;
}

/**
 Set up the login view
 */
-(void)showLoginView
{
   self.emailTextfield.delegate = self;
   self.passwordTextfield.delegate = self;
   
   
   [self.logoutButton setTitle:@""];
   
   self.loginView.hidden = NO;
   self.loginButton.hidden = NO;
   
   [self.loginButton.layer setBorderWidth:1.0];
   [self.loginButton.layer setBorderColor:[[UIColor colorWithRed:0.949  green:0.365  blue:0.349 alpha:1] CGColor]];
   
   NSAttributedString *emailPlaceholderString = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.690  green:0.722  blue:0.761 alpha:1] }];
   self.emailTextfield.attributedPlaceholder = emailPlaceholderString;
   
   NSAttributedString *passwordPlaceholderString = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.690  green:0.722  blue:0.761 alpha:1] }];
   self.passwordTextfield.attributedPlaceholder = passwordPlaceholderString;
}

-(void)hideLoginView
{
   self.loginView.hidden = YES;
   self.loginButton.hidden = YES;
}


-(void)hideAccountView
{
   self.accountScrollView.hidden = YES;
   self.accountHeader.hidden = YES;
}

-(void)showAccountView
{
   self.accountScrollView.hidden = NO;
   self.accountHeader.hidden = NO;
}

/**
 If the user logs out, remove views created for a logged in user.
 */
-(void)removeAccountView
{
   self.accountScrollView.hidden = YES;
   self.accountScrollView = nil;
   
   self.accountHeader.hidden = YES;
   self.accountHeader = nil;
}

/**
 If a user logs in successfully, display the recent trips.  If there are none,
 display a message saying so..
 
 */
-(void)loadAccountViewWithTrips: (NSData *)tripData
{
   LuxeService *service = [LuxeService sharedInstance];
   LuxeUser *currentUser = [service currentUser];
   
   NSError *error = nil;
   NSArray *tripArray =
      [NSJSONSerialization JSONObjectWithData:tripData options:0 error:&error];
   
   NSLog(@"%@",currentUser.name);
   NSLog(@"%li",tripArray.count);
   
   if(tripArray.count > 0) {
      
      self.accountHeader = [[UILabel alloc]
                            initWithFrame:CGRectMake(self.view.frame.origin.x, 100,
                                                     self.view.frame.size.width, 26)];
      
      self.accountHeader.text = [NSString stringWithFormat:@"RECENT TRIPS"];
      self.accountHeader.textAlignment = NSTextAlignmentCenter;
      self.accountHeader.font = [UIFont fontWithName:@"Circular" size:26.0];
      self.accountHeader.textColor = [UIColor whiteColor];
      
      [self.view addSubview:self.accountHeader];
      
      self.accountScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,150,self.view.frame.size.width,self.view.frame.size.height - 150)];
      
      self.accountScrollView.delegate = self;
      [self.accountScrollView setShowsHorizontalScrollIndicator:NO];
      [self.accountScrollView setShowsVerticalScrollIndicator:YES];
      self.accountScrollView.scrollEnabled = YES;
      self.accountScrollView.userInteractionEnabled = YES;
      
      [self.view addSubview:self.accountScrollView];
      
      self.accountScrollView.contentSize= CGSizeMake(self.view.frame.size.width,200*tripArray.count + 10);
      
      for(int i = 0; i < tripArray.count; i++) {
         CGFloat initY = 0 + 200*i;
         
         CGRect coordinates = CGRectMake(20.0, initY, self.view.frame.size.width - 40.0, 200);
         [self createTripViewWithCoordinates:coordinates tripObject:tripArray[i]];
      }
   } else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No trips found"
                                                      message:@"No recent trips were found. Go book one now!"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      
      [alert show];
   }
}

-(void)createTripViewWithCoordinates: (CGRect)coordinates
                              tripObject: (NSObject *)trip
{
   // clean up our trip data for display purposes
   NSArray *tripArray = [self cleanUpTripWithObject:trip];
   
   // create a view to display the trip information inside.
   UIView* tripView = [[UIView alloc] initWithFrame:coordinates];
   tripView.layer.borderColor = [UIColor whiteColor].CGColor;
   tripView.layer.borderWidth = 1.0f;
   
   
   UILabel *idLabel = [[UILabel alloc]
                       initWithFrame:CGRectMake((tripView.frame.size.width / 2 - 10),
                                                0, tripView.frame.size.width / 2, 20)];
   
   idLabel.text = [NSString stringWithFormat:@"TRIP ID: %@", tripArray[0]];
   idLabel.textAlignment = NSTextAlignmentRight;
   idLabel.font = [UIFont fontWithName:@"M+ 1p" size:10.0];
   idLabel.textColor = [UIColor colorWithRed:0.961  green:0.961  blue:0.969 alpha:0.5];
   
   UILabel *dateLabel = [[UILabel alloc]
                         initWithFrame:CGRectMake(5, 0, tripView.frame.size.width, 20)];
   
   dateLabel.text = [NSString stringWithFormat:@"Date: %@", tripArray[1]];
   dateLabel.textAlignment = NSTextAlignmentLeft;
   dateLabel.font = [UIFont fontWithName:@"M+ 1p" size:12.0];
   dateLabel.textColor = [UIColor colorWithRed:0.961  green:0.961  blue:0.969 alpha:0.5];
   
   UILabel *departureLabel = [[UILabel alloc]
                         initWithFrame:CGRectMake(5, 20, 49, 25)];
   
   departureLabel.text = [NSString stringWithFormat:@"From:"];
   departureLabel.textAlignment = NSTextAlignmentJustified;
   departureLabel.font = [UIFont fontWithName:@"M+ 1p" size:14.0];
   departureLabel.textColor = [UIColor whiteColor];
   departureLabel.numberOfLines = 0;
   
   UILabel *departureLabel2 = [[UILabel alloc]
                              initWithFrame:CGRectMake(55, 20, (3*tripView.frame.size.width)/4 - 10, 50)];
   
   departureLabel2.text = [NSString stringWithFormat:@"%@", tripArray[2]];
   departureLabel2.textAlignment = NSTextAlignmentJustified;
   departureLabel2.font = [UIFont fontWithName:@"M+ 1p" size:14.0];
   departureLabel2.textColor = [UIColor whiteColor];
   departureLabel2.numberOfLines = 0;
   
   UILabel *arrivalLabel = [[UILabel alloc]
                              initWithFrame:CGRectMake(5, 70, 49, 25)];
   
   arrivalLabel.text = [NSString stringWithFormat:@"To:"];
   arrivalLabel.textAlignment = NSTextAlignmentJustified;
   arrivalLabel.font = [UIFont fontWithName:@"M+ 1p" size:14.0];
   arrivalLabel.textColor = [UIColor whiteColor];
   arrivalLabel.numberOfLines = 0;
   
   UILabel *arrivalLabel2 = [[UILabel alloc]
                               initWithFrame:CGRectMake(55, 70, (3*tripView.frame.size.width)/4 - 10, 50)];
   
   arrivalLabel2.text = [NSString stringWithFormat:@"%@", tripArray[3]];
   arrivalLabel2.textAlignment = NSTextAlignmentJustified;
   arrivalLabel2.font = [UIFont fontWithName:@"M+ 1p" size:14.0];
   arrivalLabel2.textColor = [UIColor whiteColor];
   arrivalLabel2.numberOfLines = 0;
   
   UILabel *returnLabel = [[UILabel alloc]
                             initWithFrame:CGRectMake(5, 120, (3*tripView.frame.size.width)/4 - 10, 25)];
   
   returnLabel.text = [NSString stringWithFormat:@"Return Trip: %@", [tripArray[6] capitalizedString]];
   returnLabel.textAlignment = NSTextAlignmentJustified;
   returnLabel.font = [UIFont fontWithName:@"M+ 1p" size:12.0];
   returnLabel.textColor = [UIColor whiteColor];
   returnLabel.numberOfLines = 0;
   
   UILabel *passLabel = [[UILabel alloc]
                           initWithFrame:CGRectMake(5, 140, (3*tripView.frame.size.width)/4 - 10, 25)];
   
   passLabel.text = [NSString stringWithFormat:@"Passengers: %@", tripArray[4]];
   passLabel.textAlignment = NSTextAlignmentJustified;
   passLabel.font = [UIFont fontWithName:@"M+ 1p" size:12.0];
   passLabel.textColor = [UIColor whiteColor];
   passLabel.numberOfLines = 0;
   
   UILabel *childLabel = [[UILabel alloc]
                         initWithFrame:CGRectMake(5, 160, (3*tripView.frame.size.width)/4 - 10, 25)];
   
   childLabel.text = [NSString stringWithFormat:@"Children: %@", tripArray[4]];
   childLabel.textAlignment = NSTextAlignmentJustified;
   childLabel.font = [UIFont fontWithName:@"M+ 1p" size:12.0];
   childLabel.textColor = [UIColor whiteColor];
   childLabel.numberOfLines = 0;
   
   [tripView addSubview:childLabel];
   [tripView addSubview:passLabel];
   [tripView addSubview:returnLabel];
   [tripView addSubview:arrivalLabel];
   [tripView addSubview:arrivalLabel2];
   [tripView addSubview:departureLabel];
   [tripView addSubview:departureLabel2];
   [tripView addSubview:dateLabel];
   [tripView addSubview:idLabel];
   
   [self.accountScrollView addSubview:tripView];

}

-(NSArray *)cleanUpTripWithObject: (NSObject *)trip
{
   // create our initial string from the trip object
   NSString *tripString = [NSString stringWithFormat:@"%@", trip];

   // transform the string into an array, seperated by the newline characters
   NSArray *tripItems = [tripString componentsSeparatedByString:@"\n"];

   //NSLog(@"%@", tripItems);
   
   // clean the ID used for tracking trip purchases
   NSString *idString = [tripItems[2] stringByReplacingOccurrencesOfString:@" " withString:@""];
   idString = [idString stringByReplacingOccurrencesOfString:@"," withString:@""];
   
   //NSLog(@"%@", idString);
   
   // clean the time/date string of the trip
   NSString *timeString = [tripItems[3] stringByReplacingOccurrencesOfString:@" \"" withString:@""];
   timeString = [timeString stringByReplacingOccurrencesOfString:@"\"," withString:@""];
   
   NSRange range = [timeString rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
   timeString = [timeString stringByReplacingCharactersInRange:range withString:@""];

   //NSLog(@"%@", timeString);

   // clean the departure location string of the trip
   NSString *departureString = [tripItems[4] stringByReplacingOccurrencesOfString:@" \"" withString:@""];
   departureString = [departureString stringByReplacingOccurrencesOfString:@"\"," withString:@""];
   
   range = [departureString rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
   departureString = [departureString stringByReplacingCharactersInRange:range withString:@""];

   //NSLog(@"%@", departureString);
   
   // clean the arrival spot string of the trip
   NSString *arrivalString = [tripItems[5] stringByReplacingOccurrencesOfString:@" \"" withString:@""];
   arrivalString = [arrivalString stringByReplacingOccurrencesOfString:@"\"," withString:@""];
   
   range = [arrivalString rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
   arrivalString = [arrivalString stringByReplacingCharactersInRange:range withString:@""];
   
   //NSLog(@"%@", arrivalString);

   // clean the passenger count string for the trip
   NSString *passString = [tripItems[6] stringByReplacingOccurrencesOfString:@" " withString:@""];
   passString = [passString stringByReplacingOccurrencesOfString:@"," withString:@""];
   
   //NSLog(@"%@", passString);
   
   // clean the children count string for the trip
   NSString *childString = [tripItems[7] stringByReplacingOccurrencesOfString:@" " withString:@""];
   childString = [childString stringByReplacingOccurrencesOfString:@"," withString:@""];
   
   //NSLog(@"%@", childString);
   
   // clean the string that determines if the trip required a return for this trip
   NSString *returnString = [tripItems[8] stringByReplacingOccurrencesOfString:@" " withString:@""];
   returnString = [returnString stringByReplacingOccurrencesOfString:@"," withString:@""];
   
   //NSLog(@"%@", returnString);
   
   // finally, return our cleaned values in the array
   tripItems = @[idString, timeString, departureString, arrivalString, passString, childString, returnString];
   
   //NSLog(@"%@", tripItems);
   
   return tripItems;
}

@end

