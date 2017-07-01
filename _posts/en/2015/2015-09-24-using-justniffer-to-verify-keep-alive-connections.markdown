---
layout: post
title: "Using justniffer to verify Keep-Alive connections"
categories: en
tags: [golang, http, justniffer, sniffer, profiler]
---

When you perform a lot of sequential requests to the same HTTP server it is good
to check that your HTTP client is reusing connections if server supports that.
If you don't know what is the benefit of persistent connection I highly
recommend to read [High Performance Browser Networking](http://shop.oreilly.com/product/0636920028048.do).

Week ago I was working on [Splunk logging driver for Docker](https://github.com/docker/docker/pull/16488)
and because I do not have a [lot of experience]({{site.url}}/en/archive/2015/07/07/my-experience-with-golang)
with golang I wasn't sure if logger was reusing connection or not.

Documentation for [http package](https://golang.org/pkg/net/http/) says

> For control over proxies, TLS configuration, keep-alives, compression,
> and other settings, create a Transport

Also looking on [func (*Client) Do](https://golang.org/pkg/net/http/#Client.Do)

> Callers should close resp.Body when done reading from it.
> If resp.Body is not closed, the Client's underlying RoundTripper
> (typically Transport) may not be able to re-use a persistent TCP connection
> to the server for a subsequent "keep-alive" request.

Does it mean that next code is reusing HTTP connections?

```go
// jsonBuffer := ...
tr := &http.Transport{}
client := &http.Client{Transport: tr}
req, err := http.NewRequest("POST", http://example.com", jsonBuffer)
if err != nil {
    panic(err)
}
res, err := client.Do(req)
if err != nil {
    panic(err)
}
if res.Body != nil {
    defer res.Body.Close()
}
// Only if status is not Ok - read the body
if res.StatusCode != http.StatusOK {
    var body []byte
    body, err = ioutil.ReadAll(res.Body)
    if err != nil {
        panic(err)
    }
    fmt.Println("Failed to send: %s", body)
}
```

I thought that is should because *(a)* I use transport *(b)* I close body.
But how to be sure? This is where traffic sniffers can help. I used
[Justniffer](http://justniffer.sourceforge.net)

```
justniffer -i lo -p "port 8088" --log-format='%newline---%newline%connection - %connection.time%newline%newline%request%newline%newline%response'
```

Where

- `-i lo` - show only traffic on localhost interface
- `-p "port 8088"` - show only traffic on port 8088
- `--log-format='...'` - show logs in specific format, most important is
    information about connections `%connection` and `%connection.time`

After I run my tests I have found that each connection was unique, even when
I see that server returns `Connection: Keep-Alive`

```
unique - 0.000042

POST /services/collector/event/1.0 HTTP/1.1
Host: localhost:8088
User-Agent: Go 1.1 package http
Content-Length: 319
Authorization: Splunk 176FCEBF-4CF5-4EDF-91BC-703796522D20
Accept-Encoding: gzip

{"event":{"line":"172.18.42.1 - - [25/Sep/2015:02:56:34 +0000] \"GET / HTTP/1.1\" 200 612 \"-\" \"curl/7.35.0\" \"-\"","containerId":"8ebc0131b5e5a74556eecd7007471f659eda1ebed00d5769aa8116c31d92cc45","source":"stdout"},"time":"1443149794.239578","host":"089eba440133","source":"mysource","sourcetype":"myownsourcetype"}

HTTP/1.1 200 OK
Date: Fri, 25 Sep 2015 02:56:34 GMT
Content-Type: application/json; charset=UTF-8
X-Content-Type-Options: nosniff
Content-Length: 27
Connection: Keep-Alive
X-Frame-Options: SAMEORIGIN
Server: Splunkd

{"text":"Success","code":0}

---
unique - 0.000031

POST /services/collector/event/1.0 HTTP/1.1
Host: localhost:8088
User-Agent: Go 1.1 package http
Content-Length: 319
Authorization: Splunk 176FCEBF-4CF5-4EDF-91BC-703796522D20
Accept-Encoding: gzip

{"event":{"line":"172.18.42.1 - - [25/Sep/2015:02:56:36 +0000] \"GET / HTTP/1.1\" 200 612 \"-\" \"curl/7.35.0\" \"-\"","containerId":"8ebc0131b5e5a74556eecd7007471f659eda1ebed00d5769aa8116c31d92cc45","source":"stdout"},"time":"1443149796.872861","host":"089eba440133","source":"mysource","sourcetype":"myownsourcetype"}

HTTP/1.1 200 OK
Date: Fri, 25 Sep 2015 02:56:36 GMT
Content-Type: application/json; charset=UTF-8
X-Content-Type-Options: nosniff
Content-Length: 27
Connection: Keep-Alive
X-Frame-Options: SAMEORIGIN
Server: Splunkd

{"text":"Success","code":0}
```

Which was not what I expected. Fix was [very simple](https://github.com/golang/go/issues/5645)
(it is by design).
I just need to always read whole body before closing it, one of the way to do
that is to read to */dev/null*

```go
io.Copy(ioutil.Discard, res.Body)
```

After that I saw exactly what I wanted

```
start - 0.000020

OPTIONS /services/collector/event/1.0 HTTP/1.1
Host: localhost:8088
User-Agent: Go 1.1 package http
Accept-Encoding: gzip



HTTP/1.1 200 OK
Date: Fri, 25 Sep 2015 03:02:40 GMT
Allow: POST,OPTIONS
Content-Type: text/plain; charset=UTF-8
X-Content-Type-Options: nosniff
Content-Length: 0
Connection: Keep-Alive
X-Frame-Options: SAMEORIGIN
Server: Splunkd



---
continue - -

POST /services/collector/event/1.0 HTTP/1.1
Host: localhost:8088
User-Agent: Go 1.1 package http
Content-Length: 319
Authorization: Splunk 176FCEBF-4CF5-4EDF-91BC-703796522D20
Accept-Encoding: gzip

{"event":{"line":"172.18.42.1 - - [25/Sep/2015:03:02:43 +0000] \"GET / HTTP/1.1\" 200 612 \"-\" \"curl/7.35.0\" \"-\"","containerId":"c56c85b5dbcf410702923261ba3d062fe9a9879c174392362e85467476b0591c","source":"stdout"},"time":"1443150163.
012017","host":"089eba440133","source":"mysource","sourcetype":"myownsourcetype"}

HTTP/1.1 200 OK
Date: Fri, 25 Sep 2015 03:02:43 GMT
Content-Type: application/json; charset=UTF-8
X-Content-Type-Options: nosniff
Content-Length: 27
Connection: Keep-Alive
X-Frame-Options: SAMEORIGIN
Server: Splunkd

{"text":"Success","code":0}
```

First request started connection and all following requests reuse it.
