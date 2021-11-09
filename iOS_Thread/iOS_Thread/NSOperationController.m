

/*
    NSOperation：是苹果对 GCD 的封装，完全面向对象。 NSOperationQueue 可以设置并发队列的依赖关系、执行顺序、最大并发数，更加灵活，解决复杂的线程设计。
    两个核心概念：queue（队列）、 Operation（操作）
    NSOperation和NSOperationQueue结合使用实现多线程并发
 
    NSOperation的子类
    NSOperation是个抽象类，并不具备封装操作的能力，必须使用它的子类，使用NSOperation子类的方式有3种
    •    NSInvocationOperation
    •    NSBlockOperation
    •    自定义子类继承NSOperation，实现内部相应的方法

 
 */



#import "NSOperationController.h"

@interface NSOperationController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *methodNames;


@end

@implementation NSOperationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSubViews];

}

#pragma mark - NSOperation
/*
    NSInvocationOperation只有配合NSOperationQueue使用才能实现多线程编程，单独使用NSInvocationOperation不会开启线程，默认在当前线程（指执行该方法的线程）中同步执行。
 */
-(void)invocationOpeation {
    NSLog(@"*****************当前调用方法  %@  *****************", NSStringFromSelector(_cmd));

   
    
    //1.创建操作,封装任务
    /*
     第三个参数object:前面方法需要接受的参数 可以为nil
     */
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(operation1) object:nil];
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(operation2) object:nil];
    NSInvocationOperation *op3 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(operation3) object:nil];
    

    //2.启动|执行操作
    [op1 start];
    [op2 start];
    [op3 start];
}

-(void)operation1{
    NSLog(@"1--%@",[NSThread currentThread]);
}

-(void)operation2{
    NSLog(@"2--%@",[NSThread currentThread]);
}

-(void)operation3{
    NSLog(@"3--%@",[NSThread currentThread]);
}

/*
    单独使用NSBlockOperation和NSInvocationOperation一样，默认在当前线程中同步执行。
    使用addExecutionBlock追加的任务是并发执行的，如果这个操作中的任务数量大于1,那么会开子线程并发执行任务，并且追加的任务不一定就是子线程,也有可能是主线程。所以任务1、2、3执行是可期的，有序的，但是任务4、5、6是并发执行的，不可控的。
 */

-(void)blockOperation{
    NSLog(@"*****************当前调用方法  %@  *****************", NSStringFromSelector(_cmd));

    //1.创建操作
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"1----%@",[NSThread currentThread]);
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"2----%@",[NSThread currentThread]);
    }];
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"3----%@",[NSThread currentThread]);
    }];
    
    
    //追加任务
    //注意:如果一个操作中的任务数量大于1,那么会开子线程并发执行任务
    //注意:不一定是子线程,有可能是主线程
    [op3 addExecutionBlock:^{
        NSLog(@"4---%@",[NSThread currentThread]);
    }];
    
    [op3 addExecutionBlock:^{
        NSLog(@"5---%@",[NSThread currentThread]);
    }];
    
    [op3 addExecutionBlock:^{
        NSLog(@"6---%@",[NSThread currentThread]);
    }];
    
    //2.启动
    [op1 start];
    [op2 start];
    [op3 start];
}


/*
 NSOperationQueue
 NSOperation中的两种队列
     •    主队列 通过mainQueue获得，凡是放到主队列中的任务都将在主线程执行.
     •    非主队列 直接alloc init出来的队列。非主队列同时具备了并发和串行的功能，通过设置最大并发数属性来控制任务是并发执行还是串行执行
 */

- (void)invocationOperationWithQueue {
    
    NSLog(@"*****************当前调用方法  %@  *****************", NSStringFromSelector(_cmd));

    //1.创建操作,封装任务
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(operation1) object:nil];
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(operation2) object:nil];
    NSInvocationOperation *op3 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(operation3) object:nil];
    
    //2.创建队列
    /*
     GCD:
     串行类型:create & 主队列
     并发类型:create & 全局并发队列
     NSOperation:
     主队列:   [NSOperationQueue mainQueue] 和GCD中的主队列一样,串行队列
     非主队列: [[NSOperationQueue alloc]init]  非常特殊(同时具备并发和串行的功能)
     //默认情况下,非主队列是并发队列
     */
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    //3.添加操作到队列中
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
}


/*
    NSBlockOperation和NSOperationQueue组合：
 */
- (void)blockOperationWithQueue {
    
    NSLog(@"*****************当前调用方法  %@  *****************", NSStringFromSelector(_cmd));

    //1.创建操作
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"1----%@",[NSThread currentThread]);
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"2----%@",[NSThread currentThread]);
    }];
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"3----%@",[NSThread currentThread]);
    }];
    //追加任务
    [op2 addExecutionBlock:^{
        NSLog(@"4----%@",[NSThread currentThread]);
    }];
    [op2 addExecutionBlock:^{
        NSLog(@"5----%@",[NSThread currentThread]);
    }];
    [op2 addExecutionBlock:^{
        NSLog(@"6----%@",[NSThread currentThread]);
    }];
    
    //2.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    //3.添加操作到队列
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
    
    
    //提供一个简便方法，使用Block直接添加任务
    //1)创建操作,2)添加操作到队列中
    [queue addOperationWithBlock:^{
        NSLog(@"7----%@",[NSThread currentThread]);
    }];
}

