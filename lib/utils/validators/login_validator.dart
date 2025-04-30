String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Vui lòng nhập email';
  }
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Email không hợp lệ';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Vui lòng nhập mật khẩu';
  }
  return null;
}
