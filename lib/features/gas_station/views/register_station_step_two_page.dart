import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/step_progress_header.dart';
import '../../../../core/widgets/responsive_form_content.dart';
import '../models/gas_station_model.dart';
import '../viewmodels/register_station_viewmodel.dart';

class RegisterStationStepTwoPage extends StatefulWidget {
  final String name;
  final String cnpj;
  final String phone;
  final String email;
  final String password;

  const RegisterStationStepTwoPage({
    super.key,
    required this.name,
    required this.cnpj,
    required this.phone,
    required this.email,
    required this.password,
  });

  @override
  State<RegisterStationStepTwoPage> createState() =>
      _RegisterStationStepTwoPageState();
}

class _RegisterStationStepTwoPageState
    extends State<RegisterStationStepTwoPage> {
  final RegisterStationViewModel _viewModel = RegisterStationViewModel();

  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _neighborhoodController = TextEditingController();

  final TextEditingController _cityController = TextEditingController();

  bool _isLoading = false;

  Future<void> _finishRegister() async {
    final errorMessage = _viewModel.validateStepTwo(
      address: _addressController.text,
      neighborhood: _neighborhoodController.text,
      city: _cityController.text,
    );

    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final station = GasStationModel(
        name: widget.name,
        cnpj: widget.cnpj,
        phone: widget.phone,
        email: widget.email,
        password: widget.password,
        address: _addressController.text.trim(),
        neighborhood: _neighborhoodController.text.trim(),
        city: _cityController.text.trim(),
      );

      await _viewModel.registerStation(station);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Posto cadastrado com sucesso!')),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.stationDashboard,
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_registrationErrorMessage(error))));
    } on FirebaseException catch (error) {
      debugPrint(
        'Falha no Firestore durante o cadastro do posto: '
        '${error.code} - ${error.message}',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_firestoreErrorMessage(error))));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível cadastrar o posto. Tente novamente.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _registrationErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'invalid-email':
        return 'Digite um e-mail válido.';
      case 'weak-password':
        return 'Escolha uma senha mais forte.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      default:
        return 'Não foi possível cadastrar o posto.';
    }
  }

  String _firestoreErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'O Firestore recusou o cadastro. Publique as regras de segurança e tente novamente.';
      case 'not-found':
        return 'O banco Firestore ainda não foi criado no projeto Firebase.';
      case 'unavailable':
        return 'O Firestore está indisponível. Verifique sua conexão e tente novamente.';
      case 'failed-precondition':
        return 'O Firestore ainda não está configurado corretamente.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      default:
        return 'Não foi possível salvar o posto no Firestore (${error.code}).';
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(title: const Text('Endereço do Posto')),

      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveFormContent(
            child: Column(
              children: [
                const StepProgressHeader(currentStep: 2, totalSteps: 2),
                const SizedBox(height: 28),
                const Icon(
                  Icons.location_on_outlined,
                  size: 52,
                  color: AppTheme.primary,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Localização',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textLight,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Informe o endereço do posto.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMuted),
                ),

                const SizedBox(height: 32),

                CustomTextField(
                  label: 'Endereço',
                  hint: 'Ex: Avenida Brasil, 1000',
                  icon: Icons.map_outlined,
                  controller: _addressController,
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Bairro',
                  hint: 'Ex: Centro',
                  icon: Icons.location_city_outlined,
                  controller: _neighborhoodController,
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Cidade',
                  hint: 'Ex: Bebedouro',
                  icon: Icons.place_outlined,
                  controller: _cityController,
                ),

                const SizedBox(height: 28),

                CustomButton(
                  text: 'Finalizar Cadastro',
                  isLoading: _isLoading,
                  onPressed: _finishRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
