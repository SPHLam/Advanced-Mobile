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
  if (value == null || value.isEmpty) {
    return 'Please enter the password';
  }
  return null;
}
