//
//  BusStop.m
//  BusRoutes
//
//  Created by Aaron Eisses on 13-07-23.
//  Copyright (c) 2013 Aaron Eisses. All rights reserved.
//

#import "BusStop.h"

@interface BusStop (PrivateMethods)
- (void)parseStopDescription;
@end;

@implementation BusStop

- (id)initWithTitle:(NSString *)title description:(NSString*)decription andLocation:(KMLPoint*)location
{
    if (self = [super init])
    {
        _title = [title copy];
        _coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        _description = [decription copy];
        _date = nil;
        _address = nil;
        _routes = nil;
        [self parseStopDescription];
    }
    return self;
}

- (void)addRouteNumber:(NSNumber*)route
{
    if ([_routes indexOfObject:route] == NSNotFound) {
        NSMutableArray *mRoutes = [[NSMutableArray alloc] initWithArray:_routes];
        [mRoutes addObject:route];
        _routes = [[NSArray alloc] initWithArray:mRoutes];
        [mRoutes release];
    }
}

- (void)dealloc
{
    [super dealloc];
    [_title release];
    [_description release];
    if (_street) [_street release];
}

#pragma Private Methods
- (void)parseStopDescription
{
    NSMutableString *temp = [[NSMutableString alloc] initWithString:_description];
    [temp replaceOccurrencesOfString:@"<ul class=\"textattributes\">" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"<li><strong><span class=\"atr-name\">" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"</span>:</strong> <span class=\"atr-value\">" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"</span></li>" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    
    NSArray *splitArray = [temp componentsSeparatedByString:@"\n"];
    [temp release];
    for (NSString *element in splitArray) {
        NSString *trimedElemet = [element stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *thisArray = [trimedElemet componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([thisArray count] >= 2) {
            if ([(NSString *)([thisArray objectAtIndex:0]) isEqualToString:@"OBJECTID"]) {
                objectId = [(NSString *)([thisArray objectAtIndex:1]) integerValue];
            } else if ([(NSString *)([thisArray objectAtIndex:0]) isEqualToString:@"FCODE"]) {
                if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"TRBSIN"]) {
                    _fcode = trbsin;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"TRBSAC"]) {
                    _fcode = trbsac;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"TRBSTMIN"]) {
                    _fcode = trbstmin;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"TRBS"]) {
                    _fcode = trbs;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"TRBSSHAC"]) {
                    _fcode = trbsshac;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"TRBSSH"]) {
                    _fcode = trbssh;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"TRPR"]) {
                    _fcode = trpr;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"TRBSTMAC"]) {
                    _fcode = trbstmac;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"TRBSTM"]) {
                    _fcode = trbstm;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"TRBSSHIN"]) {
                    _fcode = trbsshin;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"TBRSML"]) {
                    _fcode = tbrsml;
                }
            } else if ([(NSString *)([thisArray objectAtIndex:0]) isEqualToString:@"SOURCE"]) {
                if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"TRANSIT"]) {
                    source = transit;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"HASTUS"]) {
                    source = hastus;
                }
            } else if ([(NSString *)([thisArray objectAtIndex:0]) isEqualToString:@"SACC"]) {
                if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"DV"]) {
                    sacc = DV;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"IN"]) {
                    sacc = IN;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"XY"]) {
                    sacc = XY;
                } else if ([(NSString*)([thisArray objectAtIndex:1]) isEqualToString:@"GP"]) {
                    sacc = GP;
                }
            } else if ([(NSString *)([thisArray objectAtIndex:0]) isEqualToString:@"SDATE"]) {
                if ([thisArray count] >= 6) {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"MMM d, YYYY hh:mm:ss a"];
                    _date = [formatter dateFromString:[NSString stringWithFormat:@"%@%@%@%@%@",[thisArray objectAtIndex:1],[thisArray objectAtIndex:2],[thisArray objectAtIndex:3],[thisArray objectAtIndex:4],[thisArray objectAtIndex:5]]];
                    [formatter release];
                }
            } else if ([(NSString *)([thisArray objectAtIndex:0]) isEqualToString:@"GOTIME"]) {
                _goTime = [(NSString *)([thisArray objectAtIndex:1]) integerValue];
            } else if ([(NSString *)([thisArray objectAtIndex:0]) isEqualToString:@"LOCATION"]) {
                _address = (NSString *)[[thisArray subarrayWithRange:NSMakeRange(1, [thisArray count]-1)] componentsJoinedByString:@" "];
                _direction = unknown;
                NSError *error = nil;
//                if ([_address isEqualToString:@"ROSS RD <FS> <IB> HWY 7"]) {
//                    NSLog(@"Hello");
//                }
                NSMutableString *myAddress = [NSMutableString stringWithString:_address];
                NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"( *<\\w+> *)" options:NSRegularExpressionCaseInsensitive error:&error];
                if (error) {
                    NSLog(@"Error on regexp: %@",[error localizedDescription]);
                    _street = @"";
                } else {
                    NSArray *matches = [regexp matchesInString:myAddress options:0 range:NSMakeRange(0, [myAddress length])];
                    if ([matches count]) {
                        for (NSTextCheckingResult *match in matches)
                        {
                            NSRange matchRange = match.range;
                            if ([[[myAddress substringWithRange:matchRange] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]] isEqualToString:@"<NB>"]) {
                                _direction = north;
                            } else if ([[[myAddress substringWithRange:matchRange] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]] isEqualToString:@"<SB>"]) {
                                _direction = south;
                            } else if ([[[myAddress substringWithRange:matchRange] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]] isEqualToString:@"<EB>"]) {
                                _direction = east;
                            } else if ([[[myAddress substringWithRange:matchRange] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]] isEqualToString:@"<WB>"]) {
                                _direction = west;
                            } else if ([[[myAddress substringWithRange:matchRange] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]] isEqualToString:@"<IB>"]) {
                                _direction = inbound;
                            } else if ([[[myAddress substringWithRange:matchRange] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]] isEqualToString:@"<OB>"]) {
                                _direction = outbound;
                            }
                        }
                    } else {
                        regexp = [NSRegularExpression regularExpressionWithPattern:@"( \\\[\\w+] *)" options:NSRegularExpressionCaseInsensitive error:&error];
                        if (error) {
                            NSLog(@"Error on regexp: %@",[error localizedDescription]);
                            _street = @"";
                        } else {
                            NSArray *matches = [regexp matchesInString:myAddress options:0 range:NSMakeRange(0, [myAddress length])];
                            for (NSTextCheckingResult *match in matches)
                            {
                                NSRange matchRange = match.range;
                                if ([[[myAddress substringWithRange:matchRange] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]] isEqualToString:@"[NB]"]) {
                                    _direction = north;
                                } else if ([[[myAddress substringWithRange:matchRange] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]] isEqualToString:@"[SB]"]) {
                                    _direction = south;
                                } else if ([[[myAddress substringWithRange:matchRange] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]] isEqualToString:@"[EB]"]) {
                                    _direction = east;
                                } else if ([[[myAddress substringWithRange:matchRange] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]] isEqualToString:@"[WB]"]) {
                                    _direction = west;
                                } else if ([[[myAddress substringWithRange:matchRange] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]] isEqualToString:@"[IB]"]) {
                                    _direction = inbound;
                                } else if ([[[myAddress substringWithRange:matchRange] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]] isEqualToString:@"[OB]"]) {
                                    _direction = outbound;
                                }
                            }
                        }
                        error = nil;
                    }
                }
                regexp = [NSRegularExpression regularExpressionWithPattern:@"\\w+" options:NSRegularExpressionCaseInsensitive error:&error];
                if (error) {
                    _street = @"";
                } else {
                    NSArray *matches = [regexp matchesInString:myAddress options:0 range:NSMakeRange(0, [myAddress length])];
                    NSMutableString *street = [[NSMutableString alloc] initWithString:@""];
                    for (NSTextCheckingResult *match in matches)
                    {
                        NSRange matchRange = match.range;
                        if ([[myAddress substringWithRange:matchRange] isEqualToString:@"FS"] ||
                            [[myAddress substringWithRange:matchRange] isEqualToString:@"OPP"] ||
                            [[myAddress substringWithRange:matchRange] isEqualToString:@"AT"] ||
                            [[myAddress substringWithRange:matchRange] isEqualToString:@"<FS>"] ||
                            [[myAddress substringWithRange:matchRange] isEqualToString:@"<AT>"] ||
                            [[myAddress substringWithRange:matchRange] isEqualToString:@"<OP>"] ||
                            [[myAddress substringWithRange:matchRange] isEqualToString:@"NS"]) {
                            break;
                        } else if ([[myAddress substringWithRange:matchRange] isEqualToString:@"<NS>"]) {
                            _direction = north;
                            break;
                        } else if ([[myAddress substringWithRange:matchRange] isEqualToString:@"<FS> <IB>"]) {
                            _direction = inbound;
                            break;
                        } else if ([[myAddress substringWithRange:matchRange] isEqualToString:@"NB"]) {
                            _direction = north;
                        } else if ([[myAddress substringWithRange:matchRange] isEqualToString:@"SB"]) {
                            _direction = south;
                        } else if ([[myAddress substringWithRange:matchRange] isEqualToString:@"EB"]) {
                            _direction = east;
                        } else if ([[myAddress substringWithRange:matchRange] isEqualToString:@"WB"]) {
                            _direction = west;
                        } else if ([[myAddress substringWithRange:matchRange] isEqualToString:@"IB"]) {
                            _direction = inbound;
                        } else if ([[myAddress substringWithRange:matchRange] isEqualToString:@"OB"]) {
                            _direction = outbound;
                        } else {
                            [street appendString:[NSString stringWithFormat:@"%@ ",[myAddress substringWithRange:matchRange]]];
                        }
                    }
                    _street = [[NSString alloc] initWithString:[street stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]]];
                    [street release];
                }
/*                if (!_street) {
                    NSLog(@"MyArray: %@",thisArray);
                    NSLog(@"Address: %@",_address);
                }
                if (_direction == unknown) {
                    NSLog(@"MyArray: %@",thisArray);
                    NSLog(@"Address: %@",_address);
                }*/
            }
        }
    }
}

@end
