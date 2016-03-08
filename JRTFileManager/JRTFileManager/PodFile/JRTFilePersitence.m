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

#import "JRTFilePersitence.h"

@implementation JRTFilePersitence

#pragma mark - Retrieving

- (NSData *)retrieveDataAtPath:(NSString *)absolutePath {
    NSData *data = nil;
    
    if (absolutePath.length > 0) {
        data = [NSData dataWithContentsOfFile:absolutePath];
    }
    
    return data;
}

#pragma mark - Saving

- (BOOL)saveData:(NSData *)data
          toPath:(NSString *)absolutePath {
    BOOL success = NO;
    
    if (data.length > 0 &&
        absolutePath.length > 0) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        BOOL createdDirectory = YES;
        
        NSString *folderPath = [absolutePath stringByDeletingLastPathComponent];
        
        if (![fileManager fileExistsAtPath:folderPath]) {
            createdDirectory = [self createDirectoryAtPath:folderPath];
        }
        
        if (createdDirectory) {
            NSError *error = nil;
            
            success = [data writeToFile:absolutePath
                                options:NSDataWritingAtomic
                                  error:&error];
                                  
            if (error) {
                NSLog(@"%s %d: Error: %@", __FILE__, __LINE__, error);
            }
        }
    }
    
    return success;
}

- (BOOL)createDirectoryAtPath:(NSString *)absolutePath {
    BOOL createdDirectory = NO;
    
    if (absolutePath.length > 0) {
        NSError *error = nil;
        
        createdDirectory = [[NSFileManager defaultManager] createDirectoryAtPath:absolutePath
                                                     withIntermediateDirectories:YES
                                                                      attributes:nil
                                                                           error:&error];
                                                                           
        if (error) {
            NSLog(@"%s %d: Error: %@", __FILE__, __LINE__, error);
        }
    }
    
    return createdDirectory;
}

#pragma mark - Exists

- (BOOL)fileExistsAtPath:(NSString *)absolutePath {
    return [[NSFileManager defaultManager] fileExistsAtPath:absolutePath];
}

- (void)fileExistsAtPath:(NSString *)absolutePath
              completion:(void (^)(BOOL fileExists))completion {
    NSOperationQueue *callBackQueue = [NSOperationQueue currentQueue];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
    {
        BOOL fileExists = [self fileExistsAtPath:absolutePath];
        
        [callBackQueue addOperationWithBlock:^
        {
            if (completion) {
                completion(fileExists);
            }
        }];
    });
}

#pragma mark - Deletion

- (BOOL)deleteDataAtPath:(NSString *)absolutePath {
    BOOL deletion = NO;
    
    if (absolutePath.length > 0) {
        NSError *error = nil;
        
        deletion = [[NSFileManager defaultManager] removeItemAtPath:absolutePath
                                                              error:&error];
                                                              
        if (error) {
            NSLog(@"%s %d: Error: %@", __FILE__, __LINE__, error);
        }
    }
    
    return deletion;
}

#pragma mark - URL

- (NSURL *)fileURLForPath:(NSString *)absolutePath {
    return [NSURL fileURLWithPath:absolutePath];
}

#pragma mark - Move

- (BOOL)moveFileFromSourcePath:(NSString *)sourcePath
             toDestinationPath:(NSString *)destinationPath {
    BOOL success = NO;
    
    if (sourcePath.length > 0 &&
        destinationPath.length > 0) {
        BOOL createdDirectory = YES;
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *destinationDirectoryPath = [destinationPath stringByDeletingLastPathComponent];
        
        if (![fileManager fileExistsAtPath:destinationDirectoryPath]) {
            createdDirectory = [self createDirectoryAtPath:destinationDirectoryPath];
        }
        
        if (createdDirectory) {
            NSError *error = nil;
            
            success = [fileManager moveItemAtPath:sourcePath
                                           toPath:destinationPath
                                            error:&error];
                                            
            if (error) {
                NSLog(@"%s %d: Error: %@", __FILE__, __LINE__, error);
            }
        }
    }
    
    return success;
}

@end
