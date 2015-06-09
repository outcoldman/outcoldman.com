---
layout: post
title: "Good bye outcoldplayer."
date: 2015-06-08 00:00:00 -00:08:00
categories: en
tags: [outcoldplayer, Windows, Windows Store, Windows RT, Google Music]
---

It is a time to say good bye to *outcoldplayer*. Google finally deprecated `ClientLogin` API (see [
ClientLogin for Installed Applications](https://developers.google.com/identity/protocols/AuthForInstalledApps)) on May 27, 2015. After this date all calls to the `ClientLogin` returns 404 (Not Found).

I know that some other application already solved this problem by pretending to be Android applications. I have reasons to not do that:

1. Sorry, but I lost interest in developing this application. I am busy at main job with interesting projects. I'm not making a lot from this application, usually it just covers the time I spend on this application. Before it was just fun, but see next points...
2. I do not use Google Music anymore.
3. Supporting this application is hard. There is always something that breaks application: Windows Updates, Google API changes, Drivers.
4. Using Android API to fix this issue means that Android API has been reverse engineered. In most applications you can find sentence *Do not reverse engineer my app*.

I already removed application from Windows Store. No need to ask me for it. If it still works for you - it will not last long. It works for you until Google Session is not expired, but it will expire. After that you will not be able to re-login to *outcoldplayer*. In next month I'm going to delete the website https://outcoldplayer.uservoice.com and delete Twitter account @outcoldplayer.

If you purchased application in last N days (maybe 30 days) - you can ask Windows Store for refund. I do not know how to do that, but I have heard that people could do that.

And most important. The life of *outcoldplayer* can continue. I was asked to open source this application, but I'm not going to do that, because of stories, like this one [https://github.com/venomous0x/WhatsAPI](https://github.com/venomous0x/WhatsAPI). But, this is what I can propose:

1. I can sell sources to somebody. If you are interesting - let me know.
2. If you are indie developer and don't have money to purchase the sources, this is ok. I can share them with you, and you can fix application, re-brand it, submit it to the Windows Store and share some profit with me for the next X years/months.
3. You like this application and think that it should be open sourced? I'm ok with this. I can share sources with you. You can fix application, submit it as free to the Windows Store and open source it on github.

To make (2) or (3) work you need to give me some proof that you have experience in building Windows Store application and you are capable to maintain it.

I really appreciate support I got from users, who submitted bugs, helped me to diagnose them and who donated money to this application. Thank you all!
