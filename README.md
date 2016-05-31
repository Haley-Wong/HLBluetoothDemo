# HLBluetoothDemo
# 故事
 这是一个悲伤的故事，真的是悲伤逆流成河啊！😂 😂 😂  <br>
本来是同事在做蓝牙打印机的开发，当时他简单分享了一下蓝牙功能开发的流程之后，我把蓝牙开发的步骤捋了捋，顺便拿他做的功能练下手。<br>
本来同事用的是第三方：[Printer](https://github.com/newOcean/printer)，但是这个库代码写的不太好，然后还有不少Bug。最重要的是作者解决问题竟然要收费，我写了这个工具类，在GP58MBIII上运行良好，所以同事就抛弃了那个第三方。 <br>
万万没想到，后来采购的同事采购错了型号，采购了一批GP-58MBIII，在这个型号的打印机上打印要么是打印没反应，要么是打印乱码。然后就是送佛送到西，各种查资料找解决方案，都没能解决匹配问题。<br>
最后看到了这个博客：[博客地址](http://www.cnblogs.com/MrDing/p/5255302.html) 。当时的心情真的是 what the fuck! 买的时候客服没说官方有SDK啊。然后去问客服，客服说不知道有iOS SDK。博主是佳博代理商，本来不买他设备，他也不给SDK,不解决问题的，最后博主仁慈😂，给了一个 V1.0.8的iOS SDK。<br>
但是这时候我们也不想换SDK，而且换起来也麻烦，我也抱着更新这个工具类的想法，去咨询了官方技术支持。技术支持又去咨询佳博集团的开发，最后开发人员说他们有的型号升级了，会自动睡眠，内部也有一些设置。不用他们SDK，不提供技术！ What the fuck! <br>
也有人指出，需要针对不同型号做什么配置，需要跟做打印机内置模块开发的人联调。😞 <br>

最后，如果你们用这个工具类正常连接但是打印没反应或者乱码（有很多用别的品牌、型号打印机的人也都打印没反应或者乱码），可能还需要一些特殊处理。建议先咨询他们售后或者技术支持要SDK。<br>
另外，如果你们有什么关于蓝牙打印机适配的解决方案，欢迎issues我，我还在关注蓝牙打印的资料，希望能解决匹配问题。

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

现添加了预览效果图，因为打印机的字号和字体与iOS的字号、字体有很大偏差，所以预览效果图与实际效果也有些偏差，出入不大，预览仅供参考。

# 效果图

![1.png](https://github.com/Halley-Wong/HLBluetoothDemo/blob/master/HLBluetoothDemo/images/1.png) ![2.png](https://github.com/Halley-Wong/HLBluetoothDemo/blob/master/HLBluetoothDemo/images/2.png)
![03.png](https://github.com/Halley-Wong/HLBluetoothDemo/blob/master/HLBluetoothDemo/images/03.png)
![04.png](https://github.com/Halley-Wong/HLBluetoothDemo/blob/master/HLBluetoothDemo/images/04.png)
![printer.png](https://github.com/Halley-Wong/HLBluetoothDemo/blob/master/HLBluetoothDemo/images/printer.png)

# 使用方式
关于详细的BLE使用方式和打印小票的功能，在[这里有篇文章详细说明](http://www.jianshu.com/p/90cc08d11b5a)

# 附加
附加一个将NSData转换为16进制字符串的方法，因为有人反馈说，同一型号的打印机，有的打印机出来乱码有的正常。
可以在打印前将数据都转换成16进制，与打印机的指令集对比，查找是拼接NSData出错，还是打印机原因。
也可以尝试自己拼接NSData测试打印情况。这里有篇关于蓝牙打印机指令的文章：[打印机指令](http://www.jianshu.com/p/2d624044a27b)
```
- (NSString *)hexStringFromData:(NSData *)printerData{
    
    Byte *bytes = (Byte *)[printerData bytes];
    
    NSString *hexStr = @"";
    for(int i = 0; i < [printerData length]; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        newHexStr = [newHexStr uppercaseString];
        if([newHexStr length]==1) {
            hexStr = [NSString stringWithFormat:@"%@ 0%@",hexStr,newHexStr];
        } else  {
            hexStr = [NSString stringWithFormat:@"%@ %@",hexStr,newHexStr];
        }
    }
    
    NSLog(@"%@",hexStr);
    
    return hexStr;
}
```

demo中也有一个使用的例子<br>

如有使用错误或者更好的建议，请issues我。
