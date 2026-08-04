import 'package:flutter/material.dart';
import 'package:foodtruck_app/domain/app_feedback.dart';
import 'package:foodtruck_app/domain/user_report.dart';
import 'package:foodtruck_app/services/report_service.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:provider/provider.dart';

/// Screen listing the current user's submitted reports and feedback,
/// each with its moderation/status badge.
class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = context.read<ReportService>();
      service.loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FoodtrackColors.cremeVintage,
      appBar: AppBar(
        title: const Text('Mes signalements & retours'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: FoodtrackColors.noirBrule,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'Signalements',
                      isSelected: _tabIndex == 0,
                      onTap: () => setState(() => _tabIndex = 0),
                    ),
                  ),
                  Expanded(
                    child: _TabButton(
                      label: 'Retours',
                      isSelected: _tabIndex == 1,
                      onTap: () => setState(() => _tabIndex = 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<ReportService>(
              builder: (context, service, child) {
                if (service.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: FoodtrackColors.rougeKetchup,
                    ),
                  );
                }

                if (_tabIndex == 0) {
                  return _buildReportList(service.myReports);
                }
                return _buildFeedbackList(service.myFeedback);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportList(List<UserReport> reports) {
    if (reports.isEmpty) {
      return _EmptyState(
        icon: Icons.verified_user_outlined,
        title: 'Aucun signalement',
        message:
            'Les signalements que tu envoies apparaitront ici '
            'avec leur statut de moderation.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ReportService>().loadMyReports(),
      color: FoodtrackColors.rougeKetchup,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ReportCard(report: report),
          );
        },
      ),
    );
  }

  Widget _buildFeedbackList(List<AppFeedback> feedbackList) {
    if (feedbackList.isEmpty) {
      return _EmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'Aucun retour',
        message:
            'Tes retours (bugs et suggestions) apparaitront ici '
            'avec leur statut.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ReportService>().loadMyFeedback(),
      color: FoodtrackColors.rougeKetchup,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        itemCount: feedbackList.length,
        itemBuilder: (context, index) {
          final feedback = feedbackList[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FeedbackCard(feedback: feedback),
          );
        },
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? FoodtrackColors.jauneMoutarde : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: FoodtrackColors.noirBrule,
            width: isSelected ? 2 : 0,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? FoodtrackColors.noirBrule
                : FoodtrackColors.noirBrule.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final UserReport report;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FoodtrackColors.noirBrule, width: 2),
        boxShadow: const [
          BoxShadow(
            color: FoodtrackColors.noirBrule,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                report.reason.icon,
                size: 22,
                color: FoodtrackColors.rougeKetchup,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  report.reason.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: FoodtrackColors.noirBrule,
                  ),
                ),
              ),
              _StatusBadge(status: report.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Utilisateur signale : ${report.reportedUserEmail}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: FoodtrackColors.noirBrule.withOpacity(0.7),
            ),
          ),
          if (report.description != null &&
              report.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              report.description!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: FoodtrackColors.noirBrule.withOpacity(0.8),
                height: 1.3,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            _formatDate(report.createdAt),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: FoodtrackColors.noirBrule.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.feedback});

  final AppFeedback feedback;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FoodtrackColors.noirBrule, width: 2),
        boxShadow: const [
          BoxShadow(
            color: FoodtrackColors.noirBrule,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: feedback.type == FeedbackType.bug
                      ? FoodtrackColors.rougeKetchup
                      : FoodtrackColors.vertPickle,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: FoodtrackColors.noirBrule,
                    width: 2,
                  ),
                ),
                child: Text(
                  feedback.type.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: FoodtrackColors.cremeVintage,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: FoodtrackColors.jauneMoutarde.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: FoodtrackColors.noirBrule,
                    width: 1,
                  ),
                ),
                child: Text(
                  feedback.category.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: FoodtrackColors.noirBrule,
                  ),
                ),
              ),
              const Spacer(),
              _StatusBadge(status: feedback.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            feedback.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: FoodtrackColors.noirBrule,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            feedback.description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: FoodtrackColors.noirBrule.withOpacity(0.8),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(feedback.createdAt),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: FoodtrackColors.noirBrule.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// A colored badge showing the current moderation/status.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final dynamic status;

  Color get _color {
    final label = status.label;
    if (label.contains('Resolu') || label.contains('Nouveau')) {
      return FoodtrackColors.vertPickle;
    }
    if (label.contains('En cours') || label.contains('Ecarte')) {
      return FoodtrackColors.jauneMoutarde;
    }
    return FoodtrackColors.rougeKetchup;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: FoodtrackColors.noirBrule, width: 1),
      ),
      child: Text(
        status.label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: FoodtrackColors.noirBrule,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: FoodtrackColors.noirBrule),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: FoodtrackColors.noirBrule,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: FoodtrackColors.noirBrule.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year;
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month/$year a $hour:$minute';
}

