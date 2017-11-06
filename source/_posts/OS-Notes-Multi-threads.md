---
title: 'OS Notes: Multi-threads'
date: 2017-10-31 21:06:02
tags: 
- Thread
- Locks
categories: 
- Operation System
- Threads
---

Thread is not like process. It is created for distributing a job. For process, different processes represent different jobs. This is the essential difference between thread and process. In other words, threads under the same process have the same logic (run the same code segment) while processes are not. 


Therefore, thread creation in Java is using 'Job-Worker' model (encouraged one):

1) Create 'Runnable' object and implement 'run()' method. This step is to define the job.

2) Create a thread object using the Runnable object in above. (new Thread(new MyRunnable())). This step is to create a worker. 


BTW, the details and another thread creation way (implementing 'run()' of Thread interface) are illustrated at: http://blog.csdn.net/firehotest/article/details/52835716


From the memory perspective, thread does not has its own memory space. Threads under the same process share the memory space of the process. Different processes have different memory spaces. 


From the instrinct of sharing memory space, we need to think about the following aspects: 

1) What does the memory space contains? What does this means in Java?

2) What is the pros and cons compares to process? (kernal or not)

3) How can we coordinate the threads? (locks, wait & notify, thread.join(), etc)

4) Classic application case: Producer & Consumer. 


I. What does it means?
----

A process is represented by a class in Java. In a public class, we can define a static main function which is actually the main thread. 


For a memory content of a process, we can see we have following things: 

1) Data (static variables)

2) Stack (method temporary variables)

3) Heap (description and instant variables values)

4) Code (cinit, init and others methods byte codes)


Typically, those are what we have for a class in Java. Therefore, for those threads which share the same memory space of a particular process, they shared Data, Heap and Codes. 


They share codes therefore they have the same logics. However, they may need to change the values of variables in Data and Heap. In order to achieve and make sure the correctness, we need to perform some kind of 'protection' on the data in Heap and Data. 


Another thing worth noticing is, although they don't share the variables of stack (e.g. the iterative variable in for loop), and each thread has its own copy of stack variables, we still need to know there is not any protection for their stack variables. Another thread, if it wants, can modify this thread's stack variable. Although this is not allowed in Java, but if we use C, we can use trick of 'stack frame overflow' to modify the other thread's stack frame's content. 


For details of how the code section like: http://blog.csdn.net/firehotest/article/details/52747964


II.  What is the pros and cons?
------

The most positive charactristic of thread is its 'agile'. Of course, agile can only be used to describe those user level threads. Kernal level threads are similar to processes. I would like to call them 'heavy machines'. Because the switch operation between them needs an interruption and kernal call. The expense of kernal call is very high; therefore, sometimes if we don't take such expense into account and use multi-threads blindly, we will achieve a worse efficiency outcome. 

Now, you may ask, if the user level thread has the efficient switch benefit, why do we need the kernal level thread? The answer is: the kernal ones can run on different cores in order to achieve real parallelism while the user level ones can only run on the same core and achieve 'fake' parallelism using pineline technology. 

For the detailed comparison, you can turn to following:

```
线程实际上分为两类：用户级线程（User Level）和内核级线程 (Kernal Level)。只有内核级线程是真正的分核运行的，

用户级线程操作系统的根本不可见的。对于这类线程，有关线程管理的所有工作都由应用程序完成，内核意识不到线程的存在。在应用程序启动后，操作系统分配给该程序一个进程号，以及其对应的内存空间等资源。应用程序通常先在一个线程中运行，该线程被成为主线“程。在其运行的某个时刻，可以通过调用线程库中的函数创建一个在相同进程中运行的新线程。 用户级线程的好处是非常高效，不需要进入内核空间。

内核级线程的管理工作由内核完成，应用程序没有进行线程管理的代码，只能调用内核线程的接口。内核级线程的好处是，内核可以将不同线程更好地分配到不同的CPU，以实现真正的并行计算。
```

III. Coordination Techniques
----

This part I going to illustrate the command techniques under the context of Java. I am going to talk about following areas:

3.1 Locks from different perspectives. 
-----

You can refer to this blog to see the details: http://blog.csdn.net/firehotest/article/details/78431938

Generally, we can classify the locks into: mutex, semaphore, read/write lock and spinning lock. 

Also, we can classify them from following perspectives: 1) Share/Exclusive (read/write), 2) Reentrant Lock, 3) Fair/Unfair Lock, 4) Optimistic/Pessimistic Lock

3.2 Object.notify() and Object.wait() 让线程交替运行
-----

Talking about wait and notify methods, we must understand the difference between wait() and sleep(). 

Wait() will let the current thread enter a state of waiting for other threads notify it and <b>give up all the locks it has</b>. 

```
Thread.sleep(int ms)和Object.wait()的区别：

对于thread类，有一个类成员方法是sleep(int ms)，让一个线程休眠（阻塞）一段时间，以ms为单位。但其不证明其休眠刚刚好是对应数字的时间，因为当对应的时间结束后，其进入了就绪状态，等待着JVM的调用。

而对应Object.wait()的作用也是让调用它的线程进入休眠。其也可以指定一个时间让它醒过来，也可以不指定，通过别人线程调用notify()或者notifyAll()来唤醒它。但是就算指定一个时间，也能被notify()或者notifyAll()提前唤醒。

那么两个休眠有什么不同呢？

1）前者是没有意义的阻塞，纯粹就是让它安静一会；后者则是大多数为了等待另外一个线程准备好其要资源，再起来继续工作；
2）所以，来到了最大的不同了：sleep的进程不会释放同步锁，所以，如果一个线程进入了一个同步方法或者一个同步代码块，在块内调用sleep()了，则在它休眠的时间内，其它的线程不会进入对象级别的同步的所有代码块或者方法。但是，调用wait()则不同了，线程会释放掉同步锁，让其它进程能进入其它的或者当前的对象级别的代码块或者方法内部继续执行。
```

