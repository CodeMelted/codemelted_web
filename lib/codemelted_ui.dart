// ignore_for_file: avoid_web_libraries_in_flutter,
// ignore_for_file: non_constant_identifier_names
/*
===============================================================================
MIT License

© 2024 Mark Shaffer. All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
===============================================================================
*/

/// Covers the User Interface use cases for constructing a Single Page
/// Application (SPA) for a Progressive Web Application (PWA).
library codemelted_ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/services.dart';

// ============================================================================
// [Setup our Main View Support Objects] ======================================
// ============================================================================

// Global key to support proper display of popup dialogs
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

/// Identifies which [CAppView] widget triggered an action via the
/// [CAppActionTriggeredCB] callback.
enum CAppActionTrigger {
  action,
  drawer,
  navigation,
}

/// Callback to support the [CAppView] widget allowing for proper support of
/// handling triggered actions from the [CAppActionTrigger] enumeration
/// signaling which [CActionItem] was tapped or clicked identifiable by its
/// title.
typedef CAppActionTriggeredCB = void Function(CAppActionTrigger, String);

/// Data items supporting the construction of different action event based
/// widgets providing information necessary to create the underlying widget.
class CActionItem {
  /// Label (for some widgets) and key for the [CAppActionTriggeredCB]
  /// callback.
  final String title;

  /// Either the already nice Icons constants or custom icon via the Image
  /// class.
  final IconData icon;

  /// Optional tooltip to provide with the given widget.
  final String? tooltip;

  const CActionItem({
    required this.title,
    required this.icon,
    this.tooltip,
  });
}

/// Provides the title for the header of the [CAppView] widget.
class CHeaderTitleItem extends StatefulWidget {
  /// A string title to display on the [CAppView] header area. This can only
  /// be used by itself and not with the logo properties. Only one or the
  /// other can be used.
  final String? title;

  /// The font size to set the title too if utilized.
  final double? fontSize;

  /// The main logo resource to display in desktop and tablet view.
  /// This cannot be used in conjunction with the title.
  final String? logoMain;

  /// The mobile logo resource to display when on a mobile view.
  /// This cannot be used in conjunction with the title.
  final String? logoMobile;

  /// Determines the height to set the logo to.
  final double? logoHeight;

  /// The determining width to transition the logo
  final double logoTransition;

  /// Will determine if we are using a logo resource or not.
  bool get isLogoSet =>
      logoMain != null &&
      logoMobile != null &&
      logoMain!.isNotEmpty &&
      logoMobile!.isNotEmpty;

  /// Will determine if we are using a title or not.
  bool get isTitleSet => title != null && title!.isNotEmpty;

  CHeaderTitleItem({
    super.key,
    this.title,
    this.fontSize,
    this.logoMain,
    this.logoMobile,
    this.logoHeight,
    this.logoTransition = 550,
  }) {
    assert(
      isLogoSet != isTitleSet,
      "Only the title or logos can be used at once",
    );
  }

  @override
  State<StatefulWidget> createState() => _CHeaderTitleItemState();
}

class _CHeaderTitleItemState extends State<CHeaderTitleItem> {
  @override
  Widget build(BuildContext context) {
    Widget? w;
    if (widget.isTitleSet) {
      w = Text(
        widget.title!,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: widget.fontSize,
        ),
      );
    } else {
      final width = MediaQuery.of(context).size.width;
      w = width >= widget.logoTransition
          ? Image.asset(
              widget.logoMain!,
              height: widget.logoHeight,
            )
          : Image.asset(
              widget.logoMobile!,
              height: widget.logoHeight,
            );
    }

    return w;
  }
}

/// Provides the control of the [CAppView] state for switching widget content,
/// displaying dialogs, and changing the overall look of the application.
class CAppController extends ChangeNotifier {
  // Member Fields:
  final _fullScreenSaveState = <String, dynamic>{};
  final _data = <String, dynamic>{};

  /// Retrieves or updates the app title.
  String get appTitle => _data["appTitle"].toString();
  set appTitle(String v) => _updateAndNotify("appTitle", v);

  /// Retrieves or updates the app theme.
  ThemeData? get appTheme => _data["appTheme"] as ThemeData?;
  set appTheme(ThemeData? v) => _updateAndNotify("appTheme", v);

  /// Retrieves or updates the content area of the app.
  Widget get content => _data["content"] as Widget;
  set content(Widget v) => _updateAndNotify("content", v);

