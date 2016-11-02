---
layout: post
title: "TSQL: Passing array/list/set to stored procedure (MS SQL Server)"
date: 2010-08-28 09:18:00
categories: en
tags: [.NET, TSQL, SQL Server, Transact SQL, Bulk Insert, Table-Valued Parameters, Stored Procedures]
redirect_from: en/blog/show/224/
---
<p>Passing array/list/set to stored procedure is fairly common task when you are working with Databases. You can meet this when you want to filter some collection. Other case – it can be an import into database from extern sources. I will consider few solutions: creation of sql-query at server code, put set of parameters to sql stored procedure’s parameter with next variants: parameters separated by comma, bulk insert, and at last table-valued parameters (it is most interesting approach, which we can use from MS SQL Server 2008).</p>

<p>Ok, let’s suppose that we have list of items and we need to filter this items by categories (“TV”, “TV game device”, “DVD-player”) and by firms (“Firm 1”, “Firm2”, “Firm 3). It will look at database like this</p>

<p><img src="{{ site.url }}/library/images/02/tableparameters/01.png" /></p>

<p>And I will show you sample of this interface</p>

<p>

<div style="border-bottom: gray 2px solid; border-left: gray 2px solid; padding-bottom: 5px; padding-left: 5px; padding-right: 5px; border-top: gray 2px solid; border-right: gray 2px solid; padding-top: 5px">
  <fieldset>
    <legend>Filter</legend>

	<div style="width:600px;height:170px">
    <div style="float: left; width: 300px"><b>Categories</b> 

      <ul>
        <li><input type="checkbox" />TV</li>

        <li><input type="checkbox" />Games</li>

        <li><input type="checkbox" />DVD</li>

        <li><input type="checkbox" />CD</li>

        <li><input type="checkbox" />Players</li>
      </ul>
    </div>

    <div style="float: left; width: 300px"><b>Firms</b> 

      <ul>
        <li><input type="checkbox" />Firm 1 </li>

        <li><input type="checkbox" />Firm 2 </li>

        <li><input type="checkbox" />Firm 3 </li>

        <li><input type="checkbox" />Firm 4 </li>

        <li><input type="checkbox" />Firm 5 </li>
      </ul>
    </div>
	</div>
	
     <input type="button" value="Search" style="float:right" /><input type="button" value="Clear" style="float:right" /> 
	
</fieldset>

  <fieldset >
    <legend>Items</legend>

    <table style="border:gray solid 1px; width:600px"><tbody>
        <tr>
          <th>Item</th>

          <th>Category</th>

          <th>Firm</th>
        </tr>

        <tr>
          <td>TV 32'</td>

          <td>TV</td>

          <td>Firm 1</td>
        </tr>

        <tr>
          <td>XBox 360</td>

          <td>Games</td>

          <td>Firm 3</td>
        </tr>
     </tbody></table>
  </fieldset>
</div>
</p>

<p>So we need a query which will return us list of items from database. Also we need opportunity to filter these items by categories or by firms. We will filter them by identifiers. Ok, we know the mission. How we will solve it? Most easy way, used by junior developers – it is creating SQL-instruction with C# code, it can be like this </p>

```
List<int> categories = new List<int>() { 1, 2, 3 };
 
StringBuilder sbSql = new StringBuilder();
sbSql.Append(
  @"
    select i.Name as ItemName, f.Name as FirmName, c.Name as CategoryName 
    from Item i
      inner join Firm f on i.FirmId = f.FirmId
      inner join Category c on i.CategoryId = c.CategoryId
    where c.CategoryId in (");
if (categories.Count > 0)
{
  for (int i = 0; i < categories.Count; i ++)
  {
    if (i != 0)
      sbSql.Append(",");
    sbSql.Append(categories[i]);
  }
}
else
{
  sbSql.Append("-1"); // It is for empty result when no one category selected
}
sbSql.Append(")");
 
string sqlQuery = sbSql.ToString();
 
DataTable table = new DataTable();
using (SqlConnection connection = new SqlConnection("Data Source=(local);Initial Catalog=TableParameters;Integrated Security=SSPI;"))
{
  connection.Open();
  using (SqlCommand command = new SqlCommand(sqlQuery, connection))
  {
    using (SqlDataAdapter dataAdapter = new SqlDataAdapter(command))
    {
      dataAdapter.Fill(table);
    }
  }
}
 
//TODO: Working with table
```

