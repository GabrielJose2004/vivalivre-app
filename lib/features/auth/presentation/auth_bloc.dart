import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthBloc() : super(AuthInitial()) {
    // Check initial state
    _firebaseAuth.authStateChanges().listen((User? user) {
      if (user != null) {
        // If we wanted to listen and emit stream updates we could use a separate stream listener event.
        // For simplicity, we are managing states directly in the handlers for now.
      }
    });

    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
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
        emit(const AuthError('Usuário não encontrado.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Erro ao fazer login.'));
    } catch (e) {
      emit(AuthError(e.toString()));
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
        emit(const AuthError('Erro ao criar conta.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Erro ao registrar usuário.'));
    } catch (e) {
      emit(AuthError(e.toString()));
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
        emit(const AuthError('Login com Google cancelado.'));
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
        emit(const AuthError('Erro ao fazer login com Google.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Erro de autenticação com Google.'));
    } catch (e) {
      emit(AuthError(e.toString()));
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
      emit(AuthError('Erro ao fazer logout: ${e.toString()}'));
    }
  }
}
