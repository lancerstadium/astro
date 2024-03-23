---
title: Chisel_0x00
author: lancer
pubDatetime: 2023-06-14T14:28:21Z
slug: chisel-00
featured: false
draft: false
tags:
  - Architecture
  - Chisel
description:
  "介绍 Chisel 语言"
---

## Table of Contents

## 1 Scala 介绍

Scala 是一门同时支持命令式、函数式风格的纯面向对象语言，具有高度的伸缩性，且与 Java 兼容。由于 Chisel 以 Scala 语言为宿主，介绍 Chisel 之前我们先来简单了解 Scala 的语法。


### 1.1 Scala 语法

以下是一个 Scala **类**例子：

```scala

class DemoClass (val para: Int) extends FatherClass with DemoTrait {
    // 定义字段
    private var field0 = 0
    val field1 = "hello"

    // 定义方法
    def func0(p: Int): Int = {
        // ...
    }

    // 定义辅助构造器
    def this(val para0: Int, val para1: String) {
        this(para0) // 调用主构造器
        this.field1 = para1
    }
}

// 实例化
val demo0 = new DemoClass(0) // 主构造器
val demo1 = new DemoClass(1, "hello") // 辅助构造器
```

> 注意：
> - val：不可变变量，声明时必须初始化，初始化后不能再赋值。
> - var:可变变量，声明时必须初始化，但是初始化后可以再次赋值。
> - Scala类的定义主体就是主构造器，如上例中的`DemoClass(para:Int)`。Scala类中还可以定义零或多个辅助构造器，函数名为this,返回类型是`Unit`(空)，每个辅助构造器的第一个表达式必须是主构造器或前面已定义的辅助构造器。


**单例对象**：`Object`定义一个单例对象，必须存在同名的类。

**工厂对象**：工厂方法是类中用于创建对象的方法，包含工厂方法的单例对象即为工厂对象。

```scala

class Student(val name:String, val score:Int){
    // ....
}

// 单例
object Student{
    def register(name: String) = new Student(name,0) // 工厂方法1
    def registerWithScore(name:String,score:Int) = new Student(name,score)  // 工厂方法2
}

val stu = Student.register(name)    //使用工厂方法实例化对象


```

传参对象时，默认调用`apply`方法：

```scala
class Student{
    var name = "none"
    var score = 0
    def apply(p0:String,p1:Int) {
        name = p0
        score = p1
        println("Apply method")
    }
}

val stu0 = new Student
stu0("lancer",100)
stu0.apply("lancer",100)

```

技巧：分配内存时不写`new`：

```scala
//      for example
class Student(name:String){
    // ...
}
object Student{     //伴生对象
    def apply(name: String) = new Student(name)     //工厂方法
}

val stu0= Student("alphaGo")

```

继承：`trait` 像是接口。

函数：在 Scale 中是**一等公民**，可作为参数传递，可匿名，可柯里化。

包：Scala 包中可以包含类、对象、函数、Trait等。使用`import`和`package`关键字。

数据结构：

```scala

val v0 = new Array[Int](10) // array
val v1 = ("hello", 32)      // tuple
val v2 = Seq(1, "a")        // seq: tuple++

// mutable collection
import scala.collection.mutable.{ArrayBuffer, Set, Map}
val v3 = ArrayBuffer(1, 2, 3) // mut array
val v4 = Set(1, 2, "ppa")    // mut set
val v5 = Map("a" -> 1, "b" -> 2) // mut map
val v6 = Iterator("a", "b", "c") // iterator
while(v6.hasNext) println(v6.next())

```

**隐式转换**是指将属于某个类的对象自动转换成属于另一个类的对象。其实大多数语言都有隐式类型转换的功能，比如C语言中，一个整数与浮点数相加，编译器检查到类型不匹配后会将整数自动转换为浮点数类型，Scla允许使用者自定义这种转换。

Scala编译器会根据隐式转换函数的签名，对程序中可以作为隐式转换函数参数的对象自动调用隐式转换函数，转换成另一种对像返回，这一过程不需要使用者参与，因此是“隐式”的。隐式转换最核心的是定义隐式转换函数，例如：

```scala
// for example
class Student(val name:String){             
    def introduce(){
        println(s"my name is ${name}")
    }
}
implicit def str2stu(i:String) ={           //定义一个 String 到 Student 对象的隐式隐式转换
    new Student(i)
}

"jiaran".trick()        // 类型不匹配，编译器自动调用隐式转换，print "my name is jiaran"

```


## 参考资料

- [Chisel 入门引导教程 | CSDN](https://zhuanlan.zhihu.com/p/567818196)
