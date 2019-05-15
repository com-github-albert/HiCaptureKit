//
//  ViewController.m
//  Sample
//
//  Created by Jett on 2019/3/4.
//  Copyright © 2019 mutating. All rights reserved.
//

#import "ViewController.h"

@import HiCaptureKit;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)startCapture:(UIButton *)sender {
    [HiCaptureAuthorization request:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                [self performSegueWithIdentifier:@"PresentCaptureSegue" sender:nil];
            } else {
                NSString *message = NSLocalizedString( @"The app doesn't have permission to use the camera, please change privacy settings", @"Alert message when the user has denied access to the camera" );
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"AVCam" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Cancel", @"Alert Cancel button" ) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    // do some thing.
                }];
                [alertController addAction:cancelAction];
                // Provide quick access to Settings.
                UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Settings", @"Alert button to open Settings" ) style:UIAlertActionStyleDefault handler:^( UIAlertAction *action ) {
                    if (@available(iOS 10.0, *)) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                    } else {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }
                }];
                [alertController addAction:settingsAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        });
    }];
}

- (IBAction)unwindSegueToHome:(UIStoryboardSegue *)unwindSegue {
}

@end
