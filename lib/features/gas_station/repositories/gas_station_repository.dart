import '../models/gas_station_model.dart';
import '../services/gas_station_service.dart';

class GasStationRepository {
  final GasStationService _service = GasStationService();

  Future<void> registerStation(GasStationModel station) async {
    await _service.registerStation(station);
  }
}
