import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'theme_provider.dart';

class ThemeSelectionPage extends StatefulWidget {
  const ThemeSelectionPage({super.key});

  @override
  State<ThemeSelectionPage> createState() => _ThemeSelectionPageState();
}

class _ThemeSelectionPageState extends State<ThemeSelectionPage> {
  double _brightness = 1.0;
  double _contrast = 1.0;
  double _saturation = 1.0;
  double _hue = 0.0;
  double _blur = 0.0;

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ${value.toStringAsFixed(1)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Belanosima',
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Theme'),
        backgroundColor: const Color(0xFF63B4FF),
        foregroundColor: Colors.white,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeProvider.currentTheme.primaryColor,
                  themeProvider.currentTheme.secondaryColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Theme Selection Section
                  const Text(
                    'App Themes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Belanosima',
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Theme List
                  ...List.generate(themeProvider.themes.length, (index) {
                    final theme = themeProvider.themes[index];
                    final isSelected = themeProvider.currentThemeIndex == index;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                      ),
                      child: ListTile(
                        onTap: () {
                          themeProvider.setTheme(index);
                          setState(() {});
                        },
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.palette,
                            color: theme.textColor,
                            size: 30,
                          ),
                        ),
                        title: Text(
                          theme.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontFamily: 'Belanosima',
                          ),
                        ),
                        subtitle: Text(
                          'Primary: ${theme.primaryColor.toString().substring(6, 16)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 30,
                              )
                            : null,
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 40),
                  
                  // Background Customization Section
                  const Text(
                    'Background Customization',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Belanosima',
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Background Preview
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.matrix([
                          _brightness, 0, 0, 0, 0,
                          0, _brightness, 0, 0, 0,
                          0, 0, _brightness, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
                          child: Image.asset(
                            'images/background.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Brightness Slider
                  _buildSlider(
                    'Brightness',
                    _brightness,
                    0.0,
                    2.0,
                    (value) => setState(() => _brightness = value),
                  ),
                  
                  // Contrast Slider
                  _buildSlider(
                    'Contrast',
                    _contrast,
                    0.0,
                    2.0,
                    (value) => setState(() => _contrast = value),
                  ),
                  
                  // Saturation Slider
                  _buildSlider(
                    'Saturation',
                    _saturation,
                    0.0,
                    2.0,
                    (value) => setState(() => _saturation = value),
                  ),
                  
                  // Hue Slider
                  _buildSlider(
                    'Hue',
                    _hue,
                    0.0,
                    360.0,
                    (value) => setState(() => _hue = value),
                  ),
                  
                  // Blur Slider
                  _buildSlider(
                    'Blur',
                    _blur,
                    0.0,
                    10.0,
                    (value) => setState(() => _blur = value),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Save background settings to theme provider
                        themeProvider.setBackgroundSettings(
                          brightness: _brightness,
                          contrast: _contrast,
                          saturation: _saturation,
                          hue: _hue,
                          blur: _blur,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Background settings applied!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF63B4FF),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Apply Background Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Belanosima',
                        ),
                      ),
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
} 