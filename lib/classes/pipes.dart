import 'dart:js' as js;

import 'package:angular/angular.dart';

@Pipe('getErrors')
class GetErrorsPipe extends PipeTransform {
  List<Map> transform(List<Map> value, String param) {
    return value.where((item) => item['param'] == param).toList();
  }
}

@Pipe('id')
class IdPipe extends PipeTransform {
  String transform(String id) {
    if (id == null) {
      return '';
    }
    return id.substring(id.length - 8);
  }
}

@Pipe('i18n')
class I18NPipe extends PipeTransform {
  String transform(String txt) {
    switch (txt) {
      case 'reservation':
        return 'Reserva';
        break;
      case 'instantly':
        return 'De inmediato!';
        break;
      case 'route':
        return 'Ruta';
        break;
      case 'Suv':
        return 'Camioneta';
        break;
      case 'costsCentersInDebt':
        return 'Hay uno o más centros de costos que deben dinero';
        break;
      case 'invalidCreditCard':
        return 'Tarjeta de crédito inválida';
        break;
      case 'credit':
        return 'Crédito';
        break;
      case 'secure_payment':
        return 'Saldo/TCC';
        break;
      case 'user':
        return 'Usuario';
        break;
      case 'beneficiary':
        return 'Beneficiario';
        break;
      case 'supervisor':
        return 'Supervisor';
        break;
      case 'admin':
        return 'Administrador';
        break;
      case 'trip':
        return 'Cobro servicio';
        break;
      case 'trip_fix':
        return 'Corrección de tarifas';
        break;
      case 'rollback_trip':
        return 'Devolución de cobro adicional';
        break;
      case 'add_balance':
        return 'Modificación de saldo';
        break;
      case 'payed':
        return 'Pagado';
        break;
      case 'payed':
        return 'Pagado';
        break;
      case 'due':
        return 'Por cobrar';
        break;
      default:
        return txt;
    }
  }
}

@Pipe('name')
class NamePipe extends PipeTransform {
  String transform(Map personal_info) {
    return '${personal_info['firstname']} ${personal_info['lastname']}';
  }
}

@Pipe('days')
class DaysPipe extends PipeTransform {
  String transform(int days) {
    String d = '';
    switch (days) {
      case 0:
        d='Domingo';
        break;
      case 1:
        d='Lunes';
        break;
      case 2:
        d='Martes';
        break;
      case 3:
        d='Miercoles';
        break;
      case 4:
        d='Jueves';
        break;
      case 5:
        d='Viernes';
        break;
      case 6:
        d='Sabado';
        break;
    }
    return d;
  }
}

@Pipe('carbrand')
class CarBrandPipe extends PipeTransform {
  String transform(Map car_info) {
    return '${car_info['brand']} ${car_info['model']}';
  }
}

@Pipe('dateformat')
class DateFormatPipe extends PipeTransform {
  String transform(String date, {String format: 'MMMM D, YYYY h:mm:ss a'}) {
    String sDate =
    js.context.callMethod('moment', [date]).callMethod('format', [format]);
    return sDate;
  }
}

@Pipe('dateformat2')
class DateFormat2Pipe extends PipeTransform {
  String transform(String date, String format) {
    if (date == null) {
      return '';
    }
    String sDate =
    js.context.callMethod('moment', [date]).callMethod('format', [format]);
    return sDate;
  }
}

@Pipe('dateformat3')
class DateFormat3Pipe extends PipeTransform {
  String transform(var date, var format, var add, var step) {
    if (date == null) {
      return '';
    }
    String sDate = js.context.callMethod('moment', [date]).callMethod(
        'add', [add, step]).callMethod('format', [format]);
    return sDate;
  }
}

@Pipe('timeago')
class TimeAgoPipe extends PipeTransform {
  String transform(String date) {
    String sDate =
    js.context.callMethod('moment', [date]).callMethod('fromNow', ['']);
    return sDate;
  }
}

@Pipe('timeagowithhour')
class TimeAgoWhitHoursPipe extends PipeTransform {
  String transform(String date) {
    String sDate =
    js.context.callMethod('moment', [date]).callMethod('calendar');
    //String sDate = js.context.callMethod('moment', [date]).callMethod('fromNow', ['']);
    return sDate;
  }
}

@Pipe('timelapse')
class TimeLapsePipe extends PipeTransform {
  String transform(String end, String start) {
    int startTime = js.context.callMethod('moment', [start]).callMethod('unix');
    int endTime = js.context.callMethod('moment', [end]).callMethod('unix');
    var tempTime = js.context['moment']
        .callMethod('duration', [(endTime - startTime) * 1000]);
    return '${tempTime.callMethod('hours')}h:${tempTime.callMethod('minutes')}m:${tempTime.callMethod('seconds')}s';
  }
}

