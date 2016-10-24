//
//  MenuViewController.m
//  Luxe
//
//  Created by Alex Vickers on 3/15/16.
//
//

#import "MenuViewController.h"
#import "LuxeService.h"

@implementation MenuViewController

- (void) viewDidLoad {
   [super viewDidLoad];
   
   LuxeService *service = [LuxeService sharedInstance];
   
   self.content = @[ @"luxeCell", @"homeCell", @"servicesCell",
                     @"bookNowCell", @"accountCell", @"registerCell", @"contactCell"];

   self.tableView.delegate = self;
   self.tableView.dataSource = self;
   self.tableView.tableFooterView = [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   // Return the number of rows in the section.
   return self.content.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
   NSString *CellIdentifier = [self.content objectAtIndex:indexPath.row];
   UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   
   if (cell == nil) {
      cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
   }
   
   return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
   NSLog(@"title of cell %@", [self.content objectAtIndex:indexPath.row]);
   
   if([[self.content objectAtIndex:indexPath.row] isEqualToString:@"accountCell"]) {
      [self performSegueWithIdentifier:@"accountSegue" sender:self];
   } else if([[self.content objectAtIndex:indexPath.row] isEqualToString:@"homeCell"]) {
      [self performSegueWithIdentifier:@"homeSegue" sender:self];
   } else if([[self.content objectAtIndex:indexPath.row] isEqualToString:@"servicesCell"]) {
      [self performSegueWithIdentifier:@"servicesSegue" sender:self];
   } else if([[self.content objectAtIndex:indexPath.row] isEqualToString:@"bookNowCell"]) {
      [self performSegueWithIdentifier:@"bookNowSegue" sender:self];
   } else if([[self.content objectAtIndex:indexPath.row] isEqualToString:@"registerCell"]) {
      [self performSegueWithIdentifier:@"registerSegue" sender:self];
   }

}

#pragma mark - Segue Preparationya
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
   // Set the title of navigation bar by using the menu items
   NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
   UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
   destViewController.title = [[self.content objectAtIndex:indexPath.row] capitalizedString];
   
   destViewController.hidesBottomBarWhenPushed = YES;
   
}


@end
