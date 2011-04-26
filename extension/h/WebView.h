/*
 * Copyright (C) 2001-2011 Ideaworks3D Ltd.
 * All Rights Reserved.
 *
 * This document is protected by copyright, and contains information
 * proprietary to Ideaworks Labs.
 * This file consists of source code released by Ideaworks Labs under
 * the terms of the accompanying End User License Agreement (EULA).
 * Please do not use this program/source code before you have read the
 * EULA and have agreed to be bound by its terms.
 */
/*
 * WARNING: this is an autogenerated file and will be overwritten by
 * the extension interface script.
 */
#ifndef S3E_EXT_WEBVIEW_H
#define S3E_EXT_WEBVIEW_H

#include <s3eTypes.h>

struct WebViewSession;

typedef void (*WebViewCallbackFn)(WebViewSession *, s3eResult *, void *);

enum WebViewCallback
{
    WEBVIEW_CALLBACK_PAGE_LOADED,
    WEBVIEW_CALLBACK_PAGE_ERROR,
	WEBVIEW_CALLBACK_LINK,
    S3E_WEBVIEW_CALLBACK_MAX
};

S3E_BEGIN_C_DECL

/**
 * Returns S3E_TRUE if the WebView extension is available.
 */
s3eBool WebViewAvailable();

/**
 * Registers a callback to be called for an operating system event.
 *
 * The available callback types are listed in @ref WebViewCallback.
 * @param cbid ID of the event for which to register.
 * @param fn callback function.
 * @param userdata Value to pass to the @e userdata parameter of @e NotifyFunc.
 * @return
 * <ul>
 *  <li>@ref S3E_RESULT_SUCCESS if no error occurred.
 *  <li>@ref S3E_RESULT_ERROR if the operation failed.\n
 * </ul>
 * @see WebViewUnRegister
 * @note For more information on the system data passed as a parameter to the callback
 * registered using this function, see the @ref WebViewCallback enum.
 */
s3eResult WebViewRegister(WebViewCallback cbid, s3eCallback fn, void* userData);

/**
 * Unregister a callback for a given event.
 * @param cbid ID of the callback for which to register.
 * @param fn Callback Function.
 * @return
 * - @ref S3E_RESULT_SUCCESS if no error occurred.
 * - @ref S3E_RESULT_ERROR if the operation failed.\n
 * @note For more information on the systemData passed as a parameter to the callback
 * registered using this function, see the WebViewCallback enum.
 * @note It is not necessary to define a return value for any registered callback.
 * @see WebViewRegister
 */
s3eResult WebViewUnRegister(WebViewCallback cbid, s3eCallback fn);

WebViewSession* InitWebView();

s3eResult CreateWebView(WebViewSession* session, const char* file);

s3eResult LinkWebView(WebViewSession* session, const char* url);

s3eResult RemoveWebView(WebViewSession* session);

S3E_END_C_DECL

#endif /* !S3E_EXT_WEBVIEW_H */
