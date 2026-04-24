import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viva_livre_app/features/auth/presentation/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Avatar
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: const Icon(Icons.person_rounded, size: 44, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                user?.displayName ?? 'Usuário',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 32),

              // Menu items
              _ProfileMenuItem(icon: Icons.person_outline, title: 'Editar Perfil', onTap: () {}),
              _ProfileMenuItem(icon: Icons.notifications_none_rounded, title: 'Notificações', onTap: () {}),
              _ProfileMenuItem(icon: Icons.privacy_tip_outlined, title: 'Privacidade & LGPD', onTap: () {}),
              _ProfileMenuItem(icon: Icons.help_outline_rounded, title: 'Ajuda e Suporte', onTap: () {}),
              const SizedBox(height: 8),
              _ProfileMenuItem(
                icon: Icons.logout_rounded,
                title: 'Sair',
                isDestructive: true,
                onTap: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red.shade600 : const Color(0xFF334155);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 22),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 15)),
        trailing: isDestructive ? null : const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
        onTap: onTap,
      ),
    );
  }
}
