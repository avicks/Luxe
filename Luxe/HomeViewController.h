//
//  ViewController.h
//  Luxe
//
//  Created by Alex Vickers on 2/3/16.
//
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "HomePageContentViewController.h"


@interface HomeViewController : UIViewController <LoginViewControllerDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageImages;
@property (weak, nonatomic) IBOutlet UIPageControl *homePageControl;
@property (weak, nonatomic) IBOutlet UIButton *serviceButton;
@property (weak, nonatomic) IBOutlet UIButton *bookButton;

@end

