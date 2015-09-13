---
layout: post
title: "Silverlight basics. Validation. Part 1. DataAnnotations & ValidatesOnExceptions"
date: 2010-11-17 19:51:00
categories: en
tags: [Silverlight, XAML, Validation]
redirect_from: en/blog/show/259/
---
<p>Silverlight 4 has some new ways for validate input values (some new approaches to implement validation in your application). First approach is <a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.dataannotations(VS.95).aspx">DataAnnotation</a>. In this case you should describe validation rules with attributes. Two other ways (both of them is came with Silverlight 4) – you should implement one of interfaces for your ViewModel: <a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.idataerrorinfo(VS.95).aspx">IDataErrorInfo</a> or <a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.inotifydataerrorinfo(VS.95).aspx">INotifyDataErrorInfo</a>. I want to talk about all of these approaches, about pros and cons of using each of them. Goal of this article to get a best way to implement validation of input values in my and your applications. This part of article about DataAnnotations.</p>    <h2>Background</h2>  <p>I have example. I want to describe all of these approaches on simple control “change password”.</p>  <p><img style="background-image: none; border-right-width: 0px; padding-left: 0px; padding-right: 0px; display: block; float: none; border-top-width: 0px; border-bottom-width: 0px; margin-left: auto; border-left-width: 0px; margin-right: auto; padding-top: 0px" title="Capture" border="0" alt="Capture" src="{{ site.url }}/library/2010/10/19/Capture_1F726807.png" width="587" height="84" /></p>  <p>It has two controls <a href="http://msdn.microsoft.com/en-us/library/system.windows.controls.passwordbox(VS.95).aspx">PasswordBox</a>, one button and <a href="http://msdn.microsoft.com/en-us/library/system.windows.controls.validationsummary(VS.95).aspx">ValidationSummary</a>. Each sample will have own ViewModel, but XAML of UserControl will be the same:</p>  

```
<UserControl x:Class="SilverlightValidation.MainPage"
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" 
    xmlns:sdk="http://schemas.microsoft.com/winfx/2006/xaml/presentation/sdk" 
    xmlns:DataAnnotations="clr-namespace:SilverlightValidation.DataAnnotations" 
    xmlns:SilverlightValidation="clr-namespace:SilverlightValidation"    
    mc:Ignorable="d" d:DesignHeight="300" d:DesignWidth="400">
 
    <UserControl.DataContext>
        <DataAnnotations:BindingModel />
    </UserControl.DataContext>
    
    <Grid x:Name="LayoutRoot" Background="White" Width="500">
 
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="Auto" />
            <ColumnDefinition Width="*" />
        </Grid.ColumnDefinitions>
        
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto" />
            <RowDefinition Height="Auto" />
            <RowDefinition Height="Auto" />
            <RowDefinition Height="Auto" />
        </Grid.RowDefinitions>
 
        <TextBlock HorizontalAlignment="Right">New Password:</TextBlock>
 
        <PasswordBox Grid.Column="1" Password="{Binding Path=NewPassword, Mode=TwoWay, 
            ValidatesOnNotifyDataErrors=True, ValidatesOnExceptions=True, ValidatesOnDataErrors=True, NotifyOnValidationError=True}" />
 
        <TextBlock Grid.Row="1" HorizontalAlignment="Right">New Password Confirmation:</TextBlock>
 
        <PasswordBox Grid.Row="1"  Grid.Column="1" Password="{Binding Path=NewPasswordConfirmation, Mode=TwoWay, 
            ValidatesOnNotifyDataErrors=True, ValidatesOnExceptions=True, ValidatesOnDataErrors=True, NotifyOnValidationError=True}"  />
 
        <Button Grid.Row="2" Grid.ColumnSpan="2" HorizontalAlignment="Right"  Content="Change" 
                Command="{Binding Path=ChangePasswordCommand}" />
 
        <sdk:ValidationSummary Grid.Row="3" Grid.ColumnSpan="2" />
        
    </Grid>
</UserControl>
```

<p>I had set 4 properties referred to validation in bindings for password boxes. For now I will tell only about <a href="http://msdn.microsoft.com/en-us/library/system.windows.data.binding.notifyonvalidationerror(VS.95).aspx">NotifyOnValidationError</a> property. I use it for notify ValidationSummary that some validation errors exist. </p>

