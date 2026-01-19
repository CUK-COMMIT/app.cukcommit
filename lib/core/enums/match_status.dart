enum MatchStatus {
  pending,
  matched,
  rejected,
  expired;
  
  // Returns a string representation of the match status
  String get displayName {
    switch (this) {
      case MatchStatus.pending:
        return 'Pending';
      case MatchStatus.matched:
        return 'Matched';
      case MatchStatus.rejected:
        return 'Rejected';
      case MatchStatus.expired:
        return 'Expired';
      default:
        return 'Pending';
    }
  }
  
  // Converts a string to MatchStatus
  static MatchStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return MatchStatus.pending;
      case 'matched':
        return MatchStatus.matched;
      case 'rejected':
        return MatchStatus.rejected;
      case 'expired':
        return MatchStatus.expired;
      default:
        return MatchStatus.pending;
    }
  }
  
  // Check if the match is active
  bool get isActive => this == MatchStatus.matched;
  
  // Check if the match is pending
  bool get isPending => this == MatchStatus.pending;
}