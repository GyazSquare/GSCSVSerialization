//
//  GSCSVSerializationTests.m
//  GSCSVSerialization
//

@import UIKit;
@import XCTest;

#import "GSCSVSerialization.h"

@interface GSCSVSerializationTests : XCTestCase
@end

@implementation GSCSVSerializationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testIsValidCSVRecords {
    // nil records
    {
        NSArray *records = nil;
        XCTAssertFalse([GSCSVSerialization isValidCSVRecords:records]);
    }
    // empty records
    {
        NSArray *records = @[];
        XCTAssertFalse([GSCSVSerialization isValidCSVRecords:records]);
    }
    // empty fields
    {
        NSArray *records = @[@[]];
        XCTAssertFalse([GSCSVSerialization isValidCSVRecords:records]);
    }
    // wrong field type
    {
        NSArray *records = @[@0];
        XCTAssertFalse([GSCSVSerialization isValidCSVRecords:records]);
    }
    // wrong record type
    {
        NSArray *records = @[@[@0]];
        XCTAssertFalse([GSCSVSerialization isValidCSVRecords:records]);
    }
    // different number of fields
    {
        NSArray *records = @[@[@"aaa", @"bbb", @"ccc"], @[@"zzz", @"yyy"]];
        XCTAssertFalse([GSCSVSerialization isValidCSVRecords:records]);
    }
    // correct records
    {
        NSArray *records = @[@[@"aaa", @"bbb", @"ccc"], @[@"zzz", @"yyy", @"xxx"]];
        XCTAssertTrue([GSCSVSerialization isValidCSVRecords:records]);
    }
}

- (void)testDataWithCSVRecords {
    // nil records
    {
        NSArray *records = nil;
        NSStringEncoding encoding = NSUTF8StringEncoding;
        GSCSVWritingOptions opt = 0;
        NSError *error = nil;
        XCTAssertThrowsSpecificNamed([GSCSVSerialization dataWithCSVRecords:records encoding:encoding options:opt error:&error], NSException, NSInvalidArgumentException);
    }
    // invalid records
    {
        NSArray *records = @[@[]];
        NSStringEncoding encoding = NSUTF8StringEncoding;
        GSCSVWritingOptions opt = 0;
        NSError *error = nil;
        XCTAssertThrowsSpecificNamed([GSCSVSerialization dataWithCSVRecords:records encoding:encoding options:opt error:&error], NSException, NSInvalidArgumentException);
    }
    // wrong encoding
    {
        NSArray *records = @[@[@"aaａ", @"bbb", @"ccc"], @[@"zzz", @"yyy", @"xxx"]];
        NSStringEncoding encoding = NSASCIIStringEncoding;
        GSCSVWritingOptions opt = 0;
        NSError *error = nil;
        NSData *data = [GSCSVSerialization dataWithCSVRecords:records encoding:encoding options:opt error:&error];
        XCTAssertNil(data);
        XCTAssertEqualObjects(GSCSVErrorDomain, error.domain);
        XCTAssertEqual(GSCSVErrorWriteInapplicableStringEncodingError, error.code);
    }
    // empty records
    {
        NSArray *records = @[@[@""]];
        NSData *expected = [NSData data];
        NSStringEncoding encoding = NSUTF8StringEncoding;
        GSCSVWritingOptions opt = 0;
        NSError *error = nil;
        NSData *data = [GSCSVSerialization dataWithCSVRecords:records encoding:encoding options:opt error:&error];
        XCTAssertEqualObjects(expected, data);
        XCTAssertNil(error);
    }
    // correct records
    {
        NSArray *records = @[@[@"aaa", @"bbb", @"ccc"], @[@"zzz", @"yyy", @"xxx"]];
        NSData *expected = [@"aaa,bbb,ccc\r\nzzz,yyy,xxx" dataUsingEncoding:NSUTF8StringEncoding];
        NSStringEncoding encoding = NSUTF8StringEncoding;
        GSCSVWritingOptions opt = 0;
        NSError *error = nil;
        NSData *data = [GSCSVSerialization dataWithCSVRecords:records encoding:encoding options:opt error:&error];
        XCTAssertEqualObjects(expected, data);
        XCTAssertNil(error);
    }
}

