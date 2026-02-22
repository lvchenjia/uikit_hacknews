//
//  SceneDelegate.m
//  HackNews
//
//  Created by horse on 2026/2/22.
//

#import "SceneDelegate.h"
#import "ViewController.h"
#import "LanguageManager.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) return;
    
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    
    [self setupRootViewController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupRootViewController) name:@"LanguageChangedNotification" object:nil];
    
    // Ensure LanguageManager is initialized early
    [LanguageManager sharedManager];
    
    // Restore Appearance
    NSInteger savedStyle = [[NSUserDefaults standardUserDefaults] integerForKey:@"AppAppearanceStyle"];
    self.window.overrideUserInterfaceStyle = (UIUserInterfaceStyle)savedStyle;
}

- (void)setupRootViewController {
    ViewController *vc = [[ViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    // Customize navigation bar appearance for a better look
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor systemOrangeColor];
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        nav.navigationBar.standardAppearance = appearance;
        nav.navigationBar.scrollEdgeAppearance = appearance;
        nav.navigationBar.compactAppearance = appearance;
        nav.navigationBar.tintColor = [UIColor whiteColor];
    } else {
        nav.navigationBar.barTintColor = [UIColor systemOrangeColor];
        nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        nav.navigationBar.tintColor = [UIColor whiteColor];
    }
    
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}


@end
