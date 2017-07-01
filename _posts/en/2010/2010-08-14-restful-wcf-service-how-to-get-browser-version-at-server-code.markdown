---
layout: post
title: "RESTful WCF Service – How to get browser version at server code"
date: 2010-08-14 14:55:00
categories: en
tags: [Silverlight, .NET, C#, Internet Explorer 8, PDF, Reports, WCF, RESTful, FireFox]
redirect_from: en/blog/show/215/
---
<p>At our product we have a client Silverlight part and server-code part, which contains a lot of WCF methods. We don’t use ASP.NET Compatible mode, because we want to leave an opportunity to deploy server part to server without web-server role (without IIS). Really, I don’t know why we chose this way, because all of our installations at current moment are on IIS. But we have what we have, so we haven’t ASP.NET Compatible mode, and as an expected result we can’t get <i>HttpContext.Current</i> instance at server WCF methods. One of WCF Service is a <a href="http://msdn.microsoft.com/en-us/magazine/dd315413.aspx">RESTful service</a>, which at his methods returns report files, so it can handle GET-queries from browsers. This is standard code:</p>

```
WebOperationContext context = WebOperationContext.Current;
context.OutgoingResponse.ContentLength = reportBytes.Length;
context.OutgoingResponse.ContentType = "application/pdf";
context.OutgoingResponse.Headers.Set("content-disposition", "attachment;filename=" + fileName);
```

<p>But we got a problem. Some files contain spaces at their names, and different browsers handle these names by their ways. First problem was: if variable filename contains name like “file with spaces.pdf”, then FireFox will show us only “file”, we solved this problem easy, need to surround file name with quotes (Really, I don’t know how many times I have been writing this code and always get the same problems):</p>

```
context.OutgoingResponse.Headers.Set("content-disposition", "attachment;filename=\"" + fileName + "\"");
```

<p>Internet Explorer has his own way to handle filenames with spaces. It replaces spaces with symbol ‘_’. I was trying to solve this problem with this code:</p>

```
filename = HttpUtility.UrlPathEncode(filename);
```

<p>After this line variable <i>filename</i> will has value “filename%20with%20spaces.pdf” and Internet Explorer now saves file with correct name, but FireFox leave %20 instead of spaces. So I need a way to get information at server code which browser asked file. I wrote method <i>IsInternetExplorer</i>:</p>

```
private bool IsInternetExplorer()
{
  WebOperationContext context = WebOperationContext.Current;
  if (context != null)
  {
    string userAgentInfo = context.IncomingRequest.Headers["User-Agent"];
    if (userAgentInfo != null)
      return userAgentInfo.Contains("MSIE");
  }
  return false;
}
```

<p>So I place plug for Internet Explorer in server code:</p>

```
if (IsInternetExplorer())
  filename = HttpUtility.UrlPathEncode(filename);
```

<p>It was a surprise for me, that I couldn’t find a way to get browser version in internet. But I knew that should be the way to get user-agent string from request. At first I wrote realization with OperationContext:</p>

```
private bool IsInternetExplorer()
{
  OperationContext context = OperationContext.Current;
  HttpRequestMessageProperty httpRequest = context.IncomingMessageProperties["httpRequest"] as HttpRequestMessageProperty;
  if (httpRequest != null)
  {
    string userAgentInfo = httpRequest.Headers["User-Agent"];
    if (userAgentInfo != null)
      return userAgentInfo.Contains("MSIE");
  }
  return false;
}
```

<p>But then I remembered about WebOperationContext. I think that WCF is not transparent. I will try in future to learn more about WCF and maybe will try to pass MS exam about WCF. </p>
