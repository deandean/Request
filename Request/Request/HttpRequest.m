//
//  HttpRequest.m
//  Request
//
//  Created by deandean on 14-1-23.
//  Copyright (c) 2014年 deandean. All rights reserved.
//

#import "HttpRequest.h"
#define kCachedMaxByte      102400
@implementation HttpRequest
@synthesize request=_request;
@synthesize deleteFileBeforeDownload=_deleteFileBeforeDownload;
@synthesize tmpFilePath=_tmpFilePath;
@synthesize fileHandle=_fileHandle;
@synthesize dataCache=_dataCache;
@synthesize url=_url;
@synthesize delegate=_delegate;
@synthesize desFilePath=_desFilePath;
@synthesize downloadSizeSoFar;
@synthesize totalNeedDownloadSize;
-(id)initWithURLString:(NSString *)url_
{
    if (self=[super init])
    {
        self.url=url_;
        NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url_] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0f];
        self.request=request;
        _deleteFileBeforeDownload=NO;
        mStart=0;
        mEnd=0;
        actualGetSize=0;
        checkSize=YES;
        self.dataCache=[NSMutableData data];
        [request release];
    }
    return self;
}
-(void)go
{
    if (_deleteFileBeforeDownload)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.tmpFilePath])
		{
            NSError *err = nil;
			[[NSFileManager defaultManager] removeItemAtPath:self.tmpFilePath error:&err];
			[[NSFileManager defaultManager] createFileAtPath:self.tmpFilePath contents:nil attributes:nil];
		}
        else
		{
			[[NSFileManager defaultManager] createFileAtPath:self.tmpFilePath contents:nil attributes:nil];
		}
    }
    else
    {
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.tmpFilePath])
        {
            [[NSFileManager defaultManager] createFileAtPath:self.tmpFilePath contents:nil attributes:nil];
        }
    }//创建临时下载文件
    
    
    if (_fileHandle)
    {
        [_fileHandle release];
        _fileHandle=nil;
    }
    _fileHandle = [[NSFileHandle fileHandleForWritingAtPath:self.tmpFilePath] retain];
    [_fileHandle seekToEndOfFile];
    
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.tmpFilePath])
    {
        NSError *err = nil;
        NSDictionary *fattrib = [[NSFileManager defaultManager] attributesOfItemAtPath:self.tmpFilePath error:&err];
        if (fattrib != nil)
        {
            downloadSizeSoFar=[fattrib fileSize];
        }
    }
    else
    {
        [[NSFileManager defaultManager] createFileAtPath:self.tmpFilePath contents:nil attributes:nil];
        downloadSizeSoFar=0;
    }
    
    if (downloadSizeSoFar>0)
    {
        if (mEnd>0)
        {
            [self.request addValue:[NSString stringWithFormat:@"bytes=%llu-%llu",mStart+downloadSizeSoFar,mEnd] forHTTPHeaderField:@"Range"];
        }else
        {
            [self.request addValue:[NSString stringWithFormat:@"bytes=%llu-",mStart+downloadSizeSoFar] forHTTPHeaderField:@"Range"];
        }
    }
    else
    {
        if (mEnd>0)
        {
            [self.request addValue:[NSString stringWithFormat:@"bytes=0-%llu",mEnd] forHTTPHeaderField:@"Range"];
        }
    }
    _connection=[[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:YES];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([(NSHTTPURLResponse *)response statusCode] >= 400)
    {
        startReceive=NO;
        return;
    }
    NSDictionary *header=[(NSHTTPURLResponse *)response allHeaderFields];
    NSString *contentRange=[header objectForKey:@"Content-Range"];
    NSString *contentLenght=nil;
    unsigned long long startPoint=0;
    unsigned long long endPoint=0;
    if (contentRange)
    {
        NSArray *array=[contentRange componentsSeparatedByString:@"/"];
        if ([array count]==2)
        {
            contentLenght=[array objectAtIndex:1];
            NSArray *ttt=[[array objectAtIndex:0] componentsSeparatedByString:@"-"];
            if ([ttt count]==2)
            {
                NSString *_startPoint=[ttt objectAtIndex:0];
                NSString *_endPoint=[ttt objectAtIndex:1];
                if (_startPoint!=nil && [_startPoint length]>0)
                {
                    _startPoint=[_startPoint stringByReplacingOccurrencesOfString:@"bytes" withString:@""];
                    startPoint=[_startPoint longLongValue];
                    mStart=startPoint;
                }
                if (_endPoint!=nil && [_endPoint length]>0)
                {
                    endPoint=[_endPoint longLongValue];
                    totalNeedDownloadSize=endPoint;
                }
            }
            else
            {
//                if (DEBUG)MLOG(@"error 1 content-Range:%@",contentRange);
//                mItem.failCode = url_illegal;
//                [self failureReuest:request];
                return;
            }
        }
        else
        {
//            if (DEBUG)MLOG(@"error 2 content-Range:%@",contentRange);
//            mItem.failCode = url_illegal;
//            [self failureReuest:request];
            return;
        }
        
    }
    else
    {
        
    }
    
    
    httpCode = [(NSHTTPURLResponse *)response statusCode];
    int status=200;
    startReceive=YES;
    if (checkSize)
    {
        expectedSize=[response expectedContentLength];
        if (totalNeedDownloadSize<=0)
        {
            totalNeedDownloadSize=[response expectedContentLength];
        }
        actualGetSize=0;
    }
    if (_delegate)
    {
        if ([_delegate respondsToSelector:@selector(startDownloadRequest:)])
        {
            [_delegate startDownloadRequest:self];
        }
        
    }

}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (startReceive)
    {
        if (self.fileHandle)
        {
            [self.dataCache appendData:data];
            
            if (self.dataCache.length > kCachedMaxByte)
            {

                [_fileHandle writeData:self.dataCache];
                [self.dataCache setData:nil];
            }
        }
        if (checkSize)
        {
            actualGetSize+=data.length;
            downloadSizeSoFar+=data.length;
        }
        if (_delegate && [_delegate respondsToSelector:@selector(getDownloadDataRequest:)])
        {
            [_delegate getDownloadDataRequest:self];
        }
    }
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (startReceive)
    {
        if (self.fileHandle)
        {
            if (self.dataCache.length)
            {
                [self.fileHandle writeData:self.dataCache];
                self.dataCache=nil;
            }
            
            [_fileHandle closeFile];
            [_fileHandle release];
            _fileHandle=nil;
            if (_desFilePath)
            {
                NSError *error;
                if ([[NSFileManager defaultManager] fileExistsAtPath:_desFilePath])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:_desFilePath error:nil];
                }
                [[NSFileManager defaultManager] moveItemAtPath:_tmpFilePath toPath:_desFilePath error:&error];
            }
        }
        
        finishDownload=YES;
        if (_delegate)
        {
            
            if ([_delegate respondsToSelector:@selector(finishDownloadRequest:)])
            {
                if (checkSize)
                {
                    if (actualGetSize!=expectedSize)
                    {
                        if (DEBUG) NSLog(@"***********************************************************size error:requestSize=%@,contentLenght=%@,url=%@"
                                         ,[NSString stringWithFormat:@"%llu",actualGetSize]
                                         ,[NSString stringWithFormat:@"%llu",expectedSize]
                                         ,self.url
                                         );
//                        NSError *error=[NSError errorWithDomain:@"www.baidu.com" code:404 userInfo:nil];
//                        [self connection:connection didFailWithError:error];
                    }
                    else
                    {
                        [_delegate finishDownloadRequest:self];
                    }
                    
                }
                else
                {
                    [_delegate finishDownloadRequest:self];
                    
                }
                
                
            }
            
        }
        [connection cancel];
        
    }
    else
    {
//        NSError *error=[NSError errorWithDomain:_(@"http://www.baidu.com") code:status userInfo:nil];
//        [self connection:connection didFailWithError:error];
    }
}
-(BOOL)cancelRequest
{
	if (!finishDownload)
	{
		if (_connection)
		{
			[_connection cancel];
		}
        
        if (_dataCache.length)
        {
            [_fileHandle writeData:_dataCache];
            [_dataCache setData:nil];
        }
        
		if (_fileHandle)
		{
			[_fileHandle closeFile];
			[_fileHandle release];
			_fileHandle=nil;
		}
	}
	
	return YES;
}
-(void)dealloc
{
    self.delegate=nil;
    self.tmpFilePath=nil;
    self.desFilePath=nil;
    self.url=nil;
    self.dataCache=nil;
    if (_fileHandle)
	{
		[_fileHandle closeFile];
		[_fileHandle release];
		_fileHandle=nil;
	}
    if (_connection)
    {
        [_connection release];
        _connection=nil;
    }
}
@end
