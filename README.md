#YYFileDown
-用于大文件下载
	
##使用说明Demo



####下载方法  downing 下载中持续调用   	completionHandler 下载完毕后调用

```objc
/**
*progress 已下载百分比
*error 错误信息
*filePath 下载完成文件存放的地址
*/
     +(instancetype)DowFileWith:(NSString *) url downing:(void (^)(double progress)) downing completionHandler:(void (^)(NSError *error,NSString *filePath)) handler;
```
	
