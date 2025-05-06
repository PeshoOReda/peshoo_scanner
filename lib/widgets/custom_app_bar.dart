// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:peshoo_scanner/constant/routes.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout(context);
    Navigator.pushReplacementNamed(context, Routes.signGoogle);
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.deleteAccount(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
        automaticallyImplyLeading: false,
        title: const Text('👻PeshoOCoOde🍀',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.indigo,
        actions: [
          PopupMenuButton<String>(onSelected: (value) {
            switch (value) {
              case 'user':
                Navigator.pushNamed(context, '/user_settings');
                break;
              case 'logout':
                _logout(context);
                break;
              case 'delete_account':
                _deleteAccount(context);
                break;
            }
          }, itemBuilder: (BuildContext context) {
            return {'user', 'logout', 'delete_account'}.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice == 'user'
                    ? 'User'
                    : choice == 'logout'
                        ? 'Logout'
                        : 'Delete Account'),
              );
            }).toList();
          })
        ]);
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
