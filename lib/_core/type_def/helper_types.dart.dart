import 'dart:async';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pos/main.export.dart';

typedef FromMapT<T> = T Function(QMap map);
typedef ToMapT<T> = Map Function(T data);

typedef ListValueGetter<T> = List<T> Function(List<T> input);

typedef QMap = Map<String, dynamic>;
typedef SMap = Map<String, String>;

typedef FormBuilderTextState = FormBuilderFieldState<FormBuilderField<String>, String>;

typedef FVoid = Future<void>;
typedef FutureCallback<T> = Future<T> Function();
typedef FutureVCallback<T> = Future<T> Function(T value);
typedef StSub<T> = StreamSubscription<T>;

typedef LuIcons = LucideIcons;
