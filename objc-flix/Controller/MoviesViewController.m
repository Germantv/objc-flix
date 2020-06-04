//
//  MoviesViewController.m
//  objc-flix
//
//  Created by German Flores on 6/2/20.
//  Copyright © 2020 German Flores. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *filteredMovies;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    
    [self fetchMovies];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)fetchMovies {
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/upcoming?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
               
               NSString *errorText = [NSString stringWithFormat:@"%@", [error localizedDescription]];
               
               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error Fetching Movies!"
                                                                              message:errorText
                                                                       preferredStyle:(UIAlertControllerStyleAlert)];
               
               // create a cancel action
               UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                        // handle cancel response here. Doing nothing will dismiss the view.
                   [self dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
               // add the cancel action to the alertController
               [alert addAction:cancelAction];

               // create an OK action
               UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
                                                                        // handle response here.
                   [self dismissViewControllerAnimated:YES completion:nil];
                                                                }];
               // add the OK action to the alert controller
               [alert addAction:okAction];
               
               // show alert controller
               [self presentViewController:alert animated:YES completion:^{
                   // optional code for what happens after the alert controller has finished presenting
               }];
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               
               NSLog(@"%@", dataDictionary);
               
               self.movies = dataDictionary[@"results"];
               self.filteredMovies = self.movies;
               
               for (NSDictionary *movie in self.movies) {
                   NSLog(@"%@", movie[@"title"]);
               }
               
               [self.tableView reloadData];
           }
            [self.refreshControl endRefreshing];
        }];
        [task resume];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    
    NSDictionary *movie = self.movies[indexPath.row];
    
    DetailsViewController *detailVC = [segue destinationViewController];
    detailVC.movie = movie;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredMovies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    NSDictionary *movie = self.filteredMovies[indexPath.row];
    
    
    cell.titleLabel.text = movie[@"title"];
    cell.overviewLabel.text = movie[@"overview"];
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    
    NSString *lowResBaseURLString = @"https://image.tmdb.org/t/p/w200";
    NSString *lowResPosterURLString = [lowResBaseURLString stringByAppendingString:posterURLString];
    
    NSURL *smallPosterURL = [NSURL URLWithString:lowResPosterURLString];
    NSURL *largePosterURL = [NSURL URLWithString:fullPosterURLString];
//    [cell.posterImageView setImageWithURL:posterURL];
    NSURLRequest *requestSmall = [NSURLRequest requestWithURL:smallPosterURL];
    NSURLRequest *requestLarge = [NSURLRequest requestWithURL:largePosterURL];
    
    [cell.posterImageView setImageWithURLRequest:requestSmall placeholderImage:nil success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *smallImage) {
        // imageResponse will be nil if the image is cached
        if (imageResponse) {
            NSLog(@"Image was NOT cached, fade in image");
            cell.posterImageView.alpha = 0.0;
            cell.posterImageView.image = smallImage;
            
            //Animate UIImageView back to alpha 1 over 0.3sec
            [UIView animateWithDuration:0.3
            animations:^{
                
                cell.posterImageView.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                // The AFNetworking ImageView Category only allows one request to be sent at a time
                // per ImageView. This code must be in the completion block.
                [cell.posterImageView setImageWithURLRequest:requestLarge
                                      placeholderImage:smallImage
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
                                                    cell.posterImageView.image = largeImage;
                                      }
                                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                   // do something for the failure condition of the large image request
                                                   // possibly setting the ImageView's image to a default image
                                               }];
            }];
        }
        else {
            NSLog(@"Image was cached so just update the image");
            cell.posterImageView.image = smallImage;
        }
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        // do something for the failure condition
    }];
    
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length != 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title contains[c] %@)", searchText];
        
        self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
        
        NSLog(@"%@", self.filteredMovies);
        
    }
    else {
        self.filteredMovies = self.movies;
    }
    
    [self.tableView reloadData];
 
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}

@end
