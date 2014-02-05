//
//  ViewController.m
//  Request
//
//  Created by deandean on 14-1-23.
//  Copyright (c) 2014年 deandean. All rights reserved.
//

#import "ViewController.h"
#import "DownloadArrayManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    HttpRequest *request1=[[HttpRequest alloc] initWithURLString:@"http://sj.91rb.com/iphone/soft//2014/1/22/dbb58009eb4d42e9a0c99a8ce06f9ab0/com.elextech.ram_4.1.2_4.1.2_635259959025282537.ipa"];
    request1.tmpFilePath=[NSString stringWithFormat:@"%@/Documents/1xxx.tmpp",NSHomeDirectory()];
    request1.desFilePath=[NSString stringWithFormat:@"%@/Documents/1.ipa",NSHomeDirectory()];
    
    
    HttpRequest *request2=[[HttpRequest alloc] initWithURLString:@"http://sj.91rb.com/iphone/soft//2014/1/22/dbb58009eb4d42e9a0c99a8ce06f9ab0/com.elextech.ram_4.1.2_4.1.2_635259959025282537.ipa"];
    request2.tmpFilePath=[NSString stringWithFormat:@"%@/Documents/2xxx.tmpp",NSHomeDirectory()];
    request2.desFilePath=[NSString stringWithFormat:@"%@/Documents/2.ipa",NSHomeDirectory()];
    
    
    HttpRequest *request3=[[HttpRequest alloc] initWithURLString:@"http://sj.91rb.com/iphone/soft//2014/1/22/dbb58009eb4d42e9a0c99a8ce06f9ab0/com.elextech.ram_4.1.2_4.1.2_635259959025282537.ipa"];
    request3.tmpFilePath=[NSString stringWithFormat:@"%@/Documents/3xxx.tmpp",NSHomeDirectory()];
    request3.desFilePath=[NSString stringWithFormat:@"%@/Documents/3.ipa",NSHomeDirectory()];
    
    DownloadArrayManager *loadManager=[[DownloadArrayManager alloc] init];
    [loadManager addHttpRequest:request1];
    [loadManager addHttpRequest:request2];
    [loadManager addHttpRequest:request3];
    [loadManager startDownload];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
