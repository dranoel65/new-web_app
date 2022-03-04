import 'package:google_maps/google_maps.dart';

class Config {

    final String client_host = 'transportation-api.miaguila.com';
    final String scheme = 'https';
    final int client_port = 443;
//  final String scheme = 'http';
//  final String client_host = 'localhost';
//  final int client_port = 3071;
  //TO-DO: Se debe realizar archivo de configuracion .env
  //se probó con librerías dotenv y con libreria i/o y no son compatibles
  // con la plataforma
  final String METABASE_SITE_URL = "https://orders-api.miaguila.com:3000";
  final String METABASE_SECRET_KEY = "f057fce2a28c3ec2dd1752bd65592364c9b133fc70017045c8dc58a68dac3297";

  static final List<MapTypeStyle> mapStyles = <MapTypeStyle>[
    MapTypeStyle()
      ..featureType = MapTypeStyleFeatureType.ADMINISTRATIVE_LAND_PARCEL
      ..elementType = MapTypeStyleElementType.LABELS_TEXT_FILL
      ..stylers = <MapTypeStyler>[
        MapTypeStyler()
          ..color = "#bdbdbd",
        MapTypeStyler()
          ..weight = 1.2
      ],
    MapTypeStyle()
      ..featureType = MapTypeStyleFeatureType.ADMINISTRATIVE
      ..elementType = MapTypeStyleElementType.GEOMETRY_STROKE
      ..stylers = <MapTypeStyler>[
        MapTypeStyler()
          ..color = "#fefefe",
        MapTypeStyler()
          ..weight = 1.2
      ],
    MapTypeStyle()
      ..featureType = MapTypeStyleFeatureType.ADMINISTRATIVE
      ..elementType = MapTypeStyleElementType.GEOMETRY_FILL
      ..stylers = <MapTypeStyler>[
        MapTypeStyler()
          ..color = "#fefefe"
      ],
    MapTypeStyle()
      ..featureType = MapTypeStyleFeatureType.WATER
      ..elementType = MapTypeStyleElementType.GEOMETRY_FILL
      ..stylers = <MapTypeStyler>[MapTypeStyler()
        ..color = "#a8e6f5"
      ],
    MapTypeStyle()
      ..featureType = MapTypeStyleFeatureType.LANDSCAPE_MAN_MADE
      ..elementType = MapTypeStyleElementType.GEOMETRY_FILL
      ..stylers = <MapTypeStyler>[MapTypeStyler()
        ..visibility = "on", MapTypeStyler()
        ..color = "#efefef"
      ],
    MapTypeStyle()
      ..featureType = MapTypeStyleFeatureType.ROAD
      ..elementType = MapTypeStyleElementType.GEOMETRY
      ..stylers = <MapTypeStyler>[MapTypeStyler()
        ..visibility = "on", MapTypeStyler()
        ..color = "#ffffff",
      ],
    MapTypeStyle()
      ..featureType = MapTypeStyleFeatureType.LANDSCAPE
      ..elementType = MapTypeStyleElementType.GEOMETRY
      ..stylers = <MapTypeStyler>[MapTypeStyler()
        ..visibility = "on", MapTypeStyler()
        ..color = "#f5f5f5"
      ],
    MapTypeStyle()
      ..featureType = MapTypeStyleFeatureType.ROAD_HIGHWAY
      ..elementType = MapTypeStyleElementType.GEOMETRY_FILL
      ..stylers = <MapTypeStyler>[MapTypeStyler()
        ..color = "#ffffff"
      ],
    MapTypeStyle()
      ..featureType = MapTypeStyleFeatureType.ROAD_HIGHWAY
      ..elementType = MapTypeStyleElementType.GEOMETRY_STROKE
      ..stylers = <MapTypeStyler>[MapTypeStyler()
        ..visibility = "on", MapTypeStyler()
        ..color = "#ffffff",
      MapTypeStyler()
        ..weight = 0.2
      ],
    MapTypeStyle()
      ..featureType = MapTypeStyleFeatureType.ROAD_ARTERIAL
      ..elementType = MapTypeStyleElementType.GEOMETRY
      ..stylers = <MapTypeStyler>[MapTypeStyler()
        ..color = "#ffffff"
      ],
    MapTypeStyle()
      ..featureType = MapTypeStyleFeatureType.ROAD_ARTERIAL
      ..elementType = MapTypeStyleElementType.LABELS_TEXT_FILL
      ..stylers = <MapTypeStyler>[MapTypeStyler()
        ..color = "#757575"
      ],
    MapTypeStyle()
      ..featureType = MapTypeStyleFeatureType.ROAD_LOCAL
      ..elementType = MapTypeStyleElementType.GEOMETRY
      ..stylers = <MapTypeStyler>[MapTypeStyler()
        ..color = "#ffffff", MapTypeStyler()
      ],
    MapTypeStyle()
      ..featureType = MapTypeStyleFeatureType.POI
      ..elementType = MapTypeStyleElementType.GEOMETRY
      ..stylers = <MapTypeStyler>[MapTypeStyler()
        ..color = "#eeeeee", MapTypeStyler()
      ],
    MapTypeStyle()
      ..featureType = MapTypeStyleFeatureType.POI
      ..elementType = MapTypeStyleElementType.LABELS_TEXT_FILL
      ..stylers = <MapTypeStyler>[MapTypeStyler()
        ..color = "#757575", MapTypeStyler()
      ],
    MapTypeStyle()
      ..featureType = MapTypeStyleFeatureType.POI_PARK
      ..elementType = MapTypeStyleElementType.GEOMETRY_FILL
      ..stylers = <MapTypeStyler>[MapTypeStyler()
        ..color = "#c4eeba", MapTypeStyler()
      ],
    MapTypeStyle()
      ..featureType = MapTypeStyleFeatureType.POI_PARK
      ..elementType = MapTypeStyleElementType.LABELS_TEXT_FILL
      ..stylers = <MapTypeStyler>[MapTypeStyler()
        ..color = "#9e9e9e"
      ],
    MapTypeStyle()
      ..featureType = MapTypeStyleFeatureType.ALL
      ..elementType = MapTypeStyleElementType.LABELS_TEXT_STROKE
      ..stylers = <MapTypeStyler>[MapTypeStyler()
        ..color = "#f5f5f5", MapTypeStyler()
        ..visibility = "on"
      ],
    MapTypeStyle()
      ..featureType = MapTypeStyleFeatureType.ALL
      ..elementType = MapTypeStyleElementType.LABELS_TEXT_FILL
      ..stylers = <MapTypeStyler>[
        MapTypeStyler()
          ..color = "#616161",
        MapTypeStyler()
      ],
    MapTypeStyle()
      ..featureType = MapTypeStyleFeatureType.ALL
      ..elementType = MapTypeStyleElementType.LABELS_ICON
      ..stylers = <MapTypeStyler>[MapTypeStyler()
        ..visibility = "off"
      ],
    MapTypeStyle()
      ..featureType = MapTypeStyleFeatureType.TRANSIT
      ..elementType = MapTypeStyleElementType.GEOMETRY
      ..stylers = <MapTypeStyler>[MapTypeStyler()
        ..color = "#f2f2f2", MapTypeStyler()
      ]
  ];
}