<p>We will filter items only by categories. Just want to write less code. In the previous example first line is list of categories identifiers, chosen by user (user can select checkboxes). Problems of this solution are: a) sql-injections in some cases (user can change identifiers, which we get from web-form); b) not really good code support at feature when categories can be a really big set. One more problem – it will be hard to place this code to stored procedure (of course you can use exec statement at sql-server, but it will be not a good choice). So we can name this solution like “Solution #0”, because you can use it only if you are very lazy guy, or because this solution is very fast written. </p>

<h2>Solution #1. String – parameters separated by comma. </h2>

<p>In all next solutions we will use stored procedures at sql server. So first solution will be a list of parameters separated by comma in one string sql-parameter, like this ‘1,2,3,4’. First we need to create function at sql server, which create a table from this string parameter, name of this function will be Split:</p>

```
if object_id('Split') is not null 
    drop function split
go
 
create function dbo.Split
(
    @String varchar(max)
)
returns @SplittedValues table
(
    Id varchar(50) primary key
)
as
begin
    declare @SplitLength int, @Delimiter varchar(5)
    
    set @Delimiter = ','
    
    while len(@String) > 0
    begin 
        select @SplitLength = (case charindex(@Delimiter,@String) when 0 then
            len(@String) else charindex(@Delimiter,@String) -1 end)
 
        insert into @SplittedValues
        select substring(@String,1,@SplitLength) 
    
        select @String = (case (len(@String) - @SplitLength) when 0 then  ''
            else right(@String, len(@String) - @SplitLength - 1) end)
    end 
return  
end
```

<p>Now we can use this function in our stored procedure for looking items:</p>

```
if object_id('FindItems') is not null 
    drop proc FindItems
go
 
set ansi_nulls on
go 
set quoted_identifier on
go
 
create proc FindItems
(
    @categories varchar(max)
)
as
begin
    
  select i.Name as ItemName, f.Name as FirmName, c.Name as CategoryName 
  from Item i
    inner join Firm f on i.FirmId = f.FirmId
    inner join Category c on i.CategoryId = c.CategoryId
    inner join dbo.Split(@categories) cf on c.CategoryId = cf.Id
end 
```

<p>At last C# code, which will put filter to stored procedure and get list of products:</p>

```
List<int> categories = new List<int>() { 1, 2, 3 };
 
DataTable table = new DataTable();
using (SqlConnection connection = new SqlConnection("Data Source=(local);Initial Catalog=TableParameters;Integrated Security=SSPI;"))
{
  connection.Open();
  using (SqlCommand command = new SqlCommand("FindItems", connection) { CommandType = CommandType.StoredProcedure })
  {
    command.Parameters.AddWithValue("@categories", string.Join(",", categories));
    using (SqlDataAdapter dataAdapter = new SqlDataAdapter(command))
    {
      dataAdapter.Fill(table);
    }
  }
}
 
//TODO: Working with table
```


<p>Problems of this solution can be: composite primary keys, or string identifiers with commas. But in simple cases it can works. </p>

<p>These problems you can solve with another solution “<a href="http://weblogs.asp.net/jgalloway/archive/2007/02/16/passing-lists-to-sql-server-2005-with-xml-parameters.aspx">Passing lists to SQL Server with XML Parameters</a>”, I don’t consider this solution in my article, because you can get a more great explanation of how to do it, because I never use this solution in my developer’s life. </p>

