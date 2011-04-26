//
//  WebViewObj.m
//  WebView_iphone
//
//  Created by Bjorn Runaker on 2011-04-14.
//  Copyright 2011 Runåker Produktkonsult AB. All rights reserved.
//
#include "WebView_autodefs.h"
#import "WebViewObj.h"
#include "s3eEdk.h"
#include "s3eEdk_iphone.h"


enum WebViewCallback
{
    WEBVIEW_CALLBACK_PAGE_LOADED,
    WEBVIEW_CALLBACK_PAGE_ERROR,
	WEBVIEW_CALLBACK_LINK,
    S3E_WEBVIEW_CALLBACK_MAX
};



///////////////////////////////////////////////////////////////////////////////////////////////////
// global

static CGFloat kTransitionDuration = 0.3;


BOOL IsDeviceIPad() {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return YES;
	}
#endif
	return NO;
}


@implementation WebViewObj

- (BOOL)shouldRotateToOrientation:(UIDeviceOrientation)orientation {
	if (orientation == _orientation) {
		return NO;
	} else {
		return orientation == UIDeviceOrientationLandscapeLeft
		|| orientation == UIDeviceOrientationLandscapeRight
		|| orientation == UIDeviceOrientationPortrait
		|| orientation == UIDeviceOrientationPortraitUpsideDown;
	}
}

- (CGAffineTransform)transformForOrientation {
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (orientation == UIInterfaceOrientationLandscapeLeft) {
		return CGAffineTransformMakeRotation(M_PI*1.5);
	} else if (orientation == UIInterfaceOrientationLandscapeRight) {
		return CGAffineTransformMakeRotation(M_PI/2);
	} else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
		return CGAffineTransformMakeRotation(-M_PI);
	} else {
		return CGAffineTransformIdentity;
	}
}

- (void)sizeToFitOrientation:(BOOL)transform {
	if (transform) {
		self.transform = CGAffineTransformIdentity;
	}
	
	CGRect frame = [UIScreen mainScreen].applicationFrame;
	CGPoint center = CGPointMake(
								 frame.origin.x + ceil(frame.size.width/2),
								 frame.origin.y + ceil(frame.size.height/2));
	
	CGFloat scale_factor = 1.0f;
	
	CGFloat width = floor(scale_factor * frame.size.width);
	CGFloat height = floor(scale_factor * frame.size.height);
	
	_orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (UIInterfaceOrientationIsLandscape(_orientation)) {
		self.frame = CGRectMake(0, 0, height, width);
	} else {
		self.frame = CGRectMake(0, 0, width, height);
	}
	self.center = center;
	
	if (transform) {
		self.transform = [self transformForOrientation];
	}
}

- (void)updateWebOrientation {
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		[_webView stringByEvaluatingJavaScriptFromString:
		 @"document.body.setAttribute('orientation', 90);"];
	} else {
		[_webView stringByEvaluatingJavaScriptFromString:
		 @"document.body.removeAttribute('orientation');"];
	}
}

- (void)bounce1AnimationStopped {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
	self.transform = CGAffineTransformScale([self transformForOrientation], 0.9, 0.9);
	[UIView commitAnimations];
}

- (void)bounce2AnimationStopped {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/2];
	self.transform = [self transformForOrientation];
	[UIView commitAnimations];
}

- (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params {
	if (params) {
		NSMutableArray* pairs = [NSMutableArray array];
		for (NSString* key in params.keyEnumerator) {
			NSString* value = [params objectForKey:key];
			NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																						  NULL, /* allocator */
																						  (CFStringRef)value,
																						  NULL, /* charactersToLeaveUnescaped */
																						  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																						  kCFStringEncodingUTF8);
			
			[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
			[escaped_value release];
		}
		
		NSString* query = [pairs componentsJoinedByString:@"&"];
		NSString* url = [NSString stringWithFormat:@"%@?%@", baseURL, query];
		return [NSURL URLWithString:url];
	} else {
		return [NSURL URLWithString:baseURL];
	}
}


- (void)addObservers {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceOrientationDidChange:)
												 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)removeObservers {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIDeviceOrientationDidChangeNotification" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIKeyboardWillShowNotification" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)postDismissCleanup {
	[self removeObservers];
	[self removeFromSuperview];
}


- (id)init {
	if (self = [super initWithFrame:CGRectZero]) {
		_loadingURL = nil;
		_orientation = UIDeviceOrientationUnknown;
		_showingKeyboard = NO;

		self.backgroundColor = [UIColor clearColor];
		self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.contentMode = UIViewContentModeRedraw;

		_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 480, 480)];
		_webView.delegate = self;
		_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:_webView];

		_spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
					UIActivityIndicatorViewStyleWhiteLarge];
		_spinner.autoresizingMask =
		UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
		| UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[self addSubview:_spinner];
	}
	return self;
}		