Then, we need to understand that notify and wait must be used with synchronized in order to work well. Here is the example: 

```Java
/**
 * A 1, B 1, B 2, B 3, A 2, A 3
 */
private static void demo3() {
    Object lock = new Object();
    Thread A = new Thread(new Runnable() {
        @Override
        public void run() {
            synchronized (lock) {
                System.out.println("A 1");
                try {
                    lock.wait();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                System.out.println("A 2");
                System.out.println("A 3");
            }
        }
    });
    Thread B = new Thread(new Runnable() {
        @Override
        public void run() {
            synchronized (lock) {
                System.out.println("B 1");
                System.out.println("B 2");
                System.out.println("B 3");
                lock.notify();
            }
        }
    });
    A.start();
    B.start();
}
```

Result is as followed:

```
A 1
A waiting…
 
B 1
B 2
B 3
A 2
A 3
```

3.3 Thead.join() 让一个线程等另外一个线程结束才运行
-----

Join can easily schedule two threads running priority. However, its constraint is we must let one thread finish first then only with the first thread completion, should the other thread begins. Also, it can be useful only if you have exactly two threads. 

Here is the example: 

```Java
private static void demo2() {
    Thread A = new Thread(new Runnable() {
        @Override
        public void run() {
            printNumber("A");
        }
    });
    Thread B = new Thread(new Runnable() {
        @Override
        public void run() {
            System.out.println("B 开始等待 A");
            try {
                A.join();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            printNumber("B");
        }
    });
    B.start();
    A.start();
}
```

Result is as followed: 

```
B 开始等待 A
A print: 1
A print: 2
A print: 3
 
B print: 1
B print: 2
B print: 3
```

3.4 CountdownLatch() 让线程D在A、B、C都同步运行完之后，才能运行
-----

Latch in chinese is '门栓'. Therefore, 'CountdownLatch()' is setting a latch which is on when the counter does not equal to 0. As soon as the counter becomes zero, the thread with CountdownLatch.await() in its run method will start working. 

Don't forget, the other threads should use CoungdownLatch.countdown() to decrement the counter. 

Please notice that await() and countdown() are instant methods. 

Here is an example: 

```Java
private static void runDAfterABC() {
    int worker = 3;
    CountDownLatch countDownLatch = new CountDownLatch(worker);
    new Thread(new Runnable() {
        @Override
        public void run() {
            System.out.println("D is waiting for other three threads");
            try {
                countDownLatch.await();
                System.out.println("All done, D starts working");
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }).start();
    for (char threadName='A'; threadName <= 'C'; threadName++) {
        final String tN = String.valueOf(threadName);
        new Thread(new Runnable() {
            @Override
            public void run() {
                System.out.println(tN + "is working");
                try {
                    Thread.sleep(100);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                System.out.println(tN + "finished");
                countDownLatch.countDown();
            }
        }).start();
    }
}
```

The result is:

```
D is waiting for other three threads
A is working
B is working
C is working
 
A finished
C finished
B finished
All done, D starts working
```

3.5 CyclicBarrier类 让多个线程同时做准备工作，等全部线程都就绪后再一起开始
-----

CyclicBarrier makes every target threads do their ready phase independently. However, they must wait until each other finishes ready phase before they start their working phase. 

先创建一个公共 CyclicBarrier 对象，设置 同时等待 的线程数，CyclicBarrier cyclicBarrier = new CyclicBarrier(3);
这些线程同时开始自己做准备，自身准备完毕后，需要等待别人准备完毕，这时调用 cyclicBarrier.await(); 即可开始等待别人；
当指定的 同时等待的线程数都调用了 cyclicBarrier.await();时，意味着这些线程都准备完毕好，然后这些线程才同时继续执行。

Here is the example: 

```Java
private static void runABCWhenAllReady() {
    int runner = 3;
    CyclicBarrier cyclicBarrier = new CyclicBarrier(runner);
    final Random random = new Random();
    for (char runnerName='A'; runnerName <= 'C'; runnerName++) {
        final String rN = String.valueOf(runnerName);
        new Thread(new Runnable() {
            @Override
            public void run() {
                long prepareTime = random.nextInt(10000) + 100;
                System.out.println(rN + "is preparing for time:" + prepareTime);
                try {
                    Thread.sleep(prepareTime);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                try {
                    System.out.println(rN + "is prepared, waiting for others");
                    cyclicBarrier.await(); // 当前运动员准备完毕，等待别人准备好
                } catch (InterruptedException e) {
                    e.printStackTrace();
                } catch (BrokenBarrierException e) {
                    e.printStackTrace();
                }
                System.out.println(rN + "starts running"); // 所有运动员都准备好了，一起开始跑
            }
        }).start();
    }
}
```

Here is the result: 

```
A is preparing for time: 4131
B is preparing for time: 6349
C is preparing for time: 8206
 
A is prepared, waiting for others
 
B is prepared, waiting for others
 
C is prepared, waiting for others
 
C starts running
A starts running
B starts running
```
