---
title: FPGA_0x03
author: lancer
pubDatetime: 2024-03-03T14:23:43Z
slug: fpga-03
featured: false
draft: false
tags:
  - Architecture
  - FPGA
  - Verilog
description:
  "详解 Verilog 状态机"
---


## Table of contents


## 1 状态机概念

有限状态机（*Finite State Machine, FSM*）是一种能够描述对象在运行周期内的所有**有限状态**，以及从一个状态到另一种状态转换过程的抽象模型。状态机可归纳为4个要素，即现态、条件、动作、次态。
1. 现态：当前所处的状态；
2. 条件：当一个条件被满足，将会触发一个动作，或者执行一次运行状态的变化；
3. 动作：条件满足后执行的动作。动作不是必需的，也可以直接迁移到新状态而不进行任何动作；
4. 次态：条件满足后要跳转到的新状态。其中，“次态”是相对于“现态”而言的，一旦被跳转后，“次态”就转变成新的“现态”了。


## 2 状态机分类

通常情况下，FPGA状态机一般有两种类型：
- Moore型状态机：下一状态只由当前状态决定。
- Meay型状态机：下一状态不但与当前状态有关，还与当前输入值有关。

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

由于Mealy型状态机的输出与输入有关，输出信号很容易出现毛刺，所以一般采用Moore型状态机。


## 3 状态机实现

FPGA状态机的描述方式主要分为3种，分别是一段式、两段式、三段式。

### 3.1 一段式

一段式状态机使用1个`always`块，把状态跳转和寄存器输出逻辑都写在一起，其输出是寄存器输出，无毛刺，但是这种方式代码较混乱，逻辑不清晰，难于修改和调试，应该尽量避免使用。

下面给出一个一段式的Mealy状态机示例：

```verilog

module one_state_machine(
    input clk,
    input rst_n,
    input [1:0] inp,
    output reg outp
);

// 状态
localparam STATE_0 = 2'b00, 
    STATE_1 = 2'b01, 
    STATE_2 = 2'b10,
    STATE_3 = 2'b11;

// 状态寄存器
reg [1:0] state_r;

// 状态转移
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        state_r <= STATE_0;
    else begin
        case(state_r)
            STATE_0: begin
                if(inp == 2'b00) begin
                    state_r <= STATE_0;
                    outp <= 1'b0;
                end else if(inp == 2'b01) begin
                    state_r <= STATE_1;
                    outp <= 1'b1;
                end else if(inp == 2'b10) begin
                    state_r <= STATE_2;
                    outp <= 1'b0;
                end else begin
                    state_r <= STATE_3;
                    outp <= 1'b1;
                end
            end
            STATE_1: begin
                // ...
            end
            STATE_2: begin
                // ...
            end
            STATE_3: begin
                // ...
            end
        endcase
    end
end

endmodule
```

### 3.2 二段式

二段式状态机使用2个`always`块，都是时序逻辑，其中一个`always`:`块用于写状态机的状态跳转逻辑，另一个`always`块用于写当前状态下的寄存器输出逻辑。这种方式逻辑代码清晰，易于调试和理解，是比较推荐的一个方式。

下面给出一个二段式的Moore状态机示例：

```verilog

module two_state_machine(
    input clk,
    input rst_n,
    output reg outp
);

// 状态
localparam IDLE = 2'b00, 
    STATE_1 = 2'b01, 
    STATE_2 = 2'b10,
    STATE_3 = 2'b11;

// 状态寄存器
reg [1:0] state_r;

// 时序逻辑代码块：实现状态跳转逻辑
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state_r <= IDLE;
    end else begin
        case(state_r)
            IDLE: begin
                state_r <= STATE_1;
            end
            STATE_1: begin
                state_r <= STATE_2;
            end
            STATE_2: begin
                state_r <= STATE_3;
            end
            STATE_3: begin
                state_r <= IDLE;
            end
        endcase
    end
