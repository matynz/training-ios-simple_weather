//
//  MECManager.h
//  SimpleWeather
//
//  Created by Matias Casanova on 22/04/14.
//  Copyright (c) 2014 Matias Casanova. All rights reserved.
//

@import CoreLocation;
@import Foundation;
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
#import "MECCondition.h"

@interface MECManager : NSObject<CLLocationManagerDelegate>

+ (instancetype) sharedManager;

@property(nonatomic, strong, readonly) MECCondition *currentCondition;
@property(nonatomic, strong, readonly) CLLocation *currentLocation;
@property(nonatomic, strong, readonly) NSArray *hourlyForecast;
@property(nonatomic, strong, readonly) NSArray *dailyForecast;

- (void)findCurrentLocation;

@end
