import 'dart:async';
import 'dart:convert';
import 'dart:html' hide Point, Events;
import 'dart:js' as js;

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:web_app/classes/pipes.dart';
import 'package:web_app/services/services.dart';
import 'package:web_app/src/dashboard/dashboard.dart';

import 'dart:convert' show HtmlEscape;

import 'package:web_app/src/menu_top/menu_top.dart';

@Component(selector: 'load-files',
    styleUrls: ['style.css'],
    templateUrl: 'loadFile.html',
    directives: [ MenuTopComponent],
    pipes: [GetErrorsPipe, IdPipe, NamePipe, CarBrandPipe, DateFormatPipe, MoneyPipe, I18NPipe])
class LoadFileComponent extends DashboardComponent implements  OnInit, AfterViewInit{
  HtmlElement self;
  FormElement _readForm;
  InputElement _fileInput;
  Element _dropZone;
  OutputElement _output;
  HtmlEscape sanitizer = HtmlEscape();
  String accept;
  Timer timer;

  @Input('driver_id')
  String driver_id;

  @Input('result')
  String result;


  LoadFileComponent(Router router, AdminServices adminServices, HtmlElement el) : super(router, adminServices) {
  self = el;
  }

  @override
  void ngAfterViewInit() {
    accept = self.getAttribute('data-accept');
  }


  @override
  void ngOnInit () {
    timer = Timer(Duration(seconds: 1), ()
    {
      _output = document.querySelector('#list');
      _readForm = document.querySelector('#read');
      _fileInput = document.querySelector('#files');
      _fileInput?.onChange?.listen((e) => _onFileInputChange());

      _dropZone = document.querySelector('#drop-zone');
      _dropZone?.onDragOver?.listen(_onDragOver);
      _dropZone?.onDragEnter?.listen((e) => _dropZone.classes.add('hover'));
      _dropZone?.onDragLeave?.listen((e) => _dropZone.classes.remove('hover'));
      _dropZone?.onDrop?.listen(_onDrop);
    });
  }

  void _onDragOver(MouseEvent event) {
    event.stopPropagation();
    event.preventDefault();
    event.dataTransfer.dropEffect = 'copy';
  }

  void _onDrop(MouseEvent event) {
    event.stopPropagation();
    event.preventDefault();
    _dropZone.classes.remove('hover');
    _readForm.reset();
    _onFilesSelected(event.dataTransfer.files);
  }

 void _onFileInputChange() {
    _onFilesSelected(_fileInput.files);
  }

  void _onFilesSelected(List<File> files) {
    DashboardComponent.xFiles['list'] = files;
    _output.nodes.clear();
    var list = Element.tag('ul');
    for (var file in files) {
      var item = Element.tag('li');

      // If the file is an image, read and display its thumbnail.
      if (file.type.startsWith('image')) {
        if(document.querySelector('#list.no-thumb') == null){
          var thumbHolder = Element.tag('span');
          var reader = FileReader();
          reader.onLoad.listen((e) {
            var thumbnail = ImageElement(src: reader.result);
            thumbnail.classes.add('thumb');
            thumbnail.title = sanitizer.convert(file.name);
            thumbHolder.nodes.add(thumbnail);
          });
          reader.readAsDataUrl(file);
          item.nodes.add(thumbHolder);
        }
        
      }else if (file.type =='application/pdf'){
        var thumbHolder = Element.tag('span');
        var reader = FileReader();
        reader.onLoad.listen((e) {
          var thumbnail = IFrameElement();
          thumbnail.src=reader.result;
          thumbnail.classes.add('thumbPDF');
          thumbnail.height='600px';
          thumbnail.width= '800px';
          thumbnail.title = sanitizer.convert(file.name);
          thumbHolder.nodes.add(thumbnail);
        });
        reader.readAsDataUrl(file);
        item.nodes.add(thumbHolder);

       }

      // For all file types, display some properties.
      var properties = Element.tag('span');
      properties.innerHtml = (StringBuffer('<p>')
        ..write('<strong>')
        ..write(sanitizer.convert(file.name))
        ..write('</strong> (')
        ..write(file.type != null ? sanitizer.convert(file.type) : 'n/a')
        ..write(') ')
        ..write(file.size)
        ..write(' bytes')
        ..write('</p>')
          // TODO(jason9t): Re-enable this when issue 5070 is resolved.
          // http://code.google.com/p/dart/issues/detail?id=5070
          // ..add(', last modified: ')
          // ..add(file.lastModifiedDate != null ?
          //       file.lastModifiedDate.toLocal().toString() :
          //       'n/a')
      ).toString();
      item.nodes.add(properties);
      list.nodes.add(item);
    }
    _output.nodes.add(list);
  }

}
