//
//  NLConsoleViewController.m
//  Interpreter
//
//  Created by Sam Rijs on 1/28/14.
//  Copyright (c) 2014 Sam Rijs. All rights reserved.
//

#import "NLConsoleViewController.h"

@implementation NLConsoleViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.consoleText = @"";
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.console.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    
    CGFloat fixedWidth = self.console.frame.size.width;
    CGSize newSize = [self.console sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    self.console.contentSize = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(askToClear)];
    tapRecognizer.numberOfTapsRequired = 2;
    tapRecognizer.numberOfTouchesRequired = 1;
    [self.console addGestureRecognizer:tapRecognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.console.text = self.consoleText;
}

-(void)textViewDidChangeSelection:(UITextView *)textView {
    [textView scrollRangeToVisible:NSMakeRange([textView.text length], 0)];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        self.console.text = @"";
        self.consoleText = @"";
    }
}

- (void)askToClear
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear Console" message:@"Do you want to clear the console?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)log:(NSString *)string {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.consoleText = [self.consoleText stringByAppendingFormat:@"%@\n", string];
        self.console.text = self.consoleText;
    });
}

@end
