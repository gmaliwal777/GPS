//
//  GeoAction.h
//  BewaakDeBuurt
//
//  Created by Ghanshyam on 12/05/14.
//
//

#import <Foundation/Foundation.h>

@interface GeoAction : NSObject
-(void)doReverseGeoCodingWithLatitude:(float)latitude longitude:(float)longitude;
-(void)doGeoCodingWithAddress:(NSString *)address;
@end
