//
//  AppDelegate.m
//  geocoupons
//
//  Created by Hector Garcia on 2016-12-10.
//  Copyright © 2016 Hector Garcia. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    //using notification.alertBody uses the message we put into the notification we created in viewcontroller.m and passes it to this method as the message to use in the pop-up.  This constructs the alert.
    
    application.applicationIconBadgeNumber = 0;
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Magic Spells Inc." message: notification.alertBody preferredStyle:UIAlertControllerStyleAlert];
    
    //adds Action button to alert
    UIAlertAction *aa = [UIAlertAction actionWithTitle: @"Okay" style: UIAlertActionStyleDefault handler:nil];
    
    [ac addAction:aa];
    
    //make sure this alert gets run on the UI thread.  Presents to VC.
    dispatch_async(dispatch_get_main_queue(), ^{
        [application.keyWindow.rootViewController presentViewController:ac animated:YES completion:nil];
    });
}

@end