  /// Retrieves or updates the background color of the header / footer areas.
  Color? get backgroundColor => _data["backgroundColor"] as Color?;
  set backgroundColor(Color? v) => _updateAndNotify("backgroundColor", v);

  /// Retrieves or updates the foreground color of the header / footer areas.
  Color? get foregroundColor => _data["foregroundColor"] as Color?;
  set foregroundColor(Color? v) => _updateAndNotify("foregroundColor", v);

  /// Retrieves or updates the selected color of actions in the footer areas.
  Color? get selectedItemColor => _data["selectedItemColor"] as Color?;
  set selectedItemColor(Color? v) => _updateAndNotify("selectedItemColor", v);

  /// Retrieves or updates the shadow color of the header to add some
  /// decoration to a header area with elevation.
  Color? get shadowColor => _data["shadowColor"] as Color?;
  set shadowColor(Color? v) => _updateAndNotify("shadowColor", v);

  /// Retrieves or updates the elevation of the header / footer areas.
  double? get elevation => _data["elevation"] as double?;
  set elevation(double? v) => _updateAndNotify("elevation", v);

  /// Retrieves or updates the font sizes of actions in the header / footer
  /// areas.
  double get fontSize => _data["fontSize"] as double;
  set fontSize(double v) => _updateAndNotify("fontSize", v);

  /// Retrieves or updates the icon sizes of action in the header / footer
  /// areas.
  double? get iconSize => _data["iconSize"] as double?;
  set iconSize(double? v) => _updateAndNotify("iconSize", v);

  /// Retrieves or updates the header size.
  double? get height => _data["height"] as double?;
  set height(double? v) => _updateAndNotify("height", v);

  /// Retrieves or updates the drawer width.
  double? get width => _data["width"] as double?;
  set width(double? v) => _updateAndNotify("width", v);

  /// Retrieves or updates the slide out drawer of options associated with the
  /// header.
  List<CActionItem>? get drawer => _data["drawer"] as List<CActionItem>?;
  set drawer(List<CActionItem>? v) => _updateAndNotify("drawer", v);

  /// Retrieves or updates the header title configured for the app header area.
  CHeaderTitleItem? get headerTitle =>
      _data["headerTitle"] as CHeaderTitleItem?;
  set headerTitle(CHeaderTitleItem? v) => _updateAndNotify("headerTitle", v);

  /// Retrieves or updates the header actions that make up actions to the right
  /// of the header logo or title.
  List<CActionItem>? get headerActions =>
      _data["headerActions"] as List<CActionItem>?;
  set headerActions(List<CActionItem>? v) =>
      _updateAndNotify("headerActions", v);

  /// Retrieves or updates the floater widget placed in the bottom right hand
  /// corner of the app content area.
  Widget? get floater => _data["floater"] as Widget?;
  set floater(Widget? v) => _updateAndNotify("floater", v);

  /// Retrieves or updates the footer actions that make up the bottom
  /// navigation.
  List<CActionItem>? get footerActions =>
      _data["footerActions"] as List<CActionItem>?;
  set footerActions(List<CActionItem>? v) =>
      _updateAndNotify("footerActions", v);

  /// Supports the showFullScreen option by attaching a close button
  /// to the view when a full screen page is shown.
  Widget? get closeButton => _data["closeButton"] as Widget?;
  set closeButton(Widget? v) => _updateAndNotify("closeButton", v);

  /// Determines if a full screen dialog is present or not.
  bool get isFullScreenShown => _fullScreenSaveState.isNotEmpty;

  /// Closes an open dialog and returns an answer depending on the type of
  /// dialog shown.
  void closeDialog<T>([T? answer]) async {
    if (isFullScreenShown) {
      _data.clear();
      _data.addAll(_fullScreenSaveState);
      _fullScreenSaveState.clear();
      notifyListeners();
    } else {
      Navigator.of(_navigatorKey.currentContext!, rootNavigator: true)
          .pop(answer);
    }
  }

  /// Provides the ability to show a full page within the [CAppView] changing
  /// the header, removing the drawer, and presenting a close button with
  /// icons for performing additional actions if necessary.
  void showFullScreen({
    required String title,
    required Widget content,
    List<CActionItem>? actions,
    void Function(String)? onAction,
  }) async {
    // If a full screen is already shown, just return.
    if (isFullScreenShown) {
      return;
    }

    // Go save the state so we can provide a custom scaffold
    _fullScreenSaveState.addAll(_data);

    // Update our state
    drawer = null;
    this.content = content;
    headerActions = actions;
    headerTitle = CHeaderTitleItem(title: title);
    closeButton = IconButton(
      icon: const Icon(Icons.close),
      onPressed: () => closeDialog(),
    );
  }

