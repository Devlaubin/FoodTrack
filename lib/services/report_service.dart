import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:foodtruck_app/domain/app_feedback.dart';
import 'package:foodtruck_app/domain/user_report.dart';

/// Handles user reports (moderation) and app feedback
/// (bug reports / feature suggestions) backed by Supabase.
class ReportService extends ChangeNotifier {
  ReportService(this._supabase);

  final SupabaseClient _supabase;

  List<UserReport> _myReports = [];
  List<AppFeedback> _myFeedback = [];
  bool _isLoading = false;
  String? _error;

  List<UserReport> get myReports => List.unmodifiable(_myReports);
  List<AppFeedback> get myFeedback => List.unmodifiable(_myFeedback);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Submits a report against another user.
  Future<bool> submitUserReport({
    required String reporterId,
    String? reportedUserId,
    required String reportedUserEmail,
    required ReportReason reason,
    String? description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase.from('user_reports').insert({
        'reporter_id': reporterId,
        'reported_user_id': reportedUserId,
        'reported_user_email': reportedUserEmail,
        'reason': reason.apiValue,
        'description': description,
      });

      await loadMyReports();
      return true;
    } catch (e) {
      debugPrint('Error submitting user report: $e');
      _error = 'Impossible d\'envoyer ton signalement. Reessaie.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submits a bug report or a feature suggestion.
  Future<bool> submitFeedback({
    required String userId,
    required FeedbackType type,
    required FeedbackCategory category,
    required String title,
    required String description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase.from('feedback').insert({
        'user_id': userId,
        'type': type.apiValue,
        'category': category.apiValue,
        'title': title,
        'description': description,
      });

      await loadMyFeedback();
      return true;
    } catch (e) {
      debugPrint('Error submitting feedback: $e');
      _error = 'Impossible d\'envoyer ton retour. Reessaie.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads the current user's submitted reports.
  Future<void> loadMyReports() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('user_reports')
          .select()
          .eq('reporter_id', user.id)
          .order('created_at', ascending: false);

      _myReports = response
          .map<UserReport>((json) => UserReport.fromJson(json))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading my reports: $e');
      _error = 'Impossible de charger tes signalements';
      notifyListeners();
    }
  }

  /// Loads the current user's submitted feedback.
  Future<void> loadMyFeedback() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('feedback')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      _myFeedback = response
          .map<AppFeedback>((json) => AppFeedback.fromJson(json))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading my feedback: $e');
      _error = 'Impossible de charger tes retours';
      notifyListeners();
    }
  }

  /// Loads both reports and feedback for the current user.
  Future<void> loadAll() async {
    await Future.wait([loadMyReports(), loadMyFeedback()]);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clears cached data (called on sign-out).
  void clear() {
    _myReports = [];
    _myFeedback = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}

