//
//  UIDevice+MGAbout.h
//  TestTable
//
//  Created by Inder Kumar Rathore on 19/01/13.
//  Copyright (c) 2013 Rathore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (MGAbout)

/** This method returs the readble description without identifier (GSM, CDMA, GLOBAL) */
- (NSString *)hardwareSimpleDescription;


- (NSString*)macaddress;

- (NSString *)devicetype;
- (NSString*)deviceSystemVersion;

- (NSString*)deviceClientVersion;

- (NSString*)deviceNettype;

- (NSString*)MGCarrierName;
- (NSString *) MGDeviceResolution;

- (NSString *) MGDeviceIdfv;  // IDFV

- (NSDictionary *)deviceDict;

@end
