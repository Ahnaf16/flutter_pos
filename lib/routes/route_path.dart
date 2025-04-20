import 'package:pos/routes/logic/app_route.dart';

export 'package:go_router/go_router.dart';

class RPaths {
  const RPaths._();

  // auth
  static const welcome = RPath('/welcome');

  static final login = welcome + const RPath('/login');

  // home
  static const home = RPath('/home');

  static const settings = RPath('/settings');
  static RPath language = settings + const RPath('/language');
}
