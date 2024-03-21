---
date: "2024-03-21"
tags:
- vision-pro
- cloudkit
- apple
- vision-os
- icloud
- app store
title: Rapid development with CloudKit public database
slug: cloudkit-development
draft: true
---

This is my second blog about CloudKit Public database. I am sorry, I am just amazed how good it is, and how easy it is to
develop with it. I feel like it is a hidden gem, that a lot of developers are missing.

## 🧑‍💻 User authentication and authorization

First of all, as long as a user is logged in to iCloud, you got your authenticated user. You don't have to do a thing,
only to show a message that the user is not logged in to iCloud, when they are not.

To get the user's recordID, you can use the following code:

```swift
let container = CKContainer(identifier: "iCloud.app.loshadki.MyApp")
let userID = container.publicCloudDatabase.userRecordID()
print(userID)
```

This user recordID is unique for each user.

This is your authentication. Now you can create a different record type, like `Account` and link it to the user's recordID,
in case if you want user to have multiple accounts. And in case if you want multiple users to share the same account, you
can create `Reference(List)` as a field in the `Account` record type.

## 🔐 Security and maintenance

You don't have to write any backend code. Only apps signed with Apple's certificates can access the public database.
Only your code can write to the database, and only your code can read from the database. No need to host any server,
no need to worry that somebody is going to hack your server. And yes, a public database is free. It grows more users you have.

Apple does everything for you here. None of the other apps are allowed to access your public database. But you can also
create a second app, that can access the same database. In case if you want to build a second application just to manage
the database.

At this moment [ImmersiShare](https://immersishare.app) has close to 2,000 users, and the current database limit is over 4GB,
and asset storage is limited to 400GB.

We will see how it goes, and how quickly CloudKit database can keep up with demand.

## ✉️ Notifications



## ✋ Downsides of using CloudKit public database

There are some downsides of using CloudKit public database. First of all, you can't use it outside the Apple ecosystem.
You can't use it on Android, you can't use it on the web. You can't use it on Windows. You can't use it on Linux.

This means if your application grows to the point when you decide to create a port for Android, you will have to think
about migration procedure. But I feel like in case if you reached to the point that you want to create a multiplatform
application, you will have enough resources to do the migration.

In my case, I am (as a user) really stuck with Apple ecosystem. I have an iPhone, iPad, MacBook, iMac, Apple Watch, and
not plan to switch to anything else. And it feels like there is a good number of people like me.

I should note that my spouse is an Android user. Sure, I do want her to use my apps, but maybe it is a healthy thing for
our relationship not to push her to use my apps 😉.

## Letter
