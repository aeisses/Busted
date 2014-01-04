//
//  MTTwitterViewController.m
//  Busted
//
//  Created by Aaron Eisses on 2013-11-26.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "MTTwitterViewController.h"

@interface MTTwitterViewController ()

@end

@implementation MTTwitterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_twitterTable registerNib:[UINib nibWithNibName:@"TwitterCell" bundle:nil] forCellReuseIdentifier:@"TwitterCell"];

    twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:@"4nCDEefDi54ErZd3qtpZ7g"
                                            consumerSecret:@"q4Fq2xLFFEh7TPfTTVPGGRivx99BD0Hjzou7HieECI"
                                                oauthToken:@"1969214929-dWw75ztFDOXTzlTvDxtkdpUZC2PuRSiEdYFkcZI"
                                          oauthTokenSecret:@"3HRCrTu0tN4M4IqpbRJMxk5YLNqDaA77ywibDTPH8wHvK"];
    
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *bearerToken) {
        
        NSLog(@"Access granted with %@", bearerToken);
        
        [twitter getUserTimelineWithScreenName:@"hfxtransit"
                                         count:10
                                  successBlock:^(NSArray *statuses)
        {
            _statuses = [statuses copy];
            [_twitterTable reloadData];
            NSLog(@"-- statuses: %@", statuses);
        } errorBlock:^(NSError *error) {
            NSLog(@"-- error: %@", error);
        }];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"-- error %@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchBackButton:(id)sender
{
    dispatch_queue_t menuQueue  = dispatch_queue_create("menu queue", NULL);
    dispatch_async(menuQueue, ^{
        [self.superDelegate touchedHomeButton:NO];
    });
    dispatch_release(menuQueue);
}

- (void)dealloc
{
    [super dealloc];
    [_backButton release]; _backButton = nil;
    [_backGroundImage release]; _backGroundImage = nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 116;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.statuses count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TwitterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwitterCell"];
    cell.delegate = self;
    
    if(cell == nil) {
        cell = [[[TwitterCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TwitterCell"] autorelease];
    }
    
    NSDictionary *status = [self.statuses objectAtIndex:indexPath.row];
    
    cell.statusId = [status objectForKey:@"id_str"];
    cell.replyStatusId = [status objectForKey:@"in_reply_to_user_id_str"];
    cell.favourited = [status objectForKey:@"favorited"];
    cell.nameInfo.text = [NSString stringWithFormat:@"%@ @%@",[status valueForKeyPath:@"user.name"],[status valueForKeyPath:@"user.screen_name"]];
    cell.tweet.text = [status objectForKey:@"text"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE MMM dd HH:mm:ss zzzzz yyyy"];
    NSDate *date = [formatter dateFromString:[status objectForKey:@"created_at"]];
    [formatter setDateFormat:@"d MMM"];
    NSTimeInterval dateDiff = [date timeIntervalSinceNow];
    int min = (int)(dateDiff/-60);
    int hours = (int)(dateDiff/-3600);
    if (hours > 0)
    {
        if (hours < 24)
        {
            cell.date.text = [NSString stringWithFormat:@"%i h",hours];
        }
        else
        {
            cell.date.text = [formatter stringFromDate:date];
        }
    }
    else
    {
        cell.date.text = [NSString stringWithFormat:@"%i m",min];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [formatter release];
    NSDictionary *user = [status objectForKey:@"user"];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[user valueForKey:@"profile_image_url_https"]]]];
    cell.iconImage.image = image;
    return cell;
}

#pragma TwitterCellDelegate
- (void)touchReplyButton:(NSString*)statusId
{
    
}

- (void)touchRetweetButton:(NSString*)statusId
{
    [twitter postStatusRetweetWithID:statusId
                        successBlock:^(NSDictionary *status)
    {
    }
                          errorBlock:^(NSError *error)
    {
    }];
}

- (void)touchFavouriteButton:(NSString*)statusId isFavourite:(BOOL)favourite
{
    [twitter postFavoriteState:favourite
                   forStatusID:statusId
                  successBlock:^(NSDictionary *status)
     {
     }
                    errorBlock:^(NSError *error)
     {
     }];
}

@end