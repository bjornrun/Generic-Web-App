/*
 * WARNING: this is an autogenerated file and will be overwritten by
 * the extension interface script.
 */

#include "s3eExt.h"
#include "IwDebug.h"

#include "WebView.h"

/**
 * Definitions for functions types passed to/from s3eExt interface
 */
typedef  s3eResult(*WebViewRegister_t)(WebViewCallback cbid, s3eCallback fn, void* userData);
typedef  s3eResult(*WebViewUnRegister_t)(WebViewCallback cbid, s3eCallback fn);
typedef WebViewSession*(*InitWebView_t)();
typedef  s3eResult(*CreateWebView_t)(WebViewSession* session, const char* file);
typedef  s3eResult(*LinkWebView_t)(WebViewSession* session, const char* url);
typedef  s3eResult(*RemoveWebView_t)(WebViewSession* session);


/**
 * struct that gets filled in by WebViewRegister
 */
typedef struct WebViewFuncs
{
    WebViewRegister_t m_WebViewRegister;
    WebViewUnRegister_t m_WebViewUnRegister;
    InitWebView_t m_InitWebView;
    CreateWebView_t m_CreateWebView;
    LinkWebView_t m_LinkWebView;
    RemoveWebView_t m_RemoveWebView;
} WebViewFuncs;

static WebViewFuncs ext;
static bool g_got_ext = false;
static bool g_tried_ext = false;
static bool g_tried_nomsg_ext = false;



static bool _extLoad()
{
    if (!g_got_ext && !g_tried_ext)
    {
        s3eResult res = s3eExtGetHash(0xbedac4de, &ext, sizeof(ext));
        if (res == S3E_RESULT_SUCCESS)
            g_got_ext = true;
        else
            s3eDebugAssertShow(S3E_MESSAGE_CONTINUE_STOP_IGNORE, "error loading extension: WebView");
        g_tried_ext = true;
        g_tried_nomsg_ext = true;
    }

    return g_got_ext;
}


static bool _extLoadNoMsg()
{
    if (!g_got_ext && !g_tried_nomsg_ext)
    {
        s3eResult res = s3eExtGetHash(0xbedac4de, &ext, sizeof(ext));
        if (res == S3E_RESULT_SUCCESS)
            g_got_ext = true;
        g_tried_nomsg_ext = true;
        if (g_tried_ext)
            g_tried_ext = true;
    }

    return g_got_ext;
}



s3eBool WebViewAvailable()
{
    _extLoadNoMsg();
    return g_got_ext ? S3E_TRUE : S3E_FALSE;
}

s3eResult WebViewRegister(WebViewCallback cbid, s3eCallback fn, void* userData)
{
    IwTrace(WEBVIEW_VERBOSE, ("calling WebView[0] func: WebViewRegister"));

    if (!_extLoad())
        return S3E_RESULT_ERROR;

    return ext.m_WebViewRegister(cbid, fn, userData);
}

s3eResult WebViewUnRegister(WebViewCallback cbid, s3eCallback fn)
{
    IwTrace(WEBVIEW_VERBOSE, ("calling WebView[1] func: WebViewUnRegister"));

    if (!_extLoad())
        return S3E_RESULT_ERROR;

    return ext.m_WebViewUnRegister(cbid, fn);
}

WebViewSession* InitWebView()
{
    IwTrace(WEBVIEW_VERBOSE, ("calling WebView[2] func: InitWebView"));

    if (!_extLoad())
        return NULL;

    return ext.m_InitWebView();
}

s3eResult CreateWebView(WebViewSession* session, const char* file)
{
    IwTrace(WEBVIEW_VERBOSE, ("calling WebView[3] func: CreateWebView"));

    if (!_extLoad())
        return S3E_RESULT_ERROR;

    return ext.m_CreateWebView(session, file);
}

s3eResult LinkWebView(WebViewSession* session, const char* url)
{
    IwTrace(WEBVIEW_VERBOSE, ("calling WebView[4] func: LinkWebView"));

    if (!_extLoad())
        return S3E_RESULT_ERROR;

    return ext.m_LinkWebView(session, url);
}

s3eResult RemoveWebView(WebViewSession* session)
{
    IwTrace(WEBVIEW_VERBOSE, ("calling WebView[5] func: RemoveWebView"));

    if (!_extLoad())
        return S3E_RESULT_ERROR;

    return ext.m_RemoveWebView(session);
}
