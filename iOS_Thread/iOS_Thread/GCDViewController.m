//
//  GCDViewController.m
//  iOS_Thread
//
//  Created by zhaoYC on 2021/11/8.
//

/*
 
 GCD中有2个用来执行任务的函数
 用同步的方式执行任务
 dispatch_sync(dispatch_queue_t queue, dispatch_block_t block);
 queue：队列
 block：任务

 用异步的方式执行任务
 dispatch_async(dispatch_queue_t queue, dispatch_block_t block);
 
 
 GCD的队列可以分为2大类型
 并发队列（Concurrent Dispatch Queue）
 可以让多个任务并发（同时）执行（自动开启多个线程同时执行任务）
 并发功能只有在异步（dispatch_async）函数下才有效

 串行队列（Serial Dispatch Queue）
 让任务一个接着一个地执行（一个任务执行完毕后，再执行下一个任务）

 
 算上主队列，一共有6种组合方式
 
 1、同步执行 + 并发队列
 2、异步执行 + 并发队列
 3、同步执行 + 串行队列
 4、异步执行 + 串行队列
 5、同步执行 + 主队列
 6、异步执行 + 主队列
 

 */


#import "GCDViewController.h"

@interface GCDViewController () <UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, strong) NSArray *methodNames;

@end

@implementation GCDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSubViews];

            
    //主队列
    dispatch_queue_t queue1 = dispatch_get_main_queue();
    //全局并发队列
    dispatch_queue_t queue2  = dispatch_get_global_queue(0, 0);
    //串行队列
    dispatch_queue_t queue3 = dispatch_queue_create("DISPATCH_QUEUE_SERIAL", DISPATCH_QUEUE_SERIAL);
    //并发队列
    dispatch_queue_t queue4 = dispatch_queue_create("DISPATCH_QUEUE_CONCURRENT", DISPATCH_QUEUE_CONCURRENT);
    
    NSLog(@"%p %p %p %p", queue1, queue2, queue3, queue4);
    
    
    
    /*
     任务的创建方法
     
     异步执行任务创建方法
     dispatch_async(dispatch_queue_t  _Nonnull queue1, ^{
        异步执行任务代码

     });
     
     同步执行任务创建方法
     dispatch_sync(dispatch_queue_t  _Nonnull queue1, ^{
        同步执行任务代码
     })
     
     */
}

#pragma mark - 组合用例

/**
 * 同步执行 + 并发队列
 * 特点：在当前线程中执行任务，不会开启新线程，执行完一个任务，再执行下一个任务。
 */
- (void)syncConcurrent {
    NSLog(@"*****************当前调用方法  %@  *****************", NSStringFromSelector(_cmd));

    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"syncConcurrent---begin");
    dispatch_queue_t queue = dispatch_queue_create("syncConcurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_sync(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_sync(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    NSLog(@"syncConcurrent---end");
}

/**
 * 异步执行 + 并发队列
 * 特点：可以开启多个线程，任务交替（同时）执行。
 */
