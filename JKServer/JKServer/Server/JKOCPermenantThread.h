//
//  JKPermenantThread.h
//  JKRunloopTest
//
//  Created by 王冲 on 2018/10/21.
//  Copyright © 2018年 JK科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^JKOCPermenantThreadTask)(void);

@interface JKOCPermenantThread : NSObject

/**
开启线程
*/
//- (void)run;

/**
 在当前子线程执行一个任务
 */
- (void)executeTask:(JKOCPermenantThreadTask)task;

/**
 结束线程
 */
- (void)stop;

@end


NS_ASSUME_NONNULL_END
