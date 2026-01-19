enum AuthStatus {
  initial,
  unauthenticated,
  authenticating,
  authenticated,
  error;

  // Check if the user is authenticated
  bool get isAuthenticated => this == AuthStatus.authenticated;

  // Check if the user is in the process of authentication
  bool get isAuthenticating => this == AuthStatus.authenticating;

  // Check if the user is not authenticated
  bool get isUnauthenticated => this == AuthStatus.unauthenticated;

  // Check if there was an error during authentication
  bool get hasError => this == AuthStatus.error;
}
