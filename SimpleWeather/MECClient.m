//
//  MECClient.m
//  SimpleWeather
//
//  Created by Matias Casanova on 22/04/14.
//  Copyright (c) 2014 Matias Casanova. All rights reserved.
//

#import "MECClient.h"
#import "MECCondition.h"
#import "MECDailyForecast.h"

@interface MECClient()

@property (nonatomic,strong) NSURLSession *session;

@end

@implementation MECClient

- (instancetype) init{
    self = [super init];
    if(self){
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    
    return self;
}


-(RACSignal *)fetchJSONFromURL:(NSURL *)url{
    NSLog(@"Fetching: %@", url.absoluteString);
    
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url
                                                         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                                                             if (!error) {
                                                                 NSError *jsonError = nil;
                                                                 id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                                                                 if(!jsonError){
                                                                     [subscriber sendNext:json];
                                                                 }else{
                                                                     [subscriber sendError:jsonError];
                                                                 }
                                                             }else{
                                                                 [subscriber sendError:error];
                                                             }
                                                             [subscriber sendCompleted];
                                                         }];
        [dataTask resume];
        return [RACDisposable disposableWithBlock:^{
            
        }];
        
    }]doError:^(NSError *error){
        NSLog(@"%@", error);
    }];
}


- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate{
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=metric", coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json){
        return [MTLJSONAdapter modelOfClass:[MECCondition class] fromJSONDictionary:json error:nil];
    }];
}

- (RACSignal *)fetchHourlyForecatForLocation:(CLLocationCoordinate2D)coordinate{
    NSString * urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&units=metric&cnt=12", coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json){
        RACSequence *list = [json[@"list"] rac_sequence];
        
        return [[list map:^(NSDictionary *item){
            
            return [MTLJSONAdapter modelOfClass:[MECCondition class] fromJSONDictionary:item error:nil];
        }]array];
    }];
}

- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate{
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&units=metric&cnt=7", coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json){
        
        RACSequence *list = [json[@"list"] rac_sequence];

        return [[list map:^(NSDictionary *item){
            return [MTLJSONAdapter modelOfClass:[MECDailyForecast class] fromJSONDictionary:item error:nil];
        }]array];
        
    }];
}


@end