end

// 时序逻辑代码块：实现状态输出逻辑
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        outp <= 1'b0;
    end else begin
        case(state_r)
            IDLE: begin
                outp <= 1'b0;
            end
            STATE_1: begin
                outp <= 1'b1;
            end
            STATE_2: begin
                outp <= 1'b0;
            end
            STATE_3: begin
                outp <= 1'b1;
            end
        endcase
    end
end

endmodule

```


### 3.3 三段式

三段式状态机使用3个`always`块，其中一个组合`always`块用于写状态机的状态跳转逻辑，一个时序`always`块用于缓存状态寄存器，另一个`always`块用于写当前状态下的寄存器输出逻辑。这种方式逻辑代码清晰，易于调试和理解，也是比较推荐的一个方式。


```verilog
module three_state_machine(
    input clk,
    input rst_n,
    input [1:0] inp,
    output reg outp
);

// 状态
localparam STATE_0 = 2'b00, 
    STATE_1 = 2'b01, 
    STATE_2 = 2'b10,
    STATE_3 = 2'b11;

// 状态寄存器
reg [1:0] state_r, state_r_n;

// 定义状态寄存器
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state_r <= STATE_0;
    end else begin
        state_r <= state_r_n;
    end
end

// 定义状态转移逻辑
always @(*) begin
    case(state_r)
        STATE_0: begin
            if(inp == 2'b00) begin
                state_r_n = STATE_0;
            end else if(inp == 2'b01) begin
                state_r_n = STATE_1;
            end else if(inp == 2'b10) begin
                state_r_n = STATE_2;
            end else begin
                state_r_n = STATE_3;
            end
        end
        STATE_1: begin
            // ...
        end
        STATE_2: begin
            // ...
        end
        STATE_3: begin
            // ...
        end
    endcase
end

// 定义输出逻辑
always @(*) begin
    case(state_r)
        STATE_0: begin
            outp = 1'b0;
        end
        STATE_1: begin
            outp = 1'b1;
        end
        STATE_2: begin
            outp = 1'b0;
        end
        STATE_3: begin
            outp = 1'b1;
        end
    endcase
end

module

```

> 注意：
> 组合逻辑代码中，if语句和case语句必须写满，否则容易形成latch,导致实际运行出问题。


## 4 状态机编码

### 4.1 独热码 One-hot
独热码（*One-hot*）是一种状态编码方式，其特点是对于任意给定的状态，状态寄存器中只有1位为1，其余位都为0。

使用独热码可以简化译码逻辑电路，因为状态机只需对寄存器中的一位进行译码，同时可用省下的面积抵消额外触发器占用的面积。相比于其他类型的有限状态机，加入更多的状态时，独热码的译码逻辑并不会变得更加复杂，速度仅取决于到某特定状态的转移数量。

此外，独热码还具有诸如设计简单、修改灵活、易于综合和调试等优点。但值得注意的是，相对于二进制码，独热码速度更快但占用面积较大。


```verilog

module state_machine(
    input clk,
    output reg[3:0] state_out
);

// 状态编码：One-hot
localparam STATE_0 = 4'b0001,
    STATE_1 = 4'b0010,
    STATE_2 = 4'b0100,
    STATE_3 = 4'b1000;

// 状态寄存器
reg [3:0] state_r, state_r_n;

// 定义状态寄存器
always @(posedge clk) begin
    if(state_r != state_r_n)
        state_r <= state_r_n;
end

// 定义状态转移
always @(*) begin
    case(state_r)
        STATE_0: state_r_n = STATE_1;
        STATE_1: state_r_n = STATE_2;
        STATE_2: state_r_n = STATE_3;
        STATE_3: state_r_n = STATE_0;
        default: state_r_n = STATE_0;
    endcase
end

// 输出当前状态
assign state_out = state_r;

endmodule

```


### 4.2 格雷码 Gray-code

格雷码（*Gray code*）是一种相邻的两个码组之间仅有一位不同的编码方式。在格雷码中，相邻的两个码组之间仅有一位不同，这种编码方式可以用于实现相邻的两个状态之间只有一位不同的状态机。

FPGA中的状态机通常需要高速运行，因此使用格雷码可以减少状态转换的开销，并提高时序性能。

```verilog
module state_machine(
    input clk,
    output reg[3:0] state_out
);

// 状态编码：Gray-code
localparam STATE_0 = 4'b0000,
    STATE_1 = 4'b0001,
    STATE_2 = 4'b0011,
    STATE_3 = 4'b0010;

// 状态寄存器
reg [3:0] state_r, state_r_n;

// 定义状态寄存器
always @(posedge clk) begin
    if(state_r != state_r_n)
        state_r <= state_r_n;
end

// 定义状态转移
always @(*) begin
    case(state_r)
        STATE_0: state_r_n = STATE_1;
        STATE_1: state_r_n = STATE_2;
        STATE_2: state_r_n = STATE_3;
        STATE_3: state_r_n = STATE_0;
        default: state_r_n = STATE_0;
    endcase
end

// 输出当前状态
assign state_out = state_r;

endmodule
```


### 4.3 二进制码 Binary-code

FPGA状态机可以用普通二进制码表示，不同状态按照二进制数累加表示，是常用的一种方式，仿真调试时，状态显示清晰，易于理解代码。

```verilog
module state_machine(
    input clk,
    output reg[3:0] state_out
);

// 状态编码：Binary-code
localparam STATE_0 = 2'b00,
    STATE_1 = 2'b01,
    STATE_2 = 2'b10,
    STATE_3 = 2'b11;

reg [1:0] state_r, state_r_n;

always @(posedge clk) begin
    if(state_r != state_r_n)
        state_r <= state_r_n;
end

always @(*) begin
    case(state_r)
        STATE_0: state_r_n = STATE_1;
        STATE_1: state_r_n = STATE_2;
        STATE_2: state_r_n = STATE_3;
        STATE_3: state_r_n = STATE_0;
        default: state_r_n = STATE_0;
    endcase
end

assign state_out = state_r;

endmodule

```

### 4.4 码制转换

二进制码：一个`n`位的二进制码可以表示`2n`种状态，它有`2(n-1)`个相邻状态之间只有一位不同。

格雷码：一个`n`位的格雷码可以表示`2^n`种状态，它有`2^(n-1)`个相邻状态之间只有一位不同。

1. 将二进制码转换为格雷码

假设当前的状态用二进制码表示为`B`,那么它所对应的格雷码`G`可以按照以下方式计算得出：

```verilog
assign G = B ^ (B >> 1)
```

其中，`>>`表示右移操作，`^`表示异或操作。具体来说，我们先将`B`右移一位，再与原来的`B`进行异或运算，就可以得到对应的格雷码`G`。


2. 将格雷码转换为二进制码

假设当前的状态用格雷码表示为`G`,那么它所对应的二进制码`B`可以按照以下方式计算得出：

```verilog
assign B = G ^ (G >> 1)
```

与二进制码转换成格雷码的方法类似，`>>`表示右移操作，`^`表示异或操作。具体来说，我们先将`G`右移一位，再与原来的`G`进行异或运算，就可以得到对应的二进制码`B`。

下面给出4位二进制码转换为4位格雷码的示例代码：

```verilog
module bin2gray(
    input [3:0]bin,
    output reg [3:0]gray
);
    always @(*) begin
        gray[0] bin[0];
        gray[1] bin[1] ^ bin[0];
        gray[2] bin[2] ^ bin[1];
        gray[3] bin[3] ^ bin[2];
    end
endmodule

```

> 注意：
> 用来转换格雷码时，如果输入的格雷码不是有效的格雷码，输出的结果将会是无意义的。