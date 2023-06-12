#r "C:\Program Files\workspacer\workspacer.Shared.dll"
#r "C:\Program Files\workspacer\plugins\workspacer.Bar\workspacer.Bar.dll"
#r "C:\Program Files\workspacer\plugins\workspacer.ActionMenu\workspacer.ActionMenu.dll"
#r "C:\Program Files\workspacer\plugins\workspacer.FocusIndicator\workspacer.FocusIndicator.dll"
#r "C:\Program Files\workspacer\plugins\workspacer.TitleBar\workspacer.TitleBar.dll"
#r "C:\Program Files\workspacer\plugins\workspacer.Gap\workspacer.Gap.dll"

using System;
using System.Collections.Generic;
using System.Linq;
using workspacer;
using workspacer.ActionMenu;
using workspacer.Bar.Widgets;
using workspacer.Bar;
// using workspacer.Color;
using workspacer.FocusIndicator;
using workspacer.TitleBar;
using workspacer.Gap;

public class FocusLayoutEngine : ILayoutEngine {
	// this is copy-pasted from the FullLayoutEngine source since I do not fully
	// understand how inheritance works. I wanted to do this with the above
	// child class that's currently commented out.
	private IWindow _lastFull;
	private static Logger Logger = Logger.Create();
	private readonly double _widthFrac;
	private readonly double _heightFrac;
	private readonly int yoffincrement;
	private readonly int xoffincrement;
	private int numWindows;
	public FocusLayoutEngine(): this(0.5, 0.75, 0) {}
	public FocusLayoutEngine(double widthFrac, double heightFrac, int offsetincrement) {
		_widthFrac = widthFrac;
		_heightFrac = heightFrac;
		yoffincrement = offsetincrement;
		xoffincrement = offsetincrement;
		Logger.Info("In the instantiator or generator or whatever");
	}
	private int CenteredPosition(int Size, int Total) {
		var empty = Total - Size;
		return empty / 2;
	}
	public IEnumerable<IWindowLocation> CalcLayout(IEnumerable<IWindow> windows, int spaceWidth, int spaceHeight) {
		var winWidth = (int)((double)spaceWidth * _widthFrac);
		var winHeight = (int)((double)spaceHeight * _heightFrac);
		var xPos = CenteredPosition(winWidth, spaceWidth);
		var yPos = CenteredPosition(winHeight, spaceHeight);
		var list = new List<IWindowLocation>();
		numWindows = windows.Count();
		if (numWindows == 0) {
			return list;
		}
		var windowList = windows.ToList();
		var noFocus = !windowList.Any(w => w.IsFocused);
		var yoffset = 0;
		for (var i = 0; i < numWindows; i++) {
			var window = windowList[i];
			var forceNormal = (noFocus && window == _lastFull) || window.IsFocused;
			var loopoffset = 0;
			if (forceNormal) {
				_lastFull = window;
			} else {
				yoffset += yoffincrement;
				loopoffset = yoffset;
			}
			forceNormal = forceNormal || yoffset != 0;
			list.Add(new WindowLocation(xPos, yPos-loopoffset, winWidth, winHeight, GetDesiredState(windowList[i], forceNormal)));
		}
		return list;
	}
	public string Name {
		get {
			return $"focus [/{numWindows}]";
		}
	}
	public void ShrinkPrimaryArea() { }
	public void ExpandPrimaryArea() { }
	public void ResetPrimaryArea() { }
	public void IncrementNumInPrimary() { }
	public void DecrementNumInPrimary() { }
	private WindowState GetDesiredState(IWindow window, bool forceNormal = false) {
		if (window.IsFocused || forceNormal) {
			return WindowState.Normal;
		} else {
			return WindowState.Minimized;
		}
	}
}

