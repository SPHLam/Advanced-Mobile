String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter the email';
  }
  if (!RegExp(r'^[\w-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Email is invalid';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty || value.length < 8) {
    return 'Password must be at least 8 characters';
  }

  // pattern for validate password, it must have at least 1 uppercase letter, at least 1 number
  String pattern = r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{6,}$';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(value)) {
    return 'Password must contain at least 1 uppercase letter and 1 number';
  }
  return null;
}

String? validateConfirmPassword(String? confirmPassword, String? password) {
  if (confirmPassword == null || confirmPassword.isEmpty) {
    return 'Please confirm password';
  }
  if (confirmPassword != password) {
    return 'Confirmation password does not match';
  }
  return null;
}
