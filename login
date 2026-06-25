// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:step_flutter/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:step_flutter/l10n/app_localizations.dart';
import 'package:step_flutter/util/cores.dart';
import 'package:step_flutter/util/get_it.dart';
import 'package:step_flutter/widgets/botao_padrao.dart';
import 'package:step_flutter/widgets/textfield_padrao.dart';
import 'package:step_flutter/widgets/texto_notosans.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>()..add(const AuthStarted()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  String _mensagemErro = '';
  Timer? _errorTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _errorTimer?.cancel();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _senhaController.text;
    if (email.isEmpty || password.isEmpty) {
      _showError('Preencha todos os campos');
      return;
    }
    context
        .read<AuthBloc>()
        .add(AuthLoginSubmitted(email: email, password: password));
  }

  void _showError(String message) {
    _errorTimer?.cancel();
    setState(() => _mensagemErro = message);
    _errorTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _mensagemErro = '');
    });
  }

  void _showPrivacyPolicy(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: RichText(
              text: TextSpan(
                text: '${l10n.login_privacy_policy_title}\n\n',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Cores.textoPadrao,
                ),
                children: [
                  TextSpan(
                    text: '${l10n.login_privacy_policy_item1}\n\n',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: '${l10n.login_privacy_policy_item1a}\n\n',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: '${l10n.login_privacy_policy_item1b}\n\n',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: '${l10n.login_privacy_policy_item1c}\n\n',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: '${l10n.login_privacy_policy_item1d}\n\n',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: '${l10n.login_privacy_policy_item1e}\n\n',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final altura = MediaQuery.of(context).size.height;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.pushReplacementNamed(context, '/home', arguments: 0);
        } else if (state is AuthFailureState) {
          _showError(state.message);
        } else if (state is AuthValidationError) {
          _showError('Email ou senha inválidos !');
        }
      },
      builder: (context, state) {
        final obscure = state.obscurePassword;
        final loading = state is AuthLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: altura),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Expanded(child: Container()),
                      Image.asset('assets/images/Logo.png', width: 147),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          TextoNotoSans(
                            texto: l10n.login_email,
                            tamanhoTexto: 16,
                            weightTexto: FontWeight.bold,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      TextFieldPadrao(
                        controller: _emailController,
                        titulo: '',
                        inputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          TextoNotoSans(
                            texto: l10n.login_password,
                            tamanhoTexto: 16,
                            weightTexto: FontWeight.bold,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      TextFieldPadrao(
                        controller: _senhaController,
                        titulo: '',
                        onSubmitted: (_) => _submit(),
                        suffixIcon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility,
                          color: Cores.cinzaClaro,
                        ),
                        obscure: obscure,
                        funcaoSuffixIcon: () {
                          context
                              .read<AuthBloc>()
                              .add(const AuthPasswordVisibilityToggled());
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_mensagemErro.isNotEmpty)
                        TextoNotoSans(
                          texto: _mensagemErro,
                          tamanhoTexto: 14,
                          weightTexto: FontWeight.bold,
                          corTexto: Colors.red,
                        ),
                      const SizedBox(height: 16),
                      BotaoPadrao(
                        textoBotao: l10n.login_login,
                        funcaoBotao: loading ? null : _submit,
                        carregandoBotao: loading,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _showPrivacyPolicy(context),
                        child: TextoNotoSans(
                          texto: l10n.login_terms_use,
                          tamanhoTexto: 14,
                          weightTexto: FontWeight.bold,
                          corTexto: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextoNotoSans(
                        texto: '${l10n.login_version} 2.12.94',
                        tamanhoTexto: 10,
                        weightTexto: FontWeight.bold,
                        corTexto: Colors.grey,
                      ),
                      Expanded(child: Container()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
