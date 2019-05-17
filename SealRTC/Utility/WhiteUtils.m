//
//  WhiteUtils.m
//  WhiteSDKPrivate_Example
//
//  Created by yleaf on 2019/3/4.
//  Copyright © 2019 leavesster. All rights reserved.
//

#import "WhiteUtils.h"

@implementation WhiteUtils

static NSString *APIHost = @"https://cloudcapiv4.herewhite.com";

+ (NSString *)sdkToken
{
    /* FIXME: 此处 tonken 只做 demo 试用。
     实际使用时，请从 console.herewhite.com 重新注册申请。
     该 token 不应该保存在客户端中，所有涉及该 token 的请求，都应该放在服务器中。
     */
    return @"WHITEcGFydG5lcl9pZD02dFBKT1lzMG52MHFoQzN2Z1BRUXVmN0t0RnVOVGl0bzBhRFAmc2lnPTMyZTRiNTMwNjkyN2RhN2I3NzI4MjMwOTJlZTNmNDJhNWI3MGMyMjU6YWRtaW5JZD0yMTEmcm9sZT1taW5pJmV4cGlyZV90aW1lPTE1ODkzNzY1MjEmYWs9NnRQSk9ZczBudjBxaEMzdmdQUVF1ZjdLdEZ1TlRpdG8wYURQJmNyZWF0ZV90aW1lPTE1NTc4MTk1Njkmbm9uY2U9MTU1NzgxOTU2OTQyNTAw";
}

//FIXME:我们推荐将这两个请求，放在您的服务器端进行。防止您从 console.herewhite.com 获取的 token 发生泄露。
+ (void)createRoomWithResult:(void (^) (BOOL success, id response, NSError *error))result;
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:[APIHost stringByAppendingPathComponent:@"room?token=%@"], self.sdkToken]]];
    NSMutableURLRequest *modifyRequest = [request mutableCopy];
    [modifyRequest setHTTPMethod:@"POST"];
    [modifyRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [modifyRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //@"mode": @"historied" 为可回放房间，默认为持久化房间。
    NSDictionary *params = @{@"name": @"test", @"limit": @110, @"mode": @"historied"};
    NSData *postData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    [modifyRequest setHTTPBody:postData];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:modifyRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error && result) {
                result(NO, nil, error);
            } else if (result) {
                NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                result(YES, responseObject, nil);
            }
        });
    }];
    [task resume];
}

/**
 向服务器获取对应 room uuid 所需要的房间 roomToken
 
 @param uuid 房间 uuid
 @param result 服务器返回信息
 */
+ (void)getRoomTokenWithUuid:(NSString *)uuid Result:(void (^) (BOOL success, id response, NSError *error))result
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:[APIHost stringByAppendingPathComponent:@"/room/join?uuid=%@&token=%@"], uuid, self.sdkToken]]];
    NSMutableURLRequest *modifyRequest = [request mutableCopy];
    [modifyRequest setHTTPMethod:@"POST"];
    [modifyRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:modifyRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error && result) {
                result(NO, nil, error);
            } else if (result) {
                NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if ([responseObject[@"code"] integerValue] == 200) {
                    result(YES, responseObject, nil);
                } else {
                    result(NO, responseObject, nil);
                }
            }
        });
    }];
    [task resume];
}

+ (void)deleteRoomTokenWithUuid:(NSString *)uuid
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:[APIHost stringByAppendingPathComponent:@"/room/close?token=%@"], self.sdkToken]]];
    NSMutableURLRequest *modifyRequest = [request mutableCopy];
    [modifyRequest setHTTPMethod:@"POST"];
    [modifyRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *params = @{@"uuid": uuid};
    NSData *postData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    [modifyRequest setHTTPBody:postData];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:modifyRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    }];
    [task resume];
}

+ (void)getWhiteBoardPagePreviewImage:(NSString *)uuid withRoomToken:(NSString *)token result:(void (^) (BOOL success, id response, NSError *error))result
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:[APIHost stringByAppendingPathComponent:@"/handle/rooms/snapshots?roomToken=%@"], token]]];
    NSMutableURLRequest *modifyRequest = [request mutableCopy];
    [modifyRequest setHTTPMethod:@"POST"];
    [modifyRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *params = @{@"width"     : @"160",
                             @"height"    : @"120",
                             @"uuid"      : uuid,
                             @"page"      : @(1),
                             @"size"      : @(10),
                             @"scenePath" : @"/rtc"};
    NSData *postData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    [modifyRequest setHTTPBody:postData];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:modifyRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error && result) {
                result(NO, nil, error);
            } else if (result) {
                NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if ([responseObject[@"code"] integerValue] == 200) {
                    result(YES, responseObject, nil);
                } else {
                    result(NO, responseObject, nil);
                }
            }
        });
    }];
    [task resume];
}

@end
