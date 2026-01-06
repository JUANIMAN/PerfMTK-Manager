abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ConfigFailure extends Failure {
  const ConfigFailure(super.message);
}

class SystemCommandFailure extends Failure {
  const SystemCommandFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}
