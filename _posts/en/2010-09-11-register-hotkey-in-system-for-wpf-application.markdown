---
layout: post
title: "Register hotkey in system for WPF application"
date: 2010-09-11 14:11:46
categories: en
tags: [.NET, C#, WPF, Hotkey]
redirect_from: en/blog/show/240/
---
<p>Couple days ago I got a question about how to register hotkey in Windows for WPF application. I remembered that one year ago I was solving the same problem in WinForms application, I was registering hot keys for my application, it was Vista Keys Extender project. I knew that my project worked, so I suggested author of question to use code of my project to solve his problem. But as we learned later in WPF message handle mechanism different from WinForms. So I started to find solution for WPF application. I copied my <a href="http://keysextender.codeplex.com/SourceControl/changeset/view/51053#330409">old code</a> from my old project and started to rewrite it step-by-step.</p>    <p>First off all we need to import WinAPI methods:</p>  

```
internal class HotKeyWinApi
{
    public const int WmHotKey = 0x0312;
 
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool RegisterHotKey(IntPtr hWnd, int id, ModifierKeys fsModifiers, Keys vk);
 
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool UnregisterHotKey(IntPtr hWnd, int id);
}
```

<p>In Vista Keys Extender project I implemented own enum KeyModifiers, but in WPF I don’t need to do this, because it has <a href="http://msdn.microsoft.com/en-us/library/system.windows.input.modifierkeys.aspx">System.Windows.Input.ModifierKeys</a>, which equals to my own enum. Also in my old project I used <a href="http://msdn.microsoft.com/en-us/library/system.windows.forms.keys.aspx">System.Windows.Forms.Keys</a>, but in WPF enum <a href="http://msdn.microsoft.com/en-us/library/system.windows.input.key.aspx">System.Windows.Input.Key</a> different, it has other values. I didn’t want to set reference from my new WPF project to assembly <em>System.Windows.Forms</em>, because I need just one enum. So I copied this enum from assembly to my new WPF project. Ok, so I did all preparations and now I need to realize main class HotKey:</p>

```
public sealed class HotKey : IDisposable
{
    public event Action<HotKey> HotKeyPressed;
 
    private readonly int _id;
    private bool _isKeyRegistered;
    readonly IntPtr _handle;
 
    public HotKey(ModifierKeys modifierKeys, Keys key, Window window)
        : this (modifierKeys, key, new WindowInteropHelper(window))
    {
        Contract.Requires(window != null);
    }
 
    public HotKey(ModifierKeys modifierKeys, Keys key, WindowInteropHelper window)
        : this(modifierKeys, key, window.Handle)
    {
        Contract.Requires(window != null);
    }
 
    public HotKey(ModifierKeys modifierKeys, Keys key, IntPtr windowHandle)
    {
        Contract.Requires(modifierKeys != ModifierKeys.None || key != Keys.None);
        Contract.Requires(windowHandle != IntPtr.Zero);
 
        Key = key;
        KeyModifier = modifierKeys;
        _id = GetHashCode();
        _handle = windowHandle;
        RegisterHotKey();
        ComponentDispatcher.ThreadPreprocessMessage += ThreadPreprocessMessageMethod;
    }
 
    ~HotKey()
    {
        Dispose();
    }
 
    public Keys Key { get; private set; }
 
    public ModifierKeys KeyModifier { get; private set; }
 
    public void RegisterHotKey()
    {
        if (Key == Keys.None)
            return;
        if (_isKeyRegistered)
            UnregisterHotKey();
        _isKeyRegistered = HotKeyWinApi.RegisterHotKey(_handle, _id, KeyModifier, Key);
        if (!_isKeyRegistered)
            throw new ApplicationException("Hotkey already in use");
    }
 
    public void UnregisterHotKey()
    {
        _isKeyRegistered = !HotKeyWinApi.UnregisterHotKey(_handle, _id);
    }
 
    public void Dispose()
    {
        ComponentDispatcher.ThreadPreprocessMessage -= ThreadPreprocessMessageMethod;
        UnregisterHotKey();
    }
 
    private void ThreadPreprocessMessageMethod(ref MSG msg, ref bool handled)
    {
        if (!handled)
        {
            if (msg.message == HotKeyWinApi.WmHotKey
                && (int)(msg.wParam) == _id)
            {
                OnHotKeyPressed();
                handled = true;
            }
        }
    }
 
    private void OnHotKeyPressed()
    {
        if (HotKeyPressed != null)
            HotKeyPressed(this);
    }
}
```

<p>And small sample of using:</p>

```
public partial class MainWindow : Window
{
    private HotKey _hotkey;
 
    public MainWindow()
    {
        InitializeComponent();
        Loaded += (s, e) =>
                      {
                          _hotkey = new HotKey(ModifierKeys.Windows | ModifierKeys.Alt, Keys.Left, this);
                          _hotkey.HotKeyPressed += (k) => Console.Beep();
                      };
    }
}
```

<p>You can look and download source code of this sample from my public SVN repository at <a href="https://www.assembla.com/code/outcoldman_p/subversion/nodes/BlogProjects/WpfApplicationHotKey">assembla</a>.</p>
