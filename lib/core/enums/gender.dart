enum Gender {
  male,
  female;
  
  // Returns a display name for the gender
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      default:
        return 'Male';
    }
  }
  
  // Converts a string to Gender
  static Gender fromString(String value) {
    switch (value.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      default:
        return Gender.male;
    }
  }
  
  // Returns all gender values as strings
  static List<String> get displayNames => [
    Gender.male.displayName,
    Gender.female.displayName,
  ];
}
