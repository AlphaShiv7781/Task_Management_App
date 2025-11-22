import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_event.dart';
import '../../logic/auth/auth_state.dart';
import '../widgets/app_button.dart';
import '../widgets/input_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        RegisterEvent(
          nameCtrl.text.trim(),
          emailCtrl.text.trim(),
          passCtrl.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: primaryBlue,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is RegisterSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Registration successful! Please login.")),
                );
                Navigator.of(context).pop();
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              final loading = state is AuthLoading;

              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    InputField(
                      controller: nameCtrl,
                      label: "Name",
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Name is required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    InputField(
                      controller: emailCtrl,
                      label: "Email",
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Email is required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    InputField(
                      controller: passCtrl,
                      label: "Password",
                      obscure: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Password is required";
                        }
                        if (v.length < 6) {
                          return "At least 6 characters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: "Register",
                      onPressed: _onRegister,
                      loading: loading,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
