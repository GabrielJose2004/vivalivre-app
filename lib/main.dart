import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viva_livre_app/features/auth/presentation/auth_bloc.dart';
import 'package:viva_livre_app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // O MultiBlocProvider é instanciado aqui, no nível mais alto possível
  // (acima do próprio App/MaterialApp), garantindo que o contexto
  // com o Bloc esteja disponível em TODA a árvore de widgets,
  // inclusive dentro do Navigator e das rotas criadas pelo MaterialApp.
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(),
        ),
      ],
      child: const App(),
    ),
  );
}
