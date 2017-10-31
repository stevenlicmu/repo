---
title: 'SQL Notes: Group Functions'
date: 2017-09-20 20:05:12
tags: SQL
categories: Techniques
---

今天我们来讲一讲Group Function。回顾之前，我们讲了在WHERE子句的条件样式：比较符号 + 列名、比较符号 + ANY或者ALL +（列，名，们）、LIKE + Wildcard, BETWEEN...AND..., IN + (列，名，们), IS NULL. 

多表查询的在WHERE后面qualified的等式或者不等式，JOIN...ON（不等式或者名字不同的等式）和JOIN...USING (等式且名字相同)。LEFT, RIGHT, FULL JOIN的Outer Join。

ORDER BY是整个SQL句式中只能出现一次并只能出现在末尾的句式。ORDER BY后面根据列的排序优先顺序排列。默认的排序方式有两个：1）默认是升序，如果是要按照某一列的降序，则在列名之后添加DESC关键字。2）默认NULL在最后，如果要把NULL排在前面，则需要NULL FIRST关键字。

那么GROUP FUNCTION又是怎么用的呢？可以将它看作是一种post-processing. 

## SQL语句的处理流程

为什么说是post-processing？首先我们来看SQL语句的处理流程：

Step1: FROM 哪些表，有没有JOIN，怎么JOIN

Step2: WHERE的条件是什么，选择哪些row出来

Step3: GROUP BY and
 HAVING 把选择出来的rows怎么组合呈现给用户
 
Step4: SELECT这些rows里面的哪些列给用户看

Step5: ORDER BY怎么给这些rows排序

## 怎么用GROUP BY，什么是HAVING

Group By实质是从筛选剩下的行当中，按照某一列的值作为key去归类。归类之后创建一个新的行。行的内容是SELECT里面的原有列 + SELECT里面用Group Function创建的列。

Group Function的意义是，针对归类后的同一类的行进行统计，结果反映其统计数据。

HAVING对于GROUP BY而言，如何WHERE对于SELECT而言。不同的是，对于Group Function组成的新列的条件必须在HAVING里面表达。而原有列的条件则在WHERE表达。

这里强调一点，如果SELECT之后跟了Group Function组成的心列，在SELECT里面出现的原有列必须在GROUP BY里面出现。GROUP BY的用法类似于ORDER BY，根据优先顺序排列组合的条件。

但反之，GROUP BY里面出现的列名，不需要一定出现在SELECT后面。

**另外提醒一点：** HAVING里面的Group function里面的列，必须是出现在SELECT之后的，否则用不了。并且HAVING后面的Group function，不一定需要出现在SELECT之后。

## 常用的Group Function有哪些

MIN, MAX和COUNT对于任何类型的数据都适用。

SUM, AVG, MEDIAN, STDDEV, VARIANCE对于数值类数据使用。

COUNT是唯一一个会care NULL值的Group Function，其余都忽略NULL值。

## 几个例子

How many books do we have in each book category? Order the result alphabetically.

```SQL
SQL> SELECT category, COUNT(ISBN) 
FROM books
GROUP BY categoryORDER BY category;
```

Find the categories and the average expected profit for those categories that have average expected profit above $15. Sort by the average expected profit in descending order.

```SQL
SQL> SELECT category,
TO_CHAR(AVG(retail-cost),'$990.99') "Profit" 

FROM books
GROUP BY category
HAVING AVG(retail-cost) > 15ORDER BY AVG(retail-cost) DESC;
```
Find the categories and the average expected profit for those categories with average expected profit above $15 for books that were published since January 1st, 2005

```SQL
SQL> SELECT category,
TO_CHAR(AVG(retail-cost),'$990.99') "Profit"

FROM books
WHERE pubdate >= '01-Jan-05'
GROUP BY category
HAVING AVG(retail-cost) > 15;
```

