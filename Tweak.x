#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Spoof iOS version to 16.4 within this app
%hook UIDevice

- (NSString *)systemVersion {
    return @"16.4";
}

%end

// Intercept network responses to modify the force-upgrade feature flag
%hook NSURLSession

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler {

    NSString *url = request.URL.absoluteString;

    if ([url containsString:@"feature-flags"]) {
        // Wrap the original completion handler
        void (^originalHandler)(NSData *, NSURLResponse *, NSError *) = [completionHandler copy];

        void (^modifiedHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error) {
            if (data) {
                NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

                if (body && [body containsString:@"force-upgrade"]) {
                    // Replace maxVersion with 0.0.0 so no app version triggers force upgrade
                    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\"maxVersion\":\"[^\"]*\""
                                                                                         options:0
                                                                                           error:nil];
                    NSString *modified = [regex stringByReplacingMatchesInString:body
                                                                        options:0
                                                                          range:NSMakeRange(0, body.length)
                                                                withTemplate:@"\"maxVersion\":\"0.0.0\""];

                    NSData *modifiedData = [modified dataUsingEncoding:NSUTF8StringEncoding];

                    if (modifiedData) {
                        NSLog(@"[HBOMaxBypass] Successfully modified force-upgrade flag");
                        originalHandler(modifiedData, response, error);
                        return;
                    }
                }
            }

            // Fall through to original if no modification needed
            originalHandler(data, response, error);
        };

        return %orig(request, modifiedHandler);
    }

    return %orig;
}

%end

%ctor {
    NSLog(@"[HBOMaxBypass] Loaded successfully");
}
