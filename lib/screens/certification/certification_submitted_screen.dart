import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/certification_model.dart';
import '../home_screen.dart';

class CertificationSubmittedScreen extends StatelessWidget {
  final CertificationApplicationModel application;
  final Map<String, dynamic>? submissionResponse;

  const CertificationSubmittedScreen({
    super.key,
    required this.application,
    this.submissionResponse,
  });

  CertificationScoreSummary? _resolveScoreSummary() {
    if (application.scoreSummary != null) return application.scoreSummary;
    final rawData = submissionResponse?['data'] ?? submissionResponse;
    if (rawData is Map && rawData['scores'] is Map) {
      return CertificationScoreSummary.fromJson(
        Map<String, dynamic>.from(rawData['scores'] as Map),
      );
    }
    return null;
  }

  List<CertificationSectionScoreItem> _resolveSectionScores() {
    if (application.sectionScores.isNotEmpty) return application.sectionScores;
    final rawData = submissionResponse?['data'] ?? submissionResponse;
    if (rawData is Map && rawData['section_scores'] is List) {
      return (rawData['section_scores'] as List)
          .whereType<Map>()
          .map((e) => CertificationSectionScoreItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  List<CertificationSubmittedAnswerItem> _resolveAnswers() {
    if (application.submittedAnswers.isNotEmpty) {
      return application.submittedAnswers;
    }

    final rawData = submissionResponse?['data'] ?? submissionResponse;
    if (rawData is Map && rawData['answers'] is List) {
      return (rawData['answers'] as List)
          .whereType<Map>()
          .map((e) => CertificationSubmittedAnswerItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    // Fallback: reconstruct from application.questionAnswers and categoryConfig
    final answers = <CertificationSubmittedAnswerItem>[];
    if (application.categoryConfig != null) {
      for (final sec in application.categoryConfig!.sections) {
        for (final q in sec.questions) {
          final userAns = application.questionAnswers[q.id];
          if (userAns != null) {
            String formatted = '';
            if (userAns is bool) {
              formatted = userAns ? 'Yes' : 'No';
            } else if (userAns is num) {
              formatted = q.answerType.toLowerCase() == 'percentage' ? '$userAns%' : '$userAns';
            } else if (userAns is List) {
              formatted = userAns.join(', ');
            } else {
              formatted = userAns.toString();
            }

            if (q.optionItems.isNotEmpty) {
              final opt = q.optionItems.firstWhere(
                (o) => o.id.toString() == userAns.toString() || o.label == userAns.toString(),
                orElse: () => const CertificationQuestionOption(id: '', label: ''),
              );
              if (opt.label.isNotEmpty) {
                formatted = opt.label;
              }
            }

            answers.add(
              CertificationSubmittedAnswerItem(
                questionId: q.id,
                questionText: q.text,
                sectionId: sec.id,
                sectionName: sec.name,
                sectionCode: sec.code,
                answerType: q.answerType,
                rawAnswer: userAns,
                formattedAnswer: formatted.isNotEmpty ? formatted : '—',
                score: 0,
                maxScore: 0,
              ),
            );
          }
        }
      }
    }
    return answers;
  }

  @override
  Widget build(BuildContext context) {
    final now = application.submissionDate ?? DateTime.now();
    final dateStr = '${now.month}/${now.day}/${now.year}';
    final appId = (application.applicationNo != null && application.applicationNo!.trim().isNotEmpty)
        ? application.applicationNo!.trim()
        : ((application.applicationId != null && application.applicationId!.trim().isNotEmpty)
            ? application.applicationId!.trim()
            : '—');
    final institution = application.institutionName.trim().isNotEmpty
        ? application.institutionName.trim()
        : '—';
    final rev = application.reviewStatus.trim().toLowerCase();
    final appStatus = application.status.trim().toLowerCase();
    final dispStatus = application.displayStatus.trim().toLowerCase();
    final isRejected = appStatus.contains('reject') ||
        dispStatus.contains('reject') ||
        rev.contains('reject');

    final String status;
    if (isRejected) {
      status = 'Rejected';
    } else if (rev == 'manual_review' ||
        rev == 'manual review' ||
        rev == 'under_review' ||
        rev == 'in_review' ||
        rev == 'in review' ||
        rev == 'ai_audit' ||
        rev == 'submitted') {
      status = 'Manual Review';
    } else if (application.displayStatus.trim().isNotEmpty &&
        dispStatus != 'submitted') {
      status = application.displayStatus.trim();
    } else if (appStatus == 'submitted') {
      status = 'Manual Review';
    } else {
      status = application.status.trim().isNotEmpty ? application.status.trim() : 'Manual Review';
    }

    final scores = _resolveScoreSummary();
    final sectionScores = _resolveSectionScores();
    final answers = _resolveAnswers();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Submission Details',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Status Hero Card
              _buildTopStatusCard(isRejected: isRejected),
              const SizedBox(height: 16),

              // Overall Score Summary (if present)
              if (scores != null) ...[
                _buildScoresSummaryCard(scores),
                const SizedBox(height: 16),
              ],

              // Section Scores Breakdown (if present)
              if (sectionScores.isNotEmpty) ...[
                _buildSectionScoresCard(sectionScores),
                const SizedBox(height: 16),
              ],

              // Questions & Answers with Scores (The main feature requested)
              if (answers.isNotEmpty) ...[
                _buildQuestionsAndAnswersSection(answers),
                const SizedBox(height: 16),
              ],

              // Application Metadata Card
              _buildDetailsCard(
                appId: appId,
                dateStr: dateStr,
                institution: institution,
                status: status,
                isRejected: isRejected,
              ),
              const SizedBox(height: 16),

              // AI Validation Notice Box
              _buildNoticeBox(isRejected: isRejected),
              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Top Status Hero
  Widget _buildTopStatusCard({required bool isRejected}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isRejected ? const Color(0xFFFEE2E2) : const Color(0xFFE2F8E9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isRejected ? const Color(0xFFDC2626) : const Color(0xFF00AA13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isRejected ? Icons.close_rounded : Icons.check_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isRejected ? 'Application Rejected' : 'Application Submitted!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              isRejected
                  ? 'AI validation rejected your application because required supporting evidence was not submitted.'
                  : 'Your certification application has been evaluated and successfully submitted.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF64748B),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Overall Score Summary Card
  Widget _buildScoresSummaryCard(CertificationScoreSummary scores) {
    final bool passed = scores.passed;
    final percentVal = (scores.percent > 0)
        ? scores.percent
        : (scores.max > 0 ? (scores.total / scores.max * 100) : 0.0);
    final percentStr = percentVal.toStringAsFixed(1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: passed ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
          width: passed ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: passed
                ? const Color(0xFF10B981).withAlpha(12)
                : Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.analytics_outlined,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Evaluation Score',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: passed ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      passed ? Icons.check_circle : Icons.info_outline,
                      size: 13,
                      color: passed ? const Color(0xFF15803D) : const Color(0xFFB45309),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      passed ? 'Passed' : 'Needs Review',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: passed ? const Color(0xFF15803D) : const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${scores.total}',
                style: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: passed ? const Color(0xFF0F172A) : const Color(0xFFD97706),
                ),
              ),
              Text(
                ' / ${scores.max} pts',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$percentStr%',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: scores.max > 0 ? (scores.total / scores.max).clamp(0.0, 1.0) : 0.0,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                passed ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
              ),
            ),
          ),
          if (scores.passScore != null) ...[
            const SizedBox(height: 10),
            Text(
              'Minimum passing score required: ${scores.passScore} pts',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 3. Section Scores Card
  Widget _buildSectionScoresCard(List<CertificationSectionScoreItem> sectionScores) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.assessment_outlined,
                  color: Color(0xFF16A34A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Section Scores',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...sectionScores.map((sec) {
            final double ratio = sec.maxScore > 0 ? (sec.score / sec.maxScore).clamp(0.0, 1.0) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          sec.name,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${sec.score} / ${sec.maxScore} pts',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ratio >= 0.8 ? const Color(0xFF10B981) : const Color(0xFF0284C7),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 4. Questions & Answers Section with Score Badges
  Widget _buildQuestionsAndAnswersSection(List<CertificationSubmittedAnswerItem> answers) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.question_answer_outlined,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submitted Responses',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Questions answered and points awarded',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${answers.length} Qs',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...answers.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final item = entry.value;
            final bool isScored = item.maxScore > 0;
            final bool isFullScore = isScored && item.score >= item.maxScore;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Section tag + Score Chip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withAlpha(25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Q$index',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                          if (item.sectionCode != null && item.sectionCode!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.sectionCode!,
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Score pill
                      if (isScored)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: isFullScore
                                ? const Color(0xFFDCFCE7)
                                : (item.score > 0 ? const Color(0xFFFEF3C7) : const Color(0xFFFEE2E2)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isFullScore ? Icons.check_circle : Icons.stars,
                                size: 12,
                                color: isFullScore
                                    ? const Color(0xFF16A34A)
                                    : (item.score > 0 ? const Color(0xFFD97706) : const Color(0xFFDC2626)),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${item.score} / ${item.maxScore} pts',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isFullScore
                                      ? const Color(0xFF15803D)
                                      : (item.score > 0 ? const Color(0xFFB45309) : const Color(0xFFB91C1C)),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Descriptive',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Question text
                  Text(
                    item.questionText,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // User's Submitted Answer box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 13,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Submitted Answer:',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.formattedAnswer,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 5. Details Card
  Widget _buildDetailsCard({
    required String appId,
    required String dateStr,
    required String institution,
    required String status,
    required bool isRejected,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildRow('Application ID', appId, isBoldValue: true),
          const SizedBox(height: 14),
          _buildRow('Submission Date', dateStr),
          const SizedBox(height: 14),
          _buildRow('Institution', institution, isBoldValue: true),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Status',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: const Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: isRejected
                      ? const Color(0xFFFEE2E2)
                      : ((status == 'In Review' ||
                              status == 'under_review' ||
                              status == 'Manual Review')
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFE0F2FE)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isRejected
                        ? const Color(0xFFDC2626)
                        : ((status == 'In Review' ||
                                status == 'under_review' ||
                                status == 'Manual Review')
                            ? const Color(0xFFD97706)
                            : const Color(0xFF0284C7)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 6. AI Notice Box
  Widget _buildNoticeBox({required bool isRejected}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isRejected
            ? const Color(0xFFFEF2F2)
            : const Color(0xFFE0F2FE).withAlpha(160),
        borderRadius: BorderRadius.circular(14),
        border: isRejected ? Border.all(color: const Color(0xFFFECACA)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isRejected ? '⚠️' : '🤖', style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isRejected
                  ? 'AI validation rejected: Required supporting evidence was not uploaded. Application is marked as Rejected. Please upload required evidence in details.'
                  : 'AI validation recorded. Application has transitioned to Manual Review.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isRejected ? const Color(0xFFDC2626) : const Color(0xFF0284C7),
                fontWeight: isRejected ? FontWeight.w600 : FontWeight.w400,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 7. Action Buttons
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const HomeScreen(
                    initialTabIndex: 3,
                    initialAppTabIndex: 1,
                  ),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              'View Applications',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const HomeScreen(),
                ),
                (route) => false,
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: AppColors.primaryBlue,
                width: 1.3,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              'Back to Home',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value, {bool isBoldValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: isBoldValue ? FontWeight.w700 : FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}
