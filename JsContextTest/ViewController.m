//
//  ViewController.m
//  JsContextTest
//
//  Created by Andrew Sinkevitch on 04/08/15.
//  Copyright (c) 2015 sinkevitch.name. All rights reserved.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "AFNetworking.h"

@interface ViewController ()

@property (nonatomic,strong) AFHTTPRequestOperationManager * httpClient;

@end


@implementation ViewController

@synthesize httpClient;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIWebView * webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    webView.delegate = self;
    JSContext * jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //JSContext * jsContext = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
    
    [jsContext setExceptionHandler:^(JSContext *context, JSValue *value) {
        NSLog(@"js_exception: %@", value);
    }];
    
#ifdef DEBUG
    NSLog(@"debug");
    jsContext[@"bbLog"] = ^{
        NSArray * args = [JSContext currentArguments];
        NSLog(@"js_console: %@", [args componentsJoinedByString:@" | "]);
    };
#endif
    
    
    //get the js code all in one file
    NSURL * url = [NSURL URLWithString:@"http://192.168.0.2/bybalance_bases/tool/get_js.php"];
    NSString * jsCode = [[NSString alloc] initWithContentsOfURL: url
                                                       encoding: NSUTF8StringEncoding
                                                          error: nil];
    //NSLog(@"%@", jsCode);
    [jsContext evaluateScript:jsCode];

    
    [self prepareHttpClient];
    
    jsContext[@"bbClear"] = ^(NSString * url) {
        NSArray * args = [JSContext currentArguments];
        NSLog(@"js_console bbClear: %@", [args componentsJoinedByString:@" | "]);
        [self doClear:url];
    };
    
    jsContext[@"bbGet"] = ^(NSString * url, JSValue * completion) {
        NSArray * args = [JSContext currentArguments];
        NSLog(@"js_console bbGet: %@", [args componentsJoinedByString:@" | "]);
        [self doGet:url withCompletion:completion];
    };
    
    jsContext[@"bbPost"] = ^(NSDictionary * params, JSValue * completion) {
        NSArray * args = [JSContext currentArguments];
        NSLog(@"js_console bbPost: %@", [args componentsJoinedByString:@" | "]);
        [self doPost:params withCompletion:completion];
    };
    
    JSValue * func = jsContext[@"checkBalance"];
    NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"123", @"username",
                           @"123", @"password",
                           nil];
    [func callWithArguments:@[@1, data]];
    
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"webView shouldStartLoadWithRequest: %@", request.URL);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"webView didFailLoadWithError: %@", error);
}

#pragma mark - request mediator

- (void) doClear:(NSString *)url
{
    NSLog(@"doClear %@", url);
    [self clearCookies:url];
}

- (void) doGet:(NSString *)url withCompletion:(JSValue *)completion
{
    NSLog(@"doGet %@", url);
    
    [self.httpClient GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //[self onStep1:operation.responseString];
        //callback(YES, operation.responseString);
        //NSLog(@"%@", operation.responseString);
        //NSLog(@"completion %@", completion);
        [completion callWithArguments:@[@1, operation.responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"doGet httpclient_error: %@", error.localizedDescription);
        //[self doFinish];
        //callback(NO, @"");
        [completion callWithArguments:@[@0, @""]];
    }];
}

- (void) doPost:(NSDictionary *)dict withCompletion:(JSValue *)completion
{
    NSLog(@"doPost %@", dict);
    
    
}


- (void) showCookies:(NSString *)url
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:url]];
    for (NSHTTPCookie *cookie in cookies)
    {
        NSLog(@"__cookie: %@", cookie);
    }
}

- (void) clearCookies:(NSString *)url
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:url]];
    for (NSHTTPCookie *cookie in cookies)
    {
        //DDLogVerbose(@"__cookie: %@", cookie);
        //if ([cookie.name isEqualToString:@"X3"]) continue; //skip velcom
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

- (void) prepareHttpClient
{
    self.httpClient = [AFHTTPRequestOperationManager manager];
    [httpClient.requestSerializer setValue:@"Mozilla/5.0 (Windows NT 6.1; WOW64; rv:38.0) Gecko/20100101 Firefox/38.0" forHTTPHeaderField:@"User-Agent"];
    httpClient.responseSerializer = [AFHTTPResponseSerializer serializer];
    httpClient.securityPolicy.allowInvalidCertificates = YES;
}

@end

