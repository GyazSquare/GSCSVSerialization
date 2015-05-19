//
//  GSCSVSerialization.m
//  GSCSVSerialization
//

@import Foundation;

#import "GSCSVSerialization.h"

#define kDQUOTE @"\x22"
#define kCOMMA  @"\x2C"
#define kCR     @"\x0D"
#define kLF     @"\x0A"
#define kCRLF   @"\x0D\x0A"

#define kDQUOTECharacter 0x22

static BOOL __GSCSVIsValidCSVRecords(NSArray *records, NSString **errorString) {
    if (records.count == 0) {
        if (errorString) {
            *errorString = @"records count is zero";
        }
        return NO;
    }
    NSUInteger fieldCount = 0;
    for (NSArray *fields in records) {
        if (![fields isKindOfClass:[NSArray class]]) {
            if (errorString) {
                *errorString = [NSString stringWithFormat:@"invalid record type (%@)", [fields class]];
            }
            return NO;
        }
        if (fieldCount == 0) {
            fieldCount = fields.count;
            if (fieldCount == 0) {
                if (errorString) {
                    *errorString = @"number of fields is zero";
                }
                return NO;
            }
        } else {
            if (fieldCount != fields.count) {
                if (errorString) {
                    *errorString = @"each record should contain the same number of fields";
                }
                return NO;
            }
        }
        for (NSString *field in fields) {
            if (![field isKindOfClass:[NSString class]]) {
                if (errorString) {
                    *errorString = [NSString stringWithFormat:@"invalid field type (%@)", [field class]];
                }
                return NO;
            }
        }
    }
    return YES;
}

static BOOL __GSCSVScanEscaped(NSScanner *scanner, GSCSVReadingOptions opt, NSString **outEscaped, NSError **outError) {
    NSUInteger startLocation = scanner.scanLocation;
    if (![scanner scanString:kDQUOTE intoString:NULL]) {
        [NSException raise:NSInternalInconsistencyException format:@"*** %s: a escaped field must start with a double-quote", __PRETTY_FUNCTION__];
    }
    NSString *result = nil;
    for (;;) {
        NSString *partialString = @"";
        [scanner scanUpToString:kDQUOTE intoString:&partialString];
        if (![scanner scanString:kDQUOTE intoString:NULL]) {
            if (outError) {
                NSString *description = NSLocalizedString(@"The data couldn’t be read because it isn’t in the correct format.", @"");
                NSString *debugDescription = [NSString stringWithFormat:NSLocalizedString(@"Invalid escaped field around character %lu", @""), (unsigned long)startLocation];
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: description, @"NSDebugDescription": debugDescription};
                *outError = [NSError errorWithDomain:GSCSVErrorDomain code:GSCSVErrorReadCorrupt userInfo:userInfo];
            }
            return NO;
        }
        if (!result) {
            result = partialString;
        } else {
            result = [result stringByAppendingString:partialString];
        }
        if (![scanner scanString:kDQUOTE intoString:NULL]) {
            break;
        }
        // 2DQUOTE
        result = [result stringByAppendingString:kDQUOTE];
    }
    if (outEscaped) {
        if (opt & GSCSVReadingMutableLeaves) {
            *outEscaped = [result mutableCopy];
        } else {
            *outEscaped = result;
        }
    }
    return YES;
}

static BOOL __GSCSVScanNonEscaped(NSScanner *scanner, GSCSVReadingOptions opt, NSString **outNonEscaped, NSError **outError) {
    static NSCharacterSet *fieldSeparatorCharacterSet = nil; // CR / LF / COMMA
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        fieldSeparatorCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"\x2C\x0D\x0A"];
    });
    NSString *result = @"";
    [scanner scanUpToCharactersFromSet:fieldSeparatorCharacterSet intoString:&result];
    if (outNonEscaped) {
        if (opt & GSCSVReadingMutableLeaves) {
            *outNonEscaped = [result mutableCopy];
        } else {
            *outNonEscaped = result;
        }
    }
    return YES;
}

