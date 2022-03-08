//
//  TTPublics.h
//  Installer
//
//  Created by Eason on 24/10/2013.
//  Copyright (c) 2013 www.freetalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGMacros.h"


#define MGAPPVersion [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
#define MGAPPBundleId [[NSBundle mainBundle] bundleIdentifier]
#define MGAPPDisplayName [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
//SDK
#define kTTMGUserRememberBool YES
#define kTTMGUserAutomaticLoginBool YES
#define kTTMGUserReadAgreementBool YES






// define width, height
#define TTScreenHeight [[UIScreen mainScreen] bounds].size.height
#define TTScreenWidth [[UIScreen mainScreen] bounds].size.width

#define TTSegmentedControlHeight 29.f
#define TTSegmentedControlIndictorHeight 3.f
#define TTTabBarHeight 50.f

#define TTRecommendPageSegmentCount 3
#define TTSoftwarePageSegmentCount 4
#define TTGamesPageSegmentCount 4
#define TTUpdatePageSegmentCount 2

// global colors
#define TTGlobalColor TTHexColor(0x007aff) // global color

#define TTGlobalInstallColor TTRGBColor(114, 174, 41)
#define TTGlobalDownloadColor TTRGBColor(108, 172, 21)
#define TTGlobalDownloadingColor TTRGBColor(128, 183, 211)
#define TTGlobalUpdateColor TTHexColor(0x00c75a)
#define TTGlobalPauseColor TTRGBColor(206, 94, 94)


// common use initial values
#define kTTMaxDownloadingTaskCount 3
#define kTTSwitch3GNetworkStopDownload YES
#define kTTFinishDownloadAutoInstall YES
#define kTTInstallingNotice YES
#define kTTDownloadingForbidLockScreen YES
#define kTTAfterInstalledDeleteIpa NO // for bug test
#define kTTShowTipsBubbleOnTabBar YES

#ifdef DEBUG
#define kTTShowGuidelineOnFirstEnter YES //no is for debug, not show guide view
#define kTTShowAuthViewIfNotAuthorized YES // yes is for debug, not show auth view
#else
#define kTTShowGuidelineOnFirstEnter YES
#define kTTShowAuthViewIfNotAuthorized NO
#endif

// ui values

#define kTTGlobalCornerRadius TT_IS_IPHONE ? 9.f : 11.5f
#define kTTGlobalCellHeight 66.f

///////////////////////////////////////////////////////////////////////


// folder path

#define TTDocumentsFolderPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

#define TTInstallFilesFolder @"TTInstallFiles"
#define TTInstallFilesDirectory [TTDocumentsFolderPath stringByAppendingPathComponent:TTInstallFilesFolder]

#define TTTaskFilesFolder @"TTTaskFiles"
#define TTTaskFilesFolderDirectory [TTDocumentsFolderPath stringByAppendingPathComponent:TTTaskFilesFolder]


// for iPad
#define kTTHDContentViewWidth 475.f
#define kTTHDContentViewHeight TT_IS_IOS7_AND_UP ? 688 : 748
#define kTTHDTableViewCellHeight 100.f
#define kTTHDHeaderViewHeight 80.f

//#define kTTHDContentViewHeight  TT_IS_IOS7_AND_UP ? 768:748

#define DEFAULT_SPLIT_WD 210

//for ipad newVersion

#define NewHDTopSeqLineColor TTRGBColor(206, 206, 213)

#define NewHDCellSeqLineColor TTHexColor(0xd5d5db)

#define NewkTTGlobalCornerRadius 14

#define kTTHDNewLeftMenuWidth 210

#define kTTHDNewContentViewWidth (1024 - kTTHDNewLeftMenuWidth)
#define kTTHDNewContentViewHeight 768

#define kTTNewAppCellHeight 91

// MGPlatform Defines


@interface MGPublics : NSObject

@end
