//
//  GTMNSString+URLArguments.m
//
//  Copyright 2006-2008 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import "NSString+MGURLArguments.h"

@implementation NSString (NSStringMGURLArgumentsAdditions)

- (NSString*)MGStringByEscapingForURLArgument
{
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                  (CFStringRef)self,
                                                                  NULL,
                                                                  (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                                  kCFStringEncodingUTF8);
#if defined(__has_feature) && __has_feature(objc_arc)
    return CFBridgingRelease(escaped);
#else
    return [(NSString*)escaped autorelease];
#endif
}

- (NSString*)MGStringByUnescapingFromURLArgument
{
    NSMutableString* resultString = [NSMutableString stringWithString:self];
    [resultString replaceOccurrencesOfString:@"+"
                                  withString:@" "
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, [resultString length])];
    return [resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString*)MGURLEncodedString
{
    NSString* encodedString = (NSString*)
	CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
								  (CFStringRef)self,
								  (CFStringRef) @"!$&'()*+,-./:;=?@_~%#[]",
								  NULL,
								  kCFStringEncodingUTF8));
    return encodedString;
}

@end
