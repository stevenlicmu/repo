---
title: 'SQL Notes: Multi-table Query'
date: 2017-09-18 20:28:54
tags: SQL
categories: Techniques
---

这篇文章简单讲述跨表格Query的语法。总体而言，跨表格的表达方式有两种：

1 在WHERE条件当中，通过Qualified的（前面加了表格名.）的列之间的条件（等式或者不等式）来表达；

2 在FROM条件当中，通过显示的关键词JOIN来表达。而通过关键词JOIN则分为：

1) INNER JOIN

表示等式关系的JOIN，分为：
NATURAL JOIN, JOIN USING(只有等式关系能用)以及JOIN ON（必须用的情况有两种：不等式关系中用，JOIN的两个等式关系的列的名字不同的情况，然而在名字相同的情况下也可以用。所以JOIN ON的通用水平更高）

2) 不等式关系的JOIN ON;

3) OUTER JOIN(LEFT JOIN, RIGHT JOIN, FULL JOIN); 

4) SELF JOIN. 

5) 还有一个很不常用也没有实际意义的Cartesian Product JOIN，这里忽略不介绍。

总体而言，一句话总结，JOIN ON可以用于等于或者不等于。JOIN USING只能用于等于且同名。JOIN ON和JOIN USING都能在Self Join和Outer Join里面用。所以，一般建议用JOIN ON。

3 介绍一下多个tables JOIN的情况如何理解。

```SQL
SQL> SELECT lastname, firstname, title
FROM customers JOIN orders USING (customer#)
JOIN orderitems USING (order#)
JOIN books      USING (ISBN)
ORDER BY lastname, firstname;
```

怎么理解呢？等价于下面的代码：

```SQL
SQL> SELECT lastname, firstname, title 
FROM customers, orders, orderitems, books 
WHERE customers.customer# = orders.customer# 
AND orders.order# = orderitems.order#
AND orderitems.ISBN = books.ISBN
```

可见，最后的逻辑关系是想从customers跨到books。然而，可能一开始无法直接跨过去，所有要跨过多个tables. 

下面将按照等式关系、不等式关系以及OUTER JOIN来详细介绍语法。SELF JOIN最后将做简单介绍。

## 一、Equality

等式关系的是最常用的跨表格查询关系。在Cloud Computing的课上曾经学过这么一个概念：Star - Schema. 参考我的旧博客网址：http://blog.csdn.net/firehotest/article/details/50990402

利用Star - Schema存储数据时，经常会用到等式操作来实现跨表（Fact Table和Dimension Table）查询。

### 1.1 WHERE 条件用法

当SELECT后面的列名可以让SQL清楚辨认属于哪个表的时候，SELECT后的列名可以不用Qualifying. 但是WHERE之后的条件表达需要，原因显而易见，因为不用的话，则出现模糊。

List book title and the name of its publisher

```SQL
SQL> SELECT title, name
FROM   books, publisher
WHERE  books.pubid = publisher.pubid;
```

反之，出现Ambiguity的时候，需要Qualifying. 

```SQL
SQL> SELECT title, books.pubid, name 
FROM   books, publisher 
WHERE  books.pubid = publisher.pubid
```

### 1.2 Natural Join

注意一点，使用natural join时，qualifying key是不被允许的。

用法：

```SQL
SQL> SELECT title, pubid, name 
FROM   books  NATURAL JOIN  publisher;
```
SQL会自己寻找合适的JOIN KEY。 

而以下的用法则会出现错误：

```SQL
SQL> SELECT title, publisher.pubid, name FROM books NATURAL JOIN publisher;

ERROR at line 1:
ORA-25155: column used in NATURAL join cannot have qualifier
```

### 1.3 JOIN USING

JOIN USING只能是在等式关系中使用，且两个表格对应的KEY列的名字必须相等。

```SQL
SQL> SELECT title, pubid, name 
FROM   books  JOIN  publisher USING (pubid);
```

### 1.4 JOIN ON

在等式关系中，列的名字不同的时候，必须要用JOIN ON。 

```SQL
SQL> SELECT title, pubid, name 
FROM   books JOIN publisher  ON  id = pubid;
```
## 二、Non - Equality

### 2.1 WHERE表达

Bookstore offered a weeklong promotion in which customers receive a gift based on the value of each book they purchased.

Determine the gift the customers could receive for any of the books currently represented in the inventory. 

```SQL
SQL> SELECT title, gift 
FROM books, promotion 
WHERE retail BETWEEN minretail AND maxretail;
```

### 2.2 JOIN ON表达

```SQL
SQL> SELECT title, gift 
FROM books JOIN promotion 
ON retail BETWEEN minretail AND maxretail;
```

## 三、Self-Join

注意，Self Join始终需要Qualifying，无论是使用WHERE还是JOIN。并且，由于表名都一样，在FROM子句那里需要为两个表创建Alias. 

Self Join一般是需要用到自己表中两列的关系时，才会用到。譬如：

List customer ID and customer name of those customers who were referred by another customer. Also include the ID and last name of the referring customer.

### 3.1 JOIN ON用法

```SQL
SQL> SELECT c.customer# "#", c.lastname, c. firstname, 
r.customer# "#", r.lastname "Referred By" 
FROM customers c JOIN customers r
ON c.referred = r.customer#;
```

### 3.2 WHERE用法

```SQL
SQL> SELECT c.customer# "#", c.lastname, c.firstname,
r.customer# "#", r.lastname "Referred By" 
FROM customers c, customers r
WHERE c.referred = r.customer#;
```

## 四、Outer Join

Outer Join分为Left Join，Right Join和Full Join. Left Join的意思是，FROM子句后面的两个表格，左边表格的所有内容会被Selected出来。而Right Join则相反。Full Join则两边表格的内容都会被全部Selected出来。

参考：

Outer joins include all rows that are correctly matched plus the rows that do not have a match in the other table. 

Left: all unmatched rows from the table on the left are to be also included

Right: all unmatched rows from the table on the right are to be also included

Full: all unmatched rows from both tables are to be also included

例子：List customer number & name of each customer. For those who placed orders before, show the corresponding order number

### 4.1 JOIN用法 

```SQL
SQL> SELECT customer#, lastname, firstname, order# 
FROM customers LEFT OUTER JOIN orders
USING (customer#)
```

### 4.2 WHERE用法

比较有意思的是Where的用法。(+)所在的位置刚好与left和right相反。left join则在右，right join则在左。

```SQL
SQL> SELECT c.customer#, lastname, firstname, order# 
FROM customers c, orders o
WHERE c.customer# = o.customer#(+)
```
