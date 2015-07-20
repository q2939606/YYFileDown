#YYFileDown
-用于大文件下载
	
##使用说明Demo



####下载方法  downing 下载中持续调用   	completionHandler 下载完毕后调用

```objc
     +(instancetype)DowFileWith:(NSString *) url downing:(void (^)(double progress)) downing completionHandler:(void (^)(NSError *error,NSString *filePath)) handler;
```
	
