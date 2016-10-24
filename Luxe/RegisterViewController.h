//
//  RegisterViewController.h
//  Luxe
//
//  Created by Alex Vickers on 8/10/16.
//
//

#import <UIKit/UIKit.h>

@protocol RegisterViewControllerDelegate;


@interface RegisterViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *registerView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIView *waitView;
@property (nonatomic, weak) id<RegisterViewControllerDelegate> delegate;

- (IBAction)didHitRegister:(id)sender;

@end

@protocol RegisterViewControllerDelegate

- (void)registerViewControllerSucceeded:(RegisterViewController *)registerVC;

@end
