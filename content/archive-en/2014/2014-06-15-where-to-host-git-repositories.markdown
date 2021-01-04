---
categories: en
date: "2014-06-15T00:00:00Z"
tags:
- git
- GitHub
- GitLab
- Visual Studio online
- BitBucket
title: Where to host private Git repositories?
slug: "where-to-host-git-repositories"
---

I don't know about you, but I have a lot private Git repositories. Most of these repositories are dead or almost dead projects. But I still want to keep them, because some of them can have good ideas or some solved issues which I maybe will need to solve in future again. So sometimes I use them as a tutorial or documentation for some issues, which I solved before. This is why I need some place where I can host 2-3 dozen of small repositories and about 5 my main repositories, where I do my personal projects. 

So, lets take a look on what we can use for personal projects.

## Git in local folders (also can be stored in DropBox, OneCloud, GoogleDrive folders)

This is the simplest solution. It allows to sync projects between your computers if you keep repositories under one of the cloud storage folders, like DropBox, OneCloud, GoogleDrive or something else. 

My guess that there can be some issues if you will try to do changes on two computers in offline. No web interface (for me it can be an issue).

I actually never tried this solution, so nothing to add here. 

## GitHub

GitHub is the best, but it can be expensive for storing dead repositories, because their [price](https://github.com/pricing) is based on number of Private repositories. I would love to see Indie-plans with limited number of Collaborators and unlimited number of private repositories. I would pay for this. 

## Visual Studio Online

Like their price model. Unlimited number of private repositories for up to 5 users. Best option for Indie developers, but it does not support SSH access. See [Add support for SSH keys as alternate authentication method in TFS Online](https://visualstudio.uservoice.com/forums/121579-visual-studio/suggestions/3801342-add-support-for-ssh-keys-as-alternate-authenticati). It just a paint to import your password on each pull/push request.
Also there are no public repositories. So if you will decide to publish one of the repositories you will need to actually give access for specific users. 

## BitBucket

Unlimited number of private repositories up to 5 users. Atlassian has a lot of great [products](https://www.atlassian.com/software) and services and BitBucket is just one of them. There are no reasons to not use them, except one, if you don't trust them for some reason.

Actually only one reason why I think that BitBucket is not so popular, because at the beginning BitBucket made not very good choice for them, they chose Mercurial over Git and only in 2011 they added Git support [Bitbucket now rocks Git](http://blog.bitbucket.org/2011/10/03/bitbucket-now-rocks-git/), but people still think that Git is GitHub and BitBucket supports only Mercurial.

## Assembla

[Their plans](https://www.assembla.com/plans) don't work for Indie developers. 10 Git repositories will cost you $49/month.

## GitLab 

### ... in Cloud

GitLab itself very good product. I really like it. But this company ([Gitlab B.V.](http://www.crunchbase.com/organization/gitlab-com)) is not so mature as [Atlassian](http://www.crunchbase.com/organization/atlassian) or [GitHub](http://www.crunchbase.com/organization/github), so it is more risky to upload your private repositories to their servers. 

### ... in Cloud (DigitalOcean) but maintained by you

If you don't trust Gitlab Cloud, but like GitLab as a product, you can host it on your own. On your home server or somewhere in the cloud. For example DigitalOcean has manual about how to install it in their cloud [How To Use the GitLab One-Click Install Image to Manage Git Repositories](https://www.digitalocean.com/community/tutorials/how-to-use-the-gitlab-one-click-install-image-to-manage-git-repositories).

I also helped to improve documentation [Installation guide for GitLab 6.8 on OS X 10.9 with Server 3](https://github.com/CiTroNaK/Installation-guide-for-GitLab-on-OS-X).

## My decision...

I would pay GitHub for Indie plan, but while they don't have it I'm looking on other options. I don't have any reasons to not use BitBucket, but at the same time I don't use it. I'm afraid to upload my private repositories to GitLab in Cloud, but I like GitLab itself, so for now I just host it on my own server. I'm not happy with that, because as I have figure out I am too lazy to do upgrades every month. So I will probably move everything to BitBucket. 