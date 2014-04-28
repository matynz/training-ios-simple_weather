//
//  MECClient.h
//  SimpleWeather
//
//  Created by Matias Casanova on 22/04/14.
//  Copyright (c) 2014 Matias Casanova. All rights reserved.
//

@import CoreLocation;
@import Foundation;
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>

@interface MECClient : NSObject

- (RACSignal *)fetchJSONFromURL:(NSURL *)url;
- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate;
- (RACSignal * )fetchHourlyForecatForLocation:(CLLocationCoordinate2D)coordinate;
- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate;





@end
