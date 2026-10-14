import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/support_models.dart';
import '../../services/api_client.dart';
import '../../services/support_service.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _messageController;

  List<SupportIssueType> _issueTypes = [];
  SupportIssueType? _selectedIssueType;
  bool _isLoadingTypes = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _fetchIssueTypes();
  }

  Future<void> _fetchIssueTypes() async {
    try {
      final types = await SupportService.getIssueTypes();
      if (mounted) {
        setState(() {
          _issueTypes = types;
          _isLoadingTypes = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingTypes = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_selectedIssueType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select an issue type',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please describe your issue in detail',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (message.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please describe your issue in more detail (at least 10 characters)',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await SupportService.createTicket(
        issueTypeId: _selectedIssueType!.id,
        message: message,
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // Show confirmation dialog with ticket number
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ticket Created',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ticket Number:',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        result.ticket.ticketNo.isNotEmpty
                            ? result.ticket.ticketNo
                            : '#${result.ticket.id}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  result.message.isNotEmpty
                      ? result.message
                      : 'Your message has been sent. Our support team will get back to you shortly.',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    height: 1.45,
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        final errorText = e is ApiException ? e.displayMessage : '$e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorText,
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Contact Support',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Issue Type
                      _buildFieldLabel('Issue Type'),
                      const SizedBox(height: 8),
                      _buildSubjectDropdown(),
                      const SizedBox(height: 24),

                      // Message
                      _buildFieldLabel('Message'),
                      const SizedBox(height: 8),
                      _buildMessageTextArea(),
                      const SizedBox(height: 6),
                      Text(
                        'Minimum 10 characters required',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),

            // Sticky Send Message Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Submit Ticket',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF334155),
      ),
    );
  }

  Widget _buildSubjectDropdown() {
    if (_isLoadingTypes) {
      return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading issue types...',
              style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8)),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SupportIssueType>(
          value: _selectedIssueType,
          hint: Text(
            'Select issue type...',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF94A3B8),
            ),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF0F172A),
          ),
          items: _issueTypes.map((SupportIssueType type) {
            return DropdownMenuItem<SupportIssueType>(
              value: type,
              child: Text(type.name),
            );
          }).toList(),
          onChanged: (SupportIssueType? newValue) {
            setState(() {
              _selectedIssueType = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildMessageTextArea() {
    return TextFormField(
      controller: _messageController,
      maxLines: 7,
      style: GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        hintText: 'Describe your issue in detail...',
        hintStyle: GoogleFonts.inter(
          fontSize: 13.0,
          color: const Color(0xFFB0BAC9),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
      ),
    );
  }
}
