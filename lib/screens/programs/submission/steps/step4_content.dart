import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme.dart';
import '../../../../models/program_submission_model.dart';
import '../../../../widgets/custom_button.dart';

class Step4Content extends StatefulWidget {
  final ProgramSubmissionModel model;
  final VoidCallback onContinue;

  const Step4Content({
    super.key,
    required this.model,
    required this.onContinue,
  });

  @override
  State<Step4Content> createState() => _Step4ContentState();
}

class _AgendaSession {
  final TextEditingController titleController;
  String time;

  _AgendaSession({
    String? title,
    this.time = '',
  }) : titleController = TextEditingController(text: title ?? '');

  void dispose() {
    titleController.dispose();
  }
}

class _Step4ContentState extends State<Step4Content> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _programDescController;
  final List<_AgendaSession> _sessions = [];
  String? _agendaError;

  @override
  void initState() {
    super.initState();
    _programDescController =
        TextEditingController(text: widget.model.programDescription);

    if (widget.model.agendaItems.isNotEmpty) {
      for (final item in widget.model.agendaItems) {
        _sessions.add(
          _AgendaSession(
            title: item['title'] ?? '',
            time: item['start_time'] ?? '',
          ),
        );
      }
    } else if (widget.model.agenda.trim().isNotEmpty) {
      // Parse any multiline text if previously set
      final lines = widget.model.agenda.split('\n').where((l) => l.trim().isNotEmpty);
      for (final line in lines) {
        final match = RegExp(r'^(\d{1,2}:\d{2})\s*[-:]?\s*(.*)$').firstMatch(line.trim());
        if (match != null) {
          _sessions.add(
            _AgendaSession(
              time: match.group(1)!,
              title: match.group(2)!,
            ),
          );
        } else {
          _sessions.add(_AgendaSession(title: line.trim(), time: ''));
        }
      }
    }

    if (_sessions.isEmpty) {
      _sessions.add(_AgendaSession(title: '', time: ''));
    }
  }

  @override
  void dispose() {
    _programDescController.dispose();
    for (final s in _sessions) {
      s.dispose();
    }
    super.dispose();
  }

  void _addSession() {
    setState(() {
      _sessions.add(_AgendaSession(title: '', time: ''));
      _agendaError = null;
    });
  }

  void _removeSession(int index) {
    if (_sessions.length <= 1) {
      setState(() {
        _sessions[0].titleController.clear();
        _sessions[0].time = '';
      });
      return;
    }
    setState(() {
      final removed = _sessions.removeAt(index);
      removed.dispose();
    });
  }

  Future<void> _pickTime(int index) async {
    final currentStr = _sessions[index].time;
    TimeOfDay initial = const TimeOfDay(hour: 9, minute: 0);
    if (currentStr.isNotEmpty && currentStr.contains(':')) {
      final parts = currentStr.split(':');
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h != null && m != null) {
        initial = TimeOfDay(hour: h, minute: m);
      }
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _sessions[index].time = '$hour:$minute';
        _agendaError = null;
      });
    }
  }

  void _handleContinue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final validSessions = <Map<String, String>>[];
    for (var i = 0; i < _sessions.length; i++) {
      final s = _sessions[i];
      final title = s.titleController.text.trim();
      final time = s.time.trim();

      if (title.isNotEmpty || time.isNotEmpty) {
        if (time.isEmpty) {
          setState(() {
            _agendaError = 'Please pick a start time for Session #${i + 1}';
          });
          return;
        }
        if (title.isEmpty) {
          setState(() {
            _agendaError = 'Please enter a title for Session #${i + 1}';
          });
          return;
        }
        validSessions.add({
          'start_time': time,
          'title': title,
        });
      }
    }

    widget.model.programDescription = _programDescController.text.trim();
    widget.model.agendaItems = validSessions;
    widget.model.agenda = validSessions
        .map((s) => '${s['start_time']} - ${s['title']}')
        .join('\n');

    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Program Description
          _buildFieldLabel('Program Description *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _programDescController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Detailed description of the program...',
              alignLabelWithHint: true,
            ),
            validator: (val) =>
                val == null || val.trim().isEmpty ? 'Please provide detailed description' : null,
          ),
          const SizedBox(height: 22),

          // Agenda Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFieldLabel('Program Agenda Schedule'),
              InkWell(
                onTap: _addSession,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.primaryBlue),
                      const SizedBox(width: 4),
                      Text(
                        'Add Session',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Specify start times and activity titles for your program agenda.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),

          // Error box if validation failed
          if (_agendaError != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFDC2626)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _agendaError!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFFDC2626),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // List of Session Cards
          ...List.generate(_sessions.length, (index) {
            final session = _sessions[index];
            final hasTime = session.time.isNotEmpty;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 1.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(4),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SESSION #${index + 1}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (_sessions.length > 1)
                        InkWell(
                          onTap: () => _removeSession(index),
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Time Picker Container
                  InkWell(
                    onTap: () => _pickTime(index),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: hasTime ? const Color(0xFFF0F9FF) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: hasTime ? const Color(0xFFBAE6FD) : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 18,
                            color: hasTime ? AppColors.primaryBlue : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            hasTime ? 'Start Time: ${session.time}' : 'Select Start Time *',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: hasTime ? FontWeight.w700 : FontWeight.w500,
                              color: hasTime ? AppColors.primaryBlue : const Color(0xFF64748B),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF64748B)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Session Title Field
                  TextFormField(
                    controller: session.titleController,
                    onChanged: (_) {
                      if (_agendaError != null) setState(() => _agendaError = null);
                    },
                    style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Session title (e.g. Opening Keynote & Warm-up)',
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // Continue Button
          CustomButton(
            text: 'Continue',
            onPressed: _handleContinue,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
