//
//  NLMasterViewController.h
//  Interpreter
//
//  Created by Sam Rijs on 1/28/14.
//  Copyright (c) 2014 Sam Rijs. All rights reserved.
//

#import "FHSegmentedViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface NLMasterViewController : FHSegmentedViewController <UIAlertViewDelegate>

@property UIViewController *editorViewController;
@property UIViewController *consoleViewController;
@property UIViewController *documentationViewController;
@property NSString *jsRuntime;

@property JSContext *context;
@property id logger;

- (void)executeJS:(NSString *)code;

@end