<p>PasswordBox has only OneWay binding from control to source (security reason). Binding works only when focus changed (the same like with TextBox). In WPF you can change this behavior, you can set that binding should happened when user press some key (key down event). In Silverlight you can do the same with <a href="http://msdn.microsoft.com/en-us/library/cc265152(VS.95).aspx">Attached Property</a>:</p>

```
public static class UpdateSourceTriggerHelper
{
    public static readonly DependencyProperty UpdateSourceTriggerProperty =
        DependencyProperty.RegisterAttached("UpdateSourceTrigger", typeof(bool), typeof(UpdateSourceTriggerHelper),
                                            new PropertyMetadata(false, OnUpdateSourceTriggerChanged));
 
    public static bool GetUpdateSourceTrigger(DependencyObject d)
    {
        return (bool)d.GetValue(UpdateSourceTriggerProperty);
    }
 
    public static void SetUpdateSourceTrigger(DependencyObject d, bool value)
    {
        d.SetValue(UpdateSourceTriggerProperty, value);
    }
 
    private static void OnUpdateSourceTriggerChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
    {
        if (e.NewValue is bool && d is PasswordBox)
        {
            PasswordBox textBox = d as PasswordBox;
            textBox.PasswordChanged -= PassportBoxPasswordChanged;
 
            if ((bool)e.NewValue)
                textBox.PasswordChanged += PassportBoxPasswordChanged;
        }
    }
 
    private static void PassportBoxPasswordChanged(object sender, RoutedEventArgs e)
    {
        var frameworkElement = sender as PasswordBox;
        if (frameworkElement != null)
        {
            BindingExpression bindingExpression = frameworkElement.GetBindingExpression(PasswordBox.PasswordProperty);
            if (bindingExpression != null)
                bindingExpression.UpdateSource();
        }
    }
}
```

<p>If you want use it you should set this attached property for password box:</p>

```
<PasswordBox Grid.Column="1" Password="{Binding Path=NewPassword, Mode=TwoWay, 
    ValidatesOnNotifyDataErrors=True, ValidatesOnExceptions=True, ValidatesOnDataErrors=True, NotifyOnValidationError=True}"
    SilverlightValidation:UpdateSourceTriggerHelper.UpdateSourceTrigger="True"/>
```

<p>I will not use any frameworks, so I need own DelegateCommand (class which implements ICommand interface):</p>

```
public class DelegateCommand : ICommand
{
    private readonly Action<object> _execute;
    private readonly Func<object, bool> _canExecute;
 
    public DelegateCommand(Action<object> execute)
    {
        if (execute == null)
            throw new ArgumentNullException("execute");
        _execute = execute;
    }
 
    public DelegateCommand(Action<object> execute, Func<object, bool> canExecute)
        : this(execute)
    {
        if (canExecute == null)
            throw new ArgumentNullException("canExecute");
        _canExecute = canExecute;
    }
 
    public bool CanExecute(object parameter)
    {
        if (_canExecute != null)
            return _canExecute(parameter);
        return true;
    }
 
    public void Execute(object parameter)
    {
        _execute(parameter);
    }
 
    public void RaiseCanExecuteChanged()
    {
        CanExecuteChanged(this, EventArgs.Empty);
    }
 
    public event EventHandler CanExecuteChanged = delegate {};
}
```

<p><strong>This realization is no good, you can get memory leaks with it (<a href="http://compositewpf.codeplex.com/workitem/4065?ProjectName=compositewpf">Memory Leak caused by DelegateCommand.CanExecuteChanged Event</a>), so better will be get realization from Prism with version 2.1 and greater.&nbsp;</strong>&nbsp;</p>

<p>In my example I need next validation rules:</p>

<ul>
  <li>New password is required field;</li>

  <li>New password has limited length – 20 symbols (sad, but many developers forget about it, and get at production errors from DB ‘string truncated’);</li>

  <li>New Password Confirmation should be the same like New Password.</li>
</ul>

<h2>#1 DataAnnotations &amp; ValidatesOnExceptions</h2>

