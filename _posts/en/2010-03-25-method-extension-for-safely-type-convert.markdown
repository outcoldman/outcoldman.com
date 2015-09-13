---
layout: post
title: "Method extension for safely type convert"
date: 2010-03-25 19:58:00
categories: en
tags: [.NET, C#, Parse, Convert, Extension Methods]
redirect_from: en/blog/show/196/
---
<p>Recently I read good Russian post with many interesting <a href="http://nesteruk.wordpress.com/2010/03/22/extension-method-patterns/">extensions methods</a> after then I remembered that I too have one good extension method “Safely type convert”. Idea of this method I got at last job.</p>

<p>We often write code like this:</p>

```
int intValue;
if (obj == null || !int.TryParse(obj.ToString(), out intValue))
    intValue = 0;
```

<p>This is method how to safely parse object to int. Of course will be good if we will create some unify method for safely casting.</p>

<p>I found that better way is to create extension methods and use them then follows:</p>

```
int i;
i = "1".To<int>();
// i == 1
i = "1a".To<int>();
// i == 0 (default value of int)
i = "1a".To(10);
// i == 10 (set as default value 10)
i = "1".To(10);
// i == 1
// ********** Nullable sample **************
int? j;
j = "1".To<int?>();
// j == 1
j = "1a".To<int?>();
// j == null
j = "1a".To<int?>(10);
// j == 10
j = "1".To<int?>(10);
// j == 1
```

<p>Realization of this approach:</p>

```
public static class Parser
{
    /// <summary>
    /// Try cast <paramref name="obj"/> value to type <typeparamref name="T"/>,
    /// if can't will return default(<typeparamref name="T"/>)
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="obj"></param>
    /// <returns></returns>
    public static T To<T>(this object obj)
    {
        return To(obj, default(T));
    }
 
    /// <summary>
    /// Try cast <paramref name="obj"/> value to type <typeparamref name="T"/>,
    /// if can't will return <paramref name="defaultValue"/>
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="obj"></param>
    /// <param name="defaultValue"></param>
    /// <returns></returns>
    public static T To<T>(this object obj, T defaultValue)
    {
        if (obj == null)
            return defaultValue;
 
        if (obj is T)
            return (T) obj;
 
        Type type = typeof (T);
 
        // Place convert to reference types here
 
        if (type == typeof(string))
        {
            return (T)(object)obj.ToString();
        }
 
        Type underlyingType = Nullable.GetUnderlyingType(type);
        if (underlyingType != null)
        {
            return To(obj, defaultValue, underlyingType);
        }
 
        return To(obj, defaultValue, type);
    }
 
    private static T To<T>(object obj, T defaultValue, Type type)
    {
        // Place convert to sructures types here
 
        if (type == typeof(int))
        {
            int intValue;
            if (int.TryParse(obj.ToString(), out intValue))
                return (T)(object)intValue;
            return defaultValue;
        }
 
        if (type == typeof(long))
        {
            long intValue;
            if (long.TryParse(obj.ToString(), out intValue))
                return (T)(object)intValue;
            return defaultValue;
        }
 
        if (type == typeof(bool))
        {
            bool bValue;
            if (bool.TryParse(obj.ToString(), out bValue))
                return (T)(object)bValue;
            return defaultValue;
        }
 
        if (type.IsEnum)
        {
            if (Enum.IsDefined(type, obj))
                return (T)Enum.Parse(type, obj.ToString());
            return defaultValue;
        }
 
        throw new NotSupportedException(string.Format("Couldn't parse to Type {0}", typeof(T)));
    }
}
```


<p>This realization isn’t full – this is small method part, I use it at my site engine. It can work with int, long, bool, string, enums (with Nullable type of this types too). I think that you can add types very easy for this method (don’t forget about culture). </p>

<p>Obviously this approach you can use just inside of developers group, because It is not obviously why this method can’t cast any type A to type B.</p>

<p>

</p>