  /// Shows a rounded snackbar at the bottom of the content area to display
  /// some information.
  void showSnackbar({
    required String message,
    double? width,
    int? seconds,
  }) =>
      ScaffoldMessenger.of(_navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: seconds != null
              ? Duration(seconds: seconds)
              : const Duration(seconds: 4),
          width: width,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      );

  /// Supports updating the application state and notifying to update the
  /// widget state.
  void _updateAndNotify(String key, dynamic value) {
    _data[key] = value;
    notifyListeners();
  }
}

/// This represents the main view for an entire Progressive Web Application.
/// This in combination with the [CAppController] provide all the tools
/// necessary to quickly construct and control the PWA as a Single Page
/// Application.
class CAppView extends StatefulWidget {
  /// The title for the overall application.
  final String appTitle;

  /// The theme to apply to the application
  final ThemeData? appTheme;

  /// Provides the ability to update and control state on this widget.
  final CAppController controller;

  /// This represents the main body of the view. It should be the primary focus
  /// of how you present your application as compared to the header and footer.
  /// This will also be affected by the appTheme you set where the header and
  /// footers will be for the most part fixed in color.
  final Widget content;

  /// Callback handler for when a [CActionItem] has triggered an event from the
  /// view.
  final CAppActionTriggeredCB onActionTriggered;

  /// This represents the background color that will be utilized for the
  /// header and footer regions of this widget.
  final Color? backgroundColor;

  /// This represents the foreground color that will be utilized for the
  /// header and footer regions of this widget.
  final Color? foregroundColor;

  /// This represents the selected color that will be utilized for active
  /// actions in the footer navigation area.
  final Color? selectedItemColor;

  /// This represents the background color that will be utilized for the
  /// header and footer regions of this widget.
  final Color? shadowColor;

  /// Sets up the height of the header
  final double? height;

  /// Sets up the width of the drawer
  final double? width;

  /// This represents the elevation (3D effect) that will be utilized for the
  /// header and footer regions of this widget.
  final double? elevation;

  /// This represents the font size that will be utilized for the
  /// header and footer regions of this widget.
  final double fontSize;

  /// This represents the icon size that will be utilized for the
  /// header and footer regions of this widget.
  final double? iconSize;

  /// This sets up the slide drawer of options for the application.
  final List<CActionItem>? drawer;

  /// This defines the header title represented either as a logo or a string of
  /// text represented the title.
  final CHeaderTitleItem? headerTitle;

  /// This sets up the actions in the header (upper-right hand) of one off
  /// actions to carry out.
  final List<CActionItem>? headerActions;

  /// This sets up a floater widget button or whatever in the content area
  /// of this view.
  final Widget? floater;

  /// This sets up a set of actions to build a navigation area for the overall
  /// view.
  final List<CActionItem>? footerActions;

  const CAppView({
    super.key,
    required this.appTitle,
    required this.controller,
    required this.content,
    required this.onActionTriggered,
    this.appTheme,
    this.backgroundColor,
    this.foregroundColor,
    this.selectedItemColor,
    this.shadowColor,
    this.elevation,
    this.height,
    this.width,
    this.fontSize = 12.0,
    this.iconSize,
    this.drawer,
    this.headerTitle,
    this.headerActions,
    this.floater,
    this.footerActions,
  });

  @override
  State<StatefulWidget> createState() => _CAppViewState();
}

class _CAppViewState extends State<CAppView> {
  // Member Fields:
  late CAppController _controller;
  var _bottomNavigationBarIndex = 0;

  /// Determines if this widget will have a header area or not.
  bool get hasHeader =>
      _controller.drawer != null ||
      _controller.headerTitle != null ||
      (_controller.headerActions != null &&
          _controller.headerActions!.isNotEmpty);

  /// Determines if this widget has a slide out drawer or not.
  bool get hasDrawer =>
      _controller.drawer != null && _controller.drawer!.isNotEmpty;

  /// Determines if this widget has a footer area for navigation.
  bool get hasFooter =>
      _controller.footerActions != null &&
      _controller.footerActions!.isNotEmpty;

