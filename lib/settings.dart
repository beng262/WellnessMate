import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/splash');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // Overall background color
      backgroundColor: const Color(0xFF63B4FF),
      body: Stack(
        children: [
          // 1) Main content behind the burger menu (optional placeholder)
          Container(
            alignment: Alignment.center,
            child: const Text(
              "Main Settings Content",
              style: TextStyle(color: Colors.white),
            ),
          ),

          // 2) The burger menu (left-aligned), 75% of screen width
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: screenWidth * 0.75,
              // Rounded corners only on the right side
              decoration: const BoxDecoration(
                color: Color(0xFF63B4FF), // Menu background
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              // Make it scrollable if content is tall
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -- mlogo.png at the top (40x40) --
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: Image.asset('images/mlogo.png'),
                      ),

                      // Add some spacing below the top logo
                      const SizedBox(height: 20),

                      // Big text "Profile" (20px, Belonasima)
                      const Text(
                        "Profile",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Belanosima',
                          color: Colors.white,
                        ),
                      ),

                      // 20px gap between big text and rectangles
                      const SizedBox(height: 20),

                      // Top rectangle (70px height) with blogo (48x48)
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pet & Me features coming soon!')),
                          );
                        },
                        child: _buildTopRectangle(
                          label: "Pet & Me",
                          logoPath: 'images/blogo.png',
                          arrowPath: 'images/sarrow.png',
                        ),
                      ),

                      // 20px gap before next big text
                      const SizedBox(height: 20),

                      // Big text "Preferences"
                      const Text(
                        "Preferences",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Belanosima',
                          color: Colors.white,
                        ),
                      ),

                      // 20px gap between big text and rectangles
                      const SizedBox(height: 20),

                      // Normal rectangles (30px height)
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notifications settings coming soon!')),
                          );
                        },
                        child: _buildNormalRectangle(
                          label: "Notifications",
                          arrowPath: 'images/sarrow.png',
                        ),
                      ),
                      const SizedBox(height: 10), // 10px between rectangles
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Language settings coming soon!')),
                          );
                        },
                        child: _buildNormalRectangle(
                          label: "Language",
                          arrowPath: 'images/sarrow.png',
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Audio settings coming soon!')),
                          );
                        },
                        child: _buildNormalRectangle(
                          label: "Audio",
                          arrowPath: 'images/sarrow.png',
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/theme_selection');
                        },
                        child: _buildNormalRectangle(
                          label: "App Theme",
                          arrowPath: 'images/sarrow.png',
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Background customization coming soon!')),
                          );
                        },
                        child: _buildNormalRectangle(
                          label: "Background",
                          arrowPath: 'images/sarrow.png',
                        ),
                      ),

                      // 20px gap before next big text
                      const SizedBox(height: 20),

                      // Big text "Account"
                      const Text(
                        "Account",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Belanosima',
                          color: Colors.white,
                        ),
                      ),

                      // 20px gap
                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Application data management coming soon!')),
                          );
                        },
                        child: _buildNormalRectangle(
                          label: "Application Data",
                          arrowPath: 'images/sarrow.png',
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Terms of Service coming soon!')),
                          );
                        },
                        child: _buildNormalRectangle(
                          label: "Terms of Service",
                          arrowPath: 'images/sarrow.png',
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Privacy Policy coming soon!')),
                          );
                        },
                        child: _buildNormalRectangle(
                          label: "Privacy Policy",
                          arrowPath: 'images/sarrow.png',
                        ),
                      ),

                      // 20px gap
                      const SizedBox(height: 20),

                      // Big text "Support"
                      const Text(
                        "Support",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Belanosima',
                          color: Colors.white,
                        ),
                      ),

                      // 20px gap
                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Contact support coming soon!')),
                          );
                        },
                        child: _buildNormalRectangle(
                          label: "Contact Us",
                          arrowPath: 'images/sarrow.png',
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/firebase_test');
                        },
                        child: _buildNormalRectangle(
                          label: "Firebase Test",
                          arrowPath: 'images/sarrow.png',
                        ),
                      ),
                      
                      // Add some spacing before logout
                      const SizedBox(height: 40),
                      
                      // Logout button
                      GestureDetector(
                        onTap: _logout,
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              "Logout",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontFamily: 'Belanosima',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Top rectangle (70px height) with blogo.png (48x48)
  Widget _buildTopRectangle({
    required String label,
    required String logoPath,
    required String arrowPath,
  }) {
    return Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFCAE1FF),
        borderRadius: BorderRadius.circular(20), // 20 corner radius
      ),
      // 10px from the left for blogo, 20px from the right for arrow
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 20),
        child: Row(
          children: [
            // blogo.png (48x48)
            SizedBox(width: 48, height: 48, child: Image.asset(logoPath)),
            const SizedBox(width: 10), // space between logo and text
            // Text (16px)
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),

            // Push arrow to far right
            const Spacer(),

            // Arrow icon (sarrow.png)
            SizedBox(width: 24, height: 24, child: Image.asset(arrowPath)),
          ],
        ),
      ),
    );
  }

  // Normal rectangle (30px height)
  Widget _buildNormalRectangle({
    required String label,
    required String arrowPath,
  }) {
    return Container(
      height: 30,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFCAE1FF),
        borderRadius: BorderRadius.circular(20), // 20 corner radius
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 20),
        child: Row(
          children: [
            // Text (16px)
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const Spacer(),

            // Arrow icon
            SizedBox(width: 24, height: 24, child: Image.asset(arrowPath)),
          ],
        ),
      ),
    );
  }
}
