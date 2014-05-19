---
layout: post
title: "Config Transformation Tool: Parameters support"
date: 2010-09-09 19:39:00
categories: en
tags: [.NET, C#, CodePlex, XDT, XML-Document-Transform, Config Transformation Tool]
alias: en/blog/show/238
---
<p>Couple of weeks ago I wrote about my small utility Config Transformation Tool, which I wrote with base of web.config transformation task. In those moments I was thinking about opportunity to pass parameters to transform file, to tool can replaces parameters in transformation file with special values. Yesterday I resolved this issue. From now I use class Microsoft.Web.Publishing.Tasks.XmlTransformation which works with strings and XmlDocuments instead of files. I had two tasks: (a) I need method which will replace parameters on values, (b) I need method which will be parse command line and create dictionary of parameters.</p>    <h2>ParametersTask</h2>  <p>Let’s solve first task. I decided to use next syntax for parameters: {Parameter_Name:Default_Value}, where default value is optional. Rules for replace:</p>  <ol>   <li>If parameter defined with value – tool will use this value; </li>    <li>If parameter not set, but value by default defined – tool will use default value; </li>    <li>If parameter not set and default value not set – tool will leave this as is. </li> </ol>  <p>I didn’t want to solve this issue with RegEx or string.Replace methods, because if parameters will be many, execution of this task can take a long period. So I wanted to write method which will handle all parameters in string in one pass. Also I thought that maybe will need to use symbols ‘{’, ‘}’ in string, so I need way to escape these symbols. I decided to use combinations ‘\}’, “\{”, and if you want to use ‘\’ you should use combination ‘\\’. Ok, so class ParametersTask has one field _parameters with type IDictionary&lt;string,string&gt;, where keys are names of parameters, and values are values of parameters. Main method ApplyParameters:</p>  

```
public string ApplyParameters(string sourceString)
{
    StringBuilder result = new StringBuilder();
 
    int index = 0;
 
    char[] source = sourceString.ToCharArray();
 
    bool fParameterRead = false;
 
    StringBuilder parameter = new StringBuilder();
 
    while (index < source.Length)
    {
        // If parameter read, read it and replace it
        if (fParameterRead && source[index] == '}')
        {
            var s = parameter.ToString();
            int colonIndex = parameter.ToString().IndexOf(':');
 
            var parameterName = colonIndex > 0 ? s.Substring(0, colonIndex) : s;
            var parameterDefaultValue = colonIndex > 0 ? s.Substring(colonIndex + 1, s.Length - colonIndex - 1) : null;
 
            string parameterValue = null;
            if (_parameters != null && _parameters.ContainsKey(parameterName))
                parameterValue = _parameters[parameterName];
 
            // Put "value" or "default value" or "string which was here"
            result.Append(parameterValue ?? parameterDefaultValue ?? "{" + parameter + "}");
 
            fParameterRead = false;
            index++;
            continue; 
        }
        
        if (source[index] == '{')
        {
            fParameterRead = true;
            parameter = new StringBuilder();
            index++;
        }
        // Check is this escape \{ \} \\
        else if (source[index] == '\\')
        {
            var nextIndex = index + 1;
            if (nextIndex < source.Length)
            {
                var nextChar = source[nextIndex];
                if (nextChar == '}' || nextChar == '{' || nextChar == '\\')
                {
                    index++;
                }
            }
        }
 
        if (fParameterRead)
            parameter.Append(source[index]);
        else
            result.Append(source[index]);
 
        index++;
    }
 
    return  result.ToString();
}
```

<p>In the while cycle we read parameter or just content of file. First if check that next char is end of parameter’s definition, second if check that next char is start of parameter’s definition. Next if escape special combinations “\{”, “\}” or “\\”. Of course it is not a full “<a href="http://en.wikipedia.org/wiki/Recursive_descent_parser">Recursive descent parser</a>”, but it looks good, and it is working with next tests:</p>

```
[Test]
public void ApplyParameters_Sample()
{
    const string ExpectedResult =
        @"
<value key=""Value CustomParameter1"" value=""False"" />
<value key=""Test2"" value=""Value CustomParameter2"" />
<value key=""Test3"" value=""False"" />";
 
    const string Source =
        @"
<value key=""{CustomParameter1:Default value}"" value=""{TrueValueParameter:True}"" />
<value key=""Test2"" value=""{CustomParameter2:Default value of CustomParameter2}"" />
<value key=""Test3"" value=""{TrueValueParameter:True}"" />";
 
    ParametersTask task = new ParametersTask();
 
    task.AddParameters(new Dictionary<string, string>
                        {
                            {"CustomParameter1", "Value CustomParameter1"},
                            {"TrueValueParameter", "False"},
                            {"CustomParameter2", "Value CustomParameter2"}
                        });
    var result = task.ApplyParameters(Source);
    Assert.AreEqual(ExpectedResult, result);
}
 
[Test]
public void WithoutParameters()
{
    const string Source =
        @"
<value key=""{CustomParameter1}"" value=""{TrueValueParameter}"" />
<value key=""Test2"" value=""{CustomParameter2}"" />
<value key=""Test3"" value=""{TrueValueParameter}"" />";
 
    ParametersTask task = new ParametersTask();
    var result = task.ApplyParameters(Source);
    Assert.AreEqual(Source, result);
}
 
[Test]
public void WithoutParameters_But_With_Default_Values()
{
    const string ExpectedResult =
        @"
<value key=""Default value"" value=""True"" />
<value key=""Test2"" value=""Default value of CustomParameter2"" />
<value key=""Test3"" value=""False"" />";
 
    const string Source =
        @"
<value key=""{CustomParameter1:Default value}"" value=""{TrueValueParameter:True}"" />
<value key=""Test2"" value=""{CustomParameter2:Default value of CustomParameter2}"" />
<value key=""Test3"" value=""{TrueValueParameter:False}"" />";
 
    ParametersTask task = new ParametersTask();
    var result = task.ApplyParameters(Source);
    Assert.AreEqual(ExpectedResult, result);
}
 
[Test]
public void Apply_With_Double_Colon_In_Definition()
{
    const string ExpectedResult =
        @"
<value key=""Default:value"" value=""Val"" />";
 
    const string Source =
        @"
<value key=""{Parameter1:Default:value}"" value=""Val"" />";
 
    ParametersTask task = new ParametersTask();
    var result = task.ApplyParameters(Source);
    Assert.AreEqual(ExpectedResult, result);
}
 
[Test]
public void Apply_With_Escaped_Brackets()
{
    const string ExpectedResult =
        @"
<value key=""Default:value"" value=""{TestParameter:Test}"" />";
 
    const string Source =
        @"
<value key=""{Parameter1:Default:value}"" value=""\{TestParameter:Test\}"" />";
 
    ParametersTask task = new ParametersTask();
    var result = task.ApplyParameters(Source);
    Assert.AreEqual(ExpectedResult, result);
}
 
[Test]
public void Apply_With_Escaped_Brackets_In_Default_Value()
{
    const string ExpectedResult =
        @"
<value key=""Defa{ultva}lue"" value=""{TestParameter:Test}"" />";
 
    const string Source =
        @"
<value key=""{Parameter1:Defa\{ultva\}lue}"" value=""\{TestParameter:Test\}"" />";
 
    ParametersTask task = new ParametersTask();
    var result = task.ApplyParameters(Source);
    Assert.AreEqual(ExpectedResult, result);
}
 
[Test]
public void Apply_With_Parameter_At_End_Of_String()
{
    const string ExpectedResult =
        @"
<value key=""Defa{ultva}lue"" value=""Test";
 
    const string Source =
        @"
<value key=""{Parameter1:Defa\{ultva\}lue}"" value=""{TestParameter:Test}";
 
    ParametersTask task = new ParametersTask();
    var result = task.ApplyParameters(Source);
    Assert.AreEqual(ExpectedResult, result);
}
 
[Test]
public void Apply_With_Parameter_At_Start_Of_String()
{
    const string ExpectedResult =
        @"Defa{ultva}lue"" value=""{TestParameter:Test}"" />";
 
    const string Source =
        @"{Parameter1:Defa\{ultva\}lue}"" value=""\{TestParameter:Test\}"" />";
 
    ParametersTask task = new ParametersTask();
    var result = task.ApplyParameters(Source);
    Assert.AreEqual(ExpectedResult, result);
}
```

<h2>ParametersParser</h2>

<p>Second issue – tool should parse parameters from command line. I decided to use a way which use MsBuild tool, or very similar to it. Parameters should be separated by ‘;’, name and value of parameter should be separated by ‘:’, if parameter’s value has space or ‘;’ you can quote it, also you can use ‘\”’ and ‘\\’ for escape symbols ‘”’ and ‘\’. Realization:</p>

```
/// <summary>
/// Parse string of parameters 
/// </summary>
public static class ParametersParser
{
    private readonly static ILog Log = LogManager.GetLogger(MethodBase.GetCurrentMethod().DeclaringType); 
 
    /// <summary>
    /// Parse string of parameters <paramref name="parametersString"/> separated by semi ';'.
    /// Value should be separated from name by colon ':'. 
    /// If value has spaces or semi you can use quotes for value. 
    /// You can escape symbols '\' and '"' with \.
    /// </summary>
    /// <param name="parametersString">String of parameters</param>
    /// <returns>Dicrionary of parameters, where keys are names and values are values of parameters. 
    /// Can be null if <paramref name="parametersString"/> is empty or null.</returns>
    public static IDictionary<string, string> ReadParameters(string parametersString)
    {
        if (string.IsNullOrWhiteSpace(parametersString)) return null;
 
        Dictionary<string, string> parameters = new Dictionary<string, string>();
 
        var source = parametersString.ToCharArray();
 
        int index = 0;
 
        bool fParameterNameRead = true;
        bool fForceParameterValueRead = false;
 
        StringBuilder parameterName = new StringBuilder();
        StringBuilder parameterValue = new StringBuilder();
 
        while (index < source.Length)
        {
            if (fParameterNameRead && source[index] == ':')
            {
                fParameterNameRead = false;
                index++;
 
                if (index < source.Length && source[index] == '"')
                {
                    fForceParameterValueRead = true;
                    index++;
                }
 
                continue;
            }
 
            if ((!fForceParameterValueRead && source[index] == ';')
                || (fForceParameterValueRead && source[index] == '"' && ((index + 1) == source.Length || source[index + 1] == ';')))
            {
                AddParameter(parameters, parameterName, parameterValue);
                index++;
                if (fForceParameterValueRead)
                    index++;
                parameterName.Clear();
                parameterValue.Clear();
                fParameterNameRead = true;
                fForceParameterValueRead = false;
                continue;
            }
 
            // Check is this escape \{ \} \\
            if (source[index] == '\\')
            {
                var nextIndex = index + 1;
                if (nextIndex < source.Length)
                {
                    var nextChar = source[nextIndex];
                    if (nextChar == '"' || nextChar == '\\')
                    {
                        index++;
                    }
                }
            }
 
            if (fParameterNameRead)
            {
                parameterName.Append(source[index]);
            }
            else
            {
                parameterValue.Append(source[index]);
            }
 
            index++;
        }
 
        AddParameter(parameters, parameterName, parameterValue);
 
        if (Log.IsDebugEnabled)
        {
            foreach (var parameter in parameters)
            {
                Log.DebugFormat("Parameter Name: '{0}', Value: '{1}'", parameter.Key, parameter.Value);
            }
        }
 
        return parameters;
    }
 
    private static void AddParameter(Dictionary<string, string> parameters, StringBuilder parameterName, StringBuilder parameterValue)
    {
        var name = parameterName.ToString();
        if (!string.IsNullOrWhiteSpace(name))
        {
            if (parameters.ContainsKey(name))
                parameters.Remove(name);
            parameters.Add(name, parameterValue.ToString());
        }
    }
}
```

<p>Very simple. In while cycle we read name of parameter of value of parameter. Of course you can solve this issue with split methods, but I decided to handle this string in one pass too. Some tests for this method:</p>

```
/// <summary>
/// Check simple parameters command line
/// </summary>
[Test]
public void Sample()
{
    const string parametersLine = "Parameter1:Value1;Parameter2:121.232";
 
    var parameters = ParametersParser.ReadParameters(parametersLine);
 
    Assert.AreEqual("Value1", parameters["Parameter1"]);
    Assert.AreEqual("121.232", parameters["Parameter2"]);
}
 
/// <summary>
/// Check parameters command line when one of parameter has semi in value string
/// </summary>
[Test]
public void String_With_Semicolon_In_Value()
{
    const string parametersLine = "Parameter1:Value1;Parameter2:\"121;232\"";
 
    var parameters = ParametersParser.ReadParameters(parametersLine);
 
    Assert.AreEqual("Value1", parameters["Parameter1"]);
    Assert.AreEqual("121;232", parameters["Parameter2"]);
}
 
/// <summary>
/// Check that if command line has semicon at end parameters will be loaded
/// </summary>
[Test]
public void String_With_Semicolon_At_End()
{
    const string parametersLine = "Parameter1:Value1;Parameter2:\"121.232\";";
 
    var parameters = ParametersParser.ReadParameters(parametersLine);
 
    Assert.AreEqual("Value1", parameters["Parameter1"]);
    Assert.AreEqual("121.232", parameters["Parameter2"]);
}
 
/// <summary>
/// Check that value of parameter can contain escaped quotes
/// </summary>
[Test]
public void String_With_Values_With_Quotes()
{
    const string parametersLine = @"Parameter1:Value1;Parameter2:""12\""1.2\""32"";";
 
    var parameters = ParametersParser.ReadParameters(parametersLine);
 
    Assert.AreEqual("Value1", parameters["Parameter1"]);
    Assert.AreEqual("12\"1.2\"32", parameters["Parameter2"]);
}
```

<h2>Result</h2>

<p>Ok, so let’s look on example. Source file (s.config):</p>

```
<?xml version="1.0"?>
 
<configuration>
 
    <custom>
        <groups>
            <group name="TestGroup1">
                <values>
                    <value key="Test1" value="False" />
                    <value key="Test2" value="600" />
                </values>
            </group>
 
            <group name="TestGroup2">
                <values>
                    <value key="Test3" value="C:\Test\" />
                </values>
            </group>
 
        </groups>
    </custom>
    
</configuration>
```

<p>Transform file, it contains two parameters, one is Parameter1, value of which is optional (default value is there), and parameter Test3Value:</p>

```
<?xml version="1.0"?>
<configuration xmlns:xdt="http://schemas.microsoft.com/XML-Document-Transform">
    
    <custom>
        <groups>
            <group name="TestGroup1">
                <values>
                    <value key="Test2" value="601" xdt:Transform="Replace"  xdt:Locator="Match(key)" />
                    <value key="Test1" value="{Parameter1:True5665}" xdt:Transform="Replace"  xdt:Locator="Match(key)" />
                </values>
            </group>
            
            <group name="TestGroup2">
                <values>
                    <value key="Test3" value="{Test3Value}" xdt:Transform="Replace"  xdt:Locator="Match(key)" />
                </values>
            </group>
        </groups>
    </custom>
    
</configuration>
```

<p>Call tool from command line:</p>

```
ctt s:s.config t:t.config d:d.config p:Parameter1:True;Test3Value:"c:\Program Files\Test"
```

<p>As expected d.config:</p>

```
<?xml version="1.0"?>
<configuration>
  <custom>
    <groups>
      <group name="TestGroup1">
        <values>
          <value key="Test1" value="True" />
          <value key="Test2" value="601" />
        </values>
      </group>
      <group name="TestGroup2">
        <values>
          <value key="Test3" value="c:\Program Files\Test" />
        </values>
      </group>
    </groups>
  </custom>
</configuration>
```

<p>Tool has one more argument <em>fpt – </em>you can use this argument, if transform file contains parameters with default values and in command line you don’t set values for these parameters, so if you set this argument tool will set default values, in other way tool will not execute ParametersTask, because you don’t set list of parameters.</p>

<h2>Summary</h2>

<p>Maybe you can find a lot of bugs, so please if you see something or will see – just tell me. I will glad to get from you some advises for this tool. Source code and binary you can download from project site at CodePlex: <a href="http://ctt.codeplex.com">http://ctt.codeplex.com</a>, last version <a href="http://ctt.codeplex.com/releases/view/52027">Config Transformation Tool v1.1</a>.</p>
