//
//  MECDailyForecast.m
//  
//
//  Created by Matias Casanova on 22/04/14.
//
//

#import "MECDailyForecast.h"

@implementation MECDailyForecast

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    return paths;
    
}
@end
