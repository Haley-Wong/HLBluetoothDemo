# HLBluetoothDemo
# 引言
该项目中包含两个部分的工具类`HLBluetooth` 和`HLPrinter`,蓝牙操作和打印小票功能。<br>

> 如果只是做蓝牙打印机打印小票的功能，可以看我的另一个工程[SEBLEPrinter](https://github.com/Halley-Wong/SEBLEPrinter)

因为系统的蓝牙操作库是用delegate实现的，步骤比较繁多，操作很零散，需要写一堆的代理方法，特别麻烦 <br>
所以我用block方式重写了，蓝牙管理的所有代码在HLBluetooth目录中。<br>
<br>
又因为项目中要用蓝牙控制打印机打印下票，我又把蓝牙打印机的操作封装了一下，所有代码在HLPrinter目录下。<br>

# HLBluetooth介绍
用block改写后，使用大致分为三步：
* 获取蓝牙模块的状态
* 扫描蓝牙外设
* 连接、扫描服务、扫描特性、扫描描述。
因为连接、扫描服务、扫描特性、扫描描述也是属于不同的阶段，所以在block返回时，也有阶段值返回。<br>

~~---------------------------------------------------------------------------------------------------------~~<br>
除了上面这些代理方法改写的block API之外，还有一些操作性方法，
比如：
* 读取特性值
* 读取描述值
* 往特性中写入数据
* 往描述中写入数据
* 读取信号数据
* 取消蓝牙连接
...

以上这些方法也提供block方式和一般的调用方式。<br>
# HLPrinter介绍
蓝牙打印机模板可以打印的格式有单行文字格式、左标题右参数格式、三列数据格式、分隔线、图片、二维码、条形码等。

# 效果图

![1.png](https://github.com/Halley-Wong/HLBluetoothDemo/blob/master/HLBluetoothDemo/images/1.png) ![2.png](https://github.com/Halley-Wong/HLBluetoothDemo/blob/master/HLBluetoothDemo/images/2.png)
![3.png](https://github.com/Halley-Wong/HLBluetoothDemo/blob/master/HLBluetoothDemo/images/3.png)
![printer.png](https://github.com/Halley-Wong/HLBluetoothDemo/blob/master/HLBluetoothDemo/images/printer.png)

# 使用方式
关于详细的BLE使用方式和打印小票的功能，在[这里有篇文章详细说明](http://www.jianshu.com/p/90cc08d11b5a)

demo中也有一个使用的例子<br>

如有使用错误或者更好的建议，请issues我。
