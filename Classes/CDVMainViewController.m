/*
 * Licensed Materials - Property of IBM
 * 5725-I43 (C) Copyright IBM Corp. 2006, 2013. All Rights Reserved.
 * US Government Users Restricted Rights - Use, duplication or
 * disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

//
//  CDVMainViewController.m
//  cccTestCordovaIphone
//
//

#import "CDVMainViewController.h"
#import "Messenger.h"

@implementation CDVMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    // Return YES for supported orientations
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
//    return YES;
}

#pragma mark - WebView Delegate

/**
 * Called when the UIWebView finishes loading.  This stops the activity view and closes the imageview.
 */
- (void)webViewDidFinishLoad:(UIWebView *)theWebView 
{
    
    //WebView save
    [[Messenger sharedMessenger] setPWebView:self.webView];
    [[Messenger sharedMessenger] setWebViewLoadFinish:TRUE];

//    [self.webView stringByEvaluatingJavaScriptFromString:@"(function() { console.log('네이티브22 콜 성공'); }) ()"];
//    [self.webView stringByEvaluatingJavaScriptFromString:@"test()"];
    
//    UIWebView * aa = [[Messenger sharedMessenger]pWebView];
//    [aa stringByEvaluatingJavaScriptFromString:@"test()"];
    
	return [ super webViewDidFinishLoad:theWebView ];
}

- (void)webViewDidStartLoad:(UIWebView *)theWebView 
{
    
    
	return [ super webViewDidStartLoad:theWebView ];
}

/**
 * Fail Loading With Error
 * Error - If the web page failed to load display an error with the reason.
 */
- (void)webView:(UIWebView *)theWebView didFailLoadWithError:(NSError *)error 
{
	return [ super webView:theWebView didFailLoadWithError:error ];
}

/**
 * Start Loading Request
 * This is where most of the magic happens... We take the request(s) and process the response.
 * From here we can redirect links and other protocols to different internal methods.
 */
- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
	return [ super webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType ];
}


/* Comment out the block below to over-ride */
/*
 #pragma mark - CDVCommandDelegate implementation
 
 - (id) getCommandInstance:(NSString*)className
 {
 return [super getCommandInstance:className];
 }
 
 - (void) registerPlugin:(CDVPlugin*)plugin withClassName:(NSString*)className
 {
 return [super registerPlugin:plugin withClassName:className];
 }
 */

////#pragma mark CDVOrientationDelegate
-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;

}


- (void)viewWillAppear:(BOOL)animated
{
    // View defaults to full size. If you want to customize the view's size, or its subviews (e.g. webView),
    // you can do so here.
    
    // handle iOS 7 transparent status bar
    // according to http://stackoverflow.com/questions/19209781/ios-7-status-bar-with-phonegap
    //Lower screen 20px on ios 7
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        CGRect viewBounds = [self.webView bounds];
        viewBounds.origin.y = 20;
        viewBounds.size.height = viewBounds.size.height - 20;
        self.webView.frame = viewBounds;
    }
    
    [super viewWillAppear:animated];
}


@end
