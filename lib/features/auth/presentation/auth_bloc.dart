import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthBloc({required FirebaseAuth firebaseAuth})
      : _firebaseAuth = firebaseAuth,
        super(AuthInitial()) {
    on<AuthAppStarted>(_onAuthAppStarted);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  // ── Tradução de erros do Firebase para Português ──
  String _translateFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      // Login
      case 'user-not-found':
        return 'Nenhuma conta encontrada com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta. Tente novamente.';
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'invalid-email':
        return 'O formato do e-mail é inválido.';
      case 'user-disabled':
        return 'Esta conta foi desativada. Contacte o suporte.';
      case 'too-many-requests':
        return 'Demasiadas tentativas. Aguarde alguns minutos e tente novamente.';

      // Registo
      case 'email-already-in-use':
        return 'Já existe uma conta com este e-mail.';
      case 'weak-password':
        return 'A senha é muito fraca. Use pelo menos 6 caracteres.';
      case 'operation-not-allowed':
        return 'Este método de autenticação não está disponível.';

      // Google Sign-In
      case 'account-exists-with-different-credential':
        return 'Já existe uma conta com este e-mail usando outro método de login.';
      case 'popup-closed-by-user':
      case 'cancelled':
        return 'Login cancelado pelo utilizador.';

      // Rede
      case 'network-request-failed':
        return 'Sem conexão à internet. Verifique a sua rede.';

      default:
        return e.message ?? 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  Future<void> _onAuthAppStarted(
    AuthAppStarted event,
    Emitter<AuthState> emit,
  ) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (userCredential.user != null) {
        emit(AuthAuthenticated(userCredential.user!));
      } else {
        emit(const AuthError('Não foi possível iniciar sessão.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_translateFirebaseError(e)));
    } catch (e) {
      emit(const AuthError('Ocorreu um erro inesperado. Tente novamente.'));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(event.name);

      if (userCredential.user != null) {
        emit(AuthAuthenticated(userCredential.user!));
      } else {
        emit(const AuthError('Não foi possível criar a conta.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_translateFirebaseError(e)));
    } catch (e) {
      emit(const AuthError('Ocorreu um erro inesperado. Tente novamente.'));
    }
  }

  Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(AuthUnauthenticated());
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      if (userCredential.user != null) {
        emit(AuthAuthenticated(userCredential.user!));
      } else {
        emit(const AuthError('Não foi possível iniciar sessão com o Google.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_translateFirebaseError(e)));
    } catch (e) {
      emit(const AuthError('Ocorreu um erro inesperado. Tente novamente.'));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(const AuthError('Erro ao terminar sessão. Tente novamente.'));
    }
  }
}
