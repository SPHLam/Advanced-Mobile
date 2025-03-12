import 'package:flutter/material.dart';

class UpgradeAccount extends StatefulWidget {
  const UpgradeAccount({super.key});

  @override
  UpgradeAccountState createState() => UpgradeAccountState();
}

class UpgradeAccountState extends State<UpgradeAccount> {
  String _selectedOption = 'Weekly';
  bool _isHovering = false;
  final Color _primaryColor = const Color(0xFF4E61FC);
  final Color _textColor = const Color(0xFF2A3256);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _buildLogoContainer(),
            const SizedBox(height: 24),

            _buildText("Elevate Your Experience", 28, FontWeight.w800),
            _buildText("with JarvisCopi Pro", 28, FontWeight.w800),
            const SizedBox(height: 12),

            Text(
              "Access premium features designed to boost your productivity",
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 32),

            // Plan options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildUpgradeOption('Weekly', '\$4.99', false),
                _buildUpgradeOption('Monthly', '\$14.99', true),
                _buildUpgradeOption('Yearly', '\$99.99', false),
              ],
            ),
            const SizedBox(height: 32),

            // Features list
            _buildFeaturesContainer(),
            const SizedBox(height: 40),

            // Upgrade button
            _buildUpgradeButton(),
            const SizedBox(height: 16),

            // Free trial text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time_rounded, size: 18, color: _primaryColor),
                const SizedBox(width: 8),
                Text(
                  '3-day free trial, cancel anytime',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoContainer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.rocket_launch_rounded,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  Widget _buildText(String text, double size, FontWeight weight) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: _textColor,
        height: 1.2,
      ),
    );
  }

  Widget _buildFeature(String text, IconData iconData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, color: _primaryColor, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  color: _textColor, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesContainer() {
    final features = [
      {'text': 'Unlock all chat features', 'icon': Icons.chat_bubble_outline},
      {'text': 'Unlimited access to all features', 'icon': Icons.lock_open},
      {'text': 'Higher word limit', 'icon': Icons.text_fields},
      {'text': 'Priority customer support', 'icon': Icons.support_agent},
      {'text': 'Regular updates and new features', 'icon': Icons.update},
      {'text': 'All personalities', 'icon': Icons.psychology},
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryColor.withOpacity(0.1),
            _primaryColor.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: _primaryColor.withOpacity(0.2), width: 1),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pro Membership Benefits',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: _textColor),
          ),
          const SizedBox(height: 16),
          ...features.map(
              (f) => _buildFeature(f['text'] as String, f['icon'] as IconData)),
        ],
      ),
    );
  }

  Widget _buildUpgradeOption(String title, String price, bool isPopular) {
    bool isSelected = _selectedOption == title;

    return Container(
      width: MediaQuery.of(context).size.width * 0.26,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? _primaryColor : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'POPULAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Radio<String>(
            activeColor: _primaryColor,
            value: title,
            groupValue: _selectedOption,
            onChanged: (String? value) {
              setState(() {
                _selectedOption = value!;
              });
            },
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isSelected ? _primaryColor : _textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            price,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? _primaryColor : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Handle purchase
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isHovering
                  ? [const Color(0xFF3B4DE0), const Color(0xFF5F76FF)]
                  : [_primaryColor, const Color(0xFF7089FF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(_isHovering ? 0.5 : 0.4),
                blurRadius: _isHovering ? 15 : 12,
                offset: Offset(0, _isHovering ? 8 : 6),
                spreadRadius: _isHovering ? 1 : 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'UPGRADE NOW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.translationValues(
                    _isHovering ? 5.0 : 0.0, 0.0, 0.0),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
