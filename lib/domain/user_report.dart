import 'package:flutter/material.dart';

/// Reason a user can choose when reporting another user.
enum ReportReason {
  harassment,
  spam,
  inappropriate,
  fakeFoodtruck,
  other;

  String get apiValue {
    switch (this) {
      case ReportReason.harassment:
        return 'harassment';
      case ReportReason.spam:
        return 'spam';
      case ReportReason.inappropriate:
        return 'inappropriate';
      case ReportReason.fakeFoodtruck:
        return 'fake_foodtruck';
      case ReportReason.other:
        return 'other';
    }
  }

  String get label {
    switch (this) {
      case ReportReason.harassment:
        return 'Harcelement';
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.inappropriate:
        return 'Contenu inapproprie';
      case ReportReason.fakeFoodtruck:
        return 'Faux foodtruck';
      case ReportReason.other:
        return 'Autre';
    }
  }

  IconData get icon {
    switch (this) {
      case ReportReason.harassment:
        return Icons.person_off;
      case ReportReason.spam:
        return Icons.campaign;
      case ReportReason.inappropriate:
        return Icons.visibility_off;
      case ReportReason.fakeFoodtruck:
        return Icons.local_offer;
      case ReportReason.other:
        return Icons.more_horiz;
    }
  }
}

/// Moderation status of a user report.
enum ReportStatus {
  pending,
  reviewed,
  resolved,
  dismissed;

  static ReportStatus fromApi(String value) {
    switch (value) {
      case 'reviewed':
        return ReportStatus.reviewed;
      case 'resolved':
        return ReportStatus.resolved;
      case 'dismissed':
        return ReportStatus.dismissed;
      case 'pending':
      default:
        return ReportStatus.pending;
    }
  }

  String get label {
    switch (this) {
      case ReportStatus.pending:
        return 'En attente';
      case ReportStatus.reviewed:
        return 'En cours d\'examen';
      case ReportStatus.resolved:
        return 'Resolu';
      case ReportStatus.dismissed:
        return 'Ecarte';
    }
  }
}

/// A user report filed by an authenticated user against another account.
class UserReport {
  const UserReport({
    required this.id,
    required this.reporterId,
    this.reportedUserId,
    required this.reportedUserEmail,
    required this.reason,
    this.description,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String reporterId;
  final String? reportedUserId;
  final String reportedUserEmail;
  final ReportReason reason;
  final String? description;
  final ReportStatus status;
  final DateTime createdAt;

  factory UserReport.fromJson(Map<String, dynamic> json) {
    return UserReport(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String,
      reportedUserId: json['reported_user_id'] as String?,
      reportedUserEmail: json['reported_user_email'] as String,
      reason: ReportReason.values.firstWhere(
        (r) => r.apiValue == json['reason'],
        orElse: () => ReportReason.other,
      ),
      description: json['description'] as String?,
      status: ReportStatus.fromApi(json['status'] as String? ?? 'pending'),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