  @override
  void initState() {
    // Setup our controller for later updating this widgets state.
    _controller = widget.controller;
    _controller.appTitle = widget.appTitle;
    _controller.content = widget.content;
    _controller.appTheme = widget.appTheme;
    _controller.backgroundColor = widget.backgroundColor;
    _controller.foregroundColor = widget.foregroundColor;
    _controller.selectedItemColor = widget.selectedItemColor;
    _controller.shadowColor = widget.shadowColor;
    _controller.elevation = widget.elevation;
    _controller.height = widget.height;
    _controller.width = widget.width;
    _controller.fontSize = widget.fontSize;
    _controller.iconSize = widget.iconSize;
    _controller.drawer = widget.drawer;
    _controller.headerTitle = widget.headerTitle;
    _controller.headerActions = widget.headerActions;
    _controller.floater = widget.floater;
    _controller.footerActions = widget.footerActions;
    _controller.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: _controller.appTitle,
      theme: _controller.appTheme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        floatingActionButton: _controller.floater,
        appBar: hasHeader
            ? AppBar(
                leading: _controller.closeButton,
                actions: _buildActions(),
                automaticallyImplyLeading: true,
                centerTitle: true,
                titleSpacing: 5.0,
                backgroundColor: _controller.backgroundColor,
                foregroundColor: _controller.foregroundColor,
                shadowColor: _controller.shadowColor,
                toolbarHeight:
                    _controller.height != null ? _controller.height! + 5 : null,
                elevation: _controller.elevation,
                title: _controller.headerTitle,
              )
            : null,
        drawer: hasDrawer
            ? SizedBox(
                width: _controller.width,
                child: Drawer(
                  child: Ink(
                    color: _controller.backgroundColor,
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: _buildDrawerItems(),
                    ),
                  ),
                ),
              )
            : null,
        body: _controller.content,
        bottomNavigationBar: hasFooter
            ? BottomNavigationBar(
                currentIndex: _bottomNavigationBarIndex,
                elevation: _controller.elevation,
                type: BottomNavigationBarType.fixed,
                backgroundColor: _controller.backgroundColor,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                selectedFontSize: _controller.fontSize,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                selectedItemColor: _controller.selectedItemColor,
                unselectedFontSize: _controller.fontSize,
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
                unselectedItemColor: _controller.foregroundColor,
                items: _buildBottomNavigationBarItems(),
                onTap: (index) {
                  setState(() => _bottomNavigationBarIndex = index);
                  widget.onActionTriggered(
                    CAppActionTrigger.navigation,
                    _controller.footerActions![index].title,
                  );
                },
              )
            : null,
      ),
    );
  }

  /// Assists in building the header action items.
  List<Widget> _buildActions() {
    List<Widget> list = [];
    if (_controller.headerActions == null) {
      return list;
    }
    for (var element in _controller.headerActions!) {
      list.add(
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: element.tooltip,
          iconSize: _controller.iconSize,
          icon: Icon(element.icon),
          onPressed: () => widget.onActionTriggered(
            CAppActionTrigger.action,
            element.title,
          ),
        ),
      );
    }
    return list;
  }

  /// Helper method to build the drawer items to be able to display and close
  /// upon selection of an item.
  List<Widget> _buildDrawerItems() {
    List<Widget> list = [];
    list.add(SizedBox(
      height: _controller.height != null ? _controller.height! + 5 : null,
      child: Tooltip(
        message: "Close navigation menu",
        child: InkWell(
          onTap: () {
            if (_scaffoldKey.currentState!.isDrawerOpen) {
              _scaffoldKey.currentState!.closeDrawer();
            }
          },
          child: DrawerHeader(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: _controller.headerTitle != null &&
                    _controller.headerTitle!.isLogoSet
                ? Image.asset(
                    _controller.headerTitle!.logoMobile!,
                    fit: BoxFit.fill,
                  )
                : const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Make a Selection",
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
          ),
        ),
      ),
    ));
    for (var element in _controller.drawer!) {
      var tile = ListTile(
        dense: true,
        leading: Icon(element.icon, size: _controller.iconSize),
        title: Text(
          element.title,
          style: TextStyle(
            fontSize: _controller.fontSize,
          ),
        ),
        iconColor: _controller.foregroundColor,
        textColor: _controller.foregroundColor,
        titleAlignment: ListTileTitleAlignment.center,
        onTap: () {
          widget.onActionTriggered(
            CAppActionTrigger.drawer,
            element.title,
          );
          _scaffoldKey.currentState!.closeDrawer();
        },
      );
      if (element.tooltip != null) {
        list.add(Tooltip(message: element.tooltip, child: tile));
      } else {
        list.add(tile);
      }
    }
    return list;
  }

  /// Supports the building of the bottom navigation bar for the app view.
  List<BottomNavigationBarItem> _buildBottomNavigationBarItems() {
    List<BottomNavigationBarItem> list = [];
    for (var element in _controller.footerActions!) {
      list.add(
        BottomNavigationBarItem(
          icon: Icon(element.icon),
          label: element.title,
          tooltip: element.tooltip,
        ),
      );
    }
    return list;
  }
}

