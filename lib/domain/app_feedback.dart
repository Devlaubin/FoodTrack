/// Type of feedback: a bug or a feature suggestion.
enum FeedbackType {
  bug,
  suggestion;

  String get apiValue {
    switch (this) {
      case FeedbackType.bug:
        return 'bug';
      case FeedbackType.suggestion:
        return 'suggestion';
    }
  }

  String get label {
    switch (this) {
      case FeedbackType.bug:
        return 'Bug';
      case FeedbackType.suggestion:
        return 'Amelioration';
    }
  }
}

/// Category used to classify feedback (mirrors the SQL CHECK constraint).
enum FeedbackCategory {
  carte,
  recherche,
  compte,
  pro,
  performance,
  autre;

  static FeedbackCategory fromApi(String value) {
    switch (value) {
      case 'carte':
        return FeedbackCategory.carte;
      case 'recherche':
        return FeedbackCategory.recherche;
      case 'compte':
        return FeedbackCategory.compte;
      case 'pro':
        return FeedbackCategory.pro;
      case 'performance':
        return FeedbackCategory.performance;
      case 'autre':
      default:
        return FeedbackCategory.autre;
    }
  }

  String get apiValue {
    switch (this) {
      case FeedbackCategory.carte:
        return 'carte';
      case FeedbackCategory.recherche:
        return 'recherche';
      case FeedbackCategory.compte:
        return 'compte';
      case FeedbackCategory.pro:
        return 'pro';
      case FeedbackCategory.performance:
        return 'performance';
      case FeedbackCategory.autre:
        return 'autre';
    }
  }

  String get label {
    switch (this) {
      case FeedbackCategory.carte:
        return 'Carte';
      case FeedbackCategory.recherche:
        return 'Recherche';
      case FeedbackCategory.compte:
        return 'Compte';
      case FeedbackCategory.pro:
        return 'Espace Pro';
      case FeedbackCategory.performance:
        return 'Performance';
      case FeedbackCategory.autre:
        return 'Autre';
    }
  }
}

/// Lifecycle status of a feedback entry.
enum FeedbackStatus {
  newStatus,
  inProgress,
  resolved,
  closed;

  static FeedbackStatus fromApi(String value) {
    switch (value) {
      case 'in_progress':
        return FeedbackStatus.inProgress;
      case 'resolved':
        return FeedbackStatus.resolved;
      case 'closed':
        return FeedbackStatus.closed;
      case 'new':
      default:
        return FeedbackStatus.newStatus;
    }
  }

  String get label {
    switch (this) {
      case FeedbackStatus.newStatus:
        return 'Nouveau';
      case FeedbackStatus.inProgress:
        return 'En cours';
      case FeedbackStatus.resolved:
        return 'Resolu';
      case FeedbackStatus.closed:
        return 'Clos';
    }
  }
}

/// A bug report or feature suggestion submitted by a user.
class AppFeedback {
  const AppFeedback({
    required this.id,
    required this.userId,
    required this.type,
    required this.category,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final FeedbackType type;
  final FeedbackCategory category;
  final String title;
  final String description;
  final FeedbackStatus status;
  final DateTime createdAt;

  factory AppFeedback.fromJson(Map<String, dynamic> json) {
    return AppFeedback(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] == 'suggestion'
          ? FeedbackType.suggestion
          : FeedbackType.bug,
      category: FeedbackCategory.fromApi(json['category'] as String? ?? 'autre'),
      title: json['title'] as String,
      description: json['description'] as String,
      status: FeedbackStatus.fromApi(json['status'] as String? ?? 'new'),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

