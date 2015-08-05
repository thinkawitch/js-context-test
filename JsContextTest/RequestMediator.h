//
//  RequestMediator.h
//  JsContextTest
//
//  Created by Andrew Sinkevitch on 05/08/15.
//  Copyright (c) 2015 sinkevitch.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol RequestMediatorExport <JSExport>
- (void) get:(NSString *)url then:(JSValue *)jsCallback;
- (void) post:(NSDictionary *)params then:(JSValue *)jsCallback;
@end


@interface RequestMediator : NSObject <RequestMediatorExport>
- (void) prepareHttpClient;
@end