// ============================================================================
// [Custom Widgets] ===========================================================
// ============================================================================

class CTab {
  final IconData? icon;
  final String? title;
  final Widget content;

  CTab({this.icon, this.title, required this.content}) {
    assert(icon == null || title == null, "Either icon or title must be set");
  }
}

class CTabbedView extends StatelessWidget {
  // Member Fields:
  final List<CTab> tabs;
  final Color backgroundColor;
  final bool isScrollable;
  final Color? foregroundColor;
  final double? tabHeight;
  final double? tabWidth;
  final Color? selectedColor;
  final double? fontSize;
  final double? iconSize;

  const CTabbedView({
    required this.tabs,
    required this.backgroundColor,
    this.isScrollable = false,
    this.foregroundColor,
    this.tabHeight,
    this.tabWidth,
    this.selectedColor,
    this.iconSize,
    this.fontSize,
    super.key,
  });

  @override
  Widget build(Object context) {
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          Container(
            color: backgroundColor,
            width: double.infinity,
            height: tabHeight,
            child: TabBar(
              labelPadding: EdgeInsets.zero,
              indicatorPadding: EdgeInsets.zero,
              isScrollable: isScrollable,
              labelColor: selectedColor,
              indicatorColor: selectedColor,
              labelStyle: TextStyle(fontSize: fontSize),
              unselectedLabelColor: foregroundColor,
              unselectedLabelStyle: TextStyle(fontSize: fontSize),
              tabs: _buildTabs(),
            ),
          ),
          _buildTabBarView(),
        ],
      ),
    );
  }

  List<Widget> _buildTabs() {
    List<Widget> list = [];
    for (var element in tabs) {
      list.add(
        SizedBox(
          width: tabWidth,
          child: Tab(
            iconMargin: EdgeInsets.zero,
            icon: element.icon != null
                ? Icon(element.icon, size: iconSize)
                : null,
            text: element.title,
          ),
        ),
      );
    }
    return list;
  }

  Widget _buildTabBarView() {
    List<Widget> list = [];
    for (var element in tabs) {
      list.add(element.content);
    }
    return Expanded(child: TabBarView(children: list));
  }
}

/// Provides a web view (a.k.a iframe) for the PWA.
class CWebView extends StatelessWidget {
  /// The url of what page to load into the widget.
  final String url;

  const CWebView({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    var iFrameElement = html.IFrameElement();
    iFrameElement.style.height = "100%";
    iFrameElement.style.width = "100%";
    iFrameElement.src = url;
    iFrameElement.style.border = 'none';
    iFrameElement.allowFullscreen = true;
    ui.platformViewRegistry.registerViewFactory(
      url,
      (int viewId) => iFrameElement,
    );
    return HtmlElementView(
      viewType: url,
    );
  }
}

// ============================================================================
// [Public API ] ==============================================================
// ============================================================================

/// Wrapper API for the [codemelted_ui] library.
class CodeMeltedUI {
  /// Private constructor to form a namespace.
  CodeMeltedUI._() {
    // Make sure we are on a web only platform as that is what this library was
    // designed for.
    if (!kIsWeb) {
      // This module is designed for flutter web only. If somehow this library
      // separated from its parent project and put into a flutter source, go
      // stop the user from doing it.
      throw PlatformException(
        code: "-42",
        message: "The codemelted library is only supported on web browsers.",
        stacktrace: StackTrace.current.toString(),
      );
    }
  }

  /// Constructs a [CWebView] widget
  Widget webView(String url) => CWebView(url: url);
}

/// Accesses the [CodeMeltedUI] API to build user interfaces in flutter.
final codemelted_ui = CodeMeltedUI._();
