---
title: 'SQL Notes: Single row functions'
date: 2017-09-21 21:12:12
tags: SQL
categories: Techniques
---

Number related functions. Should be remembered. 

MOD(val, num)

```SQL
MOD(52, 15) results in 7
```

Round(n, p)

rounds a numerical value to the stated precision, where
n = the value to be rounded
p = position of the digit to which the value n should be rounded

举例：

```SQL
SQL> SELECT isbn || ': ' || title "Book",
           Retail "Retail Price",
           ROUND(retail, 0) "Rounded Price"
    FROM   books
    WHERE  category = 'COMPUTER';
```

Book       Retail Price Rounded Price

8843172113: DATABASE IMPLEMENTATION 55.95 56

##TRUNC(n, p)
truncates a numerical value to the stated precision, where
n = the value to be truncated
p = position of the digit to which the value n should be truncated

