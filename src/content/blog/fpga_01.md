---
title: FPGA 0x01
author: lancer
pubDatetime: 2024-03-18T11:17:23Z
slug: FPGA-0x01
featured: false
draft: false
tags:
  - Architecture
  - FPGA
  - Verilog
description:
  "介绍 Verilog 的基本语法"
---

## Table of contents

## 1 进制

| 进制 | 二进制 | 十进制 | 十六进制 |
|:---:|:----:|:----:|:----:|
| 示例 | 4'b1100 | 4'd2 | 4'ha |
| 位宽 | 4 | 4 | 4 |
| 符号 | b | d | h |
| 值 | 1100 | 2 | a |


> 逻辑值：
> `0`：表示低电平，对应电路的 GND ；
> `1`：表示高电平，对应电路的 VCC ；
> `x`：表示未知，可能为`1`可能为`0`；
> `z`：表示高阻态，外部没有激励信号，悬空状态。


## 2 数据类型

| 数据类型 | 寄存器型 | 线网型 | 参数型 |
|:---:|:----:|:----:|:----:|
| 示例 | `reg[3:0] cnt` | `wire[15:0] flag` | `parameter a = 4'b0001;` |
| 位宽 | 4 | 16 | 4 |
| 关键字 | `reg` | `wire`, `tri` | `parameter` |
| 用途 | 表示一个抽象的数据存储单元 | 表示结构实体之间的物理连线 | 表示一个常量，通常用于定义数据位宽、状态机的状态、延迟大小等 |
| 赋值 | 定义时不能赋值，默认初始值为`x`，只能在`always`语句和`initial`语句中赋值 | 不能存储值，值由驱动它的元件所决定（驱动线网类型变量的元件有逻辑门、连续赋值语句、`assign`等），如果没有驱动元件连接，则为`z` | 定义时必须赋值 |
| 器件 | 时序逻辑对应触发器，组合逻辑对应硬件连线 | 硬件连线 | 无 |


> 标识符：用于定义模块名、端口名、信号名等。是字母、数字、`$`和`_`的组合，第一个字符不能是数字或`$`，大小写敏感。


## 3 时序逻辑和组合逻辑

组合逻辑电路（*Combinational Logic*）：任意时刻的输出只取决于该时刻的输入，与电路原来状态无关。
时序逻辑电路（*Sequential Logic*）：任何时刻的输出不仅取决于当前的输入，还与电路原来的状态有关，即与之前的输入有关，因此时序逻辑必须具备记忆功能。

## 4 Verilog 程序框架

Verilog 的基本设计单元是**模块**（`module`），一个模块包含四个部分：
1. 端口定义
2. I/O说明
3. 内部信号声明
4. 功能定义


```verilog

/* 模块名称和端口定义 */
module func(a,b,c,d);   
    /* I/O说明 */
    input wire a,b;
    output wire c,d;

    /* 内部信号声明　*/
    reg[3:0] y;

    /* 功能定义　*/
    always @(a or b or c or d)
        begin
            y = {a,b,c,d};
        end

endmodule

```


## 5 Verilog 语句块

Verilog 中的语句包括：
1. `assign`语句：描述组合逻辑，赋值语句。
2. `always`语句：描述组合逻辑或时序逻辑，循环语句。
3. 实例化语句：声明模块`module_name mod_example(a,b,c,d);`
4. 条件语句：必须在过程块（`initial`或`always`引导的语句块）中使用。


> 注意：
> Verilog 不同语句块之间是并行执行的，块内可能是并行也可能是串行。在 Verilog 中语句块的顺序不影响执行结果。


语句块是多条语句组成，一般有如下语句块。

### 5.1 initial 语句块

用于产生仿真测试信号（激励信号），只执行一次，可以用于对存储器赋初值，例如：

```verilog
initial 
    begin
        //使用非阻塞赋值
        sys_clk <= 1'b0;
        sys_rst <= 1'b0;
    end

```

### 5.2 always 语句块

可以由时钟驱动或者电平驱动，死循环。例如：

```verilog
//模拟周期为20ns的时钟信号（50Mhz）
always #10 sys_clk <= ~sys_clk;

//边沿触发，时序逻辑，非阻塞赋值
always @(posedge sys_clk or negedge sys_rst) //敏感列表
    begin
        if(sys_rst)
            counter <= 4'b0000;
        else
            counter <= a;
    end

//电平触发，组合逻辑，阻塞赋值
//如果敏感列表是语句块中等号右边所有变量，可以写成 @(*)
always @(a or b or c)
    begin
        out1 = a ? b : c;
        out2 = c ? a : b;
    end

```

在`always`语句块中有两种赋值方式：非阻塞赋值`non-blocking`和阻塞赋值`blocking`。