- (void)asyncConcurrent {
    NSLog(@"*****************当前调用方法  %@  *****************", NSStringFromSelector(_cmd));

    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncConcurrent---begin");
    
    dispatch_queue_t queue = dispatch_queue_create("asyncConcurrent", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_async(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_async(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    NSLog(@"asyncConcurrent---end");
}


/**
 * 同步执行 + 串行队列
 * 特点：不会开启新线程，在当前线程执行任务。任务是串行的，执行完一个任务，再执行下一个任务。
 */
- (void)syncSerial {
    NSLog(@"*****************当前调用方法  %@  *****************", NSStringFromSelector(_cmd));

    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"syncSerial---begin");
    
    dispatch_queue_t queue = dispatch_queue_create("syncSerial", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_sync(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_sync(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    NSLog(@"syncSerial---end");
}

/**
 * 异步执行 + 串行队列
 * 特点：会开启新线程，但是因为任务是串行的，执行完一个任务，再执行下一个任务。
 */
- (void)asyncSerial {
    
    NSLog(@"*****************当前调用方法  %@  *****************", NSStringFromSelector(_cmd));

    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncSerial---begin");
    
    dispatch_queue_t queue = dispatch_queue_create("asyncSerial", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_async(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_async(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    NSLog(@"asyncSerial---end");
}

/**
 * 同步执行 + 主队列
 * 特点(主线程调用)：互等卡住不执行。
 * 特点(其他线程调用)：不会开启新线程，执行完一个任务，再执行下一个任务。
 */
- (void)syncMain {
    NSLog(@"*****************当前调用方法  %@  *****************", NSStringFromSelector(_cmd));

    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"syncMain---begin");

    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_sync(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_sync(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_sync(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    NSLog(@"syncMain---end");
}

/**
 * 异步执行 + 主队列
 * 特点：只在主线程中执行任务，执行完一个任务，再执行下一个任务
 */
- (void)asyncMain {
    NSLog(@"*****************当前调用方法  %@  *****************", NSStringFromSelector(_cmd));

    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncMain---begin");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_async(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_async(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    NSLog(@"asyncMain---end");
}


- (void)question01
{
    NSLog(@"*****************当前调用方法  %@  *****************", NSStringFromSelector(_cmd));
    NSLog(@"执行任务1%--@",[NSThread currentThread]);      // 打印当前线程

    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_sync(queue, ^{
        NSLog(@"执行任务2--%@",[NSThread currentThread]);
    });
    
    NSLog(@"执行任务3--%@",[NSThread currentThread]);
}


//使用sync函数往当前串行队列中添加任务，会卡住当前的串行队列（产生死锁）


- (void)question02 {
    
    NSLog(@"*****************当前调用方法  %@  *****************", NSStringFromSelector(_cmd));

    dispatch_queue_t queue = dispatch_queue_create("question02", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{    // 异步执行 + 串行队列
        dispatch_sync(queue, ^{  // 同步执行 + 当前串行队列
            NSLog(@"执行任务1---%@",[NSThread currentThread]);      // 打印当前线程
        });
    });
}

//执行上面的代码会导致 串行队列中追加的任务 和 串行队列中原有的任务 两者之间相互等待，阻塞了『串行队列』，最终造成了串行队列所在的线程（子线程）死锁问题。


- (void)question03
{
    NSLog(@"*****************当前调用方法  %@  *****************", NSStringFromSelector(_cmd));

    NSLog(@"执行任务1");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        NSLog(@"执行任务2");
    });
    
    NSLog(@"执行任务3");
}
// 以下代码是在主线程执行的，不会产生死锁,dispatch_async不要求立马在当前线程同步执行任务


#pragma mark - GCD其他方法



/**
 * 栅栏方法
 *
 *  dispatch_barrier_sync(queue,void(^block)())会将queue中barrier前面添加的任务block全部执行后,再执行barrier任务的block,再执行barrier后面添加的任务block.
 
    dispatch_barrier_async(queue,void(^block)())会将queue中barrier前面添加的任务block只添加不执行,继续添加barrier的block,再添加barrier后面的block,同时不影响主线程(或者操作添加任务的线程)中代码的执行!
 *
 *
 *  注意：栅栏函数不能使用全局并发队列
 *
 */
- (void)barrierAsync {
    NSLog(@"*****************当前调用方法  %@  *****************", NSStringFromSelector(_cmd));

    
    dispatch_queue_t queue = dispatch_queue_create("barrier", DISPATCH_QUEUE_CONCURRENT);
    
    NSLog(@"aaaaaaaa");
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_async(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_barrier_async(queue, ^{
        // 追加任务 barrier
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"barrier---%@",[NSThread currentThread]);// 打印当前线程
    });
    
    NSLog(@"bbbbbbbbb");

    
    dispatch_async(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_async(queue, ^{
        // 追加任务 4
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"4---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    NSLog(@"cccccccccc");

}

- (void)barrierSync {
    NSLog(@"*****************当前调用方法  %@  *****************", NSStringFromSelector(_cmd));

    dispatch_queue_t queue = dispatch_queue_create("barrier", DISPATCH_QUEUE_CONCURRENT);
    
    NSLog(@"aaaaaaaa");
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_async(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_barrier_sync(queue, ^{
        // 追加任务 barrier
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"barrier---%@",[NSThread currentThread]);// 打印当前线程
    });
    
    NSLog(@"bbbbbbbbb");

    dispatch_async(queue, ^{
        // 追加任务 3
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    });
    dispatch_async(queue, ^{
        // 追加任务 4
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"4---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    NSLog(@"cccccccccc");
}



/**
 * 延时执行方法 dispatch_after
 */
- (void)gcdAfter {
    NSLog(@"*****************当前调用方法  %@  *****************", NSStringFromSelector(_cmd));

    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncMain---begin");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 2.0 秒后异步追加任务代码到主队列，并开始执行
        NSLog(@"after---%@",[NSThread currentThread]);  // 打印当前线程
    });
}
/**
 * 一次性代码（只执行一次）dispatch_once
 */
- (void)gcdOnce {
    
    NSLog(@"*****************当前调用方法  %@  *****************", NSStringFromSelector(_cmd));
    for (int i = 0; i < 10; i++) {
        NSLog(@"%d------- begin", i);
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            // 只执行 1 次的代码（这里面默认是线程安全的）
            NSLog(@"你觉得我执行了几次");
        });
        NSLog(@"%d------- end", i);
    }
}

/**
 * 队列组 dispatch_group_notify
 */
- (void)groupNotify {
    NSLog(@"*****************当前调用方法  %@  *****************", NSStringFromSelector(_cmd));

    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"group---begin");
    
    dispatch_group_t group =  dispatch_group_create();
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等前面的异步任务 1、任务 2 都执行完毕后，回到主线程执行下边任务
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程

        NSLog(@"group---end");
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务 4
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"4---%@",[NSThread currentThread]);      // 打印当前线程
    });
}

/**
 * 队列组 dispatch_group_wait
 */
- (void)groupWait {
    NSLog(@"*****************当前调用方法  %@  *****************", NSStringFromSelector(_cmd));

    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"group---begin");
    
    dispatch_group_t group =  dispatch_group_create();
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
    
    // 等待上面的任务全部完成后，会往下继续执行（会阻塞当前线程）
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    NSLog(@"group---end");
    
}

/**
 * 队列组 dispatch_group_enter、dispatch_group_leave
 */
- (void)groupEnterAndLeave {
    
    NSLog(@"*****************当前调用方法  %@  *****************", NSStringFromSelector(_cmd));

    
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"group---begin");
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程

        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        // 追加任务 2
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等前面的异步操作都执行完毕后，回到主线程.
        [NSThread sleepForTimeInterval:1];              // 模拟耗时操作
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    
        NSLog(@"group---end");
    });
}


/**
 * semaphore 线程同步 信号量
 
    dispatch_semaphore_create：创建一个 Semaphore 并初始化信号的总量
    dispatch_semaphore_signal：发送一个信号，让信号总量加 1
    dispatch_semaphore_wait：可以使总信号量减 1，信号总量小于 0 时就会一直等待（阻塞所在线程），否则就可以正常执行。
 *
 */
- (void)semaphoreSync {

    NSLog(@"*****************当前调用方法  %@  *****************", NSStringFromSelector(_cmd));
    
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"semaphore---begin");
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block int number = 0;
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        
        number = 100;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER); //阻塞线程
    NSLog(@"semaphore---end,number = %d",number);
}

#pragma mark - UI相关

- (void)setSubViews {
    self.methodNames = @[@"syncConcurrent",@"asyncConcurrent",@"syncSerial",@"asyncSerial",@"syncMain",@"asyncMain",@"question01",@"question02",@"question03",@"barrierAsync",@"barrierSync",@"gcdAfter",@"gcdOnce",@"groupNotify",@"groupWait",@"groupEnterAndLeave",@"semaphoreSync"];

    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 100)];
    tableView.tableFooterView = footer;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.methodNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = self.methodNames[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //1.获取方法名字
    NSString *methodStr = self.methodNames[indexPath.row];

    //2.方法调用
    SEL selector = NSSelectorFromString(methodStr);
    IMP imp = [self methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;
    func(self, selector);
}





@end



