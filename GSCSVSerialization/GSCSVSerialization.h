//
//  GSCSVSerialization.h
//  GSCSVSerialization
//

@import Foundation.NSObject;
@import Foundation.NSString;

NS_ASSUME_NONNULL_BEGIN

@class NSArray, NSData, NSError, NSInputStream, NSOutputStream;

FOUNDATION_EXPORT NSString * const GSCSVErrorDomain;

typedef NS_ENUM(NSInteger, GSCSVErrorCode) {
    GSCSVErrorUnknown = 0,
    GSCSVErrorReadInapplicableStringEncodingError = 1,
    GSCSVErrorReadCorrupt = 2,
    GSCSVErrorReadStreamError = 3,
    GSCSVErrorWriteInapplicableStringEncodingError = 4,
    GSCSVErrorWriteStreamError = 5
};

typedef NS_OPTIONS(NSUInteger, GSCSVReadingOptions) {
    GSCSVReadingMutableContainers NS_SWIFT_UNAVAILABLE("Mutability options not available") = (1UL << 0),
    GSCSVReadingMutableLeaves NS_SWIFT_UNAVAILABLE("Mutability options not available") = (1UL << 1)
};

typedef NS_OPTIONS(NSUInteger, GSCSVWritingOptions) {
    GSCSVWritingEscapeAllFields = (1UL << 0)
};

@interface GSCSVSerialization : NSObject

+ (BOOL)isValidCSVRecords:(nullable NSArray<NSArray<NSString *> *> *)records;

+ (nullable NSData *)dataWithCSVRecords:(NSArray<NSArray<NSString *> *> *)records encoding:(NSStringEncoding)encoding options:(GSCSVWritingOptions)opt error:(NSError **)error;
+ (NSInteger)writeCSVRecords:(NSArray<NSArray<NSString *> *> *)records toStream:(NSOutputStream *)stream encoding:(NSStringEncoding)encoding options:(GSCSVWritingOptions)opt error:(NSError **)error;

+ (nullable __kindof NSArray<__kindof NSArray<__kindof NSString *> *> *)CSVRecordsWithData:(NSData *)data encoding:(NSStringEncoding)encoding options:(GSCSVReadingOptions)opt error:(NSError **)error;
+ (nullable __kindof NSArray<__kindof NSArray<__kindof NSString *> *> *)CSVRecordsWithStream:(NSInputStream *)stream encoding:(NSStringEncoding)encoding options:(GSCSVReadingOptions)opt error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
