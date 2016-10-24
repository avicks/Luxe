//
//  ServicesViewController.m
//  Luxe
//
//  Created by Alex Vickers on 8/2/16.
//
//

#import "ServicesViewController.h"
#import "SWRevealViewController.h"

@interface ServicesViewController ()

@end

@implementation ServicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
   SWRevealViewController *revealViewController = self.revealViewController;
   if( revealViewController ) {
      
      // set target for action of selecting sidebar button
      [self.sidebarButton setTarget: self.revealViewController];
      
      // reveal side menu if action button selected
      [self.sidebarButton setAction: @selector( revealToggle: )];
      
      // allow user to swipe to bring menu item in/out
      [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
   }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
