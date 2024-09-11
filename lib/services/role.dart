enum UserRole {
  regular,
  moderator,
  administrator
}
enum Status {
  open,
  inProgress,
  resolved,
  closed
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
    static Status convertToStatus(String role) {
    switch(role) {
      case "open":
        return Status.open;
      case "inProgess":
        return Status.inProgress;
      case "resolved":
        return Status.resolved;
      default:
        return Status.closed;
    }
  }
}
