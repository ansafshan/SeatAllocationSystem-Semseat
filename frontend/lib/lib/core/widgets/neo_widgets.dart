import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

// A custom box shadow for the neo-brutalist effect
const neoShadow = [
  BoxShadow(
    color: Colors.black,
    offset: Offset(4, 4),
    blurRadius: 0,
  ),
];

// A smaller version for smaller elements
const neoShadowSm = [
  BoxShadow(
    color: Colors.black,
    offset: Offset(2, 2),
    blurRadius: 0,
  ),
];

class NeoCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double padding;

  const NeoCard({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.padding = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: neoShadow,
      ),
      padding: EdgeInsets.all(padding),
      child: child,
    );
  }
}

class NeoButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  const NeoButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.icon,
    this.padding,
  }) : super(key: key);

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: _isPressed && isEnabled ? Matrix4.translationValues(4, 4, 0) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: isEnabled ? widget.backgroundColor : Colors.grey.shade300,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: _isPressed || !isEnabled ? [] : neoShadow,
        ),
        padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) Icon(widget.icon, color: widget.textColor, size: 20),
            if (widget.icon != null) const SizedBox(width: 8),
            Text(
              widget.text.toUpperCase(),
              style: TextStyle(
                color: isEnabled ? widget.textColor : Colors.grey.shade600,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class AdminLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const AdminLayout({
    Key? key,
    required this.child,
    required this.title,
    this.actions,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title.toUpperCase()),
        actions: [
          ...?actions,
          IconButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: isDesktop ? null : Drawer(child: _buildSidebar(context)),
      floatingActionButton: floatingActionButton,
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Center(
              child: Text(
                'SEMSEAT',
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSidebarItem(context, 'Dashboard', Icons.home, '/admin'),
                _buildSidebarItem(context, 'Students', Icons.group, '/admin/students'),
                _buildSidebarItem(context, 'Teachers', Icons.school, '/admin/teachers'),
                _buildSidebarItem(context, 'Departments', Icons.corporate_fare, '/admin/departments'),
                _buildSidebarItem(context, 'Batches', Icons.layers, '/admin/batches'),
                _buildSidebarItem(context, 'Subjects', Icons.menu_book, '/admin/subjects'),
                _buildSidebarItem(context, 'Halls', Icons.business, '/admin/halls'),
                _buildSidebarItem(context, 'Sessions', Icons.calendar_month, '/admin/sessions'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, String title, IconData icon, String route) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final isSelected = currentPath == route;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: isSelected ? neoShadow : [],
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.black),
        title: Text(title.toUpperCase(), style: TextStyle(
          fontWeight: FontWeight.w800,
          color: isSelected ? Colors.white : Colors.black,
        )),
        onTap: () => context.go(route),
      ),
    );
  }
}

class NeoTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final Widget? suffixIcon;

  const NeoTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hint = '',
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: neoShadowSm,
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              border: InputBorder.none,
              isDense: true,
              suffixIcon: suffixIcon,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
