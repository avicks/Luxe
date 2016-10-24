//
//  HomePageContentViewController.m
//  Luxe
//
//  Created by Alex Vickers on 7/27/16.
//
//

#import "HomePageContentViewController.h"

@interface HomePageContentViewController ()

@end

@implementation HomePageContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
   self.backgroundImageView.image = [UIImage imageNamed:self.imageName];
   
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
