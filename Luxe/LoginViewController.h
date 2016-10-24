//
//  LoginViewController.h
//  Luxe
//
//  Created by Alex Vickers on 3/16/16.
//
//

#import <UIKit/UIKit.h>

@protocol LoginViewControllerDelegate;

@interface LoginViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIView *waitView;
@property (nonatomic, weak) id<LoginViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *logoutButton;

@property (strong, nonatomic) UIScrollView *accountScrollView;
@property (strong, nonatomic) UILabel *accountHeader;

- (IBAction)didTapLoginButton:(id)sender;

- (IBAction)didTapLogoutButton:(UIBarButtonItem *)sender;

@end

@protocol LoginViewControllerDelegate

- (void)loginViewControllerSucceeded:(LoginViewController *)loginVC;

@end
