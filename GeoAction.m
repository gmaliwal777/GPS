//
//  GeoAction.m
//  BewaakDeBuurt
//
//  Created by Ghanshyam on 12/05/14.
//
//

#import "GeoAction.h"
#import "WSConnection.h"

@implementation GeoAction

-(void)doReverseGeoCodingWithLatitude:(float)latitude longitude:(float)longitude{
    NSString *strWebURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true",latitude,longitude];
    ////NSLog(@"strweburl for reverse geocode is %@",strWebURL);
    WSConnection *connection = [[WSConnection alloc] init];
    [connection sendGetRequestWithUrl:strWebURL backgroundQueue:dispatch_queue_create("com.bewaakdebuurt.reversegeocode1", NULL)];
    [connection setCompletionHandler:^(NSData *responseData, int statusCode) {
        dispatch_queue_t background = dispatch_queue_create("com.bewaakdebuurt.reversegeocode", NULL);
        dispatch_async(background, ^{
            [self reverseGeocodeHandler:responseData];
        });
    }];
}

-(void)reverseGeocodeHandler:(NSData *)responseData{
    NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
    NSString *address1 = @"";
    NSString *address2 = @"";
    NSString *city = @"";
    NSString *country = @"";
    
    @try {
        NSError *error;
        NSDictionary *dictJsonData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
        //////NSLog(@"dictJsonData is %@",dictJsonData);
        
        if (dictJsonData != nil) {
            if (error) {
                ////NSLog(@"error in webservice response");
            }else if([[dictJsonData objectForKey:@"status"] isEqualToString:@"OK"]){
                NSDictionary *dictAddressData = [[dictJsonData objectForKey:@"results"] objectAtIndex:0];
                NSLog(@"dict address data is %@",dictAddressData);
                NSArray *arrAddressComp = [dictAddressData objectForKey:@"address_components"];
                
                [dictData setObject:[dictAddressData objectForKey:@"formatted_address"] forKeyedSubscript:@"address"];
                
                for (int counter =0; counter<[arrAddressComp count]; counter++) {
                    NSDictionary *dictData = [arrAddressComp objectAtIndex:counter];
                    if ([[[dictData objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"street_number"]) {
                        address1 = [dictData objectForKey:@"long_name"];
                        NSLog(@"address1 is %@",address1);
                    }else if ([[[dictData objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"sublocality_level_2"]){
                        address2=[dictData objectForKey:@"long_name"];
                        NSLog(@"city is %@",city);
                    }else if ([[[dictData objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"administrative_area_level_2"]){
                        city=[dictData objectForKey:@"long_name"];
                        NSLog(@"city is %@",city);
                    }else if ([[[dictData objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"country"]){
                        country =[dictData objectForKey:@"long_name"];
                        NSLog(@"country is %@",country);
                    }else if ([address2 isEqualToString:@""] && [[[dictData objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"locality"]){
                        address2=[dictData objectForKey:@"long_name"];
                    }else if ([address1 isEqualToString:@""] && [[[dictData objectForKey:@"types"] objectAtIndex:0] isEqualToString:@"route"]){
                        address1=[dictData objectForKey:@"long_name"];
                    }
                }
                
            }
        }
    }@catch (NSException *exception) {
        NSLog(@"exception here");
    }@finally{
        [dictData setObject:address1 forKeyedSubscript:@"address1"];
        [dictData setObject:address2 forKeyedSubscript:@"address2"];
        [dictData setObject:city forKeyedSubscript:@"city"];
        [dictData setObject:country forKeyedSubscript:@"country"];
        
        if (![dictData objectForKey:@"address"]) {
            [dictData setObject:@"" forKeyedSubscript:@"address"];
        }
        
        [self performSelectorOnMainThread:@selector(generateReverseGeocodeNotification:) withObject:dictData waitUntilDone:YES];
    }
}

-(void)generateReverseGeocodeNotification:(NSDictionary *)dictAddress{
    NSLog(@"address is %@",[dictAddress objectForKey:@"address"]);
    [[NSNotificationCenter defaultCenter] postNotificationName:BK_REVERSE_GEOCODE_ADDRESS_NOTIFICATION object:[dictAddress objectForKey:@"address"] userInfo:dictAddress];
}


-(void)doGeoCodingWithAddress:(NSString *)address{
    NSString *strWebURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true",address];
    //NSLog(@"strweburl is %@",strWebURL);
    strWebURL = [strWebURL stringByReplacingOccurrencesOfString:@" " withString:@""];
    WSConnection *connection = [[WSConnection alloc] init];
    [connection sendGetRequestWithUrl:strWebURL backgroundQueue:dispatch_queue_create("com.bewaakdebuurt.geocode1", NULL)];
    [connection setCompletionHandler:^(NSData *responseData, int statusCode) {
        dispatch_queue_t background = dispatch_queue_create("com.bewaakdebuurt.geocode", NULL);
        dispatch_async(background, ^{
            [self geoCodeHandler:responseData];
        });
    }];
}

-(void)geoCodeHandler:(NSData *)responseData{
    @try {
        NSError *error;
        NSDictionary *dictJsonData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
        //NSLog(@"dictjson data is %@",dictJsonData);
        if (error) {
            ////NSLog(@"error in geocode webservice");
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"0",@"lat",@"0",@"lng", nil];
            [self performSelectorOnMainThread:@selector(generateGeocodeNotification:) withObject:dict waitUntilDone:YES];
            
        }else if ([[dictJsonData objectForKey:@"status"] isEqualToString:@"OK"]){
            
            NSDictionary *dictAddressData = [[dictJsonData objectForKey:@"results"] objectAtIndex:0];
            NSString* updatedLat = [[[dictAddressData objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"];
            NSString* updatedLng = [[[dictAddressData objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"];
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:updatedLat,@"lat",updatedLng,@"lng", nil];
            [self performSelectorOnMainThread:@selector(generateGeocodeNotification:) withObject:dict waitUntilDone:YES];
            
        }else{
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"0",@"lat",@"0",@"lng", nil];
            [self performSelectorOnMainThread:@selector(generateGeocodeNotification:) withObject:dict waitUntilDone:YES];
        }
    }
    @catch (NSException *exception) {
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"0",@"lat",@"0",@"lng", nil];
        [self performSelectorOnMainThread:@selector(generateGeocodeNotification:) withObject:dict waitUntilDone:YES];
    }
}

-(void)generateGeocodeNotification:(NSDictionary *)dictData{
    [[NSNotificationCenter defaultCenter] postNotificationName:BK_GEOCODE_ADDRESS_NOTIFICATION object:nil userInfo:dictData];
}

-(void)dealloc{
    NSLog(@"dealloc called of geoaction class");
}

@end
