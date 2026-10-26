import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/login_page.dart';
import '../screens/admin_dashboard.dart';

class NavBar extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onServicesTap;
  final VoidCallback onPortfolioTap;
  final VoidCallback onContactTap;

  const NavBar({
    super.key,
    required this.onHomeTap,
    required this.onServicesTap,
    required this.onPortfolioTap,
    required this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Fashionable Logo
          InkWell(
            onTap: onHomeTap,
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SRISHTI',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 6.0,
                    color: const Color(0xFF2C2420),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 14, height: 1, color: const Color(0xFFC3A36E)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        'BRIDAL ATELIER',
                        style: GoogleFonts.montserrat(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3.0,
                          color: const Color(0xFF8C7355),
                        ),
                      ),
                    ),
                    Container(width: 14, height: 1, color: const Color(0xFFC3A36E)),
                  ],
                ),
              ],
            ),
          ),
          // Navigation Links (hidden on very small screens, ideally we'd use a drawer but keeping it simple for now)
          if (MediaQuery.of(context).size.width > 600)
            Row(
              children: [
                _NavTextButton(title: 'HOME', onTap: onHomeTap),
                const SizedBox(width: 20),
                _NavTextButton(title: 'SERVICES', onTap: onServicesTap),
                const SizedBox(width: 20),
                _NavTextButton(title: 'PORTFOLIO', onTap: onPortfolioTap),
                const SizedBox(width: 20),
                _NavTextButton(title: 'CONTACT', onTap: onContactTap),
                const SizedBox(width: 32),
                _buildAuthAction(context),
              ],
            )
          else
            Row(
              children: [
                _buildAuthAction(context),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 16),
                              ListTile(
                                title: const Center(child: Text('HOME')),
                                onTap: () {
                                  Navigator.pop(context);
                                  onHomeTap();
                                },
                              ),
                              ListTile(
                                title: const Center(child: Text('SERVICES')),
                                onTap: () {
                                  Navigator.pop(context);
                                  onServicesTap();
                                },
                              ),
                              ListTile(
                                title: const Center(child: Text('PORTFOLIO')),
                                onTap: () {
                                  Navigator.pop(context);
                                  onPortfolioTap();
                                },
                              ),
                              ListTile(
                                title: const Center(child: Text('CONTACT')),
                                onTap: () {
                                  Navigator.pop(context);
                                  onContactTap();
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAuthAction(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          final String fullName = user.userMetadata?['full_name'] ?? 'User';
          final String initial = fullName.isNotEmpty
              ? fullName[0].toUpperCase()
              : 'U';

          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _showProfileDialog(context, user, fullName),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              child: Text(initial),
            ),
          );
        } else {
          return TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              textStyle: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            child: const Text('SIGN IN'),
          );
        }
      },
    );
  }

  void _showProfileDialog(BuildContext context, User user, String fullName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Profile Details',
            style: TextStyle(fontFamily: 'Georgia'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name: $fullName',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Email: ${user.email}',
                style: const TextStyle(fontSize: 16),
              ),
              if (user.email == 'poojapadmakumar03@gmail.com') ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // close dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminDashboard()),
                      );
                    },
                    icon: const Icon(Icons.dashboard),
                    label: const Text('Admin Dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE'),
            ),
            ElevatedButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.pop(context); // close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out successfully')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE57373), // Soft red
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: const Text('LOGOUT'),
            ),
          ],
        );
      },
    );
  }
}

class _NavTextButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _NavTextButton({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.secondary,
        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
      child: Text(title),
    );
  }
}
