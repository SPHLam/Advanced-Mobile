import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jarvis/constants/colors.dart'; // Use old code's color constants
import 'package:jarvis/constants/text_strings.dart';
import 'package:jarvis/views/Login/login_screen.dart';
import 'package:jarvis/viewmodels/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    _loadSubscriptionDetails();
    _loadTokenUsage();
  }

  Future<void> _loadSubscriptionDetails() async {
    await Provider.of<AuthViewModel>(context, listen: false)
        .loadSubscriptionDetails();
  }

  Future<void> _loadTokenUsage() async {
    await Provider.of<AuthViewModel>(context, listen: false).fetchTokens();
  }

  Future<void> _logout() async {
    await Provider.of<AuthViewModel>(context, listen: false).logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor, // From old code
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Your Profile",
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.purple,
                        child: Center(
                          child: Text(
                            authViewModel.user?.username[0].toUpperCase() ??
                                'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authViewModel.user?.username ?? 'User',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            authViewModel.user?.email ?? 'No email',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.cyan, Colors.teal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/images/star.png',
                          width: 70,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error, color: Colors.white);
                          },
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authViewModel.versionName.isNotEmpty
                                  ? authViewModel.versionName.toUpperCase()
                                  : 'Free',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              authViewModel.maxTokens == 99999
                                  ? 'Unlimited'
                                  : 'Prompt ${authViewModel.remainingTokens ?? 0}/${authViewModel.maxTokens ?? 0}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final Uri url = Uri.parse(linkUpgrade);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Cannot open link!')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.cyan,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Upgrade',
                            style: TextStyle(
                              color: Colors.cyan,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Token Progress Bar
                  const Text(
                    'Token Usage',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: authViewModel.maxTokens == 99999
                        ? 1.0
                        : authViewModel.maxTokens != null &&
                                authViewModel.remainingTokens != null
                            ? (authViewModel.remainingTokens! /
                                    authViewModel.maxTokens!)
                                .toDouble()
                            : 0.0,
                    backgroundColor: Colors.grey[300],
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        authViewModel.maxTokens == 99999
                            ? '0'
                            : authViewModel.remainingTokens?.toString() ?? '0',
                        style: const TextStyle(fontSize: 16),
                      ),
                      authViewModel.maxTokens == 99999
                          ? const FaIcon(
                              FontAwesomeIcons.infinity,
                              size: 16.0,
                              color: Colors.blue,
                            )
                          : Text(
                              authViewModel.maxTokens?.toString() ?? '0',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Support',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCard(
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                          onTap: () {},
                        ),
                        _buildCard(
                          icon: Icons.chat_bubble_outline,
                          title: 'Chat settings',
                          onTap: () {},
                        ),
                        _buildCard(
                          icon: Icons.wb_sunny_outlined,
                          title: 'Theme',
                          subtitle: 'Light',
                          onTap: () {},
                        ),
                        _buildCard(
                          icon: Icons.translate_outlined,
                          title: 'Language',
                          subtitle: 'English',
                          onTap: () {},
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'About',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCard(
                          icon: Icons.privacy_tip,
                          title: 'Privacy Policy',
                          onTap: () {},
                        ),
                        _buildCard(
                          icon: Icons.info,
                          title: 'Version',
                          subtitle: '3.1.0',
                        ),
                        const SizedBox(height: 10),
                        const Divider(color: Colors.grey, thickness: 1),
                        const SizedBox(height: 10),
                        _buildCard(
                          icon: Icons.logout,
                          title: 'Log out',
                          iconColor: Colors.red,
                          textColor: Colors.red,
                          backgroundColor: Colors.red[50]!,
                          onTap: _logout,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color backgroundColor = Colors.white,
    Color iconColor = Colors.grey,
    Color textColor = Colors.black87,
    void Function()? onTap,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: backgroundColor,
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(color: Colors.grey))
            : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
