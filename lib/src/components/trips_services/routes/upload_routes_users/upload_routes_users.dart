import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;

import 'package:angular_forms/angular_forms.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/files/loadFile.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/dashboard/dashboard.dart';
import 'package:web_app/src/menu_top/menu_top.dart';

import '../massive_routes.dart';
import '../../../../route_paths.dart';
import '../../../../routes.dart';

@Component(selector: 'upload-routes-users',
    styleUrls: ['../style.css'],
    templateUrl: 'upload_routes_users.html',
    directives: [ coreDirectives, formDirectives, routerDirectives, MenuTopComponent,LoadFileComponent],
    pipes: [GetErrorsPipe, IdPipe, NamePipe, DateFormatPipe],
    exports: [RoutePaths, Routes])
class UploadUsersRoutesComponent extends MassiveRoutesComponent {
  bool table_view = false;
  bool uploading = false;
  String algorithm = '0';

  List<dynamic> users_results = [];
  var data;

  UploadUsersRoutesComponent(Router router, AdminServices adminServices) : super(router, adminServices);

  Future save() async {
    users_results = [];
    bool val = false;
    uploading=true;
    FormData formData = FormData();

    print(DashboardComponent.xFiles);

    var item = DashboardComponent.xFiles['list'][0];

    String regex ='.*xlsx|.*xls';
    if (!item.name.toString().contains(RegExp(regex))) {
      uploading=false;
      val=false;
      errorFileModal();
    }
    else{
      val=true;
    }

    await formData.appendBlob('files', item,item.name);
    if(val) {
      uploading=true;
      await adminServices.upload_users_routes.uploadUsers(formData, {'use_high_capacity_ride_sharing_algorithm': algorithm}.cast<String,dynamic>()).then((request) {
        data = jsonDecode(request.response);
        uploading=false;
        table_view=true;
        data['errors'].forEach((item) {
          if(item.containsKey('error')){
            users_results.add({'code':item['error']['code'], 'result':item['error']['errorMessage']});
          }
//            else{
//              users_results.add({'index':i+2, 'error':true, 'result':item['error']['errorMessage']});
//            }
        });
      }, onError: (e) {
        HttpRequest request = e.target;
      });
    }
//    }

  }

  void errorFileModal() {
    js.context.callMethod(r'$', ['#errorFileModal']).callMethod('modal', [js.JsObject.jsify({'show': true})]);
  }

}