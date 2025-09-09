enum UserRole { admin, teacher, student, unknown }
UserRole roleFromString(String? s) {
  switch ((s ?? '').toLowerCase()) { case 'admin': return UserRole.admin; case 'teacher': return UserRole.teacher; case 'student': return UserRole.student; default: return UserRole.unknown; }
}
String roleToString(UserRole r) {
  switch (r) { case UserRole.admin: return 'admin'; case UserRole.teacher: return 'teacher'; case UserRole.student: return 'student'; default: return 'unknown'; }
}
