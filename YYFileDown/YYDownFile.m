//
//  YYDownFile.m
//  断点下载
//
//  Created by mac on 15/7/19.
//  Copyright (c) 2015年 yy. All rights reserved.
//

//存放文件路径
#define YYFileFullPath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:self.fileName]

// 存储文件信息路径（caches）
#define YYDetailsFullpath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"YYDownFlie/YYDetailsFullpath.plist"]

#pragma mark --上面是鬼东西 --

#import "YYDownFile.h"
#import "ViewController.h"
#import "NSString+Hash.h"

@interface YYDownFile ()<NSURLSessionDataDelegate>

/** 下载任务 */
@property (nonatomic,strong) NSURLSessionDataTask * task ;

/** session */
@property (nonatomic,strong) NSURLSession * session ;

/** 文件流 */
@property (nonatomic,strong) NSOutputStream * stream ;


/** 文件对象 */
@property (nonatomic,strong) NSMutableDictionary *dict;


/** 是否下载过 */
@property (nonatomic,assign) Boolean  isHistory;


/** 文件信息集合 */
@property (nonatomic,strong) NSMutableArray * fileArray;


/** 进度block */
@property (nonatomic,strong) void(^downing)(double progess);

/** 结束block */
@property (nonatomic,strong) void(^over)(NSError *error,NSString *filePath);

@end

@implementation YYDownFile

#pragma mark - 一些GetSet
-(void)setFileName:(NSString *)fileName{
    if (_fileName==nil) {
        NSString * suffixName = [fileName pathExtension];
        _fileName = [@"YYDownFlie/" stringByAppendingString: [fileName.md5String stringByAppendingFormat:@".%@",suffixName] ];
    }

}
-(NSOutputStream *)stream{
    if (!_stream) {
        _stream = [NSOutputStream outputStreamToFileAtPath:YYFileFullPath append:YES];
    }
    return _stream;
}
-(NSURLSessionDataTask *)task{
    if (!_task) {
        
        self.fileArray = [NSMutableArray arrayWithContentsOfFile:YYDetailsFullpath];
        if (self.fileArray==nil) {
            //初次初始化
            self.fileArray = [NSMutableArray array];
            
            //创建文件夹路径
//            [[NSFileManager defaultManager] createDirectoryAtPath: withIntermediateDirectories:YES attributes:nil error:nil];
            NSString *testDirectory = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"YYDownFlie"];
            [[NSFileManager defaultManager] createDirectoryAtPath:testDirectory withIntermediateDirectories:YES attributes:nil error:nil];
            
        }else{
            //查找有没有存过
            for (NSMutableDictionary *dict in self.fileArray) {
                //判断文件是否存在
                if ([dict[@"url"] isEqual:self.url]) {
                    self.dict = dict;
                    self.isHistory = YES;
                    if([dict[@"isOK"] boolValue]){
                        self.over([[NSError alloc] init],YYFileFullPath);
                        return [[NSURLSessionDataTask alloc] init];
                    }
                    
                }
            }
            
        }
        
        
        NSURL *url = [NSURL URLWithString:self.url];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        if (self.isHistory) {
            NSString *range = [NSString stringWithFormat:@"bytes=%zd-", [self.dict[@"currentLength"] intValue]];
            [request  setValue:range forHTTPHeaderField:@"Range"];
        }
        
        
        //设置超时时间为一年
        request.timeoutInterval = 60*60*60*24*365;
        
        
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        _task = [self.session dataTaskWithRequest:request];
        
    }
    return _task;
}




#pragma  mark - 方法 -

+(instancetype)DowFileWith:(NSString *)url{
    YYDownFile * downFile =  [[YYDownFile alloc] init];
    downFile.url = url;

    NSArray *arry =  [url componentsSeparatedByString:@"/"];
    downFile.fileName = [arry lastObject] ;


    return downFile;
}

+(instancetype)DowFileWith:(NSString *)url downing:(void (^)(double ))downing completionHandler:(void (^)(NSError *error,NSString *filePath))handler{
    YYDownFile * downFile = [YYDownFile DowFileWith:url];
    downFile.downing = downing;
    downFile.over = handler;
    
    [downFile resume];
    
    return downFile;
}
    


+(NSString *)getFilePathWith:(NSString *)url{

    NSMutableArray  *fileArray = [NSMutableArray arrayWithContentsOfFile:YYDetailsFullpath];
    
        //查找有没有存过
        for (NSMutableDictionary *dict in fileArray) {
            //判断文件是否存在
            if ([dict[@"url"] isEqual:url]) {

                return dict[@"filePath"];
                
            }
        }
        
    
    return @"没找到";
}

//开始
- (void)resume {

    [self.task resume];


    
}
//暂停
- (void)pause {
    [self.task suspend];
}

//接收到相应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSHTTPURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    NSLog(@"任务开始");
    
    [self.stream open];
    
    //如果没有历史
    if(!self.isHistory){
        //首次初始化
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        self.dict = dict;
        dict[@"fileName"] = self.fileName; //文件名
        dict[@"url"] = self.url; //文件
        dict[@"totalLength"] =@([response.allHeaderFields[@"Content-Length"] integerValue]); //文件总大小
        dict[@"currentLength"]= @(0); //当前下载字节
        dict[@"fileType"] = [self.url pathExtension]; //文件类型
        dict[@"isOK"] = @(NO); //是否下载完毕
        dict[@"filePath"] = YYFileFullPath;
        [self.fileArray addObject:dict];
        //写入文件
        [self.fileArray writeToFile:YYDetailsFullpath atomically:YES];
        
    }
    
    //接收这个请求,允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
}


#pragma mark  -NSURLSessionDataDelegate 代理-

//持续接收数据
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{



    //写入文件流
    [self.stream write:data.bytes maxLength:data.length];
    
    self.dict[@"currentLength"]= @([self.dict[@"currentLength"] doubleValue]+data.length); //当前下载字节
    CGFloat progress = 100.0*[self.dict[@"currentLength"] doubleValue] / [self.dict[@"totalLength"] doubleValue];
    self.progress = progress;

    
    
    //更新进度
    if ([self.dict[@"currentLength"]intValue]>=[self.dict[@"totalLength"]intValue]) {
        self.dict[@"isOK"] = @(YES); //是否下载完毕
    }
    [self.fileArray writeToFile:YYDetailsFullpath atomically:YES];
    
    
    //调用block
    self.downing(progress);
}


//接收完毕
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error{
    

    NSLog(@"下载完毕 错误信息:%@",error);
    [self.stream close];
    self.stream = nil;
    
    //调用block
    self.over(error,YYFileFullPath);
}



@end
