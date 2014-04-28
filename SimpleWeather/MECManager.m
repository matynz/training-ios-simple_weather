//
//  MECManager.m
//  SimpleWeather
//
//  Created by Matias Casanova on 22/04/14.
//  Copyright (c) 2014 Matias Casanova. All rights reserved.
//

#import "MECManager.h"
#import "MECClient.h"
#import <TSMessages/TSMessage.h>

@interface MECManager()

@property (nonatomic, strong, readwrite) MECCondition *currentCondition;
@property (nonatomic, strong, readwrite) CLLocation *currentLocation;
@property (nonatomic, strong, readwrite) NSArray *hourlyForecast;
@property (nonatomic, strong, readwrite) NSArray *dailyForecast;

@property(nonatomic,strong) CLLocationManager *locationManager;
@property(nonatomic,assign) BOOL isFirstUpdate;
@property(nonatomic,strong) MECClient *client;


@end


@implementation MECManager

+ (instancetype)sharedManager{
    
    static id _sharedManger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManger = [[self alloc]init];
    });
    
    return _sharedManger;
}

- (id)init{
    self = [super init];
    if(self){
    
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
        
        _client = [[MECClient alloc] init];
        
        [[[[RACObserve(self, currentLocation)
            ignore:nil]
        
           flattenMap:^(CLLocation *newLocation){

               return [RACSignal merge:@[
                                         [self updateCurrentConditions],
                                         [self updateHourlyForecast],
                                         [self updateDailyForecast]
                                         ]];
           }] deliverOn:RACScheduler.mainThreadScheduler]
         subscribeError:^(NSError *error){

             //don't do this
             [TSMessage showNotificationWithTitle:@"Error"
                                         subtitle:@"There was a problem fetching the latest weather."
                                             type:TSMessageNotificationTypeError];
         }];
    }
    return self;
    
}

- (void)findCurrentLocation{
    self.isFirstUpdate = YES;
    [self.locationManager startUpdatingLocation];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    if(self.isFirstUpdate){
        self.isFirstUpdate = NO;
        return ;
    }
    
    CLLocation *location = [locations lastObject];
    
    if(location.horizontalAccuracy>0){
        self.currentLocation = location;
        [self.locationManager stopUpdatingLocation];
    }
    
    
}


- (RACSignal *)updateCurrentConditions{
    return [[self.client fetchCurrentConditionsForLocation:self.currentLocation.coordinate] doNext:^(MECCondition *condition){
        self.currentCondition = condition;
    }];
}

- (RACSignal *)updateHourlyForecast{
    return [[self.client fetchHourlyForecatForLocation:self.currentLocation.coordinate] doNext:^(NSArray *array){
        self.hourlyForecast = array;
    }];
}

- (RACSignal *)updateDailyForecast{
    return [[self.client fetchDailyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *array){
        self.dailyForecast = array;
    }];
}

@end