@Pipe('numberstodays')
class NumbersToDaysPipe extends PipeTransform {
  String transform(List<int> days) {
    List<String> names = [
      'Domingo',
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado'
    ];
    return days.map((day) => names[day]).join(', ');
  }
}

@Pipe('typeofpromo')
class TypeOfPromoPipe extends PipeTransform {
  String transform(String type) {
    Map names = {
      'first_trip': 'Primer Viaje',
      'corporate': 'Corporativo',
      'balance': 'Recargar Saldo',
      'trip': 'Viaje Personal'
    };
    return names[type];
  }
}

@Pipe('statusItemPassengersUser')
class StatusItemPassengersUser extends PipeTransform {
  String transform(String type) {
    Map names = {
      'onboard': 'A Bordo',
      'cancelled': 'Parada Anulada',
      'waiting': 'Parada Programada',
      'completed': 'Parada Finalizada',
      'arrived': 'Vehículo Esperando',
      'missing': 'Ausente'
    };

    return names[type];
  }
}

@Pipe('money')
class MoneyPipe extends PipeTransform {
  String transform(var money) {
    return '\$ ${money.ceil()}';
  }
}

@Pipe('ceil')
class CeilPipe extends PipeTransform {
  int transform(num num) {
    return num.ceil();
  }
}

@Pipe('dec2')
class Dec2Pipe extends PipeTransform {
  num transform(num vnum) {
    return ((vnum * 100).ceil()) / 100;
  }
}

@Pipe('onedecimal')
class OneDecimalPipe extends PipeTransform {
  num transform(num num) {
    return (num * 10).round() / 10;
  }
}

@Pipe('i18nR')
class I18NRPipe extends PipeTransform {
  String transform(String txt) {
    switch (txt) {
      case 'connected':
        return 'Conectado';
        break;
      case 'minutes':
        return 'Minutos';
        break;
      case 'working':
        return 'Trabajando';
        break;
      case 'trips_money':
        return 'Vuelos';
        break;
      case 'cancelled':
        return 'No. de cancelados (con cobro)';
        break;
      case 'finished':
        return 'No. de vuelos finalizados';
        break;
      case 'trips_total':
        return 'Totales';
        break;
      case 'price':
        return 'Facturado';
        break;
      case 'reservation':
        return 'Reservas';
        break;
      case 'instantly':
        return 'Inmediatos';
        break;
      case 'total':
        return 'Total';
        break;
      case 'fulfillment':
        return 'Cumplimiento';
        break;
      case 'lost_flights':
        return 'Vuelos perdidos';
        break;
      case 'requests':
        return 'Total servicios facturados';
        break;
      case 'unattended':
        return 'Sin Atender';
        break;
      case 'aborted':
        return 'Abortados';
        break;
      case 'sum_finished':
        return 'Facturación vuelos finalizados';
        break;
      case 'avg_finished':
        return 'Promedio Finalizados';
        break;
      case 'sum_cancelled':
        return 'Facturación vuelos cancelados con cobro';
        break;
      case 'avg_cancelled':
        return 'Promedio Cancelados';
        break;
      case 'gross':
        return 'Total Vuelos';
        break;
      case 'fee':
        return 'Fee Administrativo';
        break;
      case 'discounts':
        return 'Descuentos';
        break;
      case 'promo':
        return 'Códigos promocionales';
        break;
      case 'net':
        return 'Total facturación';
        break;
      case 'sumary':
        return 'Resumen facturación';
        break;
      case 'num':
        return '# de Vuelos';
        break;
      case 'sum_reserves_cc':
        return 'Facturado Reservas Corporativos';
        break;
      case 'sum_instantly_cc':
        return 'Facturado Inmediatos Corporativos';
        break;
      case 'unique_alliances':
        return 'Alianzas activas';
        break;
      case 'avg_alliances':
        return 'Promedio consumo por Alianzas';
        break;
      case 'unique_users':
        return 'Usuarios Activos';
        break;
      case 'all_general':
        return 'General';
        break;
      case 'kpi_general':
        return 'Generales';
        break;
      case 'kpi_invoices':
        return 'Facturación';
        break;
      case 'kpi_alliances':
        return 'Consumo por alianzas';
        break;
      case 'alliances':
        return 'Alianzas';
        break;
      case 'users':
        return 'Usuarios';
        break;
      case 'avg_price':
        return 'Costo promedio por vuelo';
        break;
      case 'avg_time':
        return 'Tiempo promedio por vuelo';
        break;
      case 'avg_distance':
        return 'Promedio km por vuelo';
        break;
      default:
        return txt;
    }
  }
}
