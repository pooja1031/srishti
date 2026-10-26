import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/ui_utils.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Map<String, dynamic>> _inquiries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInquiries();
  }

  Future<void> _fetchInquiries() async {
    try {
      final data = await Supabase.instance.client
          .from('inquiries')
          .select()
          .order('created_at', ascending: false);
          
      if (mounted) {
        setState(() {
          _inquiries = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, 'Failed to fetch inquiries: $e', isError: true);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateStatus(int id, String newStatus) async {
    try {
      await Supabase.instance.client
          .from('inquiries')
          .update({'status': newStatus})
          .eq('id', id);
          
      _fetchInquiries();
      if (mounted) {
        showCustomSnackBar(context, 'Status updated to $newStatus');
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, 'Failed to update status', isError: true);
      }
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    // Remove non-numeric characters for the link
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final url = 'https://wa.me/$cleanPhone';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        showCustomSnackBar(context, 'Could not launch WhatsApp for $phone', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.secondary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.secondary),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchInquiries();
            },
            tooltip: 'Refresh Inquiries',
          ),
          const SizedBox(width: 16),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 800;
          return Center(
            child: SafeArea(
              child: Container(
                width: isSmallScreen ? double.infinity : 1000,
                margin: EdgeInsets.all(isSmallScreen ? 20 : 40),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 24 : 40,
                  vertical: isSmallScreen ? 32 : 40,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Admin Dashboard',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Georgia',
                            letterSpacing: 2,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your consultation inquiries below',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: _isLoading 
                        ? const Center(child: CircularProgressIndicator())
                        : _inquiries.isEmpty
                            ? const Center(child: Text('No inquiries yet.', style: TextStyle(color: Colors.black54, fontSize: 16)))
                            : ListView.builder(
                                itemCount: _inquiries.length,
                                itemBuilder: (context, index) {
                                  final inquiry = _inquiries[index];
                                  return _buildInquiryCard(inquiry);
                                },
                              ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInquiryCard(Map<String, dynamic> inquiry) {
    final status = inquiry['status'] ?? 'Pending';
    Color statusColor = Colors.orange;
    if (status == 'Contacted') statusColor = Colors.blue;
    if (status == 'Booked') statusColor = Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  inquiry['name'] ?? 'Unknown Name',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'Georgia'),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: statusColor.withOpacity(0.5)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              _buildInfoItem(Icons.phone_outlined, 'Phone', inquiry['phone'] ?? 'N/A'),
              _buildInfoItem(Icons.calendar_today_outlined, 'Event Date', inquiry['event_date'] ?? 'N/A'),
              _buildInfoItem(Icons.brush_outlined, 'Service', inquiry['service_type'] ?? 'N/A'),
            ],
          ),
          if (inquiry['notes'] != null && inquiry['notes'].toString().isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Text('Notes', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Text(inquiry['notes'], style: const TextStyle(fontSize: 15, height: 1.5)),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _launchWhatsApp(inquiry['phone'] ?? ''),
                icon: const Icon(Icons.chat_outlined),
                label: const Text('WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withOpacity(0.1)),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: status,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: ['Pending', 'Contacted', 'Booked'].map((s) {
                      return DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontWeight: FontWeight.w500)));
                    }).toList(),
                    onChanged: (newVal) {
                      if (newVal != null && newVal != status) {
                        _updateStatus(inquiry['id'], newVal);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}
