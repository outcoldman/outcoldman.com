---
title: "Elasticsearch: How to avoid index throttling, deep dive in segments merging"
tags: [elasticsearch, lucene, segments, databases]
---

> *This blog post is written based on source code of Elasticsearch 5.5.0 and Lucene 6.6.*

If you are managing Elasticsearch cluster it is very important to understand what are the segments in the index, why and
when they are getting merged, and what is the right configuration.

If your Elasticsearch cluster is fairly big, default configuration might not work for you. Not sure why the
documentation for the Merge Policy is gone from
[Index Modules](https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules.html),
but you can find it in 
[source code (MergePolicyConfig.java)](https://github.com/elastic/elasticsearch/blob/5.5/core/src/main/java/org/elasticsearch/index/MergePolicyConfig.java#L32).
At [the bottom](https://github.com/elastic/elasticsearch/blob/5.5/core/src/main/java/org/elasticsearch/index/MergePolicyConfig.java#L109)
you can find really important note about the `max_merged_segment`, which is set to `5gb` by default.

> Note, this can mean that for large shards that holds many gigabytes of
> data, the default of `max_merged_segment` (`5gb`) can cause for many
> segments to be in an index, and causing searches to be slower.

So what is the *many gigabytes of data*? Let's try to answer on this question.

First I would highly recommend you to look on
[Visualizing Lucene's segment merges by Michael McCandless](http://blog.mikemccandless.com/2011/02/visualizing-lucenes-segment-merges.html).
If you are not familiar with Lucene you should also look into
[Elasticsearch from the Bottom Up](https://www.elastic.co/blog/found-elasticsearch-from-the-bottom-up).
The third video in first link presents `TieredMergePolicy`. It is the merge policy you should be most interested in. 
All the other policies were deprecated in Elasticsearch 1.6 and removed in Elasticsearch version 2.0. In the article mentioned above
you will find very good explanation on how TieredMergePolicy works.

What helped me more, when I looked in the source code of Lucene implementation of method
[TieredMergePolicy.findMerges](https://github.com/apache/lucene-solr/blob/branch_6_6/lucene/core/src/java/org/apache/lucene/index/TieredMergePolicy.java#L281).
That and looking on default configuration of Elasticsearch helped me to understand what to expect.

Back to the article mentioned above

> TieredMergePolicy first computes the allowed "budget" of how many segments
> should be in the index, by counting how many steps the "perfect logarithmic staircase"
> would require given total index size, minimum segment size (floored), mergeAtOnce,
> and a new configuration maxSegmentsPerTier that lets you set the allowed width
> (number of segments) of each stair in the staircase. This is nice because it decouples
> how many segments to merge at a time from how wide the staircase can be.

Let's look on how that is implemented

[First](https://github.com/apache/lucene-solr/blob/branch_6_6/lucene/core/src/java/org/apache/lucene/index/TieredMergePolicy.java#L292)
we get a collection segments `infosSorted`,  sorted in descending order by size.

```java
Collections.sort(infosSorted, new SegmentByteSizeDescending(writer));
```

[Block](https://github.com/apache/lucene-solr/blob/branch_6_6/lucene/core/src/java/org/apache/lucene/index/TieredMergePolicy.java#L297-L312)
calculates total size of the index (sum of all segments) and size of the smallest segment 

```java
long totIndexBytes = 0;
long minSegmentBytes = Long.MAX_VALUE;
for(SegmentCommitInfo info : infosSorted) {
  final long segBytes = size(info, writer);
  // ... skipped ... //

  minSegmentBytes = Math.min(segBytes, minSegmentBytes);
  // Accum total byte size
  totIndexBytes += segBytes;
}
```

Now we have two variables, `totIndexBytes` is the size of all indices and `minSegmentBytes` is the minimum segment size.

[Next](https://github.com/apache/lucene-solr/blob/branch_6_6/lucene/core/src/java/org/apache/lucene/index/TieredMergePolicy.java#L326)
we exclude all segments larger than `max_merged_segment/2.0` (with default value `5gb` it is `2.5gb`)

```java
int tooBigCount = 0;
while (tooBigCount < infosSorted.size()) {
  long segBytes = size(infosSorted.get(tooBigCount), writer);
  if (segBytes < maxMergedSegmentBytes/2.0) {
    break;
  }
  totIndexBytes -= segBytes;
  tooBigCount++;
}
```

> *Seem like this loop can be easily combined with previous one. [PR#219](https://github.com/apache/lucene-solr/pull/219).*

Using value of `floor_segment` (default is`2mb`) if the smallest segment is less than that

```java
minSegmentBytes = floorSize(minSegmentBytes);
```

Next [block](https://github.com/apache/lucene-solr/blob/branch_6_6/lucene/core/src/java/org/apache/lucene/index/TieredMergePolicy.java#L329-L342)
is very important, it calculates number or allowed segments. The number which triggers the merge, when the number of segments
is more than that

```java
long levelSize = minSegmentBytes;
long bytesLeft = totIndexBytes;
double allowedSegCount = 0;
while(true) {
  final double segCountLevel = bytesLeft / (double) levelSize;
  if (segCountLevel < segsPerTier) {
    allowedSegCount += Math.ceil(segCountLevel);
    break;
  }
  allowedSegCount += segsPerTier;
  bytesLeft -= segsPerTier * levelSize;
  levelSize *= maxMergeAtOnce;
}
int allowedSegCountInt = (int) allowedSegCount;
```

Taking default configuration with `floor_segment` equal to `2mb` and assuming that you have segment with size lower or
equal to `floor_segment` we can estimate the `allowedSegCountInt` to be around 40 segments and our *perfect logarithmic staircase*
should look like

![lucene perfect logarithmic staircase]({{ site.url }}/library/2017/07/elasticsearch-merge-settings/perfect-logarithmic-staircase.png)

Some observations from above:

- Changes to the `floor_segment` or index refresh can cause the value `minSegmentBytes` be very high, which will make
`allowedSegCountInt` smaller and that can cause a lot of scheduled merges.
- Changing the value of `segments_per_tier` can also significantly change on how often you will see segments to be merged in
index.
- The code above uses `max_merge_at_once` to reserve space for the tier (level) and uses `segments_per_tier` to
set how many segments is allowed for this tier. (both set to `10` by default in Elasticsearch).

[Only](https://github.com/apache/lucene-solr/blob/branch_6_6/lucene/core/src/java/org/apache/lucene/index/TieredMergePolicy.java#L374)
if number of eligible segments more than `allowedSegCountInt`, lucene proceeds with finding candidates for merges

```java
if (eligible.size() > allowedSegCountInt) {
    // ...
}
```

Where [eligible](https://github.com/apache/lucene-solr/blob/branch_6_6/lucene/core/src/java/org/apache/lucene/index/TieredMergePolicy.java#L354-L362)
is the list of all segments with size less than `max_merged_segment/2.0` and has not been included in any merges yet.

The [code](https://github.com/apache/lucene-solr/blob/branch_6_6/lucene/core/src/java/org/apache/lucene/index/TieredMergePolicy.java#L377-L442)
under this if statement trying to find the possible combination of segments to include in merges which will bring
`eligible.size()` under `allowedSegCountInt`. 

The algorithm is simple, it starts from the largest segment and trying to find N segments (where `N < max_merge_at_once`),
which in merge will result segment with size less than `max_merged_segment`. This is a reason, why actually the 
*perfect logarithmic staircase* should not happen, because this merge policy does not look for how to merge together
smallest segment, but actually trying to find how to merge the largest segments first.

This is an example

![first merge]({{ site.url }}/library/2017/07/elasticsearch-merge-settings/first-merge.png)

- Segment with size `4.2Gb` will be excluded as too big (size more than `max_merged_segment/2.0`).
- First segment considered for merge will be the one with size `2.2Gb`. This segment can be merged with the segment
with size of `2gb`, but not with `2gb` and `1gb` at the same time, so it will skip `1gb` segment and start looking for
smaller segments which will result in size of close to `5gb` or smaller (`max_merged_segment`), but number of segments in
this merge should not be larger than `max_merge_at_once` (`10` by default).
- If number of eligible segments still more than `allowedSegCountInt` the next merge will be constructed from segment
of size `1gb` and segments which are not included in previous merge (again considering two constraints `max_merged_segment`
and `max_merge_at_once`).

Some observations from this code:

- Segments larger than `max_merged_segment/2.0` will not be included in any merge, even if the percentage of deleted documents is
over `expunge_deletes_allowed` (`10%` by default). If you will end up with a lot of segments with size more than
`max_merged_segment/2.0` and you constantly deleting documents from them - their space will never be reclaimed.
You will need to perform force merge or change the configuration.
- To previous point. If index has segment with size lower than `max_merged_segment/2.0`, which cannot be merged
with any other segments (I would assume very uncommon situation) but has more than `expunge_deletes_allowed` of deleted
objects - this is the time when the deleted documents can be expunged if none of other merges will be find.
- If you have a segment with the size of `max_merged_segment/2.0 - 1byte` it will never be merged with any segment and
never be excluded from the `allowedSegCountInt`. I would assume that this is a very rarely case. I have
[asked](https://github.com/apache/lucene-solr/pull/219#issuecomment-315231437) to be sure that this is a known issue.
- Now I know why regular reindexing of all data can help with making searches faster. With `TieredMergePolicy` it is very
likely that segments will be merged not in sequence order (see my example above). This can be a problem if terms change
with the time. Because of that segments need to store terms from various periods. In my example above if `4Gb` and `2.2Gb`
are the segments with only `January` data, it is very likely that these segments will be merged with some small segment
at the end, for example last segment of size `10mb`, which holds `December` data.
- Because of the point from above - if you have time series data - using indices with time postfixes (`YYYY-mm-DD`) should
be beneficial.

Now it is much clear for me how segments are getting merged in Lucene. Let's come back to the Elasticsearch and look on
index throttling. Index throttling happens in [EngineMergeScheduler.beforeMerge](https://github.com/elastic/elasticsearch/blob/5.5/core/src/main/java/org/elasticsearch/index/engine/InternalEngine.java#L1494).
It happens when `TieredMergePolicy.findMerges` returns more merges than the value of `index.merge.scheduler.max_merge_count`.
The value of `max_merge_count` is defined in [MergeSchedulerConfig](https://github.com/elastic/elasticsearch/blob/master/core/src/main/java/org/elasticsearch/index/MergeSchedulerConfig.java#L60).
By default this value is set to `index.merge.scheduler.max_thread_count + 5`,
where `max_thread_count = Math.min(4, numberOfProcessors / 2)`.
This value can be changed dynamically as any other index setting (but for some reason it is not documented)

```
curl -XPUT http://localhost:9200/*/_settings -d'{
  "index.merge.scheduler.max_merge_count": 100
}'
```

If you are planning to play with the configuration for merge policy I would highly recommend you to change this to higher
value than default, that will help you to avoid index throttling. 

What else can cause index throttling? It really depends. First, very obvious is enabled throttling for merges
`indices.store.throttle.type` or very low value of `indices.store.throttle.max_bytes_per_sec`. Seems like in Elasticsearch
6.0 these settings [will be removed](https://github.com/elastic/elasticsearch/blob/a0fcfc732d765c9da816ded2509fdcfe96a3e51a/docs/reference/migration/migrate_6_0/settings.asciidoc#store-throttling-settings),
so merges will never be throttled. 
To find what else can cause index throttling I would recommend to look on current sizes of segments, use
the algorithm from the `TieredMergePolicy`, predict what kind of merges will be scheduled. That should help you
to answer the question. Can be that you have too many small segments or maybe too many large segments.