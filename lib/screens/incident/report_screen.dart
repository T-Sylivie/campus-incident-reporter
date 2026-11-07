import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/loading_button.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();

  String? _category;
  String? _location;
  String _urgency = Urgency.medium;
  bool _anonymous = false;
  bool _categoryError = false;
  File? _photo;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      // Compress on the phone before uploading.
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1280,
      );
      if (picked != null) setState(() => _photo = File(picked.path));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the camera or gallery.')),
      );
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState!.validate();
    setState(() => _categoryError = _category == null);
    if (!formOk || _category == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = context.read<IncidentProvider>();

    final ok = await provider.submit(
      title: _title.text,
      description: _description.text,
      category: _category!,
      location: _location!,
      urgency: _urgency,
      isAnonymous: _anonymous,
      image: _photo,
    );

    if (!mounted) return;
    if (ok) {
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Report submitted. Thank you!')),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Could not submit.')),
      );
    }
  }

  Widget _categoryTile(IncidentCategory c) {
    final selected = _category == c.name;
    return GestureDetector(
      onTap: () => setState(() {
        _category = c.name;
        _categoryError = false;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected ? AppColors.brown : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.brown : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(c.icon,
                size: 28,
                color: selected ? AppColors.amber : AppColors.brown),
            const SizedBox(height: 6),
            Text(
              c.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.card : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoPicker() {
    if (_photo == null) {
      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _showPhotoOptions,
        child: Container(
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD9B98F)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_a_photo_outlined, color: AppColors.muted),
              SizedBox(width: 10),
              Text('Add a photo (optional)',
                  style: TextStyle(color: AppColors.muted)),
            ],
          ),
        ),
      );
    }
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            _photo!,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            backgroundColor: AppColors.card,
            child: IconButton(
              tooltip: 'Remove photo',
              icon: const Icon(Icons.close, color: AppColors.brown),
              onPressed: () => setState(() => _photo = null),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<IncidentProvider>().busy;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Report an incident')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tell us what happened', style: text.titleLarge),
                const SizedBox(height: 16),
                Text('Category', style: text.titleSmall),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.15,
                  children: incidentCategories.map(_categoryTile).toList(),
                ),
                if (_categoryError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Choose a category',
                      style:
                          TextStyle(color: Colors.red.shade800, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Briefly describe the issue',
                  ),
                  validator: (v) => (v == null || v.trim().length < 5)
                      ? 'Enter at least 5 characters'
                      : null,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                  items: campusLocations
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (v) => setState(() => _location = v),
                  validator: (v) => v == null ? 'Choose a location' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _description,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 4,
                  maxLines: 6,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What happened, when, and who is affected?',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'Enter at least 10 characters'
                      : null,
                ),
                const SizedBox(height: 8),
                Text('Urgency', style: text.titleSmall),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    segments: Urgency.all
                        .map((u) => ButtonSegment(value: u, label: Text(u)))
                        .toList(),
                    selected: {_urgency},
                    onSelectionChanged: (s) =>
                        setState(() => _urgency = s.first),
                  ),
                ),
                const SizedBox(height: 16),
                _photoPicker(),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Report anonymously'),
                  subtitle: const Text(
                    'Other students will not see your name. '
                    'Campus staff can still trace misuse.',
                  ),
                  value: _anonymous,
                  onChanged: (v) => setState(() => _anonymous = v),
                ),
                const SizedBox(height: 16),
                LoadingButton(
                  label: 'Submit report',
                  loading: busy,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}