<h2>Solution #2. BULK INSERT</h2>

<p>Problems which we had at previous solution we can solve with Bulk Insert solution. We will have a code which will copy .Net DataTable object to SQL Server temporary table. First let rewrite our stored procedure FindItems:</p>

```
if object_id('FindItems') is not null 
    drop proc FindItems
go
 
set ansi_nulls on
go 
set quoted_identifier on
go
 
create proc FindItems
as
begin
    if object_id('tempdb..#FilterCategory') is null 
    begin
        raiserror('#FilterCategory(id int) should be created', 16, 1)
        return
    end
    
    select i.Name as ItemName, f.Name as FirmName, c.Name as CategoryName 
    from Item i
        inner join Firm f on i.FirmId = f.FirmId
        inner join Category c on i.CategoryId = c.CategoryId
        inner join #FilterCategory cf on c.CategoryId = cf.Id
end 
```

<p>Now our procedure expects temporary table #FilterCategory, which you should create before using this SP. And now we should write more C# code than at previous time, we will create new repository class ItemsRepository:</p>

```
public class ItemsRepository
{
  public static DataTable FindItems(List<int> categories)
  {
    DataTable tbCategories = new DataTable("FilterCategory");
    tbCategories.Columns.Add("Id", typeof (int));
    categories.ForEach(x => tbCategories.Rows.Add(x));
 
    using (
      SqlConnection connection =
        new SqlConnection("Data Source=(local);Initial Catalog=TableParameters;Integrated Security=SSPI;"))
    {
      connection.Open();
      using (SqlTransaction transaction = connection.BeginTransaction())
      {
        try
        {
          string tableName = string.Format("tempdb..#{0}", tbCategories.TableName);
 
          CreateTableOnSqlServer(connection, transaction, tbCategories, tableName);
          CopyDataToSqlServer(connection, transaction, tbCategories, tableName);
 
          DataTable result = new DataTable();
          using (SqlCommand command = new SqlCommand("FindItems", connection, transaction)
                                        {CommandType = CommandType.StoredProcedure})
          {
            using (SqlDataAdapter dataAdapter = new SqlDataAdapter(command))
            {
              dataAdapter.Fill(result);
            }
          }
          transaction.Commit();
          return result;
        }
        catch
        {
          transaction.Rollback();
          throw;
        }
      }
    }
  }
 
  private static void CopyDataToSqlServer(SqlConnection connection, SqlTransaction transaction, DataTable table,
                                          string tableName)
  {
    using (SqlBulkCopy bulkCopy = new SqlBulkCopy(connection, SqlBulkCopyOptions.Default, transaction)
                                    {
                                      DestinationTableName = tableName
                                    })
    {
      bulkCopy.WriteToServer(table);
    }
  }
 
  private static void CreateTableOnSqlServer(SqlConnection connection, SqlTransaction transaction, DataTable table,
                                             string tableName)
  {
    StringBuilder sb = new StringBuilder();
 
    sb.AppendFormat("create table {0}(", tableName);
    foreach (DataColumn column in table.Columns)
    {
      sb.AppendFormat("{0} {1} {2}",
                      table.Columns.IndexOf(column) == 0 ? string.Empty : ",",
                      column.ColumnName, GetSqlType(column.DataType));
    }
    sb.Append(")");
 
    using (SqlCommand command = new SqlCommand(sb.ToString(), connection, transaction))
    {
      command.ExecuteNonQuery();
    }
  }
 
  private static string GetSqlType(Type type)
  {
    if (type == typeof (string))
      return string.Format("{0}(max)", SqlDbType.VarChar);
    else if (type == typeof (int))
      return SqlDbType.Int.ToString();
    else if (type == typeof (bool))
      return SqlDbType.Bit.ToString();
    else if (type == typeof (DateTime))
      return SqlDbType.DateTime.ToString();
    else if (type == typeof (Single))
      return SqlDbType.Float.ToString();
    else throw new NotImplementedException();
  }
}
```


