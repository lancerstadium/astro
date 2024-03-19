---
title: FPGA_0x02
author: lancer
pubDatetime: 2024-03-02T14:17:23Z
slug: fpga-02
featured: false
draft: false
tags:
  - Architecture
  - FPGA
  - Verilog
description:
  "介绍 Verilog 项目入门"
---

## Table of contents

## 1 综合器 & 仿真器

综合器（*Synthesizer*）：当 Verilog 描述出硬件功能后，我们需要综合器对 Verilog 代码进行解释，将代码转化成实际的电路来表示，最终实际的电路，我们称之为网表。Quartus、ISE 和 Vivado 都是综合器，集成电路常用的综合器是 DC。

仿真器（*Simulator*）：在 FPGA 设计的过程中，不可避免会出现各种 BUG。如果我们编写好代码，综合成电路，烧写到 FPGA 后才看到问题，此时去定位问题就会非常地困难。在综合前，我们可以在电脑里对代码进行仿真测试一下，把 BUG 找出来解决，最后才烧写进 FPGA。常用的仿真器是 Modelsim 和 VCS 等。

> 注意：
> 仿真器只是对代码进行仿真验证。至于该电路是否可转成电路，仿真器是不关心的。


## 2 Altera & Xilinx

Altera 的FPGA产品主要包括`Stratix`系列和`Cyclone`系列。`Stratix`系列是其高端产品，提供了更高的性能和功能，适用于需要高性能的应用场景。而`Cyclone`系列则是低成本、低功耗的产品，适用于中小规模的应用。`Altera`的开发软件是 Quartus Prime 。

Xilinx 的FPGA产品主要包括`Virtex`系列和`Artix`系列。`Virtex`系列是Xilinx的高端产品，提供了最高的性能和功能，适用于要求最高性能的应用场景。而`Artix`系列则是低成本、低功耗的产品，适用于中小规模的应用。Xilinx的开发软件是 Vivado 。

完成一个 Verilog 项目，需要使用对应 FPGA 产品的开发软件，创建一个**例程**。


## 3 D触发器

数字电路介绍了多种触发器：JK触发器、D触发器、RS触发器、T触发器等。在 FPGA 中，我们使用的是最简单的触发器——D触发器。

D触发器可以看作一个芯片，拥有四个管脚。三个输入：时钟`clk`、复位`rst_n`、信号`d`，一个输出：信号`q`。

```
              +-------+
              |       |
    d ------> |   D   | ------> q
    clk ----> |       |
              +-------+
                  |
    rst_n --------+

```

其功能为：`rst_n`低电平时，`q`也为低电平；`rst_n`高电平时，再看管脚`clk`，在 clk 由 0 变 1 （上升沿）的时候，，将现在`d`的值赋给`q`。时序逻辑代码如下：

```verilog

always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0) begin
        q <= 0;
    end
    else begin
        q <= d;
    end
end

```

> 注意：
> 1. 在`clk`时钟上升沿的时候，此时变化的信号`q`的值为多少？
> - 我们想一下代码的因果关系。是先有时钟上升沿，这个是因。然后将`d`的值赋给`q`，这个是结果。对于硬件来说，这个“先后”无论是多么地快，也是占有一定时间的，所以`q`的变化会稍后于`clk`的上升沿。故`q`为 0 。但这样画图实在是没累了，而且也没有完成必要，只需掌握这种波形规则。
> 
> 2. 复位信号是在系统开始时刻或者出现异常时才使用，一般上电后就不会再次复位了，可以认为复位是特殊的情况。


## 4 至简设计法

### 4.1 类型一

案例：当收到`en=1`后，`dout`产生一个宽度为 10 个时钟周期的高电平脉冲。

推理：
1. 从功能要求中，看到数字 10，我们就知道要计数，要使用计数器；
2. 10 个是指`dout==1`的次数为 10 个时钟周期，所以该计数器数的是`dout==1`的次数， 因此看到`dout==1`时，计数器就会加 1。

> 计数器原则：
> 1. 初值为零：复位后，计数器一定要为零；
> 2. 最终清零：数到最后时，计数器要清零；


计数器代码：
```verilog

/* cnt */
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt <= 0;
    end
    else if(add_cnt) begin
        if(end_cnt)
            cnt <= 0;
        else
            cnt <= cnt + 1;
    end
end

/* 加一条件 */
assign add_cnt = dout==1;
/* 结束条件 */
assign end_cnt = add_cnt && cnt==10-1;

```

> 注意：
> `add_cnt && cnt==x-1` 表示“数到第`x`个的时候”

设计好计数器 cnt 后，我们就可以设计输出信号 dout 了。该信号有两个变化点：
1. 变 1：是由于收到`en==1`；
2. 变 0：数到了 10 个或者是数完了。

输出信号代码：

```verilog

/* dout */
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        dout <= 0;
    end
    else if(en==1) begin
        dout <= 1;
    end
    else if(end_cnt) begin
        dout <= 0;
    end
end

```

补充 module 的其他部分：`cnt`计数的最大值为 9，需要用 4 根线表示，即位宽是 4 位。`add_cnt`和`end_cnt`都是用`assign`方式设计的，因此类型为 `wire`。`dout`是用`always`方式设计的，因此类型为`reg`。

```verilog
module my_ex1(clk, rst_n, en, dout);
    input clk;
    input rst_n;
    input en;
    output dout;

    reg[3:0] cnt;
    wire add_cnt;
    wire end_cnt;
    reg dout;

    // ... 

endmodule

```


### 4.2 类型二

案例：当收到`en=1`后，`dout`间隔 3 个时钟后，产生宽度为 2 个时钟周期的高电平脉冲。

推理：
1. 出现大于 1 的数字时，就需要计数。这里有连续的数字 2 和 3，建议的计数方式为 5 ；
2. 没有信号明确计数时，补充`flag_add`信号。


计数器代码：补充该信号后，计数器的加 1 条件就变为 `flag_add==1`：
```verilog

/* cnt */
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt <= 0;
    end
    else if(add_cnt) begin
        if(end_cnt)
            cnt <= 0;
        else
            cnt <= cnt + 1;
    end
end

/* 加一条件 */
assign add_cnt = flag_add==1;
/* 结束条件 */
assign end_cnt = add_cnt && cnt==5-1;

```


`flag_add`有 2 个变化点：
1. 变 1：条件是收到`en==1`；
2. 变 0：的条件是计数器数完了。

```verilog

/* flag_add */
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        flag_add <= 0;
    end
    else if(en == 1) begin
        flag_add <= 1;
    end
    else if(end_cnt) begin
        flag_add <= 0;
    end
end

```

`dout`也有 2 个变化点：
1. 变 1 ：条件是“3 个间隔之后”
2. 变 0 ：条件是数完了

```verilog

/* dout */
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        dout <= 0;
    end
    else if(add_cnt && cnt==3-1) begin
        dout <= 1;
    end
    else if(end_cnt) begin
        dout <= 0;
    end
end

```

补充 module 的其他部分：cnt 是用 always 产生的信号，因此类型为 reg。cnt 计数的最大值为 4，需要用 3 根线表示，即 位宽是 3 位。add_cnt 和 end_cnt 都是用 assign 方式设计的，因此类型为 wire。flag_add、dout 是用 always 方式设计的，因此类型为 reg。


```verilog

module my_ex2( clk , rst_n , en , dout );
    input clk; 
    input rst_n; 
    input en; 
    output dout;

    reg[ 2:0] cnt; 
    wire add_cnt; 
    wire end_cnt; 
    reg flag_add; 
    reg dout;

    // ...

endmodule

```