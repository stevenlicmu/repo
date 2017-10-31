---
title: 'SQL Notes: Single Query'
date: 2017-09-17 10:26:53
tags: SQL
categories: Techniques
---

这篇文章主要focus on讲述select语句的where（条件）和order by（排序）两个字句。顺带讲讲DISTINCT关键词。

## WHERE

### 一、最简单的表达形式

1）包含column name或者column的alias. 
2）具有比较符号，comparison operator.

最简单的条件表达形式，参照上述两点要求：

{% codeblock lang: SQL %}
-- Use column name  
SELECT titile, retail FROM books WHERE retail = 55;  
  
-- Use column names combined expression  
SELECT title, (retail - cost) (AS) profit FROM books WHERE (retail - cost) < 0.2 * cost;  
  
-- Use column alias  
  
SELECT title, (retail - cost) (AS) profit FROM books WHERE profit < 0.2 * cost;
{% endcodeblock %}

条件与条件之间可以组合形成新的条件：NOT, AND, OR. (优先顺序如是)

### 二、用特殊的条件关键词代替比较符号

ANY, ALL, IN, BETWEEN...AND..., LIKE, IS NULL.

这里需要注意的是MAX和MIN不是属于条件表达式的逻辑名词。是Group functions. 要注意区分。

接着，这种特殊的关键词也分两种。

#### 2.1 ANY和ALL是配合比较符使用

##### ANY

ANY是加在比较符之后，数组之前。表示比较符后的数组里的只要有一个元素满足比较关系即可。

ANY is used together with < , > , ≤ , ≥ , = , ~= 
e.g.,
20 < ANY(2,11,25) True 
20 > ANY(2,11,25) True 
20 = ANY(2,11,25) False 
20 != ANY(2,11,25) True

和IN之间的逻辑关系：

(=ANY) ≡ IN 
(!=ANY) !≡ NOTIN

例子：

{% codeblock lang: SQL %}
SQL> SELECT customer# || ': ' || firstname || ' ' || lastname
             AS "Customer"
      WHERE  customer# < ANY (1001, 1002, 1003);
{% endcodeblock %}

##### ALL

ALL也是加在比较符之后，数组之前。表示比较符后的数组里要所有元素都满足比较关系。

ALL is used together with < , > , ≤ , ≥ , = , ≠ 
e.g.,
20 < ALL(2,11,25) False 
20 > ALL(2,11,25) False 
20 = ALL(2,11,25) False 
20 ≠ALL(2,11,25) True

( =ALL) ≡/ IN
( ≠ALL) ≡ NOTIN

例子：
{% codeblock lang: SQL %}
SQL> SELECT customer# || ': ' || firstname || ' ' || lastname
             AS "Customer", state
      FROM   customers
      WHERE  state != ALL ('CA', 'FL', 'GA', 'IL', 'NJ');
  Customer                  ST
  ------------------------- --
  1004: THOMAS PIERSON      ID
  1005: CINDY GIRARD        WA
  1006: MESHIA CRUZ         NY
  1007: TAMMY GIANA         TX
  1008: KENNETH JONES       WY
  1012: WILLIAM MCKENZIE    MA
  1014: JASMINE LEE         WY
  1017: BECCA NELSON        MI
{% endcodeblock %}

#### 2.2 IN, BETEEN...AND..., LIKE, IS NULL是代替比较符使用

##### IN

IN的意义是在其之后的数组之中，则返回true，否则返回false。


{% codeblock lang: SQL %}
SQL> SELECT title, pubid
       FROM   books
       WHERE  pubid IN (1,2,5);
TITLE PUBID 
------------------------------ ---------- 
REVENGE OF MICKEY 1 
BUILDING A CAR WITH TOOTHPICKS 2 
E-BUSINESS THE EASY WAY 2 
PAINLESS CHILD-REARING 5 
BIG BEAR AND LITTLE DOVE 5 
HOW TO MANAGE THE MANAGER 1 
SHORTEST POEMS 5
7 rows selected.
{% endcodeblock %}

##### BETWEEN...AND...

{% codeblock lang: SQL %}
-- List book titles falling in the B through D range
SQL> SELECT title
       FROM   books
       WHERE  title BETWEEN 'B' AND 'D';
TITLE ------------------------------
BODYBUILD IN 10 MINUTES A DAY 
BUILDING A CAR WITH TOOTHPICKS 
COOKING WITH MUSHROOMS
BIG BEAR AND LITTLE DOVE
{% endcodeblock %}

##### LIKE

LIKE是匹配其之后的wildcard pattern的。不再是跟着数组。

这里重新回顾SQL的wildcard pattern和Linux的不同。

任意0-n个字符：
SQL: %
Linux: *

任意1个字符：
SQL: _
Linux: .

LIKE一般配合ESCAPE使用。ESCAPE可以指定转义字符。不同于Linux规定‘\’是转义字符，SQL可以自己指定。

Example 1: Find any customer whose last name starts with letter ‘P’

