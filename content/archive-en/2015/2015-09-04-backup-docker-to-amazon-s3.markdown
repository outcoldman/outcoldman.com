---
categories: en
date: "2015-09-04T00:00:00Z"
tags:
- backup
- docker
- amazon
- s3
- s3cmd
- Alpine Linux
- find
title: Backup docker to Amazon S3
slug: "backup-docker-to-amazon-s3"
---

It is great that GitLab container has backup to S3 out of the box, but none of
the other containers I use have that. I tried to find simple solution, which
would allow me to map `data volume container`, specify files / folders I want
to backup, create archive periodically and upload that archive to S3. There are
plenty working images for backing up data from containers, but none of them
could do what I wanted.

So I have built my own [outcoldman/backup](https://hub.docker.com/r/outcoldman/backup/)
image (obviously [source code is available](https://github.com/outcoldman/docker-backup)).
This image is based on [Alpine Linux](http://www.alpinelinux.org), using
[find](https://www.freebsd.org/cgi/man.cgi?query=find(1)&sektion=) for selecting
files you want to backup and [s3cmd](http://s3tools.org/s3cmd) for uploading
archives to S3.

> You can also use this image if you just want to backup some files
> periodically somewhere on local drive, just don't set anything to
> `BACKUP_AWS_S3_PATH`, set `BACKUP_DELETE_LOCAL_COPY` as `false` and
> specify where you want to keep your backups using `BACKUP_DEST_FOLDER`.

If you want to upload archives to S3 at first you need to create new
bucket (services/S3), create an user (services/IAM) with access to this bucket,
for example I use next policy for my users (one user per bucket)

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1412062044000",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::your-backup-us-west-2/*"
            ]
        },
        {
            "Sid": "Stmt1412062097000",
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListAllMyBuckets"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "Stmt1412062128000",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::your-backup-us-west-2"
            ]
        }
    ]
}
```

One important thing, that for S3 buckets you can also specify Lifecycle, which
allows to archive backups to Glacier Storage (which is much cheaper that S3 for
storing data) and delete everything after N days. To do that just select
a bucket, click on Properties, find Lifecycle and add a rule. For all my backups
I specify next rule archive to Glacier after 3 days and delete files 100 days after
the object's creation date. See below.

[![AWS Buckets](/library/2015/09/docker-backup-buckets.png)](/library/2015/09/docker-backup-buckets.png)

[![AWS Bucket Rule](/library/2015/09/docker-backup-rule.png)](/library/2015/09/docker-backup-rule.png)

The next step is to find which files you want to backup. You need to know
[find](https://www.freebsd.org/cgi/man.cgi?query=find(1)&sektion=) very well to
do that. It is not hard, you basically just specify where to search for files
and after that specify some conditions on which files you want to include or
exclude (I will show some examples below).

For most of my images I use [Data Volume Containers](https://docs.docker.com/userguide/dockervolumes/)
which I mount to the image with service and also to my backup image. Let's look
on two examples (`docker-compose.yml` files)

This is how I backup my Splunk configurations (only etc folder, I do not backup
indexes)

```yaml
vsplunk:
  image: busybox
  volumes:
    - /opt/splunk/etc

splunk:
  image: outcoldman/splunk:latest
  volumes_from:
    - vsplunk

splunkbackup:
  image: outcoldman/backup:latest
  environment:
    - BACKUP_PREFIX=splunk-etc
    - BACKUP_AWS_KEY=AWS_KEY
    - BACKUP_AWS_SECRET=AWS_SECRET
    - BACKUP_AWS_S3_PATH=s3://my-backup-backet
    - BACKUP_FIND_OPTIONS=/opt/splunk/etc \( -path "/opt/splunk/etc/apps/search/*" -a ! -path "/opt/splunk/etc/apps/search/default*" \) -o \( -path "/opt/splunk/etc/system/*" -a ! -path "/opt/splunk/etc/system/default*" \)
    - BACKUP_TIMEZONE=America/Los_Angeles
    - BACKUP_CRON_SCHEDULE=10 2 * * *
  volumes_from:
    - vsplunk
```

Another example of how I backup Jenkins

```yaml
vdata:
  image: busybox
  volumes:
    - /var/jenkins_home

jenkins:
  build: jenkins:latest
  volumes_from:
    - vdata

backup:
  image: outcoldman/backup:latest
  environment:
    - BACKUP_PREFIX=jenkins
    - BACKUP_AWS_KEY=AWS_KEY
    - BACKUP_AWS_SECRET=AWS_SECRET
    - BACKUP_AWS_S3_PATH=s3://my-backup-backet
    - BACKUP_FIND_OPTIONS=/var/jenkins_home/ -path "/var/jenkins_home/.ssh/*" -o -path "/var/jenkins_home/plugins/*.jpi" -o -path "/var/jenkins_home/users/*" -o -path "/var/jenkins_home/secrets/*" -o -path "/var/jenkins_home/jobs/*" -o -regex "/var/jenkins_home/[^/]*.xml" -o -regex "/var/jenkins_home/secret.[^/]*"
    - BACKUP_TIMEZONE=America/Los_Angeles
    - BACKUP_CRON_SCHEDULE=20 2 * * *
  volumes_from:
    - vdata
```

> Please note that these are not recommended ways of how to run Jenkins and
> Splunk in containers, I removed most of the parameters from the containers
> and just kept the only one which important to demonstrate how `backup`
> image works.

Few important things in these examples:

- I specified the timezone to make sure that I can schedule backups at night,
    by default image is using UTC timezone.
- I specified different time for backups, I backup Splunk every night at
    2:10am and Jenkins every night at 2:20am.
- For both containers I specify `find` options, where first parameter is
    where I want to search for files and after that specify some conditions.
- For Splunk container I backup only two places (search app and system configuration)
    and exclude default settings.
- For Jenkins container I backup a lot of files/folders specified with various
    conditions (I used [this script](https://github.com/sue445/jenkins-backup-script)
    as an example to find what to backup).

Hope that image will be helpful for you. And if you will have some other
interesting receipts, please [add them to examples section](https://github.com/outcoldman/docker-backup/pulls).