static BOOL __GSCSVScanField(NSScanner *scanner, GSCSVReadingOptions opt, NSString **outField, NSError **outError) {
    if ([scanner isAtEnd]) {
        if (outField) {
            if (opt & GSCSVReadingMutableLeaves) {
                *outField = [NSMutableString new];
            } else {
                *outField = @"";
            }
        }
        return YES;
    } else {
        unichar c = [[scanner string] characterAtIndex:[scanner scanLocation]];
        if (c == kDQUOTECharacter) {
            return __GSCSVScanEscaped(scanner, opt, outField, outError);
        } else {
            return __GSCSVScanNonEscaped(scanner, opt, outField, outError);
        }
    }
}

static BOOL __GSCSVScanRecord(NSScanner *scanner, GSCSVReadingOptions opt, NSArray **outRecord, NSError **outError) {
    NSMutableArray *fields = [NSMutableArray new];
    NSString *field = nil;
    NSError *error = nil;
    while (__GSCSVScanField(scanner, opt, &field, &error)) {
        [fields addObject:field];
        if (![scanner scanString:kCOMMA intoString:NULL]) {
            break;
        }
    }
    if (error) {
        if (outError) {
            *outError = error;
        }
        return NO;
    } else {
        if (outRecord) {
            if (opt & GSCSVReadingMutableContainers) {
                *outRecord = fields;
            } else {
                *outRecord = [fields copy];
            }
        }
        return YES;
    }
}

static BOOL __GSCSVScanLineBreak(NSScanner *scanner, NSString **result) {
    return ([scanner scanString:kCRLF intoString:result]
            || [scanner scanString:kCR intoString:result]
            || [scanner scanString:kLF intoString:result]);
}

static BOOL __GSCSVConvertInputStreamToBytes(NSInputStream *stream, void **bytes, NSUInteger *length, NSError **error) {
    uint8_t *buf = NULL, sbuf[8192];
    NSUInteger buflen = 0, bufsize = 0;
    for (;;) {
        NSInteger retlen = [stream read:sbuf maxLength:8192];
        if (retlen <= 0) {
            if (retlen < 0) {
                if (buf) {
                    NSZoneFree(NULL, buf);
                    buf = NULL;
                }
                buflen = 0;
                if (error) {
                    *error = [stream streamError];
                }
            }
            if (bytes) {
                *bytes = buf;
            }
            if (length) {
                *length = buflen;
            }
            return (retlen == 0);
        }
        if (bufsize < buflen + retlen) {
            if (bufsize < 256 * 1024) {
                bufsize *= 4;
            } else if (bufsize < 16 * 1024 * 1024) {
                bufsize *= 2;
            } else {
                bufsize += 256 * 1024;
            }
            if (bufsize < buflen + retlen) {
                bufsize = buflen + retlen;
            }
            buf = NSZoneRealloc(NULL, buf, bufsize);
        }
        memmove(buf + buflen, sbuf, retlen);
        buflen += retlen;
    }
    return YES;
}

NSString * const GSCSVErrorDomain = @"GSCSVErrorDomain";

@implementation GSCSVSerialization

+ (BOOL)isValidCSVRecords:(NSArray *)records {
    return __GSCSVIsValidCSVRecords(records, NULL);
}

