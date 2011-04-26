/*
 * iphone-specific implementation of the WebView extension.
 * Add any platform-specific functionality here.
 */
/*
 * NOTE: This file was originally written by the extension builder, but will not
 * be overwritten (unless --force is specified) and is intended to be modified.
 */

#include "WebView_internal.h"
#import "WebViewObj.h"

WebViewObj* webview;

s3eResult WebViewInit_platform()
{

    // Add any platform-specific initialisation code here
    return S3E_RESULT_SUCCESS;
}

void WebViewTerminate_platform()
{
    // Add any platform-specific termination code here
}

WebViewSession* InitWebView_platform()
{
	webview = [[WebViewObj alloc] init];
	
    return (WebViewSession*) webview;
}

s3eResult CreateWebView_platform(WebViewSession* session, const char* file)
{
	if (session != NULL) {
		WebViewObj* _webview = (WebViewObj*) session;
		[_webview dismiss];
		
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
															 NSUserDomainMask, YES); 
		NSString* documentsDirectory = [paths objectAtIndex:0];     
		NSString* leafname = [[[NSString alloc] initWithUTF8String:file] autorelease]; 
		NSString* filenameStr = [documentsDirectory
								 stringByAppendingPathComponent:leafname];
		
				
		[_webview loadFile:filenameStr]; 
		return S3E_RESULT_SUCCESS;
	}
	
    return S3E_RESULT_ERROR;
}

s3eResult LinkWebView_platform(WebViewSession* session, const char* url)
{

	return S3E_RESULT_SUCCESS;
}

s3eResult RemoveWebView_platform(WebViewSession* session)
{
	if (session != NULL) {
		WebViewObj* _webview = (WebViewObj*) session;
		[_webview dismiss];
		[_webview release];
		return S3E_RESULT_SUCCESS;
	}
	return S3E_RESULT_ERROR;

}

