enum UserRole {
  regular,
  moderator,
  administrator
}
class RoleServices {
  static UserRole convertToEnum(String role) {
    switch(role) {
      case "moderator":
        return UserRole.moderator;
      case "administrator":
        return UserRole.administrator;
      default:
        return UserRole.regular;
    }
  }
}
