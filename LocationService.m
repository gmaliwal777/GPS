//
//  LocationService.m
//  BewaakDeBuurt
//
//  Created by Ghanshyam on 12/05/14.
//
//

/* 
 This is LocationService Class used to get updated location , new location is reverse
 Geocoded and when Reverse Geocoding is done , notification is generated for New
 Generated reverseGeocodedAddress.
 */

#import "LocationService.h"
#import "GeoAction.h"

@implementation LocationService
/**
 *  Used to initialize Location Service
 *
 *  @param reverseGeocoding : Boolean identifier which say whether to do reverse geocoding
 *
 *  @return : LocationService instacne
 */
-(id)initAndtoDoRevereGeocoding:(BOOL)reverseGeocoding{
    self = [super init];
    if (self) {
        
        toDoReverseGeocoding = reverseGeocoding;
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
    }
    return self;
}

-(void)startLocationManager{
    
    if([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];
}

-(void)stopLocationManager{
    [locationManager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    ////NSLog(@"location manager failed to get updated location");
    if ([_delegate conformsToProtocol:@protocol(LocationServiceDelegate)]
        && [_delegate respondsToSelector:@selector(locationServiceFailed)]) {
        [_delegate locationServiceFailed];
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusDenied) {
        if ([_delegate conformsToProtocol:@protocol(LocationServiceDelegate)]
            && [_delegate respondsToSelector:@selector(locationServiceNotAuthorized)]) {
            [_delegate locationServiceNotAuthorized];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    //this method is called for each second to get updated location , initially actual
    //location is deffered , we run this for at least 10 seconds to get actual locatin
    //coordinate
    //NSLog(@"calling location manager");
    
    CLLocation *location = [locations lastObject];
    float curLat = location.coordinate.latitude;
    float curLng = location.coordinate.longitude;
    
    @try {
        if (geoAction == nil && toDoReverseGeocoding) {
            geoAction = [[GeoAction alloc] init];
            [geoAction doReverseGeoCodingWithLatitude:curLat longitude:curLng];
        }
        
        //NSLog(@"lat = %f , lng = %f",curLat,curLng);
        if ([_delegate conformsToProtocol:@protocol(LocationServiceDelegate)]
            && [_delegate respondsToSelector:@selector(locationServiceDoneWithLatitude:longitude:)]) {
            [_delegate locationServiceDoneWithLatitude:curLat longitude:curLng];
        }
        
    }
    @catch (NSException *exception) {
        //Exception in location manager
    }
    @finally {
        
    }
}

-(void)dealloc{
    NSLog(@"dealloc called of locationservice class");
}

@end
