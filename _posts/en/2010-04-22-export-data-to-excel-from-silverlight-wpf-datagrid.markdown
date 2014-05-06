---
layout: post
title: "Export data to Excel from Silverlight/WPF DataGrid"
date: 2010-04-22 06:43:00
categories: en
tags: [Silverlight, C#, Excel, Dynamic, WPF, XAML, WPF 4, Silverlight 4, DataGrid, COM]
alias: en/blog/show/201
---
<p>Data export from DataGrid to Excel is very common task, and it can be solved with different ways, and chosen way depend on kind of app which you are design. If you are developing app for enterprise, and it will be installed on several computes, then you can to advance a claim (system requirements) with which your app will be work for client. Or customer will advance system requirements on which your app should work. In this case you can use COM for export (use infrastructure of Excel or OpenOffice). This approach will give you much more flexibility and give you possibility to use all features of Excel app. About this approach I’ll speak below. Other way – your app is for personal use, it can be installed on any home computer, in this case it is not good to ask user to install MS Office or OpenOffice just for using your app. In this way you can use foreign tools for export, or export to xml/html format which MS Office can read (this approach used by JIRA). But in this case will be more difficult to satisfy user tasks, like create document with landscape rotation and with defined fields for printing.</p>

<h2>Integration with Excel from Silverlight 4 and .NET 4</h2>

<p>In Silverlight 4 and .NET 4 we have dynamic objects, which give us possibility to use MS Office COM objects without referenced to MS Office dlls. So for creating excel document in .NET 4 you can write this code::</p>

```
dynamic excel = Microsoft.VisualBasic.Interaction.CreateObject("Excel.Application", string.Empty);
```

<p>And in Silverlight 4 this:</p>

```
dynamic excel = AutomationFactory.CreateObject("Excel.Application");
```

<p>If you want to use AutomationFactory in Silverlight 4 app you need to set “Required elevated trust when running outside the browser” in project settings. You can check at code that your app have this privileges with property AutomationFactory.IsAvailable.</p>

<p>First, lets design new method, which will export to Excel two-dimension array:</p>

```
public static void ExportToExcel(object[,] data) { /* ... */ }
```

<p>Above I wrote how to get instance of Excel app. Now we will write some additional requirements for export:</p>

```
excel.ScreenUpdating = false;
dynamic workbook = excel.workbooks;
workbook.Add();
 
dynamic worksheet = excel.ActiveSheet;
 
const int left = 1;
const int top = 1;
int height = data.GetLength(0);
int width = data.GetLength(1);
int bottom = top + height - 1;
int right = left + width - 1;
 
if (height == 0 || width == 0)
  return;
```

<p>In this code we set that Excel will not show changes until we allow. This approach will give us little win in performance. Next we create new workbook and get active sheet of this book. And then get dimension of range where we will place our data.</p>

<p>Next step – export to Excel. When you export to excel with set data by cell this is slowly approach than export data to range of cells (you can try to compare speed of exporting with 1000 rows). So we will use setting data for range of cells:</p>

```
dynamic rg = worksheet.Range[worksheet.Cells[top, left], worksheet.Cells[bottom, right]];
rg.Value = data;
```

<p>Ok, our data in excel document. This approach work in .NET, but doesn’t work in Silverlight 4. When I tried to export data like I wrote above I got exception&#160; </p>

```
{System.Exception: can't convert an array of rank [2] 
   at MS.Internal.ComAutomation.ManagedObjectMarshaler.MarshalArray(Array array, ComAutomationParamWrapService paramWrapService, ComAutomationInteropValue& value) 
   at MS.Internal.ComAutomation.ManagedObjectMarshaler.MarshalObject(Object obj, ComAutomationParamWrapService paramWrapService, ComAutomationInteropValue& value, Boolean makeCopy) 
   at MS.Internal.ComAutomation.ComAutomationObject.InvokeImpl(Boolean tryInvoke, String name, ComAutomationInvokeType invokeType, Object& returnValue, Object[] args) 
   at MS.Internal.ComAutomation.ComAutomationObject.Invoke(String name, ComAutomationInvokeType invokeType, Object[] args) 
   at System.Runtime.InteropServices.Automation.AutomationMetaObjectProvider.TrySetMember(SetMemberBinder binder, Object value) 
   at System.Runtime.InteropServices.Automation.AutomationMetaObjectProviderBase.<.cctor>b__3(Object obj, SetMemberBinder binder, Object value) 
   at CallSite.Target(Closure , CallSite , Object , Object[,] ) 
   at System.Dynamic.UpdateDelegates.UpdateAndExecute2[T0,T1,TRet](CallSite site, T0 arg0, T1 arg1) 
   at ExportToExcelTools.ExportManager.ExportToExcel(Object[,] data) 
   at ExportToExcelTools.DataGridExcelTools.StartExport(Object data) 
   at System.Threading.ThreadHelper.ThreadStart_Context(Object state) 
   at System.Threading.ExecutionContext.Run(ExecutionContext executionContext, ContextCallback callback, Object state, Boolean ignoreSyncCtx) 
   at System.Threading.ExecutionContext.Run(ExecutionContext executionContext, ContextCallback callback, Object state) 
   at System.Threading.ThreadHelper.ThreadStart(Object obj)}
```

<p>But I could export one-dimension arrays (one row), so I think this is problem of Silverlight, <a href="https://connect.microsoft.com/VisualStudio/feedback/details/552759/when-exporting-two-dimension-array-to-range-of-excel-doc-with-automationfactory-in-silverlight-4-get-exception">I posted</a> bug in section .net 4 on <a href="http://connect.microsoft.com">http://connect.microsoft.com</a>. </p>

<p>For export in Silverlight I use this code (export by rows):</p>

```
for (int i = 1; i <= height; i++)
{
  object[] row = new object[width];
  for (int j = 1; j <= width; j++)
  {
    row[j - 1] = data[i - 1, j - 1];
  }
  dynamic r = worksheet.Range[worksheet.Cells[i, left], worksheet.Cells[i, right]];
  r.Value = row;
  r = null;
}
```

<p>If you are developing app just for Silverlight you can use some other data structure instead of array. I try to write code which will work at .NET and Silverlight so I will use arrays. </p>

<p>After data export we should to set to Excel object that it can apply changes, and then we will show it:</p>

```
excel.ScreenUpdating = true;
excel.Visible = true;
```

<p>Before this we can set more beautiful view of our document:</p>

```
// Set borders
for (int i = 1; i <= 4; i++)
  rg.Borders[i].LineStyle = 1;
 
// Set auto columns width
rg.EntireColumn.AutoFit();
 
// Set header view
dynamic rgHeader = worksheet.Range[worksheet.Cells[top, left], worksheet.Cells[top, right]];
rgHeader.Font.Bold = true;
rgHeader.Interior.Color = 189 * (int)Math.Pow(16, 4) + 129 * (int)Math.Pow(16, 2) + 78; // #4E81BD
```

<p>With this code we set borders, set auto size for cells and mark out first row (with background color and special style for text – it will be bold): it will be header, which will show DataGrid column’s headers. If you want to set more you can use Excel macros to get how to change document view: you need to start record macro, then change interface by hand, end record macro and look at macro code. </p>

<p>At the end of export you need to clean resources. In .NET for solve this you can use method Marshal.ReleaseComObject(…), but Silverlight doesn’t have this method, but we can set null to variables and then invoke garbage collector collect method:</p>

```
#if SILVERLIGHT
#else
Marshal.ReleaseComObject(rg);
Marshal.ReleaseComObject(rgHeader);
Marshal.ReleaseComObject(worksheet);
Marshal.ReleaseComObject(workbook);
Marshal.ReleaseComObject(excel);
#endif
rg = null;
rgHeader = null;
worksheet = null;
workbook = null;
excel = null;
GC.Collect();
```

<p>So know we have this code:</p>

```
using System;
#if SILVERLIGHT
using System.Runtime.InteropServices.Automation;
#else
using System.Runtime.InteropServices;
#endif
 
namespace ExportToExcelTools
{
  public static class ExportManager
  {
    public static void ExportToExcel(object[,] data)
    {
#if SILVERLIGHT
      dynamic excel = AutomationFactory.CreateObject("Excel.Application");
#else
      dynamic excel = Microsoft.VisualBasic.Interaction.CreateObject("Excel.Application", string.Empty);
#endif
 
      excel.ScreenUpdating = false;
      dynamic workbook = excel.workbooks;
      workbook.Add();
 
      dynamic worksheet = excel.ActiveSheet;
 
      const int left = 1;
      const int top = 1;
      int height = data.GetLength(0);
      int width = data.GetLength(1);
      int bottom = top + height - 1;
      int right = left + width - 1;
 
      if (height == 0 || width == 0)
        return;
 
      dynamic rg = worksheet.Range[worksheet.Cells[top, left], worksheet.Cells[bottom, right]];
#if SILVERLIGHT
      //With setting range value for recnagle export will be fast, but this aproach doesn't work in Silverlight
      for (int i = 1; i <= height; i++)
      {
        object[] row = new object[width];
        for (int j = 1; j <= width; j++)
        {
          row[j - 1] = data[i - 1, j - 1];
        }
        dynamic r = worksheet.Range[worksheet.Cells[i, left], worksheet.Cells[i, right]];
        r.Value = row;
        r = null;
      }
#else
      rg.Value = data;
#endif
 
      // Set borders
      for (int i = 1; i <= 4; i++)
        rg.Borders[i].LineStyle = 1;
 
      // Set auto columns width
      rg.EntireColumn.AutoFit();
 
      // Set header view
      dynamic rgHeader = worksheet.Range[worksheet.Cells[top, left], worksheet.Cells[top, right]];
      rgHeader.Font.Bold = true;
      rgHeader.Interior.Color = 189 * (int)Math.Pow(16, 4) + 129 * (int)Math.Pow(16, 2) + 78; // #4E81BD
      
      // Show excel app
      excel.ScreenUpdating = true;
      excel.Visible = true;
 
#if SILVERLIGHT
#else
      Marshal.ReleaseComObject(rg);
      Marshal.ReleaseComObject(rgHeader);
      Marshal.ReleaseComObject(worksheet);
      Marshal.ReleaseComObject(workbook);
      Marshal.ReleaseComObject(excel);
#endif
      rg = null;
      rgHeader = null;
      worksheet = null;
      workbook = null;
      excel = null;
      GC.Collect();
    }
  }
}
```

<h2>Export data from DataGrid to two-dimension array</h2>

<p>So we have method which export array to Excel, now we need to write method which will export DataGrid data to array. In WPF we can get all items with <em>Items</em> property, but in Silverlight this property is internal. But we can use ItemsSource property and cast it to List:</p>

```
List<object> list = grid.ItemsSource.Cast<object>().ToList();
```

<p>Before we realize export I want to think about features we need:</p>

<ol>
  <li>In some cases we want to export not all columns from data grid, so we need an approach to disable export some of columns. </li>

  <li>In some cases columns don’t have header (text header), but in excel we want to see text header or header with other text than data grid have, so we need an approach to set header text for export. </li>

  <li>It is easy to get which properties of object need to show in excel cell for columns with types inherited from DataGridBoundColumn because it has Binding with Path, with which we can get path for export value. But in case when we use DataGridTemplateColumn it is more hardly to find out which values of which property need to export. This is why we need an approach to set custom path for export (more we can use SortMemberPath). </li>

  <li>We need to set formatting for export to Excel. </li>
</ol>

<p>I solved all of this problems with attached properties:</p>

```
/// <summary>
/// Include current column in export report to excel
/// </summary>
public static readonly DependencyProperty IsExportedProperty = DependencyProperty.RegisterAttached("IsExported",
                                                                                typeof(bool), typeof(DataGrid), new PropertyMetadata(true));
 
/// <summary>
/// Use custom header for report
/// </summary>
public static readonly DependencyProperty HeaderForExportProperty = DependencyProperty.RegisterAttached("HeaderForExport",
                                                                                typeof(string), typeof(DataGrid), new PropertyMetadata(null));
 
/// <summary>
/// Use custom path to get value for report
/// </summary>
public static readonly DependencyProperty PathForExportProperty = DependencyProperty.RegisterAttached("PathForExport",
                                                                                typeof(string), typeof(DataGrid), new PropertyMetadata(null));
 
/// <summary>
/// Use custom path to get value for report
/// </summary>
public static readonly DependencyProperty FormatForExportProperty = DependencyProperty.RegisterAttached("FormatForExport",
                                                                                typeof(string), typeof(DataGrid), new PropertyMetadata(null));
 
#region Attached properties helpers methods
 
public static void SetIsExported(DataGridColumn element, Boolean value)
{
  element.SetValue(IsExportedProperty, value);
}
 
public static Boolean GetIsExported(DataGridColumn element)
{
  return (Boolean)element.GetValue(IsExportedProperty);
}
 
public static void SetPathForExport(DataGridColumn element, string value)
{
  element.SetValue(PathForExportProperty, value);
}
 
public static string GetPathForExport(DataGridColumn element)
{
  return (string)element.GetValue(PathForExportProperty);
}
 
public static void SetHeaderForExport(DataGridColumn element, string value)
{
  element.SetValue(HeaderForExportProperty, value);
}
 
public static string GetHeaderForExport(DataGridColumn element)
{
  return (string)element.GetValue(HeaderForExportProperty);
}
 
public static void SetFormatForExport(DataGridColumn element, string value)
{
  element.SetValue(FormatForExportProperty, value);
}
 
public static string GetFormatForExport(DataGridColumn element)
{
  return (string)element.GetValue(FormatForExportProperty);
}
 
#endregion
```

<p>Then I use this code for getting all columns for export:</p>

```
List<DataGridColumn> columns = grid.Columns.Where(x => (GetIsExported(x) && ((x is DataGridBoundColumn)
          || (!string.IsNullOrEmpty(GetPathForExport(x))) || (!string.IsNullOrEmpty(x.SortMemberPath))))).ToList();
```

<p>With this code we get all columns with true values of IsExported attached property (I set true as default value for this attached property above) and for which I can get export path (binding or custom setting path, or SortMemberPath is not null). </p>

<p>Next we will create new two-dimension array, first dimension is number of elements plus one – for header. And then set text headers into first row of array:</p>

```
// Create data array (using array for data export optimization)
object[,] data = new object[list.Count + 1, columns.Count];
 
// First row will be headers
for (int columnIndex = 0; columnIndex < columns.Count; columnIndex++)
  data[0, columnIndex] = GetHeader(columns[columnIndex]);
```

<p>Method GetHeader try to get values from HeaderForExport attached property for current column and if it has null value method get header from column:</p>

```
private static string GetHeader(DataGridColumn column)
{
  string headerForExport = GetHeaderForExport(column);
  if (headerForExport == null && column.Header != null)
    return column.Header.ToString();
  return headerForExport;
}
```

<p>Then we fill array with values from DataGrid:</p>

```
for (int columnIndex = 0; columnIndex < columns.Count; columnIndex++)
{
  DataGridColumn gridColumn = columns[columnIndex];
 
  string[] path = GetPath(gridColumn);
 
  string formatForExport = GetFormatForExport(gridColumn);
 
  if (path != null)
  {
    // Fill data with values
    for (int rowIndex = 1; rowIndex <= list.Count; rowIndex++)
    {
      object source = list[rowIndex - 1];
      data[rowIndex, columnIndex] = GetValue(path, source, formatForExport);
    }
  }
}
```

Method GetPath is easy, it try to get path from set by attached property value or binding or SortMemberPath. I only support easy paths: with only properties as chain of path, I don’t support arrays or static elements in paths, and of course I mean that binding set for current row item: 

```
private static string[] GetPath(DataGridColumn gridColumn)
{
  string path = GetPathForExport(gridColumn);
 
  if (string.IsNullOrEmpty(path))
  {
    if (gridColumn is DataGridBoundColumn)
    {
      Binding binding = ((DataGridBoundColumn)gridColumn).Binding as Binding;
      if (binding != null)
      {
        path = binding.Path.Path;
      }
    }
    else
    {
      path = gridColumn.SortMemberPath;
    }
  }
 
  return string.IsNullOrEmpty(path) ? null : path.Split('.');
}
```

<p>After getting path value with method GetValue we will try to get value by this path for current item:</p>

```
private static object GetValue(string[] path, object obj, string formatForExport)
{
  foreach (string pathStep in path)
  {
    if (obj == null)
      return null;
 
    Type type = obj.GetType();
    PropertyInfo property = type.GetProperty(pathStep);
 
    if (property == null)
    {
      Debug.WriteLine(string.Format("Couldn't find property '{0}' in type '{1}'", pathStep, type.Name));
      return null;
    }
 
    obj = property.GetValue(obj, null);
  }
 
  if (!string.IsNullOrEmpty(formatForExport))
    return string.Format("{0:" + formatForExport + "}", obj);
 
  return obj;
}
```

<h2>Sample</h2>

<p>For sample I wrote some model classes and fill test data:</p>

```
public class Person
{
  public string Name { get; set; }
  public string Surname { get; set; }
  public DateTime DateOfBirth { get; set; }
}
 
public class ExportToExcelViewModel
{
  public ObservableCollection<Person> Persons
  {
    get
    {
      ObservableCollection<Person> collection = new ObservableCollection<Person>();
      for (int i = 0; i < 100; i++)
        collection.Add(new Person()
        {
          Name = "Person Name " + i,
          Surname = "Person Surname " + i,
          DateOfBirth = DateTime.Now.AddDays(i)
        });
      return collection;
    }
  }
}
```

<p>In WPF window I use this xaml declaration:</p>

```
<Window x:Class="ExportToExcelSample.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
        xmlns:ExportToExcelSample="clr-namespace:ExportToExcelSample" 
        xmlns:ExportToExcelTools="clr-namespace:ExportToExcelTools;assembly=ExportToExcelTools" >
    <Window.DataContext>
        <ExportToExcelSample:ExportToExcelViewModel />
    </Window.DataContext>
    <ScrollViewer>
        <StackPanel>
            <Button Click="Button_Click">Export To Excel</Button>
            <DataGrid x:Name="grid" ItemsSource="{Binding Persons}" AutoGenerateColumns="False" >
                <DataGrid.Columns>
                    <DataGridTextColumn Binding="{Binding Path=Name}" Header="Name" />
                    <DataGridTextColumn Binding="{Binding Path=Surname}" Header="Surname" 
                                        ExportToExcelTools:DataGridExcelTools.HeaderForExport="SecondName" />
                    <DataGridTemplateColumn ExportToExcelTools:DataGridExcelTools.FormatForExport="dd.MM.yyyy"
                                             ExportToExcelTools:DataGridExcelTools.PathForExport="DateOfBirth"
                                             ExportToExcelTools:DataGridExcelTools.HeaderForExport="Date Of Birth">
                        <DataGridTemplateColumn.CellTemplate>
                            <DataTemplate>
                                <StackPanel>
                                    <TextBlock Text="{Binding Path=DateOfBirth, StringFormat=dd.MM.yyyy}" />
                                    <TextBlock Text="{Binding Path=DateOfBirth, StringFormat=HH:mm}" />
                                </StackPanel>
                            </DataTemplate>
                        </DataGridTemplateColumn.CellTemplate>
                    </DataGridTemplateColumn>
                </DataGrid.Columns>
            </DataGrid>
        </StackPanel>
    </ScrollViewer>
</Window>
```

<p>And method Button_Click with this code:</p>

```
private void Button_Click(object sender, RoutedEventArgs e)
{
  grid.ExportToExcel();
}
```

<p>Where ExportToExcel is extension method for DataGridm which invoke export to Excel method with separate thread. That's all. In Silverlight 4 code will be exactly the same. Below I’ll put anchor with samples for Silverlight 4 and WPF 4 (solution for Visual Studio 2010).</p>

<h2>Conclusion</h2>

<p>My approach very easy allows you to set how to export data from DataGrid with attached properties. If you want to use this approach I recommend you design new features: show busy indicator when data is exporting, and use OpenOffice when Excel is not installed on computer. Thanks.</p>

Download sample: <a href="/library/content/01/ExportToExcelTools.zip">ExportToExcelTools.zip</a>

<h4>Updated</h4>

<ul> 
<li>Add opportunity to export DataGrid with DataSet data as DataSource. </li>
<li>Put SetTextFormat parameter which will set 'Text Format' for all cells in Excel file. </li>
</ul>

<p>You can download last source code from my assembla source code repository <a href="https://www.assembla.com/code/outcoldman_p/subversion/nodes/BlogProjects/ExportToExcelTools">ExportToExcelTools</a></p>
