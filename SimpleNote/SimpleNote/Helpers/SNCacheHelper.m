//
//  SNCacheHelper.m
//  SimpleNote
//
//  Created by Panda on 16/4/12.
//  Copyright © 2016年 v2panda. All rights reserved.
//

#import "SNCacheHelper.h"
#import <YYCache.h>

@implementation SNCacheHelper

+ (instancetype)sharedManager {
    static SNCacheHelper *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedManager) {
            sharedManager = [[SNCacheHelper alloc]init];
        }
    });
    return sharedManager;
}

- (BOOL)storeNote:(NoteModel *)note {
    
    NSString *basePath = [self basePath:note.notebookName];
    YYDiskCache *yy = [[YYDiskCache alloc] initWithPath:[basePath stringByAppendingPathComponent:note.noteID]];
    
//    BOOL isContain = [yy containsObjectForKey:@"1460470794.404366"];
    
    [yy setObject:note forKey:note.noteID];
    
    return YES;
}
- (BOOL)storeNoteBook:(NoteBookModel *)notebook {
    NSString *basePath = [self basePath:notebook.noteBookID.stringValue];
    YYDiskCache *yy = [[YYDiskCache alloc] initWithPath:basePath];
    
    [yy setObject:notebook forKey:notebook.noteBookID.stringValue];
    
    return YES;
}

- (NSMutableArray<NoteBookModel *> *)readAllNoteBooks {
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:nil];
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *file in files) {
        
        if ([file hasPrefix:@"data"] || [file hasPrefix:@"trash"] || [file hasPrefix:@"manifest"] || [file hasPrefix:@"."]) {
            continue ;
        }
        YYDiskCache *yy = [[YYDiskCache alloc] initWithPath:[self basePath:file]];
        NoteBookModel *note = (NoteBookModel *)[yy objectForKey:file];
        if (note) {
            [array addObject:note];
        }
    }
    
    return array;
}

- (NSString *)basePath:(NSString *)notebookName {
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    basePath = [basePath stringByAppendingPathComponent:notebookName];
    return basePath;
}


@end
