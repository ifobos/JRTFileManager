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

#import "JRTFileManager.h"
#import "JRTFileDownloader.h"
#import "JRTFilePersitence.h"

@interface JRTFileManager ()
@property (strong, nonatomic) JRTFileDownloader *fileDownloader;
@property (strong, nonatomic) JRTFilePersitence *filePersistence;
@end


@implementation JRTFileManager

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^
    {
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

#pragma mark - Getter

- (NSSearchPathDirectory)directory {
    if (!_directory) {
        _directory = NSCachesDirectory;
    }
    return _directory;
}

- (JRTFileDownloader *)fileDownloader {
    if (!_fileDownloader) {
        _fileDownloader = [JRTFileDownloader new];
    }
    return _fileDownloader;
}

- (JRTFilePersitence *)filePersistence {
    if (!_filePersistence) {
        _filePersistence = [JRTFilePersitence new];
    }
    return _filePersistence;
}

#pragma mark - Documents

- (NSString *)directoryPath {
    NSURL *directoryURL = [[[NSFileManager defaultManager] URLsForDirectory:self.directory
                                                                  inDomains:NSUserDomainMask] lastObject];
                                                                  
    return [directoryURL path];
}

- (NSString *)directoryPathForResourceWithPath:(NSString *)relativePath {
    NSString *directory = [self directoryPath];
    return [directory stringByAppendingPathComponent:relativePath];
}

#pragma mark - Saving

- (BOOL)saveData:(NSData *)data toDirectoryPath:(NSString *)relativePath {
    BOOL saved = NO;
    
    if (relativePath.length > 0) {
        NSString *directory = [self directoryPath];
        NSString *absolutePath = [directory stringByAppendingPathComponent:relativePath];
        
        saved = [self.filePersistence saveData:data toPath:absolutePath];
    }
    
    return saved;
}

#pragma mark - Retrieval

- (NSData *)retrieveDataFromDirectoryWithPath:(NSString *)relativePath {
    NSData *data = nil;
    
    if (relativePath.length > 0) {
        NSString *directory = [self directoryPath];
        NSString *absolutePath = [directory stringByAppendingPathComponent:relativePath];
        
        data = [self.filePersistence retrieveDataAtPath:absolutePath];
    }
    
    return data;
}

#pragma mark - Exists

- (BOOL)fileExistsInDirectory:(NSString *)relativePath {
    BOOL fileExists = NO;
    
    if (relativePath.length > 0) {
        NSString *directory = [self directoryPath];
        NSString *absolutePath = [directory stringByAppendingPathComponent:relativePath];
        
        fileExists = [[NSFileManager defaultManager] fileExistsAtPath:absolutePath];
    }
    
    return fileExists;
}

#pragma mark - Deletion

- (BOOL)deleteDataFromDirectoryWithPath:(NSString *)relativePath {
    BOOL deletion = NO;
    
    if (relativePath.length > 0) {
        NSString *directory = [self directoryPath];
        NSString *absolutePath = [directory stringByAppendingPathComponent:relativePath];
        
        deletion = [self.filePersistence deleteDataAtPath:absolutePath];
    }
    
    return deletion;
}

#pragma mark - Download

- (void) downloadFile:(NSString *)URLString
             withName:(NSString *)name
             progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
    completionHandler:(void (^)(NSURL *filePath, NSError *error))completionHandler {
    [self.fileDownloader downloadFile:URLString
                             withName:name
                            directory:self.directory
                             progress:^(NSProgress *downloadProgress) {
        if (downloadProgressBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                downloadProgressBlock(downloadProgress);
            });
        }
    }
                    completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        completionHandler(filePath, error);
    }];
}

@end
