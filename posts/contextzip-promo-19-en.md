---
title: "Java Spring Stacktraces: Hide the Framework, Keep the Bug"
published: true
description: "Spring Boot stack traces are 80+ lines of framework internals. ContextZip filters them to your application code frames for cleaner AI context."
tags:
  - ai
  - programming
  - productivity
  - opensource
series: "ContextZip Daily"
canonical_url: "https://github.com/jee599/contextzip"
id: 3372455
date: 'draft'
---

A NullPointerException in a Spring Boot controller. Your code has the bug on one line. Spring's stack trace is 80+ lines.

The trace walks through `DispatcherServlet`, `HandlerMethodArgumentResolverComposite`, `RequestMappingHandlerAdapter`, `InvocableHandlerMethod`, and a dozen more framework classes. Your AI reads every one.

## Before: Spring Boot NPE

```
java.lang.NullPointerException: Cannot invoke "String.length()" because "str" is null
    at com.myapp.service.UserService.validateName(UserService.java:42)
    at com.myapp.controller.UserController.createUser(UserController.java:28)
    at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
    at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:77)
    at java.base/jdk.internal.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
    at org.springframework.web.method.support.InvocableHandlerMethod.doInvoke(InvocableHandlerMethod.java:205)
    at org.springframework.web.method.support.InvocableHandlerMethod.invokeForRequest(InvocableHandlerMethod.java:150)
    at org.springframework.web.servlet.mvc.method.annotation.ServletInvocableHandlerMethod.invokeAndHandle(...)
    at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.invokeHandlerMethod(...)
    at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.handleInternal(...)
    at org.springframework.web.servlet.DispatcherServlet.doDispatch(DispatcherServlet.java:1067)
    at org.springframework.web.servlet.DispatcherServlet.doService(DispatcherServlet.java:963)
    at org.springframework.web.servlet.FrameworkServlet.processRequest(FrameworkServlet.java:1006)
    at org.springframework.web.servlet.FrameworkServlet.doPost(FrameworkServlet.java:909)
    at javax.servlet.http.HttpServlet.service(HttpServlet.java:681)
    at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(...)
    at org.apache.catalina.core.ApplicationFilterChain.doFilter(...)
    ... 22 more
```

20+ lines. Two matter.

## After: Through ContextZip

```
java.lang.NullPointerException: Cannot invoke "String.length()" because "str" is null
    at com.myapp.service.UserService.validateName(UserService.java:42)
    at com.myapp.controller.UserController.createUser(UserController.java:28)
💾 contextzip: 2,891 → 214 chars (93% saved)
```

Exception message + your two application frames. 93% reduction. Spring, Tomcat, and JDK internals stripped.

```bash
cargo install contextzip
eval "$(contextzip init)"
```

**GitHub:** [github.com/contextzip/contextzip](https://github.com/contextzip/contextzip)

---

*Part of the [ContextZip Daily](https://dev.to/ji_ai/series/contextzip-daily) series. Follow for daily tips on optimizing your AI coding workflow.*

**Install:** `npx contextzip` | **GitHub:** [jee599/contextzip](https://github.com/jee599/contextzip)
