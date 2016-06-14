# HLBluetoothDemo

# 引言
该项目中包含两个部分的工具类`HLBluetooth` 和`HLPrinter`,蓝牙操作和打印小票功能。<br>

> 如果只是做蓝牙打印机打印小票的功能，可以看我的另一个工程[SEBLEPrinter](https://github.com/Halley-Wong/SEBLEPrinter)

因为系统的蓝牙操作库是用delegate实现的，步骤比较繁多，操作很零散，需要写一堆的代理方法，特别麻烦 <br>
所以我用block方式重写了，蓝牙管理的所有代码在HLBluetooth目录中。<br>
<br>
又因为项目中要用蓝牙控制打印机打印小票，我又把蓝牙打印机的操作封装了一下，所有代码在HLPrinter目录下。<br>

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
蓝牙打印机模板可以打印的格式有
* 单行文字格式
```
[printer appendText:title alignment:HLTextAlignmentCenter fontSize:HLFontSizeTitleBig];
[printer appendText:str1 alignment:HLTextAlignmentCenter];
 ```

* 左标题右参数格式
```
[printer appendTitle:@"时间:" value:@"2016-04-27 10:01:50" valueOffset:150];
[printer appendTitle:@"订单:" value:@"4000020160427100150" valueOffset:150];
[printer appendTitle:@"总计:" value:totalStr];
[printer appendTitle:@"实收:" value:@"100.00"];
```

* 三列数据格式
```
[printer appendLeftText:@"商品" middleText:@"数量" rightText:@"单价" isTitle:YES];
[printer appendLeftText:dict[@"name"] middleText:dict[@"amount"] rightText:dict[@"price"] isTitle:NO];
```

* 分隔线
```
[printer appendSeperatorLine];
```

* 图片
```
[printer appendImage:[UIImage imageNamed:@"ico180"] alignment:HLTextAlignmentCenter maxWidth:300];
```

* 二维码
```
[printer appendQRCodeWithInfo:@"www.baidu.com" size:10];
[printer appendQRCodeWithInfo:@"www.baidu.com"];
```

* 条形码
```
[printer appendBarCodeWithInfo:@"123456789012"];
```

# 效果图

![1.png](https://github.com/Halley-Wong/HLBluetoothDemo/blob/master/HLBluetoothDemo/images/1.png) ![2.png](https://github.com/Halley-Wong/HLBluetoothDemo/blob/master/HLBluetoothDemo/images/2.png)
![03.png](https://github.com/Halley-Wong/HLBluetoothDemo/blob/master/HLBluetoothDemo/images/03.png)
![printer.png](https://github.com/Halley-Wong/HLBluetoothDemo/blob/master/HLBluetoothDemo/images/printer.png)

# 使用方式
关于详细的BLE使用方式和打印小票的功能，在[这里有篇文章详细说明](http://www.jianshu.com/p/90cc08d11b5a)
打印机的指令有ASCII、10进制和16进制三种，我使用的是16进制。
```
    Byte QRSize [] = {0x1D,0x28,0x6B,0x03,0x00,0x31,0x43,size}; // 这是16进制，其中最后一个size是10进制数，转换为NSData后，会被转换为16进制。
    Byte QRSize [] = {29,40,107,3,0,49,67,size}; // 这是10进制。
```
# 更新
修复部分型号打印乱码，乱码后再次打印没反应的Bug。（2016-06-13，佳博 Gp-58MBIII和GP58MBIII和芯烨 XPrinter某型号测试通过） 


demo中也有一个使用的例子<br>

如有使用错误或者更好的建议，请issues我。关于蓝牙打印机的问题，也欢迎大家加入群：552735579（iOS蓝牙打印机开发）。
