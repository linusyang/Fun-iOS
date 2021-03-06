//
//  NLMasterViewController.m
//  Interpreter
//
//  Created by Sam Rijs on 1/28/14.
//  Copyright (c) 2014 Sam Rijs. All rights reserved.
//

#import "NLMasterViewController.h"
#import "NLEditorViewController.h"
#import "NLConsoleViewController.h"
#import "CSNotificationView.h"
#import "NLColor.h"
#import "fun.h"
#import "jsrt.h"

typedef bool (*JSShouldTerminateCallback) (JSContextRef ctx, void* context);
void JSContextGroupSetExecutionTimeLimit(JSContextGroupRef, double limit, JSShouldTerminateCallback, void* context);

@interface NLMasterViewController ()

@end

@implementation NLMasterViewController

- (void)customInit
{
    __weak NLMasterViewController *weakSelf = self;
    
    
    _jsRuntime = [[NSString alloc] initWithBytes:runtime_min_js
                                          length:runtime_min_js_len
                                        encoding:NSUTF8StringEncoding];
    
    _logger = ^(JSValue *thing) {
        [JSContext.currentArguments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf output:[obj toString]];
            });
            [((NLConsoleViewController *)weakSelf.consoleViewController) log:[obj toString]];
        }];
    };
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self customInit];
    }
    return self;
}

- (JSContext *)createJSContext
{
    JSContext *context = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
    __weak NLMasterViewController *weakSelf = self;
    context.exceptionHandler = ^(JSContext *c, JSValue *e) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf error:[e toString]];
        });
    };
    context[@"console"] = @{@"log": _logger, @"error": _logger};
    
    JSGlobalContextRef ctx = context.JSGlobalContextRef;
    JSContextGroupRef group = JSContextGetGroup(ctx);
    JSContextGroupSetExecutionTimeLimit(group, 3.0, NULL, NULL);
    return context;
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    
    self.editorViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"editorViewController"];
    self.consoleViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"consoleViewController"];
    self.documentationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"documentationViewController"];
	[self setViewControllers:@[self.editorViewController, self.consoleViewController, self.documentationViewController]];
    [self setupStyle];
}

- (void)setupStyle {
    self.navigationController.toolbar.tintColor          = [NLColor blackColor];
    self.navigationController.toolbar.barTintColor       = [[NLColor whiteColor] colorWithAlphaComponent:0.5];
}

- (void)executeJS:(NSString *)code {
    if (_context == nil) {
        _context = [self createJSContext];
    }
    self.navigationItem.leftBarButtonItem.enabled = NO;
    __weak NLMasterViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *jsout = fun2JS(code);
        if ([jsout hasPrefix:@"!MSG!"]) {
            NSString *string = [jsout substringFromIndex:5];
            NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\x1b[^m]*m" options:NSRegularExpressionCaseInsensitive error:&error];
            NSString *modifiedString = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@""];
            NSString *finalString = [modifiedString hasPrefix:@"*** "] ? [modifiedString substringFromIndex:4] : modifiedString;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf error:finalString];
            });
        } else {
            [_context evaluateScript:[_jsRuntime stringByAppendingString:jsout]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.navigationItem.leftBarButtonItem.enabled = YES;
        });
    });
}

- (void)output:(NSString *)message {
    [CSNotificationView showInViewController:self
                                       style:CSNotificationViewStyleSuccess
                                     message:message];
}

- (void)error:(NSString *)message {
    if ([message isEqualToString:@"JavaScript execution terminated."]) {
        _context = nil;
        message = @"JavaScript execution timeout.";
    }
    [CSNotificationView showInViewController:self
                                       style:CSNotificationViewStyleError
                                     message:message];
}

- (IBAction)execute:(id)sender {
    NLTextView *textView = ((NLEditorViewController *)self.editorViewController).input;
    [textView endEditing:YES];
    [self executeJS:textView.text];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://linusyang.github.io/fun-lang"]];
    }
}

- (IBAction)showInfo:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Fun Interpreter v0.1\nAuthor: Linus Yang (@linusyang)" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Visit Website", nil];
    [alert show];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _context = nil;
}

@end
