/*
 * WARNING: this is an autogenerated file and will be overwritten by
 * the extension interface script.
 */
/*
 * This file contains the automatically generated loader-side
 * functions that form part of the extension.
 *
 * This file is awlays compiled into all loaders but compiles
 * to nothing if this extension is not enabled in the loader
 * at build time.
 */
#include "IwDebug.h"
#include "WebView_autodefs.h"
#include "s3eEdk.h"
#include "WebView.h"
//Declarations of Init and Term functions
extern s3eResult WebViewInit();
extern void WebViewTerminate();


#ifdef I3D_OS_IPHONE

static WebViewSession* InitWebView_wrap()
{
    IwTrace(WEBVIEW_VERBOSE, ("calling WebView func on main thread: InitWebView"));
    return (WebViewSession*)s3eEdkThreadRunOnOS((s3eEdkThreadFunc)InitWebView, 0);
}

static s3eResult CreateWebView_wrap(WebViewSession* session, const char* file)
{
    IwTrace(WEBVIEW_VERBOSE, ("calling WebView func on main thread: CreateWebView"));
    return (s3eResult)(intptr_t)s3eEdkThreadRunOnOS((s3eEdkThreadFunc)CreateWebView, 2, session, file);
}

static s3eResult ParamWebView_wrap(WebViewSession* session, const char* name, const char* value)
{
    IwTrace(WEBVIEW_VERBOSE, ("calling WebView func on main thread: ParamWebView"));
    return (s3eResult)(intptr_t)s3eEdkThreadRunOnOS((s3eEdkThreadFunc)ParamWebView, 3, session, name, value);
}

static s3eResult ConnectWebView_wrap(WebViewSession* session, const char* url)
{
    IwTrace(WEBVIEW_VERBOSE, ("calling WebView func on main thread: ConnectWebView"));
    return (s3eResult)(intptr_t)s3eEdkThreadRunOnOS((s3eEdkThreadFunc)ConnectWebView, 2, session, url);
}

static s3eResult RemoveWebView_wrap(WebViewSession* session)
{
    IwTrace(WEBVIEW_VERBOSE, ("calling WebView func on main thread: RemoveWebView"));
    return (s3eResult)(intptr_t)s3eEdkThreadRunOnOS((s3eEdkThreadFunc)RemoveWebView, 1, session);
}

static s3eResult TurnWebView_wrap(WebViewSession* session, int direction)
{
    IwTrace(WEBVIEW_VERBOSE, ("calling WebView func on main thread: TurnWebView"));
    return (s3eResult)(intptr_t)s3eEdkThreadRunOnOS((s3eEdkThreadFunc)TurnWebView, 2, session, direction);
}

static const char* EvalJSWebView_wrap(WebViewSession* session, const char* js)
{
    IwTrace(WEBVIEW_VERBOSE, ("calling WebView func on main thread: EvalJSWebView"));
    return (const char*)s3eEdkThreadRunOnOS((s3eEdkThreadFunc)EvalJSWebView, 2, session, js);
}

#define InitWebView InitWebView_wrap
#define CreateWebView CreateWebView_wrap
#define ParamWebView ParamWebView_wrap
#define ConnectWebView ConnectWebView_wrap
#define RemoveWebView RemoveWebView_wrap
#define TurnWebView TurnWebView_wrap
#define EvalJSWebView EvalJSWebView_wrap

#endif /* I3D_OS_IPHONE */

s3eResult WebViewRegister(WebViewCallback cbid, s3eCallback fn, void* pData)
{
    return s3eEdkCallbacksRegister(S3E_EXT_WEBVIEW_HASH, S3E_WEBVIEW_CALLBACK_MAX, cbid, fn, pData, 0);
};

s3eResult WebViewUnRegister(WebViewCallback cbid, s3eCallback fn)
{
    return s3eEdkCallbacksUnRegister(S3E_EXT_WEBVIEW_HASH, S3E_WEBVIEW_CALLBACK_MAX, cbid, fn);
}

void WebViewRegisterExt()
{
    /* fill in the function pointer struct for this extension */
    void* funcPtrs[9];
    funcPtrs[0] = (void*)WebViewRegister;
    funcPtrs[1] = (void*)WebViewUnRegister;
    funcPtrs[2] = (void*)InitWebView;
    funcPtrs[3] = (void*)CreateWebView;
    funcPtrs[4] = (void*)ParamWebView;
    funcPtrs[5] = (void*)ConnectWebView;
    funcPtrs[6] = (void*)RemoveWebView;
    funcPtrs[7] = (void*)TurnWebView;
    funcPtrs[8] = (void*)EvalJSWebView;

    /*
     * Flags that specify the extension's use of locking and stackswitching
     */
    int flags[9] = { 0 };

    /*
     * Register the extension
     */
    s3eEdkRegister("WebView", funcPtrs, sizeof(funcPtrs), flags, WebViewInit, WebViewTerminate, 0);
}

#if !defined S3E_BUILD_S3ELOADER

#if defined S3E_EDK_USE_STATIC_INIT_ARRAY
int WebViewStaticInit()
{
    void** p = g_StaticInitArray;
    void* end = p + g_StaticArrayLen;
    while (*p) p++;
    if (p < end)
        *p = (void*)&WebViewRegisterExt;
    return 0;
}

int g_WebViewVal = WebViewStaticInit();

#elif defined S3E_EDK_USE_DLLS
S3E_EXTERN_C S3E_DLL_EXPORT void RegisterExt()
{
    WebViewRegisterExt();
}
#endif

#endif
