//
//  HomePageContentViewController.h
//  Luxe
//
//  Created by Alex Vickers on 7/27/16.
//
//

#import <UIKit/UIKit.h>

@interface HomePageContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property NSUInteger pageIndex;
@property NSString *imageName;

@end
