---
title: 'SQL Notes: Set Operations'
date: 2017-09-19 22:52:21
tags: SQL
categories: Techniques
---

集合运算符在SQL当中，是针对两个SELECT出来的结果进行集合操作的。然而，使用集合操作的前提是这两个集合的列的数量和类型必须一致。注意，是两者必须一致，是数量和类型，名字可以不一致。

集合运算的优先级是出现的顺序从左到右，内部不划分优先级。如果需要指定，则可以使用括号。

集合运算有以下四种：

UNION(并集，去重)
UNION ALL（并集，不去重）
INTERSECT（交集，去重）
MINUS（减集，去重）

##用法展示


List author ID, and name for authors of books thatUnion Compatibility are in either family life or children categories

```SQL
SELECT authorid, fname, lname
FROM books JOIN bookauthor USING (isbn)
           JOIN author USING (authorID)
WHERE catergory = 'FAMILY LIFE'
(UNION/ INTERSECT/ UNION ALL/ MINUS)
SELECT authorid, fname, lname
FROM books JOIN bookauthor USING (isbn)
           JOIN author USING (authorID)
WHERE catergory = 'CHILDREN'
```
