import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../models/certification_model.dart';

class DynamicQuestionTile extends StatefulWidget {
  final CertificationQuestion question;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const DynamicQuestionTile({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  State<DynamicQuestionTile> createState() => _DynamicQuestionTileState();
}

class _DynamicQuestionTileState extends State<DynamicQuestionTile> {
  late TextEditingController _textController;
  late TextEditingController _numberController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final val = widget.value;
    String textVal = '';
    String numVal = '';

    if (val != null) {
      if (val is Map) {
        textVal = (val['text'] ?? val['answer_text'] ?? '').toString();
        numVal = (val['number'] ?? val['answer_number'] ?? '').toString();
      } else if (val is num) {
        numVal = val.toString();
        textVal = val.toString();
      } else if (val is bool) {
        textVal = val ? 'Yes' : 'No';
      } else {
        textVal = val.toString();
        if (num.tryParse(textVal) != null) {
          numVal = textVal;
        }
      }
    }

    _textController = TextEditingController(text: textVal);
    _numberController = TextEditingController(text: numVal);
  }

  @override
  void didUpdateWidget(covariant DynamicQuestionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final val = widget.value;
      if (val != null && widget.question.formatType == AnswerFormatType.textNarrative) {
        final s = val is Map ? (val['text'] ?? val['answer_text'] ?? '').toString() : val.toString();
        if (s != _textController.text) {
          _textController.text = s;
        }
      } else if (val != null &&
          (widget.question.formatType == AnswerFormatType.numeric ||
              widget.question.formatType == AnswerFormatType.percentage)) {
        final n = val is Map ? (val['number'] ?? val['answer_number'] ?? '').toString() : val.toString();
        if (n != _numberController.text) {
          _numberController.text = n;
        }
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Question Text + Required Badge + Format Tag
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.question.text,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildFormatBadge(widget.question.formatType),
            ],
          ),
          const SizedBox(height: 14),

          // Render appropriate input based on format type
          _buildInputControl(widget.question.formatType),
        ],
      ),
    );
  }

  Widget _buildFormatBadge(AnswerFormatType type) {
    String label;
    Color bg;
    Color text;

    switch (type) {
      case AnswerFormatType.yesNo:
        label = 'Yes / No';
        bg = const Color(0xFFEFF6FF);
        text = const Color(0xFF1D4ED8);
        break;
      case AnswerFormatType.percentage:
        label = '0–100%';
        bg = const Color(0xFFF0FDF4);
        text = const Color(0xFF15803D);
        break;
      case AnswerFormatType.numeric:
        label = 'Number';
        bg = const Color(0xFFFAF5FF);
        text = const Color(0xFF7E22CE);
        break;
      case AnswerFormatType.singleChoice:
        label = 'Choice';
        bg = const Color(0xFFFFF7ED);
        text = const Color(0xFFC2410C);
        break;
      case AnswerFormatType.textNarrative:
        label = 'Narrative';
        bg = const Color(0xFFF8FAFC);
        text = const Color(0xFF475569);
        break;
      case AnswerFormatType.checkbox:
        final isMulti = widget.question.id == 12 ||
            widget.question.text.toLowerCase().contains('two activities') ||
            widget.question.optionItems.length > 1 ||
            widget.question.options.length > 1;
        label = isMulti ? 'Checkbox (Select 2+)' : 'Checkbox';
        bg = isMulti ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4);
        text = isMulti ? const Color(0xFF1D4ED8) : const Color(0xFF16A34A);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: text.withAlpha(40)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }

  Widget _buildInputControl(AnswerFormatType type) {
    switch (type) {
      case AnswerFormatType.yesNo:
        return _buildYesNo();
      case AnswerFormatType.percentage:
        return _buildPercentage();
      case AnswerFormatType.numeric:
        return _buildNumeric();
      case AnswerFormatType.singleChoice:
        return _buildSingleChoice();
      case AnswerFormatType.textNarrative:
        return _buildTextNarrative();
      case AnswerFormatType.checkbox:
        return _buildCheckbox();
    }
  }

  // 1. Yes / No (Boolean)
  Widget _buildYesNo() {
    bool? current;
    if (widget.value is bool) {
      current = widget.value as bool;
    } else if (widget.value != null) {
      final s = widget.value.toString().toLowerCase();
      if (s == 'true' || s == 'yes' || s == '1') current = true;
      if (s == 'false' || s == 'no' || s == '0') current = false;
    }

    return Row(
      children: [
        Expanded(
          child: _buildChoiceButton(
            title: 'Yes',
            isSelected: current == true,
            activeColor: const Color(0xFF16A34A),
            activeBg: const Color(0xFFF0FDF4),
            icon: Icons.check_rounded,
            onTap: () => widget.onChanged(true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildChoiceButton(
            title: 'No',
            isSelected: current == false,
            activeColor: const Color(0xFFDC2626),
            activeBg: const Color(0xFFFEF2F2),
            icon: Icons.close_rounded,
            onTap: () => widget.onChanged(false),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceButton({
    required String title,
    required bool isSelected,
    required Color activeColor,
    required Color activeBg,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
            width: isSelected ? 1.6 : 1.1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected) ...[
              Icon(icon, size: 16, color: activeColor),
              const SizedBox(width: 6),
            ],
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Percentage (0 - 100%)
  Widget _buildPercentage() {
    double currentVal = 0;
    if (widget.value is num) {
      currentVal = (widget.value as num).toDouble();
    } else if (widget.value != null) {
      currentVal = double.tryParse(widget.value.toString()) ?? 0;
    }
    currentVal = currentVal.clamp(0.0, 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primaryBlue,
                  inactiveTrackColor: const Color(0xFFE2E8F0),
                  thumbColor: AppColors.primaryBlue,
                  overlayColor: AppColors.primaryBlue.withAlpha(30),
                  trackHeight: 5,
                ),
                child: Slider(
                  value: currentVal,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: '${currentVal.round()}%',
                  onChanged: (v) {
                    final rounded = v.round();
                    _numberController.text = rounded.toString();
                    widget.onChanged(rounded);
                  },
                ),
              ),
            ),
            Container(
              width: 72,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Text(
                '${currentVal.round()}%',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Quick presets: 25%, 50%, 75%, 100%
        Wrap(
          spacing: 8,
          children: [0, 25, 50, 75, 100].map((preset) {
            final isSel = currentVal.round() == preset;
            return ChoiceChip(
              label: Text('$preset%'),
              selected: isSel,
              selectedColor: const Color(0xFFEFF6FF),
              backgroundColor: const Color(0xFFF8FAFC),
              labelStyle: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                color: isSel ? AppColors.primaryBlue : const Color(0xFF64748B),
              ),
              side: BorderSide(
                color: isSel ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
              ),
              onSelected: (_) {
                _numberController.text = preset.toString();
                widget.onChanged(preset);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // 3. Numeric Value
  Widget _buildNumeric() {
    num currentVal = 0;
    if (widget.value is num) {
      currentVal = widget.value as num;
    } else if (widget.value != null) {
      currentVal = num.tryParse(widget.value.toString()) ?? 0;
    }

    return Row(
      children: [
        IconButton.outlined(
          icon: const Icon(Icons.remove, size: 18),
          style: IconButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            final n = currentVal > 0 ? currentVal - 1 : 0;
            _numberController.text = n.toString();
            widget.onChanged(n);
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: _numberController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: widget.question.placeholder ?? '0',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
            onChanged: (text) {
              final n = num.tryParse(text) ?? 0;
              widget.onChanged(n);
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton.outlined(
          icon: const Icon(Icons.add, size: 18),
          style: IconButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            final n = currentVal + 1;
            _numberController.text = n.toString();
            widget.onChanged(n);
          },
        ),
      ],
    );
  }

  // 4. Single Choice (Dropdown or Radio Chips)
  Widget _buildSingleChoice() {
    final options = widget.question.optionItems.isNotEmpty
        ? widget.question.optionItems
        : widget.question.options.map((s) => CertificationQuestionOption(id: s, label: s)).toList();

    if (options.isEmpty) {
      return Text(
        'No choice options configured for this question.',
        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
      );
    }

    // Determine current selected option id / value
    dynamic currentId;
    if (widget.value is Map) {
      currentId = widget.value['option_id'] ?? widget.value['id'] ?? widget.value['value'];
    } else {
      currentId = widget.value;
    }

    // If options <= 4, render elegant radio chips
    if (options.length <= 4) {
      return Column(
        children: options.map((opt) {
          final isSelected = currentId != null &&
              (currentId.toString() == opt.id.toString() ||
                  currentId.toString() == opt.label.toString());

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                widget.onChanged({
                  'option_id': opt.id,
                  'id': opt.id,
                  'label': opt.label,
                  'text': opt.label,
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.6 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      size: 18,
                      color: isSelected ? AppColors.primaryBlue : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        opt.label,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    // For > 4 options, render a clean Dropdown
    CertificationQuestionOption? selectedOpt;
    for (final opt in options) {
      if (currentId != null &&
          (currentId.toString() == opt.id.toString() ||
              currentId.toString() == opt.label.toString())) {
        selectedOpt = opt;
        break;
      }
    }

    return DropdownButtonFormField<CertificationQuestionOption>(
      initialValue: selectedOpt,
      hint: Text(
        'Select an option',
        style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF94A3B8)),
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      items: options.map((opt) {
        return DropdownMenuItem<CertificationQuestionOption>(
          value: opt,
          child: Text(
            opt.label,
            style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textPrimary),
          ),
        );
      }).toList(),
      onChanged: (opt) {
        if (opt != null) {
          widget.onChanged({
            'option_id': opt.id,
            'id': opt.id,
            'label': opt.label,
            'text': opt.label,
          });
        }
      },
    );
  }

  // 5. Text / Narrative
  Widget _buildTextNarrative() {
    return TextFormField(
      controller: _textController,
      minLines: 3,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: widget.question.placeholder ?? 'Enter your detailed explanation or answer here...',
        hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
      ),
      style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textPrimary),
      onChanged: (text) {
        widget.onChanged(text);
      },
    );
  }

  // 6. Checkbox (Single confirmation or Multi-choice options)
  Widget _buildCheckbox() {
    final options = widget.question.optionItems.isNotEmpty
        ? widget.question.optionItems
        : widget.question.options.map((s) => CertificationQuestionOption(id: s, label: s)).toList();

    // If options are configured, support multi-select checkbox list
    if (options.isNotEmpty) {
      List<String> selectedKeys = [];
      if (widget.value is List) {
        selectedKeys = (widget.value as List).map((e) {
          if (e is Map) return (e['id'] ?? e['value'] ?? e['label'] ?? '').toString();
          return e.toString();
        }).toList();
      } else if (widget.value != null && widget.value.toString().isNotEmpty) {
        selectedKeys = widget.value.toString().split(',').map((s) => s.trim()).toList();
      }

      final requiresMoreThanOne = widget.question.id == 12 ||
          widget.question.text.toLowerCase().contains('two activities') ||
          options.length > 1;
      final selectedCount = selectedKeys.length;
      final hasEnough = selectedCount >= 2;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...options.map((opt) {
            final optIdStr = opt.id.toString();
            final optLabel = opt.label;
            final isChecked = selectedKeys.contains(optIdStr) || selectedKeys.contains(optLabel);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isChecked ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isChecked ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
                  width: 1.1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    final updated = List<String>.from(selectedKeys);
                    if (isChecked) {
                      updated.remove(optIdStr);
                      updated.remove(optLabel);
                    } else {
                      updated.add(optIdStr);
                    }
                    widget.onChanged(updated);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: isChecked,
                            activeColor: const Color(0xFF16A34A),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) {
                              final updated = List<String>.from(selectedKeys);
                              if (val == true) {
                                if (!updated.contains(optIdStr)) updated.add(optIdStr);
                              } else {
                                updated.remove(optIdStr);
                                updated.remove(optLabel);
                              }
                              widget.onChanged(updated);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            opt.label,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: isChecked ? FontWeight.w600 : FontWeight.w500,
                              color: isChecked ? const Color(0xFF0F172A) : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          if (requiresMoreThanOne) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: hasEnough ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasEnough ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    hasEnough ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                    size: 15,
                    color: hasEnough ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasEnough
                          ? '$selectedCount options selected (Requirement met)'
                          : 'Please select more than one option (at least 2 required)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: hasEnough ? const Color(0xFF15803D) : const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    }

    // Single Checkbox (Boolean / Acknowledgment)
    bool isChecked = false;
    if (widget.value is bool) {
      isChecked = widget.value as bool;
    } else if (widget.value != null) {
      final s = widget.value.toString().toLowerCase().trim();
      isChecked = s == 'true' || s == '1' || s == 'yes' || s == 'checked';
    }

    return Container(
      decoration: BoxDecoration(
        color: isChecked ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isChecked ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
          width: 1.1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            widget.onChanged(!isChecked);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: isChecked,
                    activeColor: const Color(0xFF16A34A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) {
                      widget.onChanged(val ?? false);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isChecked ? 'Confirmed / Yes' : 'Select to confirm',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isChecked ? FontWeight.w600 : FontWeight.w500,
                      color: isChecked ? const Color(0xFF16A34A) : const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
