import 'package:flutter/material.dart';

/// Width at which Home shows the chat list and one conversation together.
///
/// This is the Material expanded window-size class. Narrower widths keep the
/// existing full-screen chat navigation. The choice is based on available
/// width, not on whether the app is running on the web.
const double messengerWideLayoutBreakpoint = 840;

/// Width of the chat list column in the wide layout.
const double messengerChatListPaneWidth = 360;

/// Whether [context] is wide enough for the side-by-side messenger shell.
bool isMessengerWideLayout(BuildContext context) {
  return MediaQuery.sizeOf(context).width >= messengerWideLayoutBreakpoint;
}
