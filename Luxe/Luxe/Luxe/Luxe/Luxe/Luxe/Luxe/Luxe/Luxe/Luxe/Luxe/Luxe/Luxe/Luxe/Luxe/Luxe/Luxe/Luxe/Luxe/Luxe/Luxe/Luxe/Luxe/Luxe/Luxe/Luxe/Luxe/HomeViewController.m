//
//  ViewController.m
//  Luxe
//
//  Created by Alex Vickers on 2/3/16.
//
//

#import "HomeViewController.h"
#import "SWRevealViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
   [super viewDidLoad];
   // Do any additional setup after loading the view, typically from a nib.
   self.title = @"Home";
   
   //NSLog(@"origin of nav %f", self.navigationController.navigationBar.frame.origin.y);
   
   // used to properly set the nav bar up top ..
   CGRect r = [[self.navigationController view] frame];
   r.origin = CGPointMake(0.0f, -30.0f);
   [[self.navigationController view] setFrame:r];
   
   SWRevealViewController *revealViewController = self.revealViewController;
   if( revealViewController ) {
      
      // set target for action of selecting sidebar button
      [self.sidebarButton setTarget: self.revealViewController];
      
      // reveal side menu if action button selected
      [self.sidebarButton setAction: @selector( revealToggle: )];
      
      // allow user to swipe to bring menu item in/out
      [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
   }
   
   UIImageView *headerImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.bounds.size.height, self.navigationController.view.bounds.size.width, 200)];
   headerImage.backgroundColor = [UIColor whiteColor];
   
   NSLog(@"origin of image %f", headerImage.frame.origin.y);
   NSLog(@"origin of nav %f", self.navigationController.navigationBar.bounds.size.height);


   [self.view addSubview:headerImage];
   
}

- (void) viewDidAppear:(BOOL)animated {

}

- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning];
   // Dispose of any resources that can be recreated.
}

@end
