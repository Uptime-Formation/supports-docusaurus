---
title: Cours - Les types de métriques pour surveiller son application
draft: false
# sidebar_position: 6
---





Pour profiter d'un monitoring efficace avec Prometheus les applications doivent participer à produire et exposer les métriques pertinentes.
Ces métriques doivent être conçues pour pouvoir

Pour pouvoir appareiller (to instrument) une application il existe des librairies client pour la plupart des langages. Ces librairies, a travers des appels dans le code de votre application vont permettre de 


## Quelques types de métriques

### Les compteurs (counters)

Les compteurs sont le type de métrique que vous utiliserez probablement le plus souvent dans l'instrumentation. Les compteurs permettent de suivre le nombre ou la taille des événements, plus techniquement de déterminer la fréquence d'exécution d'un chemin de code particulier.

Par exemple le nombre de réponses à une requête spécifique, ou le chiffre d'affaire cumulé d'un backend commercial etc.


### Les jauges (Gauges)

Gauges are a snapshot of some current state. While for counters how fast it is increasing is what you care about, for gauges it is the actual value of the
gauge. Accordingly, the values can go both up and down.

Examples of gauges include:
- The number of items in a queue
- Average requests per second in the last minute
- Number of active threads
- The last time a record was processed
- Memory usage of a cache

Gauges have three main methods you can use: `inc`, `dec`, and `set`.
Similar to the methods on counters, inc and dec default to changing a gauge’s value by one.
You can pass an argument with a different value to change by if you want. 

### Les métriques summary

The Summary
Knowing how long your application took to respond to a request or the
latency of a backend are vital metrics when you are trying to understand the
performance of your systems. Other instrumentation systems offer some
form of Timer metric, but Prometheus views things more generically. Just
as counters can be incremented by values other than one, you may wish to
track things about events other than their latency. For example, in addition
to backend latency you may also wish to track the size of the responses you
get back.
The primary method of a summary is observe, to which you pass the size
of the event. This must be a nonnegative value. Using time.time() you
can track latency, as shown in


### Les histogrammes

The Histogram
A summary will provide the average latency, but what if you want a
quantile? Quantiles tell you that a certain proportion of events had a size
below a given value. For example, the 0.95 quantile being 300 ms means
that 95% of requests took less than 300 ms.
Quantiles are useful when reasoning about actual end-user experience. If a
user’s browser makes 20 concurrent requests to your application, then it is

the slowest of them that determines the user-visible latency. In this case, the
95th percentile captures that latency.
TIP
The 95th percentile is the 0.95 quantile. As Prometheus prefers base units, it always
uses quantiles, in the same way that ratios are preferred to percentages.
The instrumentation for histograms is the same as for summaries. The
observe method allows you to do manual observations, and the time
context manager and function decorator allow for easier timings, as shown
in Example 3-11.

:::tip personnaliser le Bucket

Buckets
The default buckets cover a range of latencies from 1 ms to 10 s. This is
intended to capture the typical range of latencies for a web application. But
you can also override them and provide your own buckets when defining
metrics. This might be done if the defaults are not suitable for your use
case, or to add an explicit bucket for latency quantiles mentioned in your
Service-Level Agreements (SLAs). In order to help you detect typos, the
provided buckets must be sorted:
LATENCY = Histogram('hello_world_latency_seconds',
'Time for a request Hello World.',
buckets=[0.0001, 0.0002, 0.0005, 0.001, 0.01, 0.1])

:::

### Convention pour le nommage des métriques

METRIC SUFFIXES
You may have noticed that the example counter metrics all ended with
_total, while there is no such suffix on gauges. This is a convention
within Prometheus that makes it easier to identify what type of metric
you are working with.
With OpenMetrics, this suffix is mandated. As the prometheus_client
Python library is the reference implementation for OpenMetrics, if you
do not add the suffix, the library will add it for you.
In addition to _total, the _count, _sum, and _bucket suffixes
also have other meanings and should not be used as suffixes in your
metric names to avoid confusion.
It is also strongly recommended that you include the unit of your metric
at the end of its name. For example, a counter for bytes processed might
be myapp_requests_processed_bytes_total.


### Approaching Instrumentation

Now that you know how to use instrumentation, it is important to know
where and how much you should apply it.
What Should I Instrument?
When instrumenting, you will usually be looking to either instrument
services or libraries.
Service instrumentation
Broadly speaking, there are three types of services, each with their own key
metrics: online-serving systems, offline-serving systems, and batch jobs.
Online-serving systems are those where either a human or another service is
waiting on a response. These include web servers and databases. The key
metrics to include in service instrumentation are the request rate, latency,
and error rate. Having request rate, latency, and error rate metrics is
sometimes called the RED method, for Rate, Errors, and Duration. These
metrics are not just useful to you from the server side, but also the client
side. If you notice that the client is seeing more latency than the server, you
might have network issues or an overloaded client.
TIP
When instrumenting duration, don’t be tempted to exclude failures. If you were to
include only successes, then you might not notice high latency caused by many slow but
failing requests.
Offline-serving systems do not have someone waiting on them. They
usually batch up work and have multiple stages in a pipeline with queues
between them. A log processing system is an example of an offline-serving
system. For each stage you should have metrics for the amount of queued
work, how much work is in progress, how fast you are processing items,
and errors that occur. These metrics are also known as the USE method, for
Utilization, Saturation, and Errors. Utilization is how full your service is,
saturation is the amount of queued work, and errors is self-explanatory. If