public class MultiLayoutEngine : ILayoutEngine {
	private readonly List<ILayoutEngine> layoutList;
	private readonly int numLayouts;
	private ILayoutEngine lastEngine;
	private static Logger Logger = Logger.Create();
	public MultiLayoutEngine(IEnumerable<ILayoutEngine> _layoutList) {
		layoutList = _layoutList.ToList();
		numLayouts = layoutList.Count();
		lastEngine = layoutList[0];
	}
	public IEnumerable<IWindowLocation> CalcLayout(IEnumerable<IWindow> windows, int spaceWidth, int spaceHeight) {
		// delegate the list and dimensions to the layout engines provided
		// the number of windows determines which engine to use:
		// numWindows 0 -> return the list
		// numWindows 1 -> layoutList[0]
		// keep using the last layout engine if the number of windows extends
		// beyond the number of engines
		var numWindows = windows.Count();
		if (numWindows == 0) {
			return new List<IWindowLocation>();
		}
		var engineIndex = ((numLayouts < numWindows) ? numLayouts : numWindows) - 1;
		// engineIndex -= 1;
		Logger.Info("engineIndex: {0}", engineIndex);
		lastEngine = layoutList[engineIndex];
		return lastEngine.CalcLayout(windows, spaceWidth, spaceHeight);
	}
	public string Name { get; set; } = "multi";
	public void ShrinkPrimaryArea() { lastEngine.ShrinkPrimaryArea(); }
	public void ExpandPrimaryArea() { lastEngine.ExpandPrimaryArea(); }
	public void ResetPrimaryArea() { lastEngine.ResetPrimaryArea(); }
	public void IncrementNumInPrimary() { lastEngine.IncrementNumInPrimary(); }
	public void DecrementNumInPrimary() { lastEngine.DecrementNumInPrimary(); }
}

Action<IConfigContext> doConfig = (context) => {
    // Uncomment to switch update branch (or to disable updates)
    //context.Branch = Branch.None;
	
	var myLogger = Logger.Create();

	var BlankText = new string(' ', 30);
    context.AddBar(new BarPluginConfig(){
		// 30 spaces holy shit it's complicated to extend a string in CSharp
		BarHeight = 20,
		FontSize = 12,
		FontName = "Fairfax Hax HD",
		// BarMargin = 10,
		LeftWidgets = () => new IBarWidget[] {
			new TextWidget(BlankText),
			new WorkspaceWidget(){
				WorkspaceHasFocusColor = new Color(0xC1, 0x9C, 0x00),
			},
			new TextWidget(": "),
			new TitleWidget(),
		},
		RightWidgets = () => new IBarWidget[] {
			new TextWidget("("),
			new ActiveLayoutWidget(),
			new TextWidget(")"),
			new TimeWidget(1000, "yyyy MMM dd hh:mm"),
			new BatteryWidget(),
			new TextWidget(BlankText),
		},
	});

	// var titleBarPluginConfig = new TitleBarPluginConfig(new TitleBarStyle(showTitleBar: false, showSizingBorder: false));
	// context.AddTitleBar(titleBarPluginConfig);

    context.AddFocusIndicator(new FocusIndicatorPluginConfig(){
		TimeToShow = 300,
	});

    // var actionMenu = context.AddActionMenu();

	// Layout Engine
	// context.DefaultLayouts = () => new ILayoutEngine[] {
	// 	new DwindleLayoutEngine(),
	// 	new FocusLayoutEngine()
	// };
	context.DefaultLayouts = () => new ILayoutEngine[] {
		new MultiLayoutEngine(new ILayoutEngine[] {
			new FocusLayoutEngine(0.5, 1.0, 0),
			new DwindleLayoutEngine()
		}),
		new FocusLayoutEngine(0.6, 0.9, 0),
		new FullLayoutEngine()
	};
	myLogger.Info("DefaultLayouts: {0}", context.DefaultLayouts);

	// Filters and Routes
	// context.WindowRouter.AddFilter((window) => !window.Title.Contains("rx"));
	context.WindowRouter.AddFilter((window) => !window.Title.Contains("User Account Control"));
	context.WindowRouter.AddFilter((window) => !window.Title.Contains("Device Manager"));
	context.WindowRouter.AddFilter((window) => !window.Title.Contains("Sticky Notes"));
	context.WindowRouter.AddFilter((window) => !window.Class.Contains("Tk"));

	// Keybinds
	// KeyModifiers mod = KeyModifiers.Alt;
	// context.Keybinds.Subscribe(mod, Keys.Enter, () => );
	// context.Keybinds.Subscribe((mod|Keys.Shift), Keys.Enter, () => );
	// context.Keybinds.Unsubscribe(KeyModifiers.Alt, Keys.Enter);

    context.WorkspaceContainer.CreateWorkspaces("1", "2", "3", "4", "5", "6", "7", "8", "9");
    context.CanMinimizeWindows = false; // false by default
	context.ConsoleLogLevel = LogLevel.Info;
};
return doConfig;
