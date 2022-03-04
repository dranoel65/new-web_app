import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular/angular.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/dashboard/dashboard.dart';

import '../config.dart';

class ProfileComponent  {
  String email = '';
  Config config = Config();
  String url = '';
  Map<String,dynamic> login = {'email': '','sms':false};
  Map<String,dynamic> errors = {};
  Map<String,dynamic> modalText = {'message':'','route':''};

  final AdminServices adminServices;
  final Router router;

  ProfileComponent(this.router, this.adminServices);
}

