//
//  ViewController.m
//  JRTFileManager
//
//  Created by Juan Garcia on 3/4/16.
//  Copyright © 2016 jerti. All rights reserved.
//

#import "ViewController.h"
#import "JRTFileManager.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ViewController

#pragma mark - Actions

- (IBAction)downloadAction:(id)sender {
    [[JRTFileManager sharedInstance] downloadFile:@"https://assets-cdn.github.com/images/modules/logos_page/Octocat.png"
                                         withName:@"Octocat.png" progress:^(NSProgress *downloadProgress) {
        [self log:[NSString stringWithFormat:@"Progress: %@", downloadProgress]];
    } completionHandler:^(NSURL *filePath, NSError *error) {
        if (error) {
            [self log:[NSString stringWithFormat:@"Error: %@", error]];
        }
        else {
            [self log:[NSString stringWithFormat:@"Download Success, File Path: %@", filePath]];
        }
    }];
}

- (IBAction)retrieveAction:(id)sender {
    NSData *data = [[JRTFileManager sharedInstance] retrieveDataFromDirectoryWithPath:@"Octocat.png"];
    UIImage *image = [UIImage imageWithData:data];
    self.imageView.image = image;
}

- (IBAction)deleteAction:(id)sender {
    if ([[JRTFileManager sharedInstance] deleteDataFromDirectoryWithPath:@"Octocat.png"]) {
        [self log:@"Octocat.png Deleted"];
    }
    else {
        [self log:@"Octocat.png Not Deleted"];
    }
}

- (IBAction)saveAction:(id)sender {
    NSData *data = UIImagePNGRepresentation(self.imageView.image);
    if ([[JRTFileManager sharedInstance] saveData:data toDirectoryPath:@"Octocat.png"]) {
        [self log:@"Octocat.png Saved"];
    }
    else {
        [self log:@"Octocat.png Not Saved"];
    }
}

- (IBAction)existAction:(id)sender {
    if ([[JRTFileManager sharedInstance] fileExistsInDirectory:@"Octocat.png"]) {
        [self log:@"Octocat.png Exist"];
    }
    else {
        [self log:@"Octocat.png Not Exist"];
    }
}

- (IBAction)clearImageViewAction:(id)sender {
    self.imageView.image = nil;
}

#pragma mark - helpers

- (void)log:(NSString *)text {
    self.logTextView.text = [self.logTextView.text stringByAppendingString:[NSString stringWithFormat:@"\n\n > %@", text]];
}

@end
