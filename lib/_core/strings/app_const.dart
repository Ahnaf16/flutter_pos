import 'package:embed_annotation/embed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

part 'app_const.g.dart';

const kScrollPhysics = AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());

String kError([String? errorOn]) => 'Something went wrong${kDebugMode ? ' [${errorOn ?? ''}]' : ''}';

const kAppName = 'POS System';
final kVersion = 'v${pub.version}';

@EmbedLiteral('../../../pubspec.yaml')
const pub = _$pub;
