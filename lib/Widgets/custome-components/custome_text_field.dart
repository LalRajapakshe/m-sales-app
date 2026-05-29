import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String name;
  final IconData prefixIcon;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final TextInputType textInputType;
  final Widget? suffix;
  final String? hint;
  final Function? onChange;
  final bool readOnly; // Add this line

  CustomTextField({
    super.key,
    required this.controller,
    required this.name,
    required this.prefixIcon,
    required this.obscureText,
    required this.textCapitalization,
    required this.textInputType,
    this.onChange,
    this.hint,
    this.suffix,
    this.readOnly = false, // Default to false
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextField(
        enabled: !widget.readOnly, // Disable if readOnly is true
        controller: widget.controller,
        textCapitalization: widget.textCapitalization,
        maxLength: 32,
        onChanged: (v) {
          if (widget.onChange != null && !widget.readOnly) {
            widget.onChange!(v);
          }
        },
        maxLines: 1,
        obscureText: widget.obscureText,
        keyboardType: widget.textInputType,
        textAlign: TextAlign.start,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(color: Colors.grey, widget.prefixIcon),
          suffix: widget.suffix,
          isDense: true,
          labelText: widget.name,
          counterText: "",
          hintText: widget.hint,
          labelStyle: const TextStyle(color: Colors.grey),
          border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
        readOnly: widget.readOnly, // Add this line
      ),
    );
  }
}
