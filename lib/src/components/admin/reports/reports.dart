

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular/security.dart';
import 'package:angular_router/angular_router.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'package:web_app/services/services.dart';
import 'package:web_app/src/dashboard/dashboard.dart';
import 'package:web_app/src/menu_top/menu_top.dart';
import 'package:web_app/src/config.dart';
import 'package:web_app/classes/User.dart';

@Component(selector: 'reports', templateUrl: 'reports.html', directives: [
  coreDirectives,
  formDirectives,
  routerDirectives,
  MenuTopComponent
], pipes: [])
class ReportsComponent extends DashboardComponent {
  Config config = Config();
  DomSanitizationService sanitization;
  String iframeUrl;
  var finalUrl;


  // creates a JWT, expires in 12 hours
  String _signToken() {
    var now = DateTime.now();
    var exp = now.add(const Duration(minutes: 20));
    final jwt = JWT({
      'resource': {'dashboard': 5},
      'params': {
        "alliance_": User.user['alliance_id']['_id']
      },
      'exp': exp.millisecondsSinceEpoch
    });
    final token = jwt.sign(SecretKey(config.METABASE_SECRET_KEY));
    return token;
  }


  ReportsComponent(
      this.sanitization, Router router, AdminServices adminServices)
      : super(router, adminServices) {
    iframeUrl = '${config.METABASE_SITE_URL}/embed/dashboard/${_signToken()}';
    finalUrl = sanitization.bypassSecurityTrustResourceUrl(iframeUrl);
  }
}