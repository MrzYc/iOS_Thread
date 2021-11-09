
/*
 OSSpinLock 自旋锁

 等待锁的线程会处于忙等（busy-wait）状态，一直占用着CPU资源
 目前已经不再安全，可能会出现优先级反转问题
 如果等待锁的线程优先级较高，它会一直占用着CPU资源，优先级低的线程就无法释放锁

 os_unfair_lock
 等待os_unfair_lock锁的线程会处于休眠状态，并非忙等


 pthread_mutex_t 互斥锁
 
 pthread_mutexattr_t attr;
 pthread_mutexattr_init(&attr);
 pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL);
 // 初始化锁
 pthread_mutex_init(mutex, &attr);
 // 销毁属性
 pthread_mutexattr_destroy(&attr);  在不用的时候一定要手动销毁
 

 #define PTHREAD_MUTEX_NORMAL        0
 #define PTHREAD_MUTEX_ERRORCHECK    1
 #define PTHREAD_MUTEX_RECURSIVE     2
 #define PTHREAD_MUTEX_DEFAULT       PTHREAD_MUTEX_NORMAL
 
 
 NSLock NSLock是对mutex普通锁的封装
 
 - (void)lock;
 - (void)unlock;


 - (BOOL)tryLock;
 - (BOOL)lockBeforeDate:(NSDate *)limit;
 
 
 NSCondition  条件
 - (void)wait;
 - (BOOL)waitUntilDate:(NSDate *)limit;
 - (void)signal;
 - (void)broadcast;

 
 NSConditionLock 条件锁
- (void)lockWhenCondition:(NSInteger)condition;
 - (BOOL)tryLock;
 - (BOOL)tryLockWhenCondition:(NSInteger)condition;
 - (void)unlockWithCondition:(NSInteger)condition;
 - (BOOL)lockBeforeDate:(NSDate *)limit;
 - (BOOL)lockWhenCondition:(NSInteger)condition beforeDate:(NSDate *)limit;
 
  同步串行队列
 
    dispatch_sync(dispatch_queue_create("ticketQueue", DISPATCH_QUEUE_SERIAL), ^{
        
    });
 
 信号量 dispatch_semaphore_t
 
 信号量的初始值，可以用来控制线程并发访问的最大数量
 信号量的初始值为1，代表同时只允许1条线程访问资源，保证线程同步


 @synchronized
 
 @synchronized是对mutex递归锁的封装
 @synchronized(obj)内部会生成obj对应的递归锁，然后进行加锁、解锁操作
 
 
 */


#import "LockViewController.h"
#import <libkern/OSAtomic.h>

#import <os/lock.h>
#import <pthread.h>


@interface LockViewController ()

@property (assign, nonatomic) OSSpinLock ossPinkLock;

@property (assign, nonatomic) os_unfair_lock osUnFairLock;

@property (assign, nonatomic) pthread_mutex_t mutextLock;

@property (nonatomic, strong) NSLock *nsLock;

@property (strong, nonatomic) NSCondition *condition;

@property (strong, nonatomic) NSMutableArray *conditionData;

@property (assign, nonatomic) NSInteger ticketsCount;

@property (strong, nonatomic) dispatch_queue_t syncQueue;

@property (strong, nonatomic) dispatch_semaphore_t semaphore;

@end

@implementation LockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _ossPinkLock = OS_SPINLOCK_INIT; //初始化
    
    _osUnFairLock = OS_UNFAIR_LOCK_INIT; //初始化
    
    pthread_mutex_init(&_mutextLock, NULL); //初始化
    
    self.nsLock = [[NSLock alloc] init];
        
//    [self ticketTest];
    

        
//    [self nsconditionTest];
    
//    [self conditionLockTest];
    
//    [self syncQueueTest];
        
//    [self semaphoreTest];
    
    @synchronized ([self class]) {
        [self ticketTest];
    }
    
}


- (void)semaphoreTest {
    self.semaphore = dispatch_semaphore_create(1);
    
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    
    [self ticketTest];

    dispatch_semaphore_signal(self.semaphore);
    
}


- (void)syncQueueTest {
    self.syncQueue = dispatch_queue_create("ticketQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(self.syncQueue, ^{
        [self ticketTest];
    });
}

/**
 卖票演示
 */
- (void)ticketTest
{
    self.ticketsCount = 15;
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_async(queue, ^{   //售票员1
        for (int i = 0; i < 5; i++) {
            [self saleTicketWithName:@"售票员-01"];
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 5; i++) {
            [self saleTicketWithName:@"售票员-02"];
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 5; i++) {
            [self saleTicketWithName:@"售票员-03"];
        }
    });
}

/** 卖1张票 */
- (void)saleTicketWithName:(NSString *)name
{
        
//    OSSpinLockLock(&_ossPinkLock);
    
//    os_unfair_lock_lock(&_osUnFairLock);
    
//    pthread_mutex_lock(&_mutextLock);
    
    [self.nsLock lock];
        
    
    NSInteger curTicketsCount = self.ticketsCount;
    sleep(.2);
    curTicketsCount--;
    self.ticketsCount = curTicketsCount;
    
    NSLog(@"%@卖了第%ld张票 还剩%ld张票 - %@", name,curTicketsCount + 1,(long)curTicketsCount, [NSThread currentThread]);
    
//    OSSpinLockUnlock(&_ossPinkLock);
    
//    os_unfair_lock_unlock(&_osUnFairLock);
    
//    pthread_mutex_unlock(&_mutextLock);
    
    [self.nsLock unlock];
    
}


- (void)nsconditionTest {
    self.condition = [[NSCondition alloc] init];
    
    dispatch_queue_t queue =  dispatch_queue_create("tickets", DISPATCH_QUEUE_CONCURRENT);

    self.ticketsCount = 20;
    
    for (int i = 0; i < 50; i++) {
        dispatch_async(queue, ^{
            [self refundTickets];
        });
        dispatch_async(queue, ^{
            [self saleTickets];
        });
        dispatch_async(queue, ^{
            [self saleTickets];
        });
        dispatch_async(queue, ^{
            [self saleTickets];
        });
        
        
        if (i == 0) {
            [self.condition broadcast];
        }
        
    }
}

- (void)refundTickets {
    [self.condition lock];
    self.ticketsCount = self.ticketsCount + 1;
    NSLog(@"退票： 现有ticketCount==%zd %@",self.ticketsCount, [NSThread currentThread]);
    [self.condition unlock];
    [self.condition signal];
}

- (void)saleTickets {
    [self.condition lock];
    while (self.ticketsCount == 0) {
        NSLog(@"售罄==没有票了== %@", [NSThread currentThread]);
        [self.condition wait];
        return;
    }
    
    self.ticketsCount -= 1;
    NSLog(@"卖出一张，剩下ticketCount==%zd %@",self.ticketsCount, [NSThread currentThread]);
    [self.condition unlock];
}

- (void)conditionLockTest {
    
    NSConditionLock *conditionLock = [[NSConditionLock alloc] initWithCondition:2];
        
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
       [conditionLock lockWhenCondition:1];
       NSLog(@"线程1   %@",[NSThread currentThread]);
       [conditionLock unlockWithCondition:0];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
       [conditionLock lockWhenCondition:2];
       NSLog(@"线程2   %@",[NSThread currentThread]);
       [conditionLock unlockWithCondition:1];
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       [conditionLock lock];
       NSLog(@"线程3   %@",[NSThread currentThread]);
       [conditionLock unlock];
    });
}




- (void)dealloc {
    pthread_mutex_destroy(&_mutextLock);
    
    NSLog(@"----  dealloc  -----");
}


@end
