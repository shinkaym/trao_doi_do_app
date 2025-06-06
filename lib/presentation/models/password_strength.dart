class PasswordStrength {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumbers;
  final bool hasSpecialChar;

  const PasswordStrength({
    this.hasMinLength = false,
    this.hasUppercase = false,
    this.hasLowercase = false,
    this.hasNumbers = false,
    this.hasSpecialChar = false,
  });

  bool get isStrong {
    return hasMinLength &&
        hasUppercase &&
        hasLowercase &&
        hasNumbers &&
        hasSpecialChar;
  }

  PasswordStrength copyWith({
    bool? hasMinLength,
    bool? hasUppercase,
    bool? hasLowercase,
    bool? hasNumbers,
    bool? hasSpecialChar,
  }) {
    return PasswordStrength(
      hasMinLength: hasMinLength ?? this.hasMinLength,
      hasUppercase: hasUppercase ?? this.hasUppercase,
      hasLowercase: hasLowercase ?? this.hasLowercase,
      hasNumbers: hasNumbers ?? this.hasNumbers,
      hasSpecialChar: hasSpecialChar ?? this.hasSpecialChar,
    );
  }
}