<p>This approach we had before Silverlight 4. I had start working with Silverlight only from third version, so I can say that in third version we had this approach. The only advantage of this type of validation that most .Net technologies have it (ASP.NET, WPF, WinForms). The basic idea in this way - show validation errors by throwing exceptions. In Silverlight 3 validation with throwing exceptions was only one way to implement validation (except your own realization). If you want to use this kind of validation you should set <a href="http://msdn.microsoft.com/en-us/library/system.windows.data.binding.validatesonexceptions(VS.95).aspx">ValidatesOnExceptions</a> to true at binding.</p>

<p>Let’s create our binding model. All examples will start from realization BindingModel class, which has implementation of <a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.inotifypropertychanged(VS.95).aspx">INotifyPropertyChanged</a> and three fields: two string fields which will store passwords and one is command. I will bind this command to button at user interface, this command will do changing password (I will initialize this command at ctor).</p>

```
public class BindingModel : INotifyPropertyChanged
{
    private string _newPassword;
    private string _newPasswordConfirmation;
 
    public DelegateCommand ChangePasswordCommand { get; private set; }
 
    #region INotifyPropertyChanged
 
    public event PropertyChangedEventHandler PropertyChanged = delegate { };
 
    private void OnPropertyChanged(string propertyName)
    {
        PropertyChanged(this, new PropertyChangedEventArgs(propertyName));
    }
 
    #endregion
}
```

<p>Also I need two helper methods:</p>

```
private bool IsValidObject()
{
    ICollection<ValidationResult> results = new Collection<ValidationResult>();
    return Validator.TryValidateObject(this, new ValidationContext(this, null, null), results, true) && results.Count == 0;
}
 
private void ValidateProperty(string propertyName, object value)
{
    Validator.ValidateProperty(value, new ValidationContext(this, null, null) { MemberName = propertyName });
}
```

<p>First will check that whole object BindingModel is valid. Second method checks that some property is valid. Both methods use class <a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.dataannotations.validator(VS.95).aspx">Validator</a>, this is Silverlight infrastructure. This class gets all validation rules from attributes and check that rules have valid state. Method IsValidObject returns Boolean result. Method ValidateProperty throw exception if some validation rule has invalid state. You can describe validation rules with attributes which inherit from <a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.dataannotations.validationattribute(VS.95).aspx">ValidationAttribute</a> (you can create your own attribute inheritable from this): <a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.dataannotations.stringlengthattribute(VS.95).aspx">StringLengthAttribute,</a> <a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.dataannotations.requiredattribute(VS.95).aspx">RequiredAttribute,</a> <a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.dataannotations.regularexpressionattribute(VS.95).aspx">RegularExpressionAttribute,</a> <a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.dataannotations.rangeattribute(VS.95).aspx">RangeAttribute,</a> <a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.dataannotations.datatypeattribute(VS.95).aspx">DataTypeAttribute</a>, <a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.dataannotations.customvalidationattribute(VS.95).aspx">CustomValidationAttribute</a>. You can learn all of these attributes with links. I will describe rules for my properties:</p>

```
[Required]
[StringLength(20)]
[Display(Name = "New password")]
public string NewPassword
{
    get { return _newPassword; }
    set
    {
        _newPassword = value;
        OnPropertyChanged("NewPassword");
        ChangePasswordCommand.RaiseCanExecuteChanged();
        ValidateProperty("NewPassword", value);
    }
}
 
[CustomValidation(typeof(BindingModel), "CheckPasswordConfirmation")]
[Display(Name = "New password confirmation")]
public string NewPasswordConfirmation
{
    get { return _newPasswordConfirmation; }
    set
    {
        _newPasswordConfirmation = value;
        OnPropertyChanged("NewPasswordConfirmation");
        ChangePasswordCommand.RaiseCanExecuteChanged();
        ValidateProperty("NewPasswordConfirmation", value);
    }
}
```

