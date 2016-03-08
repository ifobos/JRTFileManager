//Copyright (c) 2015 Juan Carlos Garcia Alfaro. All rights reserved.
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

#import "JRTFileDownloader.h"
#import "AFHTTPSessionManager.h"

@interface JRTFileDownloader ()
@property (nonatomic, strong) AFURLSessionManager *manager;
@end

@implementation JRTFileDownloader

#pragma mark - Getter

- (AFURLSessionManager *)manager {
    if (!_manager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    return _manager;
}

#pragma mark - Public

- (void)downloadFile:(NSString *)URLString
            withName:(NSString *)name
           directory:(NSSearchPathDirectory)directory
            progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
   completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler {
  
    NSURLSessionDownloadTask *downloadTask = [self.manager downloadTaskWithRequest:[self requestWithURLString:URLString]
                                                                          progress:downloadProgressBlock
                                                                       destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                                                           NSURL *fileURL;
                                                                           NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:directory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                                                                           if (name) {
                                                                               fileURL = [directoryURL URLByAppendingPathComponent:name];
                                                                           }
                                                                           else {
                                                                               fileURL = [directoryURL URLByAppendingPathComponent:[response suggestedFilename]];
                                                                           }
                                                                           return fileURL;
                                                                       }
                                                                 completionHandler:completionHandler];
    [downloadTask resume];
    
}

- (void)downloadInDocumentsFile:(NSString *)URLString
                       withName:(NSString *)name
            progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
   completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler {
    [self downloadFile:URLString withName:name directory:NSDocumentDirectory progress:downloadProgressBlock completionHandler:completionHandler];
}

- (void)downloadInCacheFile:(NSString *)URLString
                   withName:(NSString *)name
                   progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
          completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler {
    [self downloadFile:URLString withName:name directory:NSCachesDirectory progress:downloadProgressBlock completionHandler:completionHandler];
}

#pragma mark - Helpers

- (NSURLRequest *)requestWithURLString:(NSString *)URLString {
    NSURL *URL = [NSURL URLWithString:[URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    return [NSURLRequest requestWithURL:URL];
}

@end
