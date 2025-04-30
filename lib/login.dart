import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // We have 6 steps:
  // 0: Name, 1: Gender, 2: Birthday, 3: Email, 4: Password, 5: Axo Color.
  int _currentStep = 0;
  static const int totalSteps = 6;

  // Data collected.
  String _userName = "";
  String _selectedGender = "";
  DateTime? _selectedBirthday;
  String _userEmail = "";
  String _userPassword = "";
  String _confirmPassword = "";
  String _selectedAxoColor = "";

  // Birthday defaults.
  int _selectedDay = 1;
  int _selectedMonth = 1;
  int _selectedYear = 2000;

  // Password visibility toggles.
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Error messages to display.
  String _emailError = "";
  String _passwordError = "";
  String _firebaseError = "";

  // Text controllers.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // ------------------ Styles & Gradients ------------------

  // Gradient for input texts: from #FF9AF5 to #A0D1FF to #CFB5FA.
  final LinearGradient inputGradient = const LinearGradient(
    colors: [
      Color(0xFFFF9AF5),
      Color(0xFFA0D1FF),
      Color(0xFFCFB5FA),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Input text style using a shader.
  TextStyle get inputTextStyle => TextStyle(
    fontFamily: 'Belanosima-Regular',
    fontSize: 24,
    foreground: Paint()..shader = inputGradient.createShader(const Rect.fromLTWH(0, 0, 300, 40)),
  );

  // Question text style: white, bold, 40pt.
  final TextStyle questionTextStyle = const TextStyle(
    fontFamily: 'Belanosima-Regular',
    fontSize: 40,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  // Button text style: bold, 26pt.
  TextStyle get buttonTextStyle => const TextStyle(
    fontFamily: 'Belanosima-Regular',
    fontSize: 26,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  // Vertical gradient for button text.
  Shader get verticalGradient => const LinearGradient(
    colors: [
      Color(0xFFB4A8FA),
      Color(0xFF69B7FF),
      Color(0xFFFF9AF5),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  ).createShader(const Rect.fromLTWH(0, 0, 300, 40));

  // ------------------ Validation ------------------

  bool get _canContinue {
    switch (_currentStep) {
      case 0:
        return _userName.trim().isNotEmpty;
      case 1:
        return _selectedGender.isNotEmpty;
      case 2:
        return _selectedBirthday != null;
      case 3:
        return _userEmail.trim().isNotEmpty && _validateEmail(_userEmail);
      case 4:
        return _userPassword.isNotEmpty &&
            _confirmPassword.isNotEmpty &&
            _userPassword == _confirmPassword &&
            _userPassword.length >= 6;
      case 5:
        return _selectedAxoColor.isNotEmpty;
      default:
        return false;
    }
  }

  // Simple email validation.
  bool _validateEmail(String email) {
    return email.contains("@") && email.contains(".");
  }

  // ------------------ Navigation Handlers ------------------

  void _onContinuePressed() {
    // Validate email on step 3.
    if (_currentStep == 3 && !_validateEmail(_userEmail)) {
      setState(() {
        _emailError = "Please enter a valid email.";
      });
      return;
    } else {
      _emailError = "";
    }

    // Validate password on step 4.
    if (_currentStep == 4) {
      if (_userPassword.isEmpty) {
        setState(() {
          _passwordError = "Please enter your password.";
        });
        return;
      }
      if (_confirmPassword.isEmpty) {
        setState(() {
          _passwordError = "Please confirm your password.";
        });
        return;
      }
      if (_userPassword.length < 6) {
        setState(() {
          _passwordError = "Password must be at least 6 characters.";
        });
        return;
      }
      if (_userPassword != _confirmPassword) {
        setState(() {
          _passwordError = "Passwords do not match.";
        });
        return;
      } else {
        _passwordError = "";
      }
    }

    if (!_canContinue) return;
    setState(() {
      if (_currentStep < totalSteps - 1) {
        _currentStep++;
      } else {
        _createFirebaseUser();
      }
    });
  }

  void _onBackPressed() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  // ------------------ Firebase User Creation ------------------

  Future<void> _createFirebaseUser() async {
    try {
      // Create user with email and password.
      UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _userEmail,
        password: _userPassword,
      );
      final uid = cred.user?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': _userName,
          'gender': _selectedGender,
          'birthday': _selectedBirthday,
          'email': _userEmail,
          'axoColor': _selectedAxoColor,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      setState(() {
        _firebaseError = e.toString();
      });
      print("Error creating user: $e");
    }
  }

  // ------------------ Build Methods ------------------

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Override hardware back button.
      onWillPop: () async {
        if (_currentStep > 0) {
          _onBackPressed();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF69B7FF),
                Color(0xFFFF9AF5),
                Color(0xFFB4A8FA),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // OPTIONAL: Insert Lottie animation here.

                // Progress Bar at the top: 300x10 white, rounded (radius 20).
                Positioned(
                  top: 30,
                  left: (MediaQuery.of(context).size.width - 300) / 2,
                  child: Container(
                    width: 300,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: (300 / totalSteps) * _currentStep,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4C7EFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
                // Back Button: positioned to the left of the Continue button.
                if (_currentStep > 0)
                  Positioned(
                    bottom: 60,
                    left: (MediaQuery.of(context).size.width - 230) / 2 - 40,
                    child: GestureDetector(
                      onTap: _onBackPressed,
                      child: Image.asset(
                        'images/BackArrow.png',
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                // Continue/Finish Button.
                Positioned(
                  bottom: 60,
                  left: (MediaQuery.of(context).size.width - 230) / 2,
                  child: GestureDetector(
                    onTap: _canContinue ? _onContinuePressed : null,
                    child: Container(
                      width: 230,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: ShaderMask(
                        shaderCallback: (bounds) => verticalGradient,
                        blendMode: BlendMode.srcIn,
                        child: Text(
                          _currentStep == totalSteps - 1 ? "Finish!" : "Continue",
                          style: buttonTextStyle,
                        ),
                      ),
                    ),
                  ),
                ),
                // Error messages (for email, password, Firebase) displayed above the button.
                if (((_currentStep == 3 && _emailError.isNotEmpty) ||
                    (_currentStep == 4 && _passwordError.isNotEmpty)) ||
                    _firebaseError.isNotEmpty)
                  Positioned(
                    bottom: 120,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        _emailError.isNotEmpty
                            ? _emailError
                            : _passwordError.isNotEmpty
                            ? _passwordError
                            : _firebaseError,
                        style: const TextStyle(
                          fontFamily: 'Belanosima-Regular',
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                // Main Step Content.
                Center(child: _buildStepContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------ Step Content Builder ------------------

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildUserInfoStep();
      case 1:
        return _buildGenderStep();
      case 2:
        return _buildBirthdayStep();
      case 3:
        return _buildEmailStep();
      case 4:
        return _buildPasswordStep();
      case 5:
        return _buildAxoColorStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // ---------- STEP 0: User Info (Name) ----------

  Widget _buildUserInfoStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("What is your name?", style: questionTextStyle, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Container(
          width: 300,
          height: 60,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20)
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: _nameController,
            onChanged: (val) => setState(() => _userName = val),
            textAlign: TextAlign.center,
            style: inputTextStyle,
            onSubmitted: (_) => _onContinuePressed(),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Write your name here...",
            ),
          ),
        ),
      ],
    );
  }

  // ---------- STEP 1: Gender ----------

  Widget _buildGenderStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("What is your gender?", style: questionTextStyle, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        _buildGenderOption(
          label: "Female",
          notSelectedTextColor: const Color(0xFFA4D3FF),
          selectedBoxColor: const Color(0xFF4C7EFF),
          isSelected: _selectedGender == "female",
          onTap: () => setState(() => _selectedGender = "female"),
        ),
        const SizedBox(height: 30),
        _buildGenderOption(
          label: "Male",
          notSelectedTextColor: const Color(0xFFFFA8F6),
          selectedBoxColor: const Color(0xFFFF63EF),
          isSelected: _selectedGender == "male",
          onTap: () => setState(() => _selectedGender = "male"),
        ),
        const SizedBox(height: 30),
        _buildGenderOption(
          label: "Non-binary",
          notSelectedTextGradient: verticalGradient,
          selectedBoxGradient: LinearGradient(
            colors: const [
              Color(0xFF69B7FF),
              Color(0xFFB4A8FA),
              Color(0xFFFF9AF5),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          isSelected: _selectedGender == "nonbinary",
          onTap: () => setState(() => _selectedGender = "nonbinary"),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => setState(() => _selectedGender = "prefer not to say"),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(10),
              color: _selectedGender == "prefer not to say" ? Colors.white24 : Colors.transparent,
            ),
            child: const Text(
              "Prefer not to say",
              style: TextStyle(fontFamily: 'Belanosima-Regular', fontSize: 20, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption({
    required String label,
    Color? notSelectedTextColor,
    Shader? notSelectedTextGradient,
    Color? selectedBoxColor,
    LinearGradient? selectedBoxGradient,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    BoxDecoration boxDecoration = !isSelected
        ? BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))
        : (selectedBoxGradient != null
        ? BoxDecoration(gradient: selectedBoxGradient, borderRadius: BorderRadius.circular(20))
        : BoxDecoration(color: selectedBoxColor, borderRadius: BorderRadius.circular(20)));

    Widget textWidget = !isSelected
        ? (notSelectedTextGradient != null
        ? ShaderMask(
      shaderCallback: (bounds) => notSelectedTextGradient,
      blendMode: BlendMode.srcIn,
      child: Text(label, style: const TextStyle(fontFamily: 'Belanosima-Regular', fontSize: 24, fontWeight: FontWeight.bold)),
    )
        : Text(label, style: TextStyle(fontFamily: 'Belanosima-Regular', fontSize: 24, fontWeight: FontWeight.bold, color: notSelectedTextColor)))
        : Text(label, style: const TextStyle(fontFamily: 'Belanosima-Regular', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        height: 60,
        decoration: boxDecoration,
        alignment: Alignment.center,
        child: textWidget,
      ),
    );
  }

  // ---------- STEP 2: Birthday ----------
  // Birthday boxes are directly editable.
  Widget _buildBirthdayStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("When is your birthday?", style: questionTextStyle, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        // Row of birthday boxes with 15px gaps.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEditableBirthdayBox("DD", _selectedDay, 1, 31, (val) {
              setState(() {
                _selectedDay = val;
                _updateBirthday();
              });
            }),
            const SizedBox(width: 15),
            _buildEditableBirthdayBox("MM", _selectedMonth, 1, 12, (val) {
              setState(() {
                _selectedMonth = val;
                _updateBirthday();
              });
            }),
            const SizedBox(width: 15),
            // Increase year box width by 10 pixels.
            _buildEditableBirthdayBox("YYYY", _selectedYear, 1900, 2025, (val) {
              setState(() {
                _selectedYear = val;
                _updateBirthday();
              });
            }, extraWidth: 10),
          ],
        ),
      ],
    );
  }

  // Editable birthday box: directly editable TextField with vertical drag.
  Widget _buildEditableBirthdayBox(String label, int currentValue, int min, int max, Function(int) onChanged, {double extraWidth = 0}) {
    final double boxWidth = 90 + extraWidth;
    final TextEditingController _boxController = TextEditingController(text: currentValue.toString());
    return Container(
      width: boxWidth,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          int delta = details.delta.dy < 0 ? -1 : 1;
          int newValue = currentValue - delta;
          if (newValue < min) newValue = min;
          if (newValue > max) newValue = max;
          onChanged(newValue);
          _boxController.text = newValue.toString();
        },
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Editable text.
              SizedBox(
                width: boxWidth - 30,
                child: TextField(
                  controller: _boxController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: inputTextStyle,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (val) {
                    int? newVal = int.tryParse(val);
                    if (newVal != null && newVal >= min && newVal <= max) {
                      onChanged(newVal);
                    } else {
                      _boxController.text = currentValue.toString();
                    }
                  },
                ),
              ),
              // Arrow indicator.
              const SizedBox(width: 4),
              Image.asset('images/arrow3.png', width: 20, height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _updateBirthday() {
    setState(() {
      _selectedBirthday = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    });
  }

  // ---------- STEP 3: Email ----------
  Widget _buildEmailStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("What is your email?", style: questionTextStyle, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Container(
          width: 300,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (val) {
              setState(() {
                _userEmail = val;
                _emailError = "";
              });
            },
            textAlign: TextAlign.center,
            style: inputTextStyle,
            onSubmitted: (_) => _onContinuePressed(),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Write your email here...",
            ),
          ),
        ),
      ],
    );
  }

  // ---------- STEP 4: Password & Confirm Password ----------
  Widget _buildPasswordStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Create a password", style: questionTextStyle, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Container(
          width: 300,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            onChanged: (val) {
              setState(() {
                _userPassword = val;
                _passwordError = "";
              });
            },
            textAlign: TextAlign.center,
            style: inputTextStyle,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Enter your password...",
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFFA0D1FF),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text("Confirm password", style: questionTextStyle, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Container(
          width: 300,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            onChanged: (val) {
              setState(() {
                _confirmPassword = val;
                _passwordError = "";
              });
            },
            textAlign: TextAlign.center,
            style: inputTextStyle,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Confirm your password...",
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFFA0D1FF),
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- STEP 5: Axo Color ----------
  Widget _buildAxoColorStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("What color would be best for your axo?", style: questionTextStyle, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAxoOption("blueaxo.png", "blue"),
            const SizedBox(width: 10),
            _buildAxoOption("pinkaxo.png", "pink"),
            const SizedBox(width: 10),
            _buildAxoOption("purpleaxo.png", "purple"),
          ],
        ),
      ],
    );
  }

  Widget _buildAxoOption(String asset, String colorValue) {
    final bool isSelected = (_selectedAxoColor == colorValue);
    // Base size 120; if selected, grow 125%.
    final double baseSize = 120;
    final double size = isSelected ? baseSize * 1.25 : baseSize;
    return GestureDetector(
      onTap: () => setState(() => _selectedAxoColor = colorValue),
      child: Image.asset(
        'images/$asset',
        width: size,
        height: size,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