<p><em>NewPassword</em> property is simple. It has two validation rules, implemented by two attributes Required and StringLenght. Also it has <a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.dataannotations.displayattribute(VS.95).aspx">DisplayAttribute</a>, this attribute set property name for controls, like ValidationSummary, if the property did not have current attribute than we will see “NewPassword” at ValidationSummary. Both properties have in set methods equal sequence of operands: set value, notify that value is changed, raise command’s <em>CanExecute</em> method (if use it), and last operand is checking validation rules for current property. Property <em>NewPassword</em> has CustomValidationAttribute. The attribute has information about method and class type which contain this method. This method should perform validation. The attribute expects public static method, should return <a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.dataannotations.validationresult(VS.95).aspx">ValidationResult</a>, first parameter should has property’s type, also you can set second parameter <a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.dataannotations.validationcontext(VS.95).aspx">ValidationContext</a>. In my case I have next realization:</p>

```
public static ValidationResult CheckPasswordConfirmation(string value, ValidationContext context)
{
    var bindingModel = context.ObjectInstance as BindingModel;
    if (bindingModel == null)
        throw new NotSupportedException("ObjectInstance must be BindingModel");
 
    if (string.CompareOrdinal(bindingModel._newPassword, value) != 0)
        return new ValidationResult("Password confirmation not equal to password.");
 
    return ValidationResult.Success;
}
```

<p>Also we should implement command and command’s methods:</p>

```
public BindingModel()
{
    ChangePasswordCommand = new DelegateCommand(ChangePassword, CanChangePassword);
}
 
private bool CanChangePassword(object arg)
{
    return IsValidObject();
}
 
private void ChangePassword(object obj)
{
    if (ChangePasswordCommand.CanExecute(obj))
    {
        MessageBox.Show("Bingo!");
    }
}
```

<p>For both PasswordBox controls I set UpdateSourceTrigger=”True” in XAML. This is result (Silverlight sample):</p>
<object data="data:application/x-silverlight-2," type="application/x-silverlight-2" width="100%" height="150px">
		  <param name="source" value="/library/content/03/SLValidation/SilverlightValidation1.xap" />
		  <param name="background" value="white" />
		  <param name="minRuntimeVersion" value="4.0.50826.0" />
		  <param name="autoUpgrade" value="true" />
		  <a href="http://go.microsoft.com/fwlink/?LinkID=149156&amp;v=4.0.50826.0" style="text-decoration:none">
 			  <img src="http://go.microsoft.com/fwlink/?LinkId=161376" alt="Get Microsoft Silverlight" style="border-style:none" />
		  </a>
	    </object>

<p>Let’s speak about problems of this approach. Main problem – we throw exceptions at set methods. This can be a mess. If you will run your application with debugger you will see a lot of excess information (especially if you will set binding for each key down). Also you can’t set null or string.Empty (dump property) to NewPassword property without any backend property or method (you can’t use default property, because it will throw exception). In my case I can’t set nulls to properties NewPassword and NewPasswordConfirmation at control loading, because I will get exception. So I need write separate methods for each control, like Set[Property]Value. So these properties we can use only for binding. Really, this is mess. </p>

<p>Another problem – realization. I don’t like to raise CanExecute event on each property set. I don’t like to set button disabled while validation fails. I think this is unintelligible. When button is active always is better. So when user click button and all controls are empty he will get information about all errors on control, and he can step by step solve these problems. But with DataAnnotation and validation by exceptions you can’t do it easy (I don’t know how to do it easy). You can’t validate all ViewModel object, and notify ValidationSummary and controls about validation errors. You can do it hardly: you can raise UpdateBinding for each control on your control with some special class like Validation Scope which you should write.</p>

<p>Also I use in my sample <em>UpdateSourceTrigger</em>, because binding works only on focus change. So when user input NewPassword and then NewPasswordConfirmation he will see that button is still disabled (beause binding will occur for NewPasswordConfirmation only when he will change focus). This is mess. But when I use <em>UpdateSourceTrigger</em> I see on each key down validation error, this is no good too.</p>

<p>In my next article I will show you validation with <a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.idataerrorinfo(VS.95).aspx">IDataErrorInfo</a> and <a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.inotifydataerrorinfo(VS.95).aspx">INotifyDataErrorInfo</a>, these interfaces give us a more easy way to implement validation for our controls. </p>

<p>You can download this sample from my <a href="https://www.assembla.com/code/outcoldman_p/subversion/nodes/BlogProjects/SilverlightValidation?rev=9">assembla.com</a> repository. </p>