+ (NSData *)dataWithCSVRecords:(NSArray *)records encoding:(NSStringEncoding)encoding options:(GSCSVWritingOptions)opt error:(NSError **)outError {
    if (!records) {
        [NSException raise:NSInvalidArgumentException format:@"*** %s: records parameter is nil", __PRETTY_FUNCTION__];
    }
    NSString *errorString = nil;
    if (!__GSCSVIsValidCSVRecords(records, &errorString)) {
        [NSException raise:NSInvalidArgumentException format:@"*** %s: %@", __PRETTY_FUNCTION__, errorString];
    }
    NSOutputStream *stream = [[NSOutputStream alloc] initToMemory];
    [stream open];
    NSData *data;
    if ([self writeCSVRecords:records toStream:stream encoding:encoding options:opt error:outError] > 0) {
        data = [stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    } else {
        data = nil;
    }
    [stream close];
    return data;
}

+ (NSInteger)writeCSVRecords:(NSArray *)records toStream:(NSOutputStream *)stream encoding:(NSStringEncoding)encoding options:(GSCSVWritingOptions)opt error:(NSError **)outError {
    if (!records) {
        [NSException raise:NSInvalidArgumentException format:@"*** %s: records parameter is nil", __PRETTY_FUNCTION__];
    }
    NSString *errorString = nil;
    if (!__GSCSVIsValidCSVRecords(records, &errorString)) {
        [NSException raise:NSInvalidArgumentException format:@"*** %s: %@", __PRETTY_FUNCTION__, errorString];
    }
    if (!stream) {
        [NSException raise:NSInvalidArgumentException format:@"*** %s: stream parameter is nil", __PRETTY_FUNCTION__];
    }
    if ([stream streamStatus] != NSStreamStatusOpen && [stream streamStatus] == NSStreamStatusWriting) {
        [NSException raise:NSInvalidArgumentException format:@"*** %s: stream is not open for writing", __PRETTY_FUNCTION__];
    }
    // TODO
    return 0;
}

+ (NSArray *)CSVRecordsWithData:(NSData *)data encoding:(NSStringEncoding)encoding options:(GSCSVReadingOptions)opt error:(NSError **)outError {
    if (!data) {
        [NSException raise:NSInvalidArgumentException format:@"*** %s: data parameter is nil", __PRETTY_FUNCTION__];
    }
    NSString *string = [[NSString alloc] initWithData:data encoding:encoding];
    if (!string) {
        if (outError) {
            NSString *description = [NSString stringWithFormat:NSLocalizedString(@"The data couldn’t be converted into Unicode characters using text encoding %@.", @""), [NSString localizedNameOfStringEncoding:encoding]];
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: description, NSStringEncodingErrorKey: @(encoding)};
            *outError = [NSError errorWithDomain:GSCSVErrorDomain code:GSCSVErrorReadInapplicableStringEncodingError userInfo:userInfo];
        }
        return nil;
    }
    NSScanner *scanner = [[NSScanner alloc] initWithString:string];
    [scanner setCharactersToBeSkipped:nil];
    NSMutableArray *records = [NSMutableArray new];
    NSArray *record = nil;
    NSError *error = nil;
    while (__GSCSVScanRecord(scanner, opt, &record, &error)) {
        [records addObject:record];
        if (!__GSCSVScanLineBreak(scanner, NULL)) {
            if (![scanner isAtEnd]) {
                NSString *description = NSLocalizedString(@"The data couldn’t be read because it isn’t in the correct format.", @"");
                NSString *debugDescription = NSLocalizedString(@"Garbage at end.", @"");
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: description, @"NSDebugDescription": debugDescription};
                error = [NSError errorWithDomain:GSCSVErrorDomain code:GSCSVErrorReadCorrupt userInfo:userInfo];
            }
            break;
        } else {
            if ([scanner isAtEnd]) {
                break;
            }
        }
    }
    if (error) {
        if (outError) {
            *outError = error;
        }
        return nil;
    } else {
        if (opt & GSCSVReadingMutableContainers) {
            return records;
        } else {
            return [records copy];
        }
    }
}

+ (NSArray *)CSVRecordsWithStream:(NSInputStream *)stream encoding:(NSStringEncoding)encoding options:(GSCSVReadingOptions)opt error:(NSError **)outError {
    if (!stream) {
        [NSException raise:NSInvalidArgumentException format:@"*** %s: stream parameter is nil", __PRETTY_FUNCTION__];
    }
    if ([stream streamStatus] != NSStreamStatusOpen && [stream streamStatus] == NSStreamStatusReading) {
        [NSException raise:NSInvalidArgumentException format:@"*** %s: stream is not open for reading", __PRETTY_FUNCTION__];
    }
    void *bytes = NULL;
    NSUInteger length = 0;
    NSError *error = nil;
    if (!__GSCSVConvertInputStreamToBytes(stream, &bytes, &length, &error)) {
        if (outError) {
            NSDictionary *userInfo = nil;
            if (error) {
                userInfo = @{NSUnderlyingErrorKey: error};
            }
            *outError = [NSError errorWithDomain:GSCSVErrorDomain code:GSCSVErrorReadStreamError userInfo:userInfo];
        }
        return nil;
    }
    NSData *data = [[NSData alloc] initWithBytesNoCopy:bytes length:length];
    return [self CSVRecordsWithData:data encoding:encoding options:opt error:outError];
}

@end
