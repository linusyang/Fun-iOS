//
//  NLEditorViewController.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLEditorViewController.h"

#import "KOKeyboardRow.h"

#import "NLColor.h"

@implementation NLEditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.input = [NLTextView textViewForView:self.view];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self.view addSubview:self.input];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      [KOKeyboardRow applyToTextView:self.input];
      ((KOKeyboardRow *)self.input.inputAccessoryView).viewController = self;
    }
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(fileOpenTriggered:) name:@"NLFileOpen" object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    /* recalculate frame size */
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(application.statusBarOrientation))
        size = CGSizeMake(size.height, size.width);
    if (!application.statusBarHidden)
        size.height -= MIN(application.statusBarFrame.size.width,
                           application.statusBarFrame.size.height);
    
    CGRect frame = self.view.frame;
    frame.size.height = size.height -
    self.navigationController.navigationBar.frame.size.height;
    self.view.frame = frame;
}

- (void)viewDidAppear:(BOOL)animated {
    [self.input becomeFirstResponder];
}

- (void)fileOpenTriggered:(NSNotification*)notification {
    self.input.text = notification.userInfo[@"script"];
}

@end
