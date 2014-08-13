//
//  DARPDetailViewController.m
//  DARPFlickrAroundYou
//
//  Created by Alessio Roberto on 13/08/14.
//  Copyright (c) 2014 Alessio Roberto. All rights reserved.
//

#import "DARPDetailViewController.h"

#import "DARPPhotosDownloadManager.h"

#import "MBProgressHUD.h"

@interface DARPDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *bigImage;

- (IBAction)doneButtonPressed:(id)sender;

@end

@implementation DARPDetailViewController

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
    // Do any additional setup after loading the view.
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setPhoto:(Photo *)photo
{
    _photo = photo;
    self.title = photo.title;
    
    // Download image
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSURL *imageURL = [NSURL URLWithString:photo.imageBigURL];
                       NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                       
                       //This is your completion handler
                       dispatch_sync(dispatch_get_main_queue(), ^{
                           self.photo.imageBig = imageData;
                           self.bigImage.image = [UIImage imageWithData:imageData];
                           [MBProgressHUD hideHUDForView:self.view animated:YES];
                       });
                   });
}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
