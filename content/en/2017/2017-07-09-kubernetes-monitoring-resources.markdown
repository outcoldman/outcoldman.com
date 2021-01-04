---
date: "2017-07-09T00:00:00Z"
tags:
- kubernetes
- monitoring
- cadvisor
- prometheus
- influxdb
- elasticsearch
- grafana
title: 'Kubernetes: Monitoring Resources'
slug: "kubernetes-monitoring-resources"
---

You know that monitoring is a hot topic this year when you see such
variety of ways how you can monitor kubernetes cluster.

> If you are using Splunk - we provide solution to monitor and collect logs from
> Kubernetes. Please take a look on [Monitoring Kubernetes](https://www.outcoldsolutions.com/docs/monitoring-kubernetes/).

## cAdvisor

It all starts from [cAdvisor](https://github.com/google/cadvisor). Kubelet is built
with cAdvisor. You can find the source code responsible for `/stats` endpoint
under [release-1.7:pkg/kubelet/server/stats](https://github.com/kubernetes/kubernetes/tree/release-1.7/pkg/kubelet/server/stats).

With `kubectl proxy` you can get access to this endpoint by

``` bash
kubectl proxy &
curl localhost:8001/api/v1/nodes/$(kubectl get nodes -o=jsonpath="{.items[0].metadata.name}")/proxy/stats/
```

Web Interface and API of cAdvisor can be enabled with `--cadvisor-port`
argument (see [kubelet](https://kubernetes.io/docs/admin/kubelet/)).

For example if you are using minikube you can start it with

```bash
minikube start --extra-config=kubelet.CAdvisorPort=4194
```

To get access to the cAdvisor Web UI just use

```bash
open http://$(minikube ip):4194
```

If you are using kubeadm, you need to modify

```bash
sudo vim /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo systemctl daemon-reload
sudo systemctl restart kubelet.service
```

And set the `--cadvisor-port=4194`. See [Managing the kubeadm drop-in file for the kubelet](https://kubernetes.io/docs/admin/kubeadm/#managing-the-kubeadm-drop-in-file-for-the-kubelet)
for more details.

![cadvisor](/library/2017/07/kubernetes-resource-metrics/cadvisor.png)

## Kubelet

Kuberlet's `/metrics` endpoint has a lot of information, including metrics for etcd,
go metrics, provided by [prometheus](https://github.com/prometheus/client_golang).
And yes, the format of the returned data is defined by [prometheus](https://prometheus.io/docs/instrumenting/exposition_formats/). It should include cadvisor metrics as well (see below)

```bash
kubectl proxy &
curl localhost:8001/metrics
```

You should be able to see all cAdvisor specific metrics, including container
resources. 

But In kubernetes 1.7 this behavior was broken. See [After upgrading to 1.7.0, Kubelet no longer reports cAdvisor stats](https://github.com/kubernetes/kubernetes/issues/48483).

## Heapster

[Heapster](https://github.com/kubernetes/heapster) is built as independent process.
It can pull metrics from kubernetes
cluster, store them in memory (limited amount) and forward to one or more of the [sinks](https://github.com/kubernetes/heapster/blob/master/docs/sink-configuration.md), including logs.

![heapster](/library/2017/07/kubernetes-resource-metrics/heapster.png)

You can find what metrics you can expect from heapster on this link: [Metrics](https://github.com/kubernetes/heapster/blob/master/docs/storage-schema.md).

Considering that Heapster is the project hosted under kubernetes - I would assume
that this will be the most stable option with combination of one of the 
[@kubernetes/heapster-maintainers](https://github.com/kubernetes/heapster/blob/master/docs/sink-owners.md)
supported sink.

## Kubernetes Dashboard

Kubernetes [Dashboard](https://github.com/kubernetes/dashboard) is the general-purpose web UI for Kubernetes clusters.

If you will have heapster deployed on your kubernetes cluster then you will be
able to see simple resource usage on Dashboard

![kubernetes-dashboard](/library/2017/07/kubernetes-resource-metrics/dashboard.png)

## Prometheus

Prometheus is the open source monitoring system. It is part of
[Cloud Native Computing Foundation](https://www.cncf.io).

Prometheus pulls metrics directly from `/metrics` endpoint. It does not depend on
heapster. To set it up you need to use [kubernetes scrape config](https://github.com/prometheus/prometheus/blob/master/documentation/examples/prometheus-kubernetes.yml).

Because in kubernetes 1.7 `/metrics` endpoint does not provide metrics reported
by cAdvisor, you need to be sure to use the latest scrape config (currently in [PR](https://github.com/prometheus/prometheus/pull/2918)) see [Kubernetes 1.7.0 requires cAdvisor changes](https://github.com/prometheus/prometheus/issues/2916). And to make this scrape config to work you need to
enable port 4194 for cAdvisor (see above).

Prometheus gives you a graph ui, which is only useful for debugging. You can also build
dashboards with [console templates](https://prometheus.io/docs/visualization/consoles/). 

![prometheus](/library/2017/07/kubernetes-resource-metrics/prometheus.png)

The benefit of using prometheus - you will not only get resource usage, but also
internal kubernetes metrics.

## Grafana

Grafana is the open source user interface for a time series data.

Grafana allows you to use a lot of various data sources, including prometheus,
ElasticSearch and InfluxDB. It is certainly the most advanced open source interface
for time series analysis.

I have built my dashboard on top of [Kubernetes cluster monitoring (via Prometheus) by Instrumentisto Team](https://grafana.com/dashboards/315), as a Data Source I have used prometheus.

![grafana](/library/2017/07/kubernetes-resource-metrics/grafana.png)

## Elastic Stack

Elasticsearch is a well known database built for full text search. It is getting
more and more use cases.

You have several options how you can get metrics in [Elasticsearch](https://www.elastic.co).
First is to use Heapster and set ElasticSearch as a sink. Current implementation
of this sink has [some issues](https://github.com/kubernetes/heapster/issues/1701),
meaning it will use more storage and it is a little bit tricky to actually query
the metrics, I would not use it in production. But you still can built some dashboards with Kibana.

![kibana](/library/2017/07/kubernetes-resource-metrics/kibana.png)

Another option is to use metricbeat with [kubernetes module](https://www.elastic.co/guide/en/beats/metricbeat/master/metricbeat-module-kubernetes.html).
It is currently in alpha, so I have not tried it yet.

Third option is to use [prometheus module](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-module-prometheus.html)
and collect metrics directly from kubernetes cluster. That could be tricky,
as you probably want to dynamically generate few metrics endpoints specific for nodes.

## InfluxData

InfluxDB is the Time Series Database. InfluxDB also has several options how you can get metrics in it.

One option is to use Heapster. Because InfluxDB sink is owner by [@kubernetes/heapster-maintainers](https://github.com/kubernetes/heapster/blob/master/docs/sink-owners.md),
I would assume that this will be the most tested, stable and less broken option.
So for production and long term support I would probably suggest to use this one.

Another option is to use [telegraf](https://www.influxdata.com/time-series-platform/telegraf/)
with [kubernetes input plugin](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/kubernetes).
Telegraf also provides some built in dashboards for Chronograf, when you use
specific inputs.

[Chronograf](https://www.influxdata.com/time-series-platform/chronograf/) is Web Interface provided by InfluxData.
Very early stage, dashboards aren't configurable as much as in Grafana. Data explorer
and alerting (need [kapacitor](https://www.influxdata.com/time-series-platform/kapacitor/))
can be useful

![chronograf](/library/2017/07/kubernetes-resource-metrics/chronograf.png)

From my opinion chronograf is on very early stage and it feels like that Grafana
is the better option.

## Summary

As you can see there are a lot of options how you can monitor Kubernets resources.
And I am for sure missing a lot of other options, including DataDog.
I am still debating on which one to use.

I like prometheus with grafana, because that gives me the most set of metrics.
And it feels like that prometheus format is the standard now, so more and more
applications provides metrics in that format. So it is good to keep prometheus
server around, and looks like with version 2 they will finally get long term storage
for metrics.

I also like elasticsearch with kibana, just because I use it for other data as well.
Current sink implementation is very hard to manage. I will give a try new kubernetes
module in metricbeat at some point, but currently I am not sure if it actually
supports elasticsearch/kibana 5.x or I need to have whole stack with version 6.

Heapster with InfluxDB and Grafana is the third choice. That combination feels
like most reliable and supported. But because of the prometheus format supported
everywhere I would probably stay with prometheus.