<p>Method FindItems create new object of type DataTable, copy to this object list of identifiers (chosen by user), then method open new transaction, create on SQL server new temporary table #FilterCategories, copy DataTable to server in this temporary table and then call stored procedure FindItems. This temporary table will be live only in transaction scope, so when we will commit or rollback transaction this table will be dropped too, and if two user in same time will execute this code, each of them will have separate temporary table #FilterCategories. </p>

<p>I used this solution very often when I had a task – copy data from Excel file to SQL server or some other import data task.</p>

<p>Let find minuses of this solution: a lot of code – is not a problem, because we can refactor this code and put it in some application framework. Next minus is more than one query for this task. Other – if this stored procedure will execute some other, which will create new temporary table with same name we will have a problems (it can be some recursive call). Other minus – will be hard to work with this approach from Management Studio, we need always write a script for creating temporary table (and the main problem you need to remember which structure this table has):</p>

```
create table #FilterCategory(id int)
insert into #FilterCategory ( id ) values  ( 1  )
insert into #FilterCategory ( id ) values  ( 2 )
insert into #FilterCategory ( id ) values  ( 3  )
insert into #FilterCategory ( id ) values  ( 4  )
 
exec FindItems
 
drop table  #FilterCategory
```

<h2>Solution #3. Table-Valued Parameters (Database Engine)</h2>

<p>And the last solution which I want to show you – is the table-valued parameters. This approach is very similar to previous, but more simple. You can use it in MS SQL server with version 2008 or bigger. Ok, we need again rewrite out stored procedure FindItems, and we should create new table-valued type Identifiers:</p>


```
if object_id('FindItems') is not null 
    drop proc FindItems
go
 
if exists(select * from sys.types where name = 'Identifiers')
    drop type Identifiers
go
 
create type Identifiers AS TABLE 
( id int primary key);
go
 
set ansi_nulls on
go 
set quoted_identifier on
go
 
create proc FindItems
(
    @categories Identifiers readonly
)
as
begin
    select i.Name as ItemName, f.Name as FirmName, c.Name as CategoryName 
    from Item i
        inner join Firm f on i.FirmId = f.FirmId
        inner join Category c on i.CategoryId = c.CategoryId
        inner join @categories cf on c.CategoryId = cf.Id
end 
go
```

<p>Also we need to rewrite C# code</p>

```
List<int> categories = new List<int>() { 1, 2, 3 };
 
DataTable tbCategories = new DataTable("FilterCategory");
tbCategories.Columns.Add("Id", typeof(int));
categories.ForEach(x => tbCategories.Rows.Add(x));
 
DataTable table = new DataTable();
using (SqlConnection connection = new SqlConnection("Data Source=(local);Initial Catalog=TableParameters;Integrated Security=SSPI;"))
{
  connection.Open();
  using (SqlCommand command = new SqlCommand("FindItems", connection) { CommandType = CommandType.StoredProcedure })
  {
    command.Parameters.AddWithValue("@categories", tbCategories);
    using (SqlDataAdapter dataAdapter = new SqlDataAdapter(command))
    {
      dataAdapter.Fill(table);
    }
  }
}
```

<p>Now it is very easy, and it is easier to work with this stored procedure from Management Studio:</p>

```
declare @categories Identifiers
 
insert into @categories ( id ) values  ( 1  )
insert into @categories ( id ) values  ( 2 )
insert into @categories ( id ) values  ( 3  )
insert into @categories ( id ) values  ( 4  )
 
exec FindItems @categories
```

<p>Table-valued parameters solution has some limitations, like this parameter should be always read-only. If you want to know about performance of this solution you can look at this article <a href="http://msdn.microsoft.com/en-us/library/bb510489.aspx">Table-Valued Parameters (Database Engine),</a> also this article will show you when will be better to use Bulk Insert and when Table-valued parameters. </p>
