//
//  GSCSVSerialization.h
//  GSCSVSerialization
//

@import Foundation.NSObject;
@import Foundation.NSString;

@class NSArray, NSData, NSError, NSInputStream, NSOutputStream;

FOUNDATION_EXPORT NSString * const GSCSVErrorDomain;

typedef NS_ENUM(NSInteger, GSCSVErrorCode) {
    GSCSVErrorUnknown = 0,
    GSCSVErrorReadInapplicableStringEncodingError = 1,
    GSCSVErrorReadStreamError = 2
};

typedef NS_ENUM(NSUInteger, GSCSVReadingOptions) {
    GSCSVReadingMutableContainers = (1UL << 0),
    GSCSVReadingMutableLeaves = (1UL << 1)
};

typedef NSUInteger GSCSVWritingOptions;

@interface GSCSVSerialization : NSObject

+ (BOOL)isValidCSVRecords:(NSArray *)records;

+ (NSData *)dataWithCSVRecords:(NSArray *)records encoding:(NSStringEncoding)encoding options:(GSCSVWritingOptions)opt error:(NSError **)error;
+ (NSInteger)writeCSVRecords:(NSArray *)records toStream:(NSOutputStream *)stream encoding:(NSStringEncoding)encoding options:(GSCSVWritingOptions)opt error:(NSError **)error;

+ (NSArray *)CSVRecordsWithData:(NSData *)data encoding:(NSStringEncoding)encoding options:(GSCSVReadingOptions)opt error:(NSError **)error;
+ (NSArray *)CSVRecordsWithStream:(NSInputStream *)stream encoding:(NSStringEncoding)encoding options:(GSCSVReadingOptions)opt error:(NSError **)error;

@end
