import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/errors/failure.dart';
import '../data/auth_repository_impl.dart';
import '../domain/auth_repository.dart';


final authRepositoryProvider = Provider<AuthRepository>(
      (ref) => AuthRepositoryImpl(Hive.box('session')),
);

class AuthState {
  const AuthState({this.email, this.isLoading = false, this.error});

  final String? email;
  final bool isLoading;
  final String? error;

  bool get isLoggedIn => email != null;
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() =>
      AuthState(email: ref.read(authRepositoryProvider).getLoggedInEmail());

  Future<void> login(String email, String password) async {
    state = const AuthState(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).login(email, password);
      state = AuthState(email: email);
    } on Failure catch (e) {
      state = AuthState(error: e.message);
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState();
  }
}

final authProvider =
NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);