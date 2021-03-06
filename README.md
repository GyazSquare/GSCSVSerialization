GSCSVSerialization
==================
[![Build Status](https://travis-ci.org/GyazSquare/GSCSVSerialization.svg?branch=master)](https://travis-ci.org/GyazSquare/GSCSVSerialization)

**Important:** This library is deprecated, it is recommended you look at [GSLCSVSerialization](https://github.com/GyazSquare/GSLCSVSerialization).

GSCSVSerialization is an Objective-C CSV parser for iOS, OS X, watchOS and tvOS.

## Requirements

* Xcode 8.1 or later
* Base SDK: iOS 10.1 / OS X 10.12 / watchOS 3.1 / tvOS 10.0 or later
* Deployment Target: iOS 8.0 / OS X 10.6 / watchOS 2.0 / tvOS 9.0  or later

## Installation

### CocoaPods

Add the pod to your `Podfile`:

```ruby
# ... snip ...

pod 'GSCSVSerialization'
```

Install the pod:

```shell
$ pod install
```

### Source

Check out the source:

```shell
$ git clone https://github.com/GyazSquare/GSCSVSerialization.git
```

## Usage

### Creating a CSV Object

GSCSVSerialization can create a CSV object from a [RFC 4180](https://tools.ietf.org/html/rfc4180)-compliant CSV data by using the following methods:

```objective-c
+ (nullable __kindof NSArray<__kindof NSArray<__kindof NSString *> *> *)CSVRecordsWithData:(NSData *)data encoding:(NSStringEncoding)encoding options:(GSCSVReadingOptions)opt error:(NSError **)error;
+ (nullable __kindof NSArray<__kindof NSArray<__kindof NSString *> *> *)CSVRecordsWithStream:(NSInputStream *)stream encoding:(NSStringEncoding)encoding options:(GSCSVReadingOptions)opt error:(NSError **)error;
```

For example, if you parse CSV data below,

```text
aaa,bbb,ccc
zzz,yyy,xxx
```

you can get a CSV object like this:

```objective-c
@[
    @[@"aaa",@"bbb",@"ccc"],
    @[@"zzz",@"yyy",@"xxx"]
]
```

### Creating CSV Data

GSCSVSerialization can create CSV data from a CSV object by using the following methods:

```objective-c
+ (nullable NSData *)dataWithCSVRecords:(NSArray<NSArray<NSString *> *> *)records encoding:(NSStringEncoding)encoding options:(GSCSVWritingOptions)opt error:(NSError **)error;
+ (NSInteger)writeCSVRecords:(NSArray<NSArray<NSString *> *> *)records toStream:(NSOutputStream *)stream encoding:(NSStringEncoding)encoding options:(GSCSVWritingOptions)opt error:(NSError **)error;
```

A `records` object is a two-dimensional array containing `field` strings. You should check whether the input will produce valid CSV data before calling these methods by using `isValidCSVRecords:`.

## License

GSCSVSerialization is licensed under the MIT License.

See the LICENSE file for more info.
