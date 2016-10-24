//
//  MenuViewController.h
//  Luxe
//
//  Created by Alex Vickers on 3/15/16.
//
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *content;

@end
