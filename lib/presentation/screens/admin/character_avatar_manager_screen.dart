import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/character_provider.dart';
import '../../../core/constants/app_constants.dart';

class CharacterAvatarManagerScreen extends StatefulWidget {
  const CharacterAvatarManagerScreen({super.key});

  @override
  State<CharacterAvatarManagerScreen> createState() =>
      _CharacterAvatarManagerScreenState();
}

class _CharacterAvatarManagerScreenState
    extends State<CharacterAvatarManagerScreen> {
  String _selectedClass = 'knight';
  int _selectedStage = 1;
  String? _localPhotoPath;
  bool _isProcessing = false;
  String? _message;
  bool _isSuccess = false;
  int _imageRefreshKey = 0; // Key to force image reload after upload

  final List<String> _classes = ['knight', 'mage', 'archer', 'assassin'];

  Future<void> _capturePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        _localPhotoPath = pickedFile.path;
        _message = null;
      });
    }
  }

  Future<void> _selectFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        _localPhotoPath = pickedFile.path;
        _message = null;
      });
    }
  }

  Future<void> _handleUpload() async {
    if (_localPhotoPath == null) {
      setState(() {
        _message = 'Please select or capture a photo first!';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _message = null;
    });

    try {
      final fileName = '${_selectedClass}_stage$_selectedStage.png';
      final characterProvider = Provider.of<CharacterProvider>(
        context,
        listen: false,
      );

      await characterProvider.uploadAvatarImage(_localPhotoPath!, fileName);

      setState(() {
        _isSuccess = true;
        _message =
            'Avatar for ${_selectedClass.toUpperCase()} Stage $_selectedStage uploaded successfully!';
        _localPhotoPath = null; // Clear local path
        _imageRefreshKey++; // Force refresh public URL preview image
      });
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _message =
            'Upload failed. Please check if bucket "Character-avatars" is created and public in Supabase Storage.';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final publicUrl =
        '${AppConstants.supabaseUrl}/storage/v1/object/public/Character-avatars/${_selectedClass}_stage$_selectedStage.png?key=$_imageRefreshKey';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar Asset Manager'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Upload Character Avatars',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2B26),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Select class and stage to upload kustom avatar files directly to Supabase Storage.',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B6862)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            if (_message != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? const Color(0xFF4E7A51).withAlpha(30)
                      : const Color(0xFFB3492F).withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isSuccess
                        ? const Color(0xFF4E7A51)
                        : const Color(0xFFB3492F),
                  ),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _isSuccess
                        ? const Color(0xFF4E7A51)
                        : const Color(0xFFB3492F),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Selections Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedClass,
                      decoration: const InputDecoration(
                        labelText: 'Character Class',
                      ),
                      items: _classes.map((cls) {
                        return DropdownMenuItem(
                          value: cls,
                          child: Text(cls.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedClass = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedStage,
                      decoration: const InputDecoration(
                        labelText: 'Appearance Stage',
                      ),
                      items: List.generate(5, (index) => index + 1).map((
                        stage,
                      ) {
                        return DropdownMenuItem(
                          value: stage,
                          child: Text(
                            'Stage $stage (Level ${(stage - 1) * 5 + 1}+)',
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedStage = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Preview Section
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Current Cloud Avatar',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9DE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE3E0D6)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            publicUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported_rounded,
                                      color: Color(0xFF6B6862),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Not uploaded yet',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF6B6862),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'New Selected Avatar',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9DE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE3E0D6)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _localPhotoPath != null
                              ? Image.file(
                                  File(_localPhotoPath!),
                                  fit: BoxFit.contain,
                                )
                              : const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate_rounded,
                                        color: Color(0xFF6B6862),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'No image selected',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF6B6862),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Select image buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing ? null : _capturePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing ? null : _selectFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_isProcessing)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                onPressed: _localPhotoPath == null ? null : _handleUpload,
                icon: const Icon(Icons.cloud_upload_rounded),
                label: const Text('Upload Avatar to Supabase'),
              ),
          ],
        ),
      ),
    );
  }
}