- (void)testWriteCSVRecords {
    // nil records
    {
        NSArray *records = nil;
        NSOutputStream *stream = nil;
        NSStringEncoding encoding = NSUTF8StringEncoding;
        GSCSVWritingOptions opt = 0;
        NSError *error = nil;
        XCTAssertThrowsSpecificNamed([GSCSVSerialization writeCSVRecords:records toStream:stream encoding:encoding options:opt error:&error], NSException, NSInvalidArgumentException);
    }
    // invalid records
    {
        NSArray *records = @[@[]];
        NSOutputStream *stream = nil;
        NSStringEncoding encoding = NSUTF8StringEncoding;
        GSCSVWritingOptions opt = 0;
        NSError *error = nil;
        XCTAssertThrowsSpecificNamed([GSCSVSerialization writeCSVRecords:records toStream:stream encoding:encoding options:opt error:&error], NSException, NSInvalidArgumentException);
    }
    // nil stream
    {
        NSArray *records = @[@[@""]];
        NSOutputStream *stream = nil;
        NSStringEncoding encoding = NSUTF8StringEncoding;
        GSCSVWritingOptions opt = 0;
        NSError *error = nil;
        XCTAssertThrowsSpecificNamed([GSCSVSerialization writeCSVRecords:records toStream:stream encoding:encoding options:opt error:&error], NSException, NSInvalidArgumentException);
    }
    // closed stream
    {
        NSArray *records = @[@[@""]];
        NSOutputStream *stream = [[NSOutputStream alloc] initToMemory];
        NSStringEncoding encoding = NSUTF8StringEncoding;
        GSCSVWritingOptions opt = 0;
        NSError *error = nil;
        XCTAssertThrowsSpecificNamed([GSCSVSerialization writeCSVRecords:records toStream:stream encoding:encoding options:opt error:&error], NSException, NSInvalidArgumentException);
    }
    // wrong encoding
    {
        NSArray *records = @[@[@"aaａ", @"bbb", @"ccc"], @[@"zzz", @"yyy", @"xxx"]];
        NSOutputStream *stream = [[NSOutputStream alloc] initToMemory];
        NSStringEncoding encoding = NSASCIIStringEncoding;
        GSCSVWritingOptions opt = 0;
        NSError *error = nil;
        [stream open];
        NSInteger result = [GSCSVSerialization writeCSVRecords:records toStream:stream encoding:encoding options:opt error:&error];
        [stream close];
        XCTAssertTrue(result < 0);
        XCTAssertEqualObjects(GSCSVErrorDomain, error.domain);
        XCTAssertEqual(GSCSVErrorWriteInapplicableStringEncodingError, error.code);
    }
    // empty records
    {
        NSArray *records = @[@[@""]];
        NSData *expected = [NSData data];
        NSOutputStream *stream = [[NSOutputStream alloc] initToMemory];
        NSStringEncoding encoding = NSUTF8StringEncoding;
        GSCSVWritingOptions opt = 0;
        NSError *error = nil;
        [stream open];
        NSInteger result = [GSCSVSerialization writeCSVRecords:records toStream:stream encoding:encoding options:opt error:&error];
        NSData *data = [stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
        [stream close];
        XCTAssertEqual(0, result);
        XCTAssertNil(error);
        XCTAssertEqualObjects(expected, data);
    }
    // 2.1, 2.2 of RFC 4180
    {
        NSArray *records = @[@[@"aaa", @"bbb", @"ccc"], @[@"zzz", @"yyy", @"xxx"]];
        NSData *expected = [@"aaa,bbb,ccc\r\nzzz,yyy,xxx" dataUsingEncoding:NSUTF8StringEncoding];
        NSOutputStream *stream = [[NSOutputStream alloc] initToMemory];
        NSStringEncoding encoding = NSUTF8StringEncoding;
        GSCSVWritingOptions opt = 0;
        NSError *error = nil;
        [stream open];
        NSInteger result = [GSCSVSerialization writeCSVRecords:records toStream:stream encoding:encoding options:opt error:&error];
        NSData *data = [stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
        [stream close];
        XCTAssertTrue(result > 0);
        XCTAssertNil(error);
        XCTAssertEqualObjects(expected, data);
    }
    // 2.3 of RFC 4180
    {
        NSArray *records = @[@[@"field_name", @"field_name", @"field_name"], @[@"aaa", @"bbb", @"ccc"], @[@"zzz", @"yyy", @"xxx"]];
        NSData *expected = [@"field_name,field_name,field_name\r\naaa,bbb,ccc\r\nzzz,yyy,xxx" dataUsingEncoding:NSUTF8StringEncoding];
        NSOutputStream *stream = [[NSOutputStream alloc] initToMemory];
        NSStringEncoding encoding = NSUTF8StringEncoding;
        GSCSVWritingOptions opt = 0;
        NSError *error = nil;
        [stream open];
        NSInteger result = [GSCSVSerialization writeCSVRecords:records toStream:stream encoding:encoding options:opt error:&error];
        NSData *data = [stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
        [stream close];
        XCTAssertTrue(result > 0);
        XCTAssertNil(error);
        XCTAssertEqualObjects(expected, data);
    }
    // 2.4 of RFC 4180
    {
        NSArray *records = @[@[@"aaa", @"bbb", @"ccc"]];
        NSData *expected = [@"aaa,bbb,ccc" dataUsingEncoding:NSUTF8StringEncoding];
        NSOutputStream *stream = [[NSOutputStream alloc] initToMemory];
        NSStringEncoding encoding = NSUTF8StringEncoding;
        GSCSVWritingOptions opt = 0;
        NSError *error = nil;
        [stream open];
        NSInteger result = [GSCSVSerialization writeCSVRecords:records toStream:stream encoding:encoding options:opt error:&error];
        NSData *data = [stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
        [stream close];
        XCTAssertTrue(result > 0);
        XCTAssertNil(error);
        XCTAssertEqualObjects(expected, data);
    }
    // 2.5 of RFC 4180
    {
        NSArray *records = @[@[@"aaa", @"bbb", @"ccc"], @[@"zzz", @"yyy", @"xxx"]];
        NSData *expected = [@"\"aaa\",\"bbb\",\"ccc\"\r\n\"zzz\",\"yyy\",\"xxx\"" dataUsingEncoding:NSUTF8StringEncoding];
        NSOutputStream *stream = [[NSOutputStream alloc] initToMemory];
        NSStringEncoding encoding = NSUTF8StringEncoding;
        GSCSVWritingOptions opt = GSCSVWritingEscapeAllFields;
        NSError *error = nil;
        [stream open];
        NSInteger result = [GSCSVSerialization writeCSVRecords:records toStream:stream encoding:encoding options:opt error:&error];
        NSData *data = [stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
        [stream close];
        XCTAssertTrue(result > 0);
        XCTAssertNil(error);
        XCTAssertEqualObjects(expected, data);
    }
    // 2.6 of RFC 4180
    {
        NSArray *records = @[@[@"aaa", @"b\r\nbb", @"ccc"], @[@"zzz", @"yyy", @"xxx"]];
        NSData *expected = [@"aaa,\"b\r\nbb\",ccc\r\nzzz,yyy,xxx" dataUsingEncoding:NSUTF8StringEncoding];
        NSOutputStream *stream = [[NSOutputStream alloc] initToMemory];
        NSStringEncoding encoding = NSUTF8StringEncoding;
        GSCSVWritingOptions opt = 0;
        NSError *error = nil;
        [stream open];
        NSInteger result = [GSCSVSerialization writeCSVRecords:records toStream:stream encoding:encoding options:opt error:&error];
        NSData *data = [stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
        [stream close];
        XCTAssertTrue(result > 0);
        XCTAssertNil(error);
        XCTAssertEqualObjects(expected, data);
    }
    // 2.7 of RFC 4180
    {
        NSArray *records = @[@[@"aaa", @"b\"bb", @"ccc"]];
        NSData *expected = [@"aaa,\"b\"\"bb\",ccc" dataUsingEncoding:NSUTF8StringEncoding];
        NSOutputStream *stream = [[NSOutputStream alloc] initToMemory];
        NSStringEncoding encoding = NSUTF8StringEncoding;
        GSCSVWritingOptions opt = 0;
        NSError *error = nil;
        [stream open];
        NSInteger result = [GSCSVSerialization writeCSVRecords:records toStream:stream encoding:encoding options:opt error:&error];
        NSData *data = [stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
        [stream close];
        XCTAssertTrue(result > 0);
        XCTAssertNil(error);
        XCTAssertEqualObjects(expected, data);
    }
}

- (void)testCSVRecordsWithData {
    // nil data
    {
        NSData *data = nil;
        XCTAssertThrowsSpecificNamed([GSCSVSerialization CSVRecordsWithData:data encoding:NSUTF8StringEncoding options:0 error:NULL], NSException, NSInvalidArgumentException);
    }
    // wrong encoding
    {
        NSString *string = @"aaa,bbb,ccc\r\nzzz,yyy,xxx\r\n";
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSArray *records = [GSCSVSerialization CSVRecordsWithData:data encoding:NSUTF32StringEncoding options:0 error:&error];
        XCTAssertNil(records);
        XCTAssertEqualObjects(GSCSVErrorDomain, error.domain);
        XCTAssertEqual(GSCSVErrorReadInapplicableStringEncodingError, error.code);
    }
    // wrong escaped (1)
    {
        NSString *string = @"\"aaa\",\"bbb\",\"ccc\r\nzzz,yyy,xxx\r\n";
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSArray *records = [GSCSVSerialization CSVRecordsWithData:data encoding:NSUTF8StringEncoding options:0 error:&error];
        XCTAssertNil(records);
        XCTAssertEqualObjects(GSCSVErrorDomain, error.domain);
        XCTAssertEqual(GSCSVErrorReadCorrupt, error.code);
    }
    // wrong escaped (2)
    {
        NSString *string = @"\"aaa\",\"b\"\"bb,\"ccc\"";
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSArray *records = [GSCSVSerialization CSVRecordsWithData:data encoding:NSUTF8StringEncoding options:0 error:&error];
        XCTAssertNil(records);
        XCTAssertEqualObjects(GSCSVErrorDomain, error.domain);
        XCTAssertEqual(GSCSVErrorReadCorrupt, error.code);
    }
    // empty data
    {
        NSString *string = @"";
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSArray *records = [GSCSVSerialization CSVRecordsWithData:data encoding:NSUTF8StringEncoding options:0 error:&error];
        NSArray *expected = @[@[@""]];
        XCTAssertEqualObjects(expected, records);
        XCTAssertNil(error);
    }
    // 2.1 of RFC 4180 (line break: CRLF)
    {
        NSString *string = @"aaa,bbb,ccc\r\nzzz,yyy,xxx\r\n";
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSArray *records = [GSCSVSerialization CSVRecordsWithData:data encoding:NSUTF8StringEncoding options:0 error:&error];
        NSArray *expected = @[@[@"aaa", @"bbb", @"ccc"], @[@"zzz", @"yyy", @"xxx"]];
        XCTAssertEqualObjects(expected, records);
        XCTAssertNil(error);
    }
    // 2.1 of RFC 4180 (line break: CR)
    {
        NSString *string = @"aaa,bbb,ccc\rzzz,yyy,xxx\r";
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSArray *records = [GSCSVSerialization CSVRecordsWithData:data encoding:NSUTF8StringEncoding options:0 error:&error];
        NSArray *expected = @[@[@"aaa", @"bbb", @"ccc"], @[@"zzz", @"yyy", @"xxx"]];
        XCTAssertEqualObjects(expected, records);
        XCTAssertNil(error);
    }
    // 2.1 of RFC 4180 (line break: LF)
    {
        NSString *string = @"aaa,bbb,ccc\nzzz,yyy,xxx\n";
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSArray *records = [GSCSVSerialization CSVRecordsWithData:data encoding:NSUTF8StringEncoding options:0 error:&error];
        NSArray *expected = @[@[@"aaa", @"bbb", @"ccc"], @[@"zzz", @"yyy", @"xxx"]];
        XCTAssertEqualObjects(expected, records);
        XCTAssertNil(error);
    }
    // 2.2 of RFC 4180
    {
        NSString *string = @"aaa,bbb,ccc\r\nzzz,yyy,xxx";
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSArray *records = [GSCSVSerialization CSVRecordsWithData:data encoding:NSUTF8StringEncoding options:0 error:&error];
        NSArray *expected = @[@[@"aaa", @"bbb", @"ccc"], @[@"zzz", @"yyy", @"xxx"]];
        XCTAssertEqualObjects(expected, records);
        XCTAssertNil(error);
    }
    // 2.3 of RFC 4180
    {
        NSString *string = @"field_name,field_name,field_name\r\naaa,bbb,ccc\r\nzzz,yyy,xxx\r\n";
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSArray *records = [GSCSVSerialization CSVRecordsWithData:data encoding:NSUTF8StringEncoding options:0 error:&error];
        NSArray *expected = @[@[@"field_name", @"field_name", @"field_name"], @[@"aaa", @"bbb", @"ccc"], @[@"zzz", @"yyy", @"xxx"]];
        XCTAssertEqualObjects(expected, records);
        XCTAssertNil(error);
    }
    // 2.4 of RFC 4180
    {
        NSString *string = @"aaa,bbb,ccc";
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSArray *records = [GSCSVSerialization CSVRecordsWithData:data encoding:NSUTF8StringEncoding options:0 error:&error];
        NSArray *expected = @[@[@"aaa", @"bbb", @"ccc"]];
        XCTAssertEqualObjects(expected, records);
        XCTAssertNil(error);
    }
    // 2.5 of RFC 4180
    {
        NSString *string = @"\"aaa\",\"bbb\",\"ccc\"\r\nzzz,yyy,xxx";
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSArray *records = [GSCSVSerialization CSVRecordsWithData:data encoding:NSUTF8StringEncoding options:0 error:&error];
        NSArray *expected = @[@[@"aaa", @"bbb", @"ccc"], @[@"zzz", @"yyy", @"xxx"]];
        XCTAssertEqualObjects(expected, records);
        XCTAssertNil(error);
    }
    // 2.6 of RFC 4180
    {
        NSString *string = @"\"aaa\",\"b\r\nbb\",\"ccc\"\r\nzzz,yyy,xxx";
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSArray *records = [GSCSVSerialization CSVRecordsWithData:data encoding:NSUTF8StringEncoding options:0 error:&error];
        NSArray *expected = @[@[@"aaa", @"b\r\nbb", @"ccc"], @[@"zzz", @"yyy", @"xxx"]];
        XCTAssertEqualObjects(expected, records);
        XCTAssertNil(error);
    }
    // 2.7 of RFC 4180
    {
        NSString *string = @"\"aaa\",\"b\"\"bb\",\"ccc\"";
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSArray *records = [GSCSVSerialization CSVRecordsWithData:data encoding:NSUTF8StringEncoding options:0 error:&error];
        NSArray *expected = @[@[@"aaa", @"b\"bb", @"ccc"]];
        XCTAssertEqualObjects(expected, records);
        XCTAssertNil(error);
    }
    // GSCSVReadingMutableContainers
    {
        NSString *string = @"aaa,bbb,ccc\r\nzzz,yyy,xxx\r\n";
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSArray *records = [GSCSVSerialization CSVRecordsWithData:data encoding:NSUTF8StringEncoding options:GSCSVReadingMutableContainers error:&error];
        for (NSMutableArray *fields in records) {
            XCTAssertNoThrow([fields removeAllObjects]);
        }
        XCTAssertNoThrow([(NSMutableArray *)records removeAllObjects]);
    }
    // GSCSVReadingMutableLeaves
    {
        NSString *string = @"aaa,bbb,ccc\r\nzzz,yyy,xxx\r\n";
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSArray *records = [GSCSVSerialization CSVRecordsWithData:data encoding:NSUTF8StringEncoding options:GSCSVReadingMutableLeaves error:&error];
        for (NSArray *fields in records) {
            for (NSMutableString *field in fields) {
                [field replaceCharactersInRange:NSMakeRange(0, field.length) withString:@""];
            }
        }
    }
}

- (void)testCSVRecordsWithStream {
    // nil stream
    {
        NSInputStream *stream = nil;
        XCTAssertThrowsSpecificNamed([GSCSVSerialization CSVRecordsWithStream:stream encoding:NSUTF8StringEncoding options:0 error:NULL], NSException, NSInvalidArgumentException);
    }
    // 2.1 of RFC 4180
    {
        NSString *string = @"aaa,bbb,ccc\r\nzzz,yyy,xxx\r\n";
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSInputStream *stream = [[NSInputStream alloc] initWithData:data];
        NSError *error = nil;
        [stream open];
        NSArray *records = [GSCSVSerialization CSVRecordsWithStream:stream encoding:NSUTF8StringEncoding options:0 error:&error];
        [stream close];
        NSArray *expected = @[@[@"aaa", @"bbb", @"ccc"], @[@"zzz", @"yyy", @"xxx"]];
        XCTAssertEqualObjects(expected, records);
        XCTAssertNil(error);
    }
}

@end
