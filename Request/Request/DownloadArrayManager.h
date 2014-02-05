//
//  DownloadArrayManager.h
//  Request
//
//  Created by hong on 14-1-23.
//  Copyright (c) 2014年 deandean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpRequest.h"
@interface DownloadArrayManager : NSObject<HttpRequestDelegate>
{
    NSMutableArray      *_httpRequestArray;
    unsigned long long  totalNeedDownloadSize;
    unsigned long long  downloadSizeSoFar;
}
@property(nonatomic,retain)NSMutableArray   *httpRequestArray;
-(void)addHttpRequest:(HttpRequest *)request;
-(void)startDownload;
@end