#pragma mark - NSOperation其它用法

/*
    最大并发数
 */

-(void)maxConcurrentTest {
    
    NSLog(@"*****************当前调用方法  %@  *****************", NSStringFromSelector(_cmd));
    
    //static const NSInteger NSOperationQueueDefaultMaxConcurrentOperationCount = -1;

    
    //1.创建队列
    //默认是并发队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    //2.设置最大并发数量 maxConcurrentOperationCount
    /*
     同一时间最多有多少个任务可以执行
     串行执行任务!=只开一条线程 (线程同步)
     maxConcurrentOperationCount >1 那么就是并发队列
     maxConcurrentOperationCount == 1 那就是串行队列
     maxConcurrentOperationCount == 0  不会执行任务
     maxConcurrentOperationCount == -1 特殊意义 最大值 表示不受限制
     */
    queue.maxConcurrentOperationCount = 1;
    
    //3.封装操作
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"1----%@",[NSThread currentThread]);
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"2----%@",[NSThread currentThread]);
    }];
    
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"3----%@",[NSThread currentThread]);
    }];
    
    NSBlockOperation *op4 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"4----%@",[NSThread currentThread]);
    }];
    
    //4.添加到队列
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
    [queue addOperation:op4];
        
    
    
}

/*
    队列的暂停和恢复以及取消
 
 
 @property (getter=isSuspended) BOOL suspended;
 - (void)setSuspended:(BOOL)state;
    设置暂停和恢复
    suspended设置为YES表示暂停，suspended设置为NO表示恢复
    暂停表示不继续执行队列中的下一个任务，暂停操作是可以恢复的
    队列中的任务也是有状态的:已经执行完毕的 | 正在执行 | 排队等待状态
    不能暂停当前正在处于执行状态的任务
    暂停操作不能使当前正在处于执行状态的任务暂停，而是该任务执行结束，后面的任务不会执行，处于排队等待状态    。例如执行2个任务，在执行第1个任务时，执行了暂停操作，第1个任务不会立即暂停，而是第1个任务执行结束后，所有任务暂停，即第2个任务不会再执行.

 - (void)cancelAllOperations;
 跟暂停相似，当前正在执行的任务不会立即取消，而是后面的所有任务永远不再执行，且该操作是不可以恢复的
 也可以调用NSOperation的 cancel 方法取消单个操作
 
    
 苹果官方建议，每当执行完一次耗时操作之后，就查看一下当前队列是否为取消状态，如果是，那么就直接退出,以此提高程序的性能 。

 
 */

/*
 
 操作依赖
 [opB addDependency: opA]; // 操作B依赖于操作A,或者前者依赖后者
 
 注意：不可以循环依赖：
 循环依赖的结果：循环依赖的操作都不会有任何的执行，不会发生异常，并且不会影响该队列的其他操作
 
 操作的监听
   op.completionBlock = ^{
     NSLog(@"op已经执行完了，可以做接下来的操作);
   };
 

 */



- (void)dependencyCompletionBlockTest{
    //1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    NSOperationQueue *queue2 = [[NSOperationQueue alloc]init];
    
    //2.封装操作
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"1---%@",[NSThread currentThread]);
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"2---%@",[NSThread currentThread]);
    }];
    
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"3---%@",[NSThread currentThread]);
    }];
    
    //操作监听
    op3.completionBlock = ^{
        NSLog(@"3已经执行完了------%@",[NSThread currentThread]);
    };
    
    //添加操作依赖
    [op1 addDependency:op3]; //跨队列依赖,op1属于queue，op3属于queue2
    [op2 addDependency:op1];
    
    //添加操作到队列
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue2 addOperation:op3];
}

/**
    NSOperation实现线程间通信
 */



- (void)operationCommunication{
    
    __block int num1 = 10;
    __block int num2 = 10;
    
    //1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    //3.num1的处理
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        num1+=10;
        
        NSLog(@"%@ num1 = %d", [NSThread currentThread], num1);
        
    }];
        
    //3.num2的处理
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        num2+=5;
        NSLog(@"%@ num2 = %d", [NSThread currentThread], num2);
    }];
    
    //4.num1 + num2
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
                    
        int sumNum = num1 + num2;
        
        NSLog(@"%@ num1 + num2 = %d",[NSThread currentThread] ,sumNum);
        
        //7.回到主线程更新数据
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                
            NSLog(@"拿到数据刷新UI---%@ sum = %d",[NSThread currentThread], sumNum);
        }];
        
    }];
    
    //5.设置操作依赖
    [op3 addDependency:op1];
    [op3 addDependency:op2];
    
    //6.添加操作到队列中执行
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
}


#pragma mark - UI相关

- (void)setSubViews {
    self.methodNames = @[@"invocationOpeation",@"blockOperation",@"invocationOperationWithQueue",@"blockOperationWithQueue",@"maxConcurrentTest",@"dependencyCompletionBlockTest",@"operationCommunication"];

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