{% codeblock lang: SQL %}
SQL> SELECT lastname
       FROM   customers
       WHERE  lastname LIKE 'P%';
{% endcodeblock %}

Example 2: You have a difficulty reading a report because someone spilled coffee on it. You can only tell the first two digits (‘10’) of the customer# and the last digit (‘9’). The third digit is hard to read. Can you find the customer?

{% codeblock lang: SQL %}
SQL> SELECT customer# || ': ' || firstname || ' ' || lastname
             AS "Customer"
      WHERE  customer# LIKE '10_9';
{% endcodeblock %}

Example 3: List customer number and his/her name of customers with the last name containing ‘MI’ or the first name containing ‘NI’

{% codeblock lang: SQL %}
SQL> SELECT customer# || ': ' || firstname || ' ' || lastname
             AS "Customer"
      WHERE  lastname  LIKE '%MI%'
         OR  firstname LIKE '%NI%';
  Customer
  -------------------------
  1001: BONITA MORALES
  1003: LEILA SMITH
  1013: NICHOLAS NGUYEN
  1019: JENNIFER SMITH
{% endcodeblock %}

Example 4: What is the name of a publisher that hasunderscore character(s) in its name?

{% codeblock lang: SQL %}
SQL> SELECT name
       FROM   Publisher
       WHERE  name LIKE '%\_%' ESCAPE '\';
   NAME
   -----------------------
   ABC_Books
   {% endcodeblock %}

Example 5: 关于单引号(apostrophe)的转义例子。What is the name of a publisher that has underscore character(s) in its name or an apostrophe in the contact’s name?

{% codeblock lang: SQL %}
SQL> INSERT INTO publisher VALUES
2 (7,'XYPublishing','John O''Brian','111-222-3333');
1 row created.
SQL> SELECT name, contact
    FROM   Publisher
    WHERE  contact LIKE '%''%'
       OR  name    LIKE '%^_%' ESCAPE '^';
NAME CONTACT ----------------------- --------------- 
ABC_Books Adam Carter 
XYPublishing John O'Brian
{% endcodeblock %}

##### IS NULL

Example: Find any order that has not been shipped

{% codeblock lang: SQL %}
SQL> SELECT order#, customer#, shipdate  
     FROM orders
     WHERE shipdate IS NULL;
ORDER#  CUSTOMER# SHIPDATE
---------- ---------- ---------
1012 1017
1015 1020
1016 1003
1018 1001
1019 1018
1020 1008
6 rows selected.
{% endcodeblock %}

## ORDER BY

ORDER BY在SQL十分好用。ORDER BY之后只要跟着排序依据的列。按照其排序的重要性依次往后递减。

默认的输出顺序是按照它们insert的顺序排列。

跟在某一个列的列名后面有可能是两个关键词：DESC（默认升序，ASC）或者 NULL FIRST（默认NULL LAST）

注意:

1) Can appear only once, at the end of he whole statement

2) Accepts column names or aliases from the first SELECT statement, or the positional notation

最普通的用法：

{% codeblock lang: SQL %}
SQL> SELECT lastname, firstname, city, state 2 FROM customers
 WHERE state = 'FL' OR state = 'CA'
 ORDER BY state DESC, city;
{% endcodeblock %}

根据SELECT后面的列的次序：

{% codeblock lang: SQL %}
SQL> SELECT lastname, firstname, city, state 2 FROM customers
 WHERE state = 'FL' OR state = 'CA'
 ORDER BY 4 DESC, 3;
{% endcodeblock %}

根据列的Aliases：

{% codeblock lang: SQL %}
SQL> SELECT lastname L, firstname F, city C, state S 2 FROM customers
 WHERE state = 'FL' OR state = 'CA'
 ORDER BY S DESC, C;
{% endcodeblock %}

根据表达式的计算结果：

{% codeblock lang: SQL %}
SQL> SELECT title, (retail – cost) profit 2 FROM books
 ORDER BY (retail – cost) DESC;
{% endcodeblock %}

使用NULL FIRST：

{% codeblock lang: SQL %}
SQL> SELECT firstname, lastname, state, referred 2 FROM customers
 WHERE state = 'CA'
 ORDER BY referred NULLS FIRST;
 {% endcodeblock %}

## DISTINCT（和UNIQUE一个意思，不过UNIQUE已经被废弃）

{% codeblock lang: SQL %}
 SQL> SELECT DISTINCT category
       FROM   books;
   CATEGORY
   ------------
   COMPUTER
   COOKING
   CHILDREN
   LITERATURE
   BUSINESS
   FITNESS
   FAMILY LIFE
   SELF HELP
   8 rows selected.
 {% endcodeblock %}

## Summary

总体来说，SQL的Select语句用法如下：

{% codeblock lang: SQL %}
SELECT [DISTINCT|UNIQUE] *,
        column [alias], ...
FROM    table [alias], ...
[WHERE  row_condition]
[GROUP BY group_by_expression]
[HAVING   group_condition]
[ORDER BY columns|expressions];
 {% endcodeblock %}