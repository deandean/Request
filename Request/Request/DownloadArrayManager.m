//
//  DownloadArrayManager.m
//  Request
//
//  Created by hong on 14-1-23.
//  Copyright (c) 2014年 deandean. All rights reserved.
//

#import "DownloadArrayManager.h"

@implementation DownloadArrayManager
@synthesize httpRequestArray=_httpRequestArray;
-(id)init
{
    if (self=[super init])
    {
        self.httpRequestArray=[NSMutableArray array];
        totalNeedDownloadSize=0;
        downloadSizeSoFar=0;
    }
    return self;
}
-(void)addHttpRequest:(HttpRequest *)request
{
    [self.httpRequestArray addObject:request];
}
-(void)startDownload
{
    for (HttpRequest *req_ in self.httpRequestArray)
    {
        req_.delegate=self;
        [req_ go];
    }
    
}
-(void)getDownloadDataRequest:(HttpRequest *)request
{
    unsigned long long download=0;
    unsigned long long total=0;
    for (HttpRequest *req_ in self.httpRequestArray)
    {
        download+=req_.downloadSizeSoFar;
        total+=req_.totalNeedDownloadSize;
    }
    downloadSizeSoFar=download;
    totalNeedDownloadSize=total;
    NSLog(@"downloadSizesofar=%llu,totalneedDownloadSize=%llu",downloadSizeSoFar,totalNeedDownloadSize);
    CGFloat progress=(CGFloat)downloadSizeSoFar/totalNeedDownloadSize;
    NSLog(@"progress=%%%d",progress*100);
    
}
-(void)startDownloadRequest:(HttpRequest *)request
{
    
}
-(void)finishDownloadRequest:(HttpRequest *)request
{
    
}
@end
