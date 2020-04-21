//程序运行完成时一定要有输出语句，本工具才能正确展示运行结果。
//console.log("Hello JSRUN! \n\n - from NodeJS .");
function Promise(fn) {
    var state = 'pending';
    var value;
    var deferred = null;
    // var callback = null;
    // this.then = function(cb) {
    // callback = cb;
    // };
    // // resolve的作用可以从这段解释可以了解一二：
    // // * "A promise can be pending wating for a value， or resolved with a value".
    // // * "Once a promise resolve to a value, it will always remain at the value and never resolve again".
    // // 也就是说，promise拿到了value，要resolve value。调用then来获取value必须在resolve value之后才能进行。
    // function resolve(value) {
    // // 直接调用callback(value)时，then函数还没有执行，所以callback是个空
    // //callback(value);
    // // 1秒之后再调用callback，由于此时then函数调用了，为callback赋值了，
    // // 此时callback是个函数，可以被调用了
    // setTimeout(function(){
    // callback(value);
    // }, 1000);
    // }
    // resolve的调用入口有二:
    // 1> 创建Promise的时候传递的回调函数fn，Promise在执行fn时，会将resolve函数作为参数调用fn，
    // 回调函数fn会在合适的时机自己决定resolve的调用。
    // 2> 在链式操作中，第二个promise的触发是在第一个promise的handle中触发的。
    // 标准：resolution procedure是一个抽象操作，该操作以一个promise和一个value作为参数。
    // 如果value是一个thenable(一个对象或函数，定义了一个then方法)，就把value也当成一个promise。
    //
    function resolve(newValue) {
        // 如果在链式操作中then中的onFuifilled返回了一个promise
        if(newValue && typeof newValue.then === 'function') {
            // 继续递归调用resolve，调用的resolve是我们当前的resolve；
            // 当newValue这个promise在完成任务后resolve的时候调用的then的onFuifilled
            // 就是then...,
            // 这里传递resolve就是个递归回调，当对onFuifilled返回的promise进行执行之后，
            // 还会回到这个resolve中，而此时的newValue不再是一个promise，于是走剩下的流程，
            
            newValue.then(resolve);
            return;
        }
        value = newValue;
        state = 'resolved';
        if(deferred) {
            handle(deferred);
        }
    }
    function reject(reason) {
        state = 'rejected';
        value = reason;
        if(deferred) {
            handle(deferred);
        }
    }
    // function handle(onResolved) {
    // // then可以多次调用，可以在promise任何状态调用；
    // // 在pending状态调用时，仅仅将onResolved的保存起来，待进入resolved状态时再调用；
    // // 在其他状态调用时，直接调用onResolved。
    // if(state === 'pending') {
    // deferred = onResolved;
    // return;
    // }
    // onResolved(value);
    // }
    function handle(handler) {
        if(state === 'pending') {
            deferred = handler;
            return;
        }
        var handlerCallback;
        if(state === 'resolved') {
            handlerCallback = handler.onResolved;
        } else {
            handlerCallback = handler.onRejected;
        }
        // 标准：如果onFulfilled不是一个函数，并且promise1进入fulfilled状态，promise2必须以promise1
        // 的value进入fulfilled状态。
        // handler.resolve就是promise2的resolve，value就是promose1的value。
        if(!handlerCallback) {
            if(state === 'resolved') {
                handler.resolve(value);
            } else {
                handler.reject(value);
            }
            return;
        }
        // 标准：如果onFuifilled返回一个value x，执行Promise Resolution Procedure. [[Resolve]](promise2, x)
        var ret = handlerCallback(value);
        // 这里调用handler.resolve是后继promise的resolve。
        // 这里就是将第一个promise的value传递给了第二个promise。
        // 这里就是链式promise沟通的桥梁。
        handler.resolve(ret);
    }
    // // onResolved就是promise.then(onFulfilled, onRejected)中的onFulfilled，
    // // onResolved的第一个参数也就是promise的value。
    // this.then = function(onResolved) {
    // handle(onResolved);
    // };
    // Always remember, inside of then()‘s callback, the promise you are responding to has already resolved.
    // The result of your callback will have no influence on this promise
    this.then = function(onResolved, onRejected) {
        // then方法必须返回一个promise。
        // then返回时创建了一个promise，参数为一个回调函数fn，这个回调函数参数是Promise1自己的resolve函数；
        // 比较奇怪的地方时回调函数fn内部的处理逻辑，一般来说回调函数fn会处理一些和promise不相关的其他事情，
        // 但是这里fn内部居然又调用了promise内部的handle函数。
        // 所以then返回时创建的promise，执行构造函数调用了自己的fn，也就是执行了Promise1的handle({onResolved,resolve})，
        // 而这时执行的handle函数是第一个Promise的handle函数，
        // 如果此时第一个Promise是pending状态，那么{onResolved, resolve}就被保存进第一个Promise的deferred中了；
        // 如果此时第一个Promise是完结状态，就会调用传递进来的onResolved；
        // handle的最后一行然后执行第二个Promise的resolve，然后将value保存进第二个Promise的value中。
        return new Promise(function(resolve, reject) {
                           handle({
                                  onResolved: onResolved,
                                  onRejected: onRejected,
                                  resolve: resolve,
                                  reject: reject
                                  });
                           });
    };
    fn(resolve, reject);
}

function doSomething() {
    // 比较奇怪的地方创建Promise的参数fn，fn是一个带参数的回调函数，Promise在
    // 调用fn的时候会传入一个参数，而这个参数居然也是一个回调函数(一般会传非block的参数)，Promise会将resolve这个
    // 函数当做fn的参数传进去。
    return new Promise(function(resolve, reject) {
                       resolve(100);
                    });
}
doSomething().then(function(value) {
                   console.log('Got a value:' + value);
                   });
doSomething().then(function(value){
                   console.log('Got the same value again:', value);
                   });

