//
//  LocationService.h
//  BewaakDeBuurt
//
//  Created by Ghanshyam on 12/05/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MediaPlayer/MediaPlayer.h>

@class GeoAction;

#import "GeoAction.h"

@protocol LocationServiceDelegate <NSObject>
-(void)locationServiceFailed;
-(void)locationServiceDoneWithLatitude:(float)latitude longitude:(float)longitude;
-(void)locationServiceNotAuthorized;
@end

@interface LocationService : NSObject<CLLocationManagerDelegate>{
    
    CLLocationManager *locationManager;
    
    GeoAction         *geoAction;
    
    /**
     *  Boolean identifier to say whether to do reverse - geocoding or not
     */
    BOOL              toDoReverseGeocoding;
}

@property(nonatomic,weak) id<LocationServiceDelegate> delegate;

-(void)startLocationManager;
-(void)stopLocationManager;



/**
 *  Used to initialize Location Service
 *
 *  @param reverseGeocoding : Boolean identifier which say whether to do reverse geocoding
 *
 *  @return : LocationService instacne
 */
-(id)initAndtoDoRevereGeocoding:(BOOL)reverseGeocoding;


@end
