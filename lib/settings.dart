import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
                          fontFamily: 'Belonasima',
                        ),
                      ),

                      // 20px gap between big text and rectangles
                      const SizedBox(height: 20),

                      // Top rectangle (70px height) with blogo (48x48)
                      _buildTopRectangle(
                        label: "Pet & Me",
                        logoPath: 'images/blogo.png',
                        arrowPath: 'images/mrarrow.png',
                      ),

                      // 20px gap before next big text
                      const SizedBox(height: 20),

                      // Big text "Preferences"
                      const Text(
                        "Preferences",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Belonasima',
                        ),
                      ),

                      // 20px gap between big text and rectangles
                      const SizedBox(height: 20),

                      // Normal rectangles (30px height)
                      _buildNormalRectangle(
                        label: "Notifications",
                        arrowPath: 'images/mrarrow.png',
                      ),
                      const SizedBox(height: 10), // 10px between rectangles
                      _buildNormalRectangle(
                        label: "Language",
                        arrowPath: 'images/mrarrow.png',
                      ),
                      const SizedBox(height: 10),
                      _buildNormalRectangle(
                        label: "Audio",
                        arrowPath: 'images/mrarrow.png',
                      ),
                      const SizedBox(height: 10),
                      _buildNormalRectangle(
                        label: "Theme",
                        arrowPath: 'images/mrarrow.png',
                      ),

                      // 20px gap before next big text
                      const SizedBox(height: 20),

                      // Big text "Account"
                      const Text(
                        "Account",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Belonasima',
                        ),
                      ),

                      // 20px gap
                      const SizedBox(height: 20),

                      _buildNormalRectangle(
                        label: "Application Data",
                        arrowPath: 'images/mrarrow.png',
                      ),
                      const SizedBox(height: 10),
                      _buildNormalRectangle(
                        label: "Terms of Service",
                        arrowPath: 'images/mrarrow.png',
                      ),
                      const SizedBox(height: 10),
                      _buildNormalRectangle(
                        label: "Privacy Policy",
                        arrowPath: 'images/mrarrow.png',
                      ),

                      // 20px gap
                      const SizedBox(height: 20),

                      // Big text "Support"
                      const Text(
                        "Support",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Belonasima',
                        ),
                      ),

                      // 20px gap
                      const SizedBox(height: 20),

                      _buildNormalRectangle(
                        label: "Contact Us",
                        arrowPath: 'images/mrarrow.png',
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

            // Arrow icon (mrarrow.png)
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
