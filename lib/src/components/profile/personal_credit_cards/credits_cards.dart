import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;

import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular/angular.dart';
import 'package:web_app/services/services.dart';

import 'package:web_app/src/dashboard/dashboard.dart';

class PersonalCreditCardsComponent extends DashboardComponent {
  String q;
  String user_id;
  Map<String,dynamic> itemModal;
  bool itemModalError = false;
  bool itemModalError2 = false;
  Map<String,dynamic> credit_card = { 'year': js.context.callMethod('moment', []).callMethod('format', ['YYYY']).toString(), 'month': '01' };

  PersonalCreditCardsComponent(Router router, AdminServices adminServices) : super(router, adminServices);

}
