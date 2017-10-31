---
title: 'Exception Notes: How to use Exception wisely in Java'
date: 2017-10-30 22:27:36
tags: Exception
categories: Technique
---



'Robustness' is a very important issue in the field of software. Exceptions and its handles help programmer easily enhance their software's robustness. But, this is under the condition that you know how to use exceptions appropriately. 

What do we care when we talk about Exceptions
----

When we talk about exception, we are focus on three areas: 
1) Where; 2) What type; 3) What message. 
In specific, 
1) Where this exception happended; 
2) What type is this exception;
3) What is message this exception brings to us. 


We can use printStackTrace() to get the information for where. We can use a more detailed subclass exception to answer the second issue. Also, we can write a more detailed message when we define this exception to address the third issue.  


In general, there are three principles you need to follow while you are using exceptions. 
1) Throw it early than NullPointerException; 
2) Be specific; 
3) Handle it later. 


Now, let us talk the details of these three principles. 


I. Throw it early than NullPointer
----

NullPointerException is the most ambigous exception. For example, if we have following code segment:

```Java
	public int lenWords(String input) {
      return input.split(" ").length;
	}
```

If pass a null reference as the input, then JVM will throw a NullPointerException but without any useful information. Therefore, we must do something before the JVM throw a NullPointerException. 


The alternative way is to throw a more specific exception earlier with specific message then NullPointerException. 

```Java
	public int lenWords(String input) {
      if (input == null) {
        throw new IllegalArgumentException("Input string cannot be null");
      }
      return input.split(" ").length;
	}
```

II. Be specific
----

Be specific means you use specific classes and write specific message. 


III. Catch it later
----

This part is the most tricky part and also is the most confusing for rookies. 


In order to achieve this requirement, we should apply modular programming all the time. Like MVC framework philosophy, UI should be a module while data process should be another model. Controller should be the one who coordinates both above. 


If an exception is thrown in the data model, it should be controller who catches the exception and handle it properly according to different situation. 


Therefore, we should use 'throws' statement when we define the data process class. Then write 'try...catch...' in the controller. Because controller can have more options to handle the exception. The normal way is to: 1) Set an useDefault in controller; 2) Use controller to call the view part to prompt an UI message to user;

Above is what we mean by catching the exception at higher level and also is the most essential advantage of exception. Never rush to catch the exception during writing codes. 

The most useless thing to do is to printStackTrace. Because this is what JVM does when there isn't any appropriate handler (catch modules). 


Summary
----

In conclusion, you should avoid NullPointer by considering extreme cases and throw appropriate exceptions earlier. Also, throw a specific exception and write detailed message with it. Last but not least, don't forget to perform modular programming and catch the exceptions at a higher level. 