1. 阻塞赋值在always语句块中，后面的赋值语句是在前面的语句结束后才开始的，使用`=`，例如：
```verilog
//时钟上升沿到达后，a,b,c的值都为0
always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                a = 2'b01;
                b = 2'b10;
                c = 2'b11;
            end
        else
            begin
                a = 2'b00;
                b = a;
                c = b;
            end
    end
```
2. 非阻塞赋值在always语句块中，在赋值开始时，计算右边的值；在赋值结束时，同时更新左边的值，，使用`<=`，例如：
```verilog
//时钟上升沿到达后，a的值变为0，b的值变为1，c的值变为2
always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                a <= 2'b01;
                b <= 2'b10;
                c <= 2'b11;
            end
        else
            begin
                a <= 2'b00;
                b <= a;
                c <= b;
            end
    end

```

> 注意：
> 1. 非阻塞赋值只能对`reg`型变量进行赋值，因此只能在`initial`和`always`等过程块中使用。 
> 2. 在描述组合逻辑时（`always`敏感信号为电平信号）使用阻塞赋值，在描述时序逻辑时（`always`敏感信号为时钟信号）使用非阻塞赋值。
> 3. 不能在一个`always`块中同时使用阻塞赋值和非阻塞赋值，也不能在多个`always`中对同一个变量赋值。



### 5.3 语句块之间调用

在Verilog中有一个顶层模块（类似C语言的`main`函数），顶层模块可以调用（也叫**例化**）其他模块、IP核（类似于库函数）等，例如：

```verilog
//file1.v
module time_count(clk,rst,flag);
    input clk,rst;
    output flag;
    parameter what = 4'b1000;
    //...
endmodule

//file2.v
module top_module(a,b,c,d);
    input a,b,c;
    output d;
    parameter WHAT = 4'b1111;
    //例化一个time_count模块，注意模块的输出端口必须传入wire型变量
    time_count counter1(.clk(a), .rst(b), .flag(c)); 
    //例化一个time_count模块，模块中what的值被强制修改成了4'b1111
    time_count #(.what WHAT) counter2(.clk(a), .rst(b), .flag(c)); 
    //...

endmodule
```


## 6 状态机

有限状态机（*Finite State Machine, FSM*）简称状态机，指在有限个状态间按一定的规律转换的时序电路，根据输出是否依赖当前输入分为`Mealy FSM`和`Moore FSM`。

```

    Mealy FSM: 

   +---------- <Input>              <clk>
   |              |                   |
   | +> [Combinational Logic: F]      |
   | |            |                   |
   | |     <Incentive Signal>         |
   | |            |                   |
   | |     [Status Register] <--------+
   | |            |
   | +---- <Current Status>
   |              |
   +--> [Combinational Logic: G]
                  |
               <Output>


    Moore FSM: 

               <Input>              <clk>
                  |                   |
     +> [Combinational Logic: F]      |
     |            |                   |
     |     <Incentive Signal>         |
     |            |                   |
     |     [Status Register] <--------+
     |            |
     +---- <Current Status>
                  |
       [Combinational Logic: G]
                  |
               <Output>


```

状态寄存器（*Status Register*）由一组触发器组成，由来记忆状态机当前所处的状态，状态的改变只发生在时钟的跳变沿。状态是否改变以及如何改变，取决于组合逻辑F的输出，F是当前状态和输入信号的函数。


状态机的输出（*Output*）由组合逻辑G提供，在Mealy状态机中，G依赖于当前状态和输入，而在Moore状态机中，G只依赖于当前状态。

### 6.1 状态机设计四段论

1. **定义状态空间**：列举所有可能出现的状态，定义存储当前状态和下一个状态的寄存器。

```verilog
//定义状态空间，编码方式可以是one-hot, binary
parameter A = 2'b00;
parameter B = 2'b01;
parameter C = 2'b10;
parameter D = 2'b11;
//存储状态的寄存器
reg[1:0] current_state;
reg[1:0] next_state;

```


2. **状态跳转**：在时钟跳变沿进行当前状态的跳转。

```verilog
always @(posedge clk or negedge rst) begin
    if(!rst)
        current_state <= A;
    else
        current_state <= next_state;
end

```


3. **下一个状态的判断**：根据当前状态和输入决定下一个状态是什么。

```verilog
always @(current_state or input_signal) begin
    case(current_state)
        A: begin
            if(input_signal)
                next_state = B;
            else
                next_state = C;
        end
        B: begin
            if(input_signal)
                next_state = C;
            else
                next_state = D;
        end
        //其他...
        default:
            //...
    endcase
end

```


4. **各个状态下的输出或动作**

```verilog
always @(current_state) begin
    if(current_state == A)
        y = 1'b1;
    else
        y = 1'b0;
end

```
三段式可以在组合逻辑后再增加一级寄存器实现时序逻辑输出：
1. 有效滤去组合逻辑输出的毛刺；
2. 有效进行时序计算与约束；
3. 对于总线形式的输出信号，利于总线数据对齐，从而减小总线数据间的偏移，减小接收端数据采样出错的频率。

## 参考资料

- [verilog-notes | Github](https://github.com/lyp365859350/Verilog/blob/master/Notes.md)