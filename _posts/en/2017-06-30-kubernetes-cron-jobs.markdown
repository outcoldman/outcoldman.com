---
layout: post
title: "Kubernetes: Cron Jobs"
categories: en
tags: [kubernetes, k8s, cron jobs, kubeadm]
---

Cron jobs is one of my favorite feature in Kubernetes. I use them for backups,
data retention, clean ups and some monitoring as well.

[Cron Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) 
feature is still in alpha. It is not enabled by default in 
Kubernetes 1.6](https://github.com/kubernetes/kubernetes.github.io/pull/4185)
(and possible in 1.7 as well). 

If you have Kubernetes setup by kubeadm, just find the file

```
/etc/kubernetes/manifests/kube-apiserver.yaml
```

Add a command argument to this Pod definition

```
--runtime-config=batch/v2alpha1=true
```

After that restart *kubelet.service* (if on ubuntu)

```
sudo systemctl restart kubelet.service
```

Few caveats about Cron Jobs:

- Cron Jobs create Jobs. Jobs are running till successful completion. 
If your container constantly fails you will end up with a lot of failed containers.
This is a proposal for this issue:
[Backoff policy and failed pod limit](https://github.com/kubernetes/community/pull/583).
While I was working on my cron jobs I ended up few times in this situation.
To deal with that - delete the job and after that clean all pods created by that 
job

```
kubectl delete pod -l job-name=<job_name>
```

- [Dashboard does not support Cron Jobs](https://github.com/kubernetes/dashboard/issues/1562),
so you will not see them. But you will see the Jobs created by Cron Jobs.

- Think about `concurrencyPolicy` which you want to apply. Default is `Allow`.
Most of Cron Jobs I created have `Forbid`.

- Set `successfulJobsHistoryLimit` and `failedJobsHistoryLimit`. These values are
unset by default. I usually use `successfulJobsHistoryLimit: 1` and `failedJobsHistoryLimit: 3`.

