/// Utility class for converting technical errors to user-friendly messages
class ErrorHandler {
  ErrorHandler._();

  /// Converts authentication errors to user-friendly messages
  static String getAuthErrorMessage(String error) {
    // Convert technical error messages to user-friendly ones
    final lowercaseError = error.toLowerCase();
    
    if (lowercaseError.contains('invalid_credentials') || 
        lowercaseError.contains('invalid login credentials')) {
      return 'Invalid email or password. Please check your credentials.';
    }
    
    if (lowercaseError.contains('user_not_found') || 
        lowercaseError.contains('user not found')) {
      return 'No account found with this email address.';
    }
    
    if (lowercaseError.contains('email_already_exists') || 
        lowercaseError.contains('user already registered')) {
      return 'An account with this email already exists. Please sign in instead.';
    }
    
    if (lowercaseError.contains('weak_password') || 
        lowercaseError.contains('password should be at least')) {
      return 'Password is too weak. Please use at least 6 characters.';
    }
    
    if (lowercaseError.contains('invalid_email') || 
        lowercaseError.contains('unable to validate email')) {
      return 'Please enter a valid email address.';
    }
    
    if (lowercaseError.contains('network') || 
        lowercaseError.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    
    if (lowercaseError.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    if (lowercaseError.contains('email not confirmed')) {
      return 'Please check your email and confirm your account before signing in.';
    }
    
    if (lowercaseError.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment before trying again.';
    }
    
    if (lowercaseError.contains('signup disabled')) {
      return 'Account registration is currently disabled. Please contact support.';
    }
    
    // Default message for unknown errors
    return 'Something went wrong. Please try again or contact support.';
  }
  
  /// Converts general service errors to user-friendly messages
  static String getServiceErrorMessage(String error) {
    final lowercaseError = error.toLowerCase();
    
    if (lowercaseError.contains('network') || 
        lowercaseError.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    
    if (lowercaseError.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    if (lowercaseError.contains('unauthorized') || 
        lowercaseError.contains('access denied')) {
      return 'You don\'t have permission to perform this action.';
    }
    
    if (lowercaseError.contains('not found')) {
      return 'The requested information could not be found.';
    }
    
    if (lowercaseError.contains('server error') || 
        lowercaseError.contains('internal error')) {
      return 'Server error. Please try again later.';
    }
    
    // Default message for unknown errors
    return 'Something went wrong. Please try again.';
  }
}