- (void)dealloc {
	_webView.delegate = nil;
	[_webView release];
	[_spinner release];
	[_loadingURL release];
	[_params release];
	[_serverURL release];
	[super dealloc];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
	NSURL* url = request.URL;

	if ([_loadingURL isEqual:url]) {
		return YES;
	} else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		static char saved_url[2048];
		strncpy(saved_url, [[url absoluteString] UTF8String], 2048);
		saved_url[2047] = 0;
		s3eEdkCallbacksEnqueue(S3E_EXT_WEBVIEW_HASH, WEBVIEW_CALLBACK_LINK, saved_url, strlen(saved_url) + 1, NULL,S3E_FALSE,NULL,NULL);	
		[_spinner sizeToFit];
		[_spinner startAnimating];
		_spinner.center = _webView.center;
		_spinner.hidden = NO;
		return YES;
	} else {
		 return YES;
	}

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[_spinner stopAnimating];
	_spinner.hidden = YES;
	
	[self updateWebOrientation];
	
	s3eEdkCallbacksEnqueue(S3E_EXT_WEBVIEW_HASH, WEBVIEW_CALLBACK_PAGE_LOADED, NULL, 0, NULL,S3E_FALSE,NULL,NULL);
	
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	NSLog (@"webView:didFailLoadWithError");
	s3eEdkCallbacksEnqueue(S3E_EXT_WEBVIEW_HASH, WEBVIEW_CALLBACK_PAGE_ERROR, NULL, 0, NULL,S3E_FALSE,NULL,NULL);
	[_spinner stopAnimating];
	_spinner.hidden = YES;

}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIDeviceOrientationDidChangeNotification

- (void)deviceOrientationDidChange:(void*)object {
	UIDeviceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (!_showingKeyboard && [self shouldRotateToOrientation:orientation]) {
		[self updateWebOrientation];
		
		CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:duration];
		[self sizeToFitOrientation:YES];
		[UIView commitAnimations];
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIKeyboardNotifications

- (void)keyboardWillShow:(NSNotification*)notification {
	
	_showingKeyboard = YES;
	
	if (IsDeviceIPad()) {
		// On the iPad the screen is large enough that we don't need to
		// resize the dialog to accomodate the keyboard popping up
		return;
	}
	
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		_webView.frame = CGRectInset(_webView.frame,
									 0,
									 0);
	}
}

- (void)keyboardWillHide:(NSNotification*)notification {
	_showingKeyboard = NO;
	
	if (IsDeviceIPad()) {
		return;
	}
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		_webView.frame = CGRectInset(_webView.frame,
									 0,
									 0);
	}
}

- (id)initWithURL: (NSString *) serverURL
           params: (NSMutableDictionary *) params

{
	
	self = [self init];
	_serverURL = [serverURL retain];
	_params = [params retain];

	return self;
}

- (void)load {
	[self loadURL:_serverURL get:_params];
}

- (void)loadURL:(NSString*)url get:(NSDictionary*)getParams {
	
	[_loadingURL release];
	_loadingURL = [[self generateURL:url params:getParams] retain];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:_loadingURL];
	
	[_webView loadRequest:request];
	[self show];
}

- (void) loadFile:(NSString*) filename  {
	[_loadingURL release];
	_loadingURL = [[NSURL fileURLWithPath:filename] retain];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:_loadingURL];

	/*
	cb = _cb;
	if (cb) {
		EDK_CALLBACK_REG(WEBVIEW, WEBVIEW_EVENT, (s3eCallback)cb, NULL, true);

	}
	*/
	[_webView loadRequest:request];
	[self show];
}

- (void)show {
	[self sizeToFitOrientation:NO];
		
	_webView.frame = CGRectMake(
								0,
								0,
								self.frame.size.width,
								self.frame.size.height);
	
	[_spinner sizeToFit];
	[_spinner startAnimating];
	_spinner.center = _webView.center;
	
	UIWindow* window = [UIApplication sharedApplication].keyWindow;
	if (!window) {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
	
	
	[window addSubview:self];
	
	
	self.transform = CGAffineTransformScale([self transformForOrientation], 0.001, 0.001);
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/1.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
	self.transform = CGAffineTransformScale([self transformForOrientation], 1.1, 1.1);
	[UIView commitAnimations];
	
	[self addObservers];
}

- (void)dismiss {
	
	[_loadingURL release];
	_loadingURL = nil;
	
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:kTransitionDuration];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(postDismissCleanup)];
		self.alpha = 0;
		[UIView commitAnimations];
}




@end
