import 'package:flutter_test/flutter_test.dart';

import 'package:completai_app/features/auth/viewmodels/forgot_password_viewmodel.dart';
import 'package:completai_app/features/auth/viewmodels/login_viewmodel.dart';
import 'package:completai_app/features/auth/viewmodels/register_user_viewmodel.dart';
import 'package:completai_app/features/gas_station/models/public_gas_station.dart';
import 'package:completai_app/features/gas_station/viewmodels/register_station_viewmodel.dart';

void main() {
  group('LoginViewModel', () {
    final viewModel = LoginViewModel();

    test('aceita credenciais com formato válido', () {
      final result = viewModel.validateLogin(
        email: 'usuario@exemplo.com',
        password: '123456',
      );

      expect(result, isNull);
    });

    test('rejeita e-mail inválido', () {
      final result = viewModel.validateLogin(
        email: 'email-invalido',
        password: '123456',
      );

      expect(result, isNotNull);
    });
  });

  group('RegisterUserViewModel', () {
    final viewModel = RegisterUserViewModel();

    test('aceita dados válidos', () {
      final result = viewModel.validateUserData(
        name: 'Maria Silva',
        email: 'maria@exemplo.com',
        phone: '17999999999',
        password: '123456',
      );

      expect(result, isNull);
    });

    test('rejeita nome e telefone inválidos', () {
      expect(
        viewModel.validateUserData(
          name: 'M',
          email: 'maria@exemplo.com',
          phone: '123',
          password: '123456',
        ),
        isNotNull,
      );
    });
  });

  group('ForgotPasswordViewModel', () {
    final viewModel = ForgotPasswordViewModel();

    test('valida o formato do e-mail', () {
      expect(viewModel.validateEmail('usuario@exemplo.com'), isNull);
      expect(viewModel.validateEmail('usuario'), isNotNull);
    });
  });

  group('RegisterStationViewModel', () {
    final viewModel = RegisterStationViewModel();

    test('aceita as duas etapas com dados válidos', () {
      expect(
        viewModel.validateStepOne(
          name: 'Posto Avenida',
          cnpj: '12345678000199',
          phone: '17999999999',
          email: 'posto@exemplo.com',
          password: '123456',
        ),
        isNull,
      );
      expect(
        viewModel.validateStepTwo(
          address: 'Avenida Brasil, 1000',
          neighborhood: 'Centro',
          city: 'Bebedouro',
        ),
        isNull,
      );
    });

    test('rejeita CNPJ e cidade fora do escopo', () {
      expect(
        viewModel.validateStepOne(
          name: 'Posto Avenida',
          cnpj: '123',
          phone: '17999999999',
          email: 'posto@exemplo.com',
          password: '123456',
        ),
        isNotNull,
      );
      expect(
        viewModel.validateStepTwo(
          address: 'Avenida Brasil, 1000',
          neighborhood: 'Centro',
          city: 'Ribeirão Preto',
        ),
        isNotNull,
      );
    });
  });

  group('Ranking justo de postos', () {
    test('prioriza histórico consistente sobre duas notas máximas', () {
      final consistentStation = PublicGasStation.fairRatingScore(
        average: 4.5,
        reviewCount: 100,
      );
      final newStation = PublicGasStation.fairRatingScore(
        average: 5,
        reviewCount: 2,
      );

      expect(consistentStation, greaterThan(newStation));
    });

    test('não ranqueia posto sem avaliações acima dos avaliados', () {
      final unratedStation = PublicGasStation.fairRatingScore(
        average: 0,
        reviewCount: 0,
      );

      expect(unratedStation, 0);
    });
  });
}
