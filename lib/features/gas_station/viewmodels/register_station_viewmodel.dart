import '../models/gas_station_model.dart';
import '../repositories/gas_station_repository.dart';

class RegisterStationViewModel {
  GasStationRepository? _repository;

  RegisterStationViewModel([this._repository]);

  GasStationRepository get _gasStationRepository =>
      _repository ??= GasStationRepository();

  String? validateStepOne({
    required String name,
    required String cnpj,
    required String phone,
    required String email,
    required String password,
  }) {
    if (name.trim().isEmpty ||
        cnpj.trim().isEmpty ||
        phone.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      return 'Preencha todos os campos.';
    }

    if (name.trim().length < 3) {
      return 'Informe um nome de posto válido.';
    }

    if (cnpj.length != 14) {
      return 'O CNPJ deve conter 14 números.';
    }

    if (phone.length < 10) {
      return 'Digite um telefone válido.';
    }

    if (!email.contains('@') || !email.contains('.')) {
      return 'Digite um e-mail válido.';
    }

    if (password.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }

    return null;
  }

  String? validateStepTwo({
    required String address,
    required String neighborhood,
    required String city,
  }) {
    if (address.trim().isEmpty ||
        neighborhood.trim().isEmpty ||
        city.trim().isEmpty) {
      return 'Preencha todos os campos.';
    }

    if (city.trim().toLowerCase() != 'bebedouro') {
      return 'Neste projeto, apenas postos de Bebedouro são permitidos.';
    }

    return null;
  }

  Future<void> registerStation(GasStationModel station) async {
    await _gasStationRepository.registerStation(station);
  }
}
