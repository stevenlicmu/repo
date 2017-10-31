---
title: 'SQL Notes: Advance Query'
date: 2017-09-21 20:59:06
tags: SQL
categories: Techniques
---

CASE WHEN

```SQL
CASE
WHEN...THEN
WHEN...THEN
ELSE
```
用法举例：

```SQL
SQL> SELECT customer#, state,
CASE state
     WHEN 'CA' THEN 0.09
     WHEN 'PA' THEN 0.07
     ELSE 0.00
     END
     AS “Sales Tax Rate”
FROM customers
```

这里的Sale Tax Rate由CASE WHEN决定。这里的用法是CASE WHEN创建一个新的列。

但是，CASE WHEN也可以用在UPDATE的SET里面。例子：

```SQL
UPDATE salary
SET
    sex = CASE sex
        WHEN 'm' THEN 'f'
        ELSE 'm'
    END;
```

## MySQL Characteristic

1) In MySQL, there is not INTERSECT and MINUS key words. If you want to realize MINUS, you should write the following pattern:

```SQL
SELECT salesperson.name
FROM salesperson
WHERE salesperson.sales_id NOT IN
(
SELECT salesperson.sales_id
FROM salesperson JOIN orders USING(sales_id)
                 JOIN company USING(com_id)
WHERE company.name = 'RED'
)
```

2) MySQL does not have ANY and ALL key words. Therefore, the SQL code segment above must use NOT IN. 

3) MySQL has a special way to deal with NULL values. ySQL uses three-valued logic -- TRUE, FALSE and UNKNOWN. Anything compared to NULL evaluates to the third value: UNKNOWN. That “anything” includes NULL itself! That’s why MySQL provides the IS NULL and IS NOT NULL operators to specifically check for NULL.

Based on the statement above, when we want to include NULL values into our final result, please REMEMBER to add check NULL values criterias into the criterias sub-sentence. 


