//
//  RequestMediator.m
//  JsContextTest
//
//  Created by Andrew Sinkevitch on 05/08/15.
//  Copyright (c) 2015 sinkevitch.name. All rights reserved.
//

#import "RequestMediator.h"
#import "AFNetworking.h"

@interface RequestMediator ()
@property (nonatomic,strong) AFHTTPRequestOperationManager * httpClient;
@end


@implementation RequestMediator

@synthesize httpClient;

- (void) prepareHttpClient
{
    self.httpClient = [AFHTTPRequestOperationManager manager];
    [httpClient.requestSerializer setValue:@"Mozilla/5.0 (Windows NT 6.1; WOW64; rv:38.0) Gecko/20100101 Firefox/38.0" forHTTPHeaderField:@"User-Agent"];
    httpClient.responseSerializer = [AFHTTPResponseSerializer serializer];
    httpClient.securityPolicy.allowInvalidCertificates = YES;
}

- (void) get:(NSString *)url then:(JSValue *)jsCallback
{
    NSLog(@"get_then");
    
    [self.httpClient GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //[self onStep1:operation.responseString];
        //callback(YES, operation.responseString);
        //NSLog(@"%@", operation.responseString);
        //NSLog(@"completion %@", completion);
        [jsCallback callWithArguments:@[@1, operation.responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"doGet httpclient_error: %@", error.localizedDescription);
        //[self doFinish];
        //callback(NO, @"");
        [jsCallback callWithArguments:@[@0, @""]];
    }];
}

- (void) post:(NSDictionary *)params then:(JSValue *)jsCallback
{
    NSLog(@"post_then");
}

@end
