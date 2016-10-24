//
//  ViewController.m
//  Luxe
//
//  Created by Alex Vickers on 2/3/16.
//
//

#import "HomeViewController.h"
#import "SWRevealViewController.h"
#import "LuxeService.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)awakeFromNib
{
   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(authenticationRequired:)
                                                name:LuxeServiceAuthRequiredNotification
                                              object:nil];
}

- (void)viewDidLoad {
   
   CGRect r = [[self.navigationController view] frame];
   r.origin = CGPointMake(0.0f, -20.0f);
   r.size = CGSizeMake(r.size.width, r.size.height+20.0f);
   [[self.navigationController view] setFrame:r];

   [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                 forBarMetrics:UIBarMetricsDefault];
   self.navigationController.navigationBar.shadowImage = [UIImage new];
   self.navigationController.navigationBar.translucent = YES;
   self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
   self.navigationController.view.backgroundColor = [UIColor clearColor];
   self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
   
   
   _pageImages = @[@"philly.png", @"bridge", @"urban_1.png", @"driver.png"];
   
   // Create page view controller
   self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
   self.pageViewController.dataSource = self;
   
   HomePageContentViewController *startingViewController = [self viewControllerAtIndex:0];
   NSArray *viewControllers = @[startingViewController];
   [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
   
   // Change the size of page view controller
   self.pageViewController.view.frame =
      CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 40.0f);
   
   [self addChildViewController:_pageViewController];
   [self.view addSubview:_pageViewController.view];
   [self.pageViewController didMoveToParentViewController:self];
   

   SWRevealViewController *revealViewController = self.revealViewController;
   if( revealViewController ) {
      
      // set target for action of selecting sidebar button
      [self.sidebarButton setTarget: self.revealViewController];
      
      // reveal side menu if action button selected
      [self.sidebarButton setAction: @selector( revealToggle: )];
      
      // allow user to swipe to bring menu item in/out
      [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
   }
   
   self.pageViewController.delegate = self;
   
   [self.view bringSubviewToFront:self.homePageControl];
   [self.view bringSubviewToFront:self.serviceButton];
   [self.view bringSubviewToFront:self.bookButton];

}

- (void) viewDidAppear:(BOOL)animated {

}

- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning];
   // Dispose of any resources that can be recreated.
}

- (HomePageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
   if (([self.pageImages count] == 0) || (index >= [self.pageImages count])) {
      return nil;
   }
   
   // Create a new view controller and pass suitable data.
   HomePageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
   pageContentViewController.imageName = self.pageImages[index];
   
   pageContentViewController.pageIndex = index;
   
   return pageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
   return [self.pageImages count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
   return 0;
}

#pragma mark - Page View Controller Data Source
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
   NSUInteger index = ((HomePageContentViewController *) viewController).pageIndex;
   
   if ((index == 0) || (index == NSNotFound)) {
      return nil;
   }
   
   
   index--;
   
   return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
   NSUInteger index = ((HomePageContentViewController*) viewController).pageIndex;
   
   if (index == NSNotFound) {
      return nil;
   }
   
   index++;
   if (index == [self.pageImages count]) {
      return nil;
   }
   return [self viewControllerAtIndex:index];
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
   HomePageContentViewController *currentPageViewController = pageViewController.viewControllers[0];
   [self.homePageControl setCurrentPage:currentPageViewController.pageIndex];
}

#pragma mark - Notifications
-(void)authenticationRequired:(NSNotification *)notification
{
   if(self.presentedViewController == nil) {
      [self performSegueWithIdentifier:@"AuthenticationSegue" sender:nil];
   }
}

#pragma mark - LoginViewControllerDelegate
-(void)loginViewControllerSucceeded:(LoginViewController *)loginVC
{
   [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if([segue.identifier isEqualToString:@"AuthenticationSegue"]) {
      LoginViewController *loginVC = (LoginViewController *)segue.destinationViewController;
      loginVC.delegate = self;
   }
}

@end
