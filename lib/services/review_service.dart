import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:foodtruck_app/domain/review.dart';

/// Handles loading and submitting reviews (ratings + comments) for foodtrucks.
class ReviewService extends ChangeNotifier {
  ReviewService(this._supabase);

  final SupabaseClient _supabase;

  List<Review> _reviews = [];
  bool _isLoading = false;
  String? _error;

  List<Review> get reviews => List.unmodifiable(_reviews);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// The current user's own review for the loaded foodtruck, if any.
  Review? get myReview {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    for (final r in _reviews) {
      if (r.userId == user.id) return r;
    }
    return null;
  }

  /// Loads all reviews for a given foodtruck, newest first.
  Future<void> loadReviews(String foodtruckId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('reviews')
          .select()
          .eq('foodtruck_id', foodtruckId)
          .order('created_at', ascending: false);

      _reviews = response.map<Review>((json) => Review.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading reviews: $e');
      _error = 'Impossible de charger les avis';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submits (or updates) the current user's review for a foodtruck.
  /// Because of the UNIQUE(foodtruck_id, user_id) constraint, we upsert.
  Future<bool> submitReview({
    required String foodtruckId,
    required int rating,
    required String comment,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _error = 'Connecte-toi pour laisser un avis';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authorName =
          user.userMetadata?['display_name']?.toString() ??
          (user.email?.split('@').first ?? 'Client');

      await _supabase.from('reviews').upsert({
        'foodtruck_id': foodtruckId,
        'user_id': user.id,
        'author_name': authorName,
        'rating': rating,
        'comment': comment.trim(),
      }, onConflict: 'foodtruck_id,user_id');

      await loadReviews(foodtruckId);
      return true;
    } catch (e) {
      debugPrint('Error submitting review: $e');
      _error = 'Impossible d\'envoyer ton avis. Reessaie.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes the current user's review for a foodtruck.
  Future<bool> deleteMyReview(String foodtruckId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase
          .from('reviews')
          .delete()
          .eq('foodtruck_id', foodtruckId)
          .eq('user_id', user.id);

      await loadReviews(foodtruckId);
      return true;
    } catch (e) {
      debugPrint('Error deleting review: $e');
      _error = 'Impossible de supprimer ton avis';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clears cached data (called on sign-out).
  void clear() {
    _reviews = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
