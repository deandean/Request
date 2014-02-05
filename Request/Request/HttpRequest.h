//
//  HttpRequest.h
//  Request
//
//  Created by deandean on 14-1-23.
//  Copyright (c) 2014年 deandean. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol HttpRequestDelegate;
@interface HttpRequest : NSObject<NSURLConnectionDelegate>
{
    NSMutableURLRequest *_request;
    NSURLConnection     *_connection;
    NSString            *_tmpFilePath;
    NSString            *_desFilePath;
    NSString            *_url;
    NSInteger           retryTime;
    BOOL                startReceive;
    int                 httpCode;
    id<HttpRequestDelegate> _delegate;
    BOOL                _deleteFileBeforeDownload;
    NSFileHandle        *_fileHandle;
    NSMutableData       *_dataCache;//数据缓冲，防止频繁写入磁盘
    BOOL                finishDownload;
    BOOL                checkSize;
    unsigned long long  downloadSizeSoFar;
    unsigned long long  totalNeedDownloadSize;
    unsigned long long  mStart;
    unsigned long long  mEnd;
    unsigned long long  actualGetSize;
    unsigned long long  expectedSize;
}
@property(nonatomic,retain)NSMutableURLRequest  *request;
@property(nonatomic,assign)BOOL deleteFileBeforeDownload;
@property(nonatomic,retain)NSString *tmpFilePath;
@property(nonatomic,retain)NSString *desFilePath;
@property(nonatomic,retain)NSFileHandle *fileHandle;
@property(nonatomic,retain)NSMutableData    *dataCache;
@property(nonatomic,retain)NSString         *url;
@property(nonatomic,assign)id<HttpRequestDelegate> delegate;
@property(nonatomic,assign)unsigned long long downloadSizeSoFar;
@property(nonatomic,assign)unsigned long long totalNeedDownloadSize;
-(id)initWithURLString:(NSString *)url_;
-(void)go;
-(BOOL)cancelRequest;
@end
@protocol HttpRequestDelegate<NSObject>

-(void)startDownloadRequest:(HttpRequest *)request;
-(void)finishDownloadRequest:(HttpRequest *)request;
-(void)getDownloadDataRequest:(HttpRequest *)request;
@end