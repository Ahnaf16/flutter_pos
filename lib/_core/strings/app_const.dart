import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Default scroll physics for scrollable widgets
const kScrollPhysics = AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());

String kError([String? errorOn]) => 'Something went wrong${kDebugMode ? ' [${errorOn ?? ''}]' : ''}';

const kAppName = 'POS System';
