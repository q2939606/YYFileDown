//
//  YYDownFile.h
//  断点下载
//
//  Created by mac on 15/7/19.
//  Copyright (c) 2015年 yy. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface YYDownFile : NSObject

/** 文件名 */
@property (nonatomic,strong) NSString * fileName;

/**文件地址*/
@property (nonatomic,strong) NSString * url;

/**下载进度*/
@property (nonatomic,assign) double progress;





//开始或恢复任务
- (void) resume;

//暂停任务
- (void) pause;


/**实例YY对象*/
+(instancetype)DowFileWith:(NSString *)url;


/** 下载方法  downing 下载中持续调用   completionHandler 下载完毕后调用*/
+(instancetype)DowFileWith:(NSString *) url downing:(void (^)(double progress)) downing completionHandler:(void (^)(NSError *error,NSString *filePath)) handler;


/**根据网址 返回已下载的文件路径*/
+(NSString *)getFilePathWith:(NSString *)url;

@end
