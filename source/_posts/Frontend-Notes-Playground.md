---
title: 'Frontend Notes: Playground'
date: 2017-10-23 22:32:08
tags: Frontends
categories: Technique
---

The reason I use this single post to record the interesting things I discovered in the field of frontend is because I am not an expert of frontend and frontend really needs much time to become an expert of it since it has so many tools and frameworks. 

I would rather to gather them into one post now before I really have time to dig deeper into each of those. 

I. Bootscrap
----

Bootscrap is an open-source beautified html-elements library. It was built by Engineers from Twitter. Really good library. The way to use it is very simple too. 

Step 1: Download the library. Then put it at the webapp folder under maven. You can download it from this site: 

http://how2j.cn/k/boostrap/boostrap-setup/539.html

Step 2: Includes following scripts before you write your html header and body. 

```HTML
<script src="bootstrap/js/jquery/2.0.0/jquery.min.js"></script>
<link href="bootstrap/css/bootstrap/3.3.6/bootstrap.min.css" rel="stylesheet">
<script src="bootstrap/js/bootstrap/3.3.6/bootstrap.min.js"></script>
```

Step 3: Include the 'class=xxx' when you are using the elements. 

For example, here is the way to set up a form

```HTML
<form class="form-inline" action="GetAnlysisData" method="GET">
		  <div class="form-group">
		    <label for="uId">User Id/ Organization Id</label>
		    <input type="text" class="form-control" name="userId" id="uId" placeholder="Input the User Id">
		    <label for="rName">Repo's Name</label>
		    <input type="text" class="form-control" name="repoName" id="rName" placeholder="Input the Repo's name">
		  </div>
		  <button type="submit" class="btn btn-default">Search</button>
		</form>
```

Pay attention to "form-inline". It is different from "form" since it will try its best to put all the things into a line. Also, form group can seperate different meanings input text frames. It helps you organize your input text frames more easily. 

II. JSP
----

Personally speaking, I really like to use JSP file. Due to JSP file, I can easily transfer the data from servlet to front-end pages. 

Based on my understanding, MVC framework should be used in this way:

Servlet receives the request and performs as a central officer who coordinates other parts working together.

Servlet collects parameters from requests and calls models with passing those parameters in order to let models collect and process data. After the models return the results then servlet can pass the result data with servlet APIs. 

Front-end pages can collect the result data using servlet's API when this page is JSP file. 

How to pass the data? Here is the example: 

```Java
// pass the values to result page.
request.setAttribute("wordcount", wordCount);
request.setAttribute("resmap", results);
```

How to collect the data at JSP page?

```HTML
<%Map<String, String> res = (Map<String, String>)request.getAttribute("resmap");%> 

<p>Word Count: <%=(String)request.getAttribute("wordcount")%></p>
```

In JSP, if we add '=' after '<%' it will directly treat it as String and display it. 

If you don't add '=' after '<%' it will just execute the Java sentence. 

By the way, here is the way to dispatch the web page in servlet:

```Java
String nextView = "result.jsp";
    	RequestDispatcher view = request.getRequestDispatcher(nextView);
        view.forward(request, response);
```

III. Use JSP to generate ECharts
----

Now, let's talk about ECharts. If you need to generate charts on your webpage, I would recommend you to use ECharts. ECharts is a very simple but powerful tool that developed by Baidu. Thanks for Baidu. 

You can turn to this page to see how to use it. 

http://echarts.baidu.com/tutorial.html#5%20%E5%88%86%E9%92%9F%E4%B8%8A%E6%89%8B%20ECharts

Here is a simple JSP file I wrote to input the data into ECharts. 

Pay to attention to the file name you downloaded, it may different with mine.

```Java
<html>
<head>
	<meta charset="UTF-8">
	<title>Analysis Result</title>
	<script src="echarts.min.js"></script>
</head>
<body>
	<%Map<String, String> res = (Map<String, String>)request.getAttribute("resmap");%>  
    <div id="main" style="width: 600px;height:400px;"></div>
    <script type="text/javascript">
        var myChart = echarts.init(document.getElementById('main'));
        var option = {
        	    title: {
        	        text: 'Personality Anlysis (Word Count: <%=(String)request.getAttribute("wordcount")%>)'
        	    },
        	    tooltip: {},
        	    legend: {
        	        data: ['Dimension Allocation']
        	    },
        	    radar: {
        	        // shape: 'circle',
        	        name: {
        	            textStyle: {
        	                color: '#fff',
        	                backgroundColor: '#999',
        	                borderRadius: 3,
        	                padding: [3, 5]
        	           }
        	        },
        	        indicator: [
        	           { name: 'Agreeableness', max: 100},
        	           { name: 'Conscientiousness', max: 100},
        	           { name: 'Introversion/Extraversion', max: 100},
        	           { name: 'Emotional range', max: 100},
        	           { name: 'Openness', max: 100},
        	        ]
        	    },
        	    series: [{
        	        name: 'Personality Radar',
        	        type: 'radar',
        	        // areaStyle: {normal: {}},
        	        data : [
        	            {
        	                value : [<%=(int)(Double.parseDouble(res.get("Agreeableness")) * 100)%>, 
        	                		 <%=(int)(Double.parseDouble(res.get("Conscientiousness")) * 100)%>, 
        	                		 <%=(int)(Double.parseDouble(res.get("Extraversion")) * 100)%>,  
        	                		 <%=(int)(Double.parseDouble(res.get("Conscientiousness")) * 100)%>, 
        	                		 <%=(int)(Double.parseDouble(res.get("Conscientiousness")) * 100)%>],
        	                name : 'Personality Attributes'
        	            }
        	        ]
        	    }]
        	};

        myChart.setOption(option);
    </script>
  </body>
</html>
```
