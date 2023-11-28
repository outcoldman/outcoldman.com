---
date: "2023-10-18"
tags:
- world
- weird
title: Hey, did you hear about the millibytes?
slug: weird
draft: false
---

This is a weird post. It's not have any intention to be read by anyone. There is no education. There is no information. 
There is no value. It's just a weird post.

My wife and I travel a lot in a motorhome across North America. Every time we hit the road, 90% are highways, and we
have a conversation, we dream. When we will have a real self-driving cars, self-driving motorhomes? But this is a thing,
we have ability to build it and technology, we just don't have it. We don't need AI, we don't need machine learning, we don't need
thousdands of engineers, we just need a rail to guide for 300 miles from point A to point B. That is all. It could be
that simple. Combine what we have learned from the trains and what we have learned from the cars. And we have a self-driving
motorhome. And we can sleep, we can watch movies, we can do whatever we want until we need to get out of the highway,
catch out exit. 

I am software engineer, with some background. Have been doing that for less than most of you, but long enough. PLaying games
in times of DOS Navigator. Earning my first money with C++Builder 6 and went all the way to fancy Go. I have worked
for Microsoft at some point, and a few other large known companies. And I have failed some interviews with some other
companies. I have never wanted to be a manager, I have been a team lead. 

If you are software developer, you are probably frustrated, like I am. With a lot of things. Let's talk about it.

## My top level domain is email for email

Yeah. Straggling with that for almost 10 years. This is not a valid email. Top level domain should not be more than 3 symbols.

I have been using FastMail for a while. And registered `.email` domain for myself a while ago. Getting close to 10 years.
At first, I tried to use sender specific emails. But so many times I was told that I could not have an email address
like `dicksport@myfirstname.mylastname.email`. 

I mean, this is obviously just an uneducated person. But that person stands in front of you. I don't want to make them
uncomfortable. They told me that I cannot have "a corporate name in my email". I don't want to argue.

So I just gave up in a few years. My email is just `[myfirstname]@[mylastname].email`, and backup is `.net`. Still cannot
get a `.com` because somebody wants it for it `$5,000`

## Passkeys are the trend

Sure. But not really. Services want to get all the telemetry on you, they possibly can. You are using a password manager?
You first choise to go throught second factor authentication would be to open their app (LinkedIn, Google, etc), so they
can quickly gather all the information they can from you.


## Millibytes

Hey. Have you heard about the millibytes? What the hell is the millibyte? I don't think anybody can describe anything smaller
than a byte. But they exist. Take a look at [Kubernetes](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#meaning-of-memory)

> Pay attention to the case of the suffixes. If you request 400m of memory, this is a request for 0.4 bytes. Someone who 
> types that probably meant to ask for 400 mebibytes (400Mi) or 400 megabytes (400M).

Ok, so just don't do that. Don't specify millibytes for memory. What is the problem?  The problem is that Kubernetes
can start describing to you in the measurement of [millibytes](https://github.com/kubernetes/kubernetes/issues/94445).

