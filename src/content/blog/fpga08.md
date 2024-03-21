---
title: FPGA_0x08
author: lancer
pubDatetime: 2024-03-05T14:28:21Z
slug: fpga-08
featured: false
draft: false
tags:
  - Architecture
  - FPGA
  - Verilog
  - Math
  - IP
description:
  "查表法实现 Verilog 复杂数学函数（幂、log、sin、cos）"
---

## Table of Contents


## 1 查找表 LUT

查找表(*Look-Up Table, LUT*)就是一个预先存储好结果的数据表。通过访问这张预先存储好结果的数据表，可以快速的获取不同输入的输出结果。

查找表可以免去运算的过程，尤其对于复杂的运算更是可以大大减少运算开销和运行时间。其缺点就是会消耗过多的系统存储空间（存储空间大小与组合逻辑的输入端口数呈二的整数次幂关系）。

故我们可以使用其他软件计算函数的离散数据，组成查找表信息，以python为例，收集`log`函数信息：

```python
import numpy as np

for i in range(0, 256):
    print('8\': log = {};'.format(
        i,
        np.array(255 * np.log(i / 255), dtype=np.uint8)
    ))

```

## 2 使用查找表




## 参考资料

- [verilog基于查找表的8位格雷码转换 | CSDN](https://blog.csdn.net/cengqiu4314/article/details/134931650)
- [“万能”的查表法 | CSDN](https://blog.csdn.net/Reborn_Lee/article/details/104955374)