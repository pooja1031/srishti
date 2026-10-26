import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/ui_utils.dart'; // To use showCustomSnackBar

class PortfolioItem {
  final int id;
  final String imageUrl;
  final String category;
  final bool isPinned;
  
  PortfolioItem(this.id, this.imageUrl, this.category, this.isPinned);
}

class PortfolioSection extends StatefulWidget {
  const PortfolioSection({super.key});

  @override
  State<PortfolioSection> createState() => _PortfolioSectionState();
}

class _PortfolioSectionState extends State<PortfolioSection> {
  String _selectedCategory = 'All';
  bool _isLoading = true;
  List<PortfolioItem> allItems = [];

  final List<String> categories = [
    'All',
    'Hindu Look',
    'Christian Look',
    'Muslim Look',
    'Hair',
    'Makeup'
  ];

  @override
  void initState() {
    super.initState();
    _fetchPortfolioImages();
  }

  Future<void> _fetchPortfolioImages() async {
    try {
      final data = await Supabase.instance.client
          .from('portfolio_images')
          .select()
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false);
      
      if (mounted) {
        setState(() {
          allItems = (data as List).map((e) => PortfolioItem(
            e['id'], 
            e['image_url'], 
            e['category'],
            e['is_pinned'] ?? false,
          )).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // showCustomSnackBar(context, 'Failed to load portfolio images.', isError: true);
      }
    }
  }

  Future<void> _uploadNewPhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    
    final Uint8List imageBytes = await image.readAsBytes();
    String? selectedCategory = categories[1]; // default to first real category

    // Show dialog to select category and confirm upload
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Upload Portfolio Photo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(imageBytes, height: 150, width: 400, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories.where((c) => c != 'All').map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedCategory = val);
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Category',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('UPLOAD'),
                ),
              ],
            );
          }
        );
      }
    );

    if (confirm != true) return;

    if (mounted) {
      showCustomSnackBar(context, 'Uploading image...');
    }

    try {
      final fileExt = image.name.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      // Upload to storage
      await Supabase.instance.client.storage
          .from('portfolio')
          .uploadBinary(
            fileName, 
            imageBytes,
            fileOptions: FileOptions(contentType: 'image/$fileExt'),
          );
          
      // Get public URL
      final publicUrl = Supabase.instance.client.storage
          .from('portfolio')
          .getPublicUrl(fileName);
          
      // Insert into DB
      await Supabase.instance.client.from('portfolio_images').insert({
        'image_url': publicUrl,
        'category': selectedCategory,
      });

      if (mounted) {
        showCustomSnackBar(context, 'Photo uploaded successfully!');
        setState(() { _isLoading = true; }); // Show loading while fetching
        _fetchPortfolioImages(); // Refresh the grid
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, 'Failed to upload photo: $e', isError: true);
      }
    }
  }

  Future<void> _deletePhoto(PortfolioItem item) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo?'),
        content: const Text('Are you sure you want to permanently remove this photo from the portfolio?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (mounted) {
      showCustomSnackBar(context, 'Deleting photo...');
      setState(() => _isLoading = true);
    }

    try {
      // If the image is from Supabase storage, also delete the actual file
      if (item.imageUrl.contains('/storage/v1/object/public/portfolio/')) {
        final fileName = item.imageUrl.split('/').last;
        await Supabase.instance.client.storage.from('portfolio').remove([fileName]);
      }

      // Delete the database record
      await Supabase.instance.client
          .from('portfolio_images')
          .delete()
          .eq('id', item.id);
          
      if (mounted) {
        showCustomSnackBar(context, 'Photo deleted successfully!');
        _fetchPortfolioImages(); // Refresh the grid
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, 'Failed to delete photo: $e', isError: true);
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _togglePin(PortfolioItem item) async {
    if (mounted) {
      showCustomSnackBar(context, item.isPinned ? 'Unpinning photo...' : 'Pinning photo...');
      setState(() => _isLoading = true);
    }
    try {
      await Supabase.instance.client
          .from('portfolio_images')
          .update({'is_pinned': !item.isPinned})
          .eq('id', item.id);
          
      if (mounted) {
        showCustomSnackBar(context, item.isPinned ? 'Photo unpinned.' : 'Photo pinned!');
        _fetchPortfolioImages();
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, 'Failed to update pin: $e', isError: true);
        setState(() => _isLoading = false);
      }
    }
  }

  bool get isAdmin {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.email == 'poojapadmakumar03@gmail.com';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Filter items based on selected category
    final filteredItems = _selectedCategory == 'All'
        ? allItems
        : allItems.where((item) => item.category == _selectedCategory).toList();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40, vertical: isMobile ? 40 : 80),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'ABOUT HER WORK',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      letterSpacing: 3,
                    ),
              ),
              if (isAdmin) ...[
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.add_a_photo, color: Theme.of(context).colorScheme.primary),
                    onPressed: _uploadNewPhoto,
                    tooltip: 'Upload new photo (Admin only)',
                  ),
                )
              ]
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: 60,
            height: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 40),
          
          // Categories Wrap
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: categories.map((category) {
              final isSelected = _selectedCategory == category;
              return ChoiceChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  }
                },
                selectedColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Colors.transparent,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Theme.of(context).colorScheme.secondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 40),
          
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _isLoading 
              ? const Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                )
              : filteredItems.isEmpty 
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('More photos coming soon to this category!'),
                    )
                  : LayoutBuilder(
                      key: ValueKey<String>(_selectedCategory),
                      builder: (context, constraints) {
                        int crossAxisCount = 3;
                        if (constraints.maxWidth < 600) {
                          crossAxisCount = 1;
                        } else if (constraints.maxWidth < 900) {
                          crossAxisCount = 2;
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.8, // Slightly taller than square
                          ),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            final imgPath = item.imageUrl;
                            final imageProvider = imgPath.startsWith('http')
                                ? NetworkImage(imgPath) as ImageProvider
                                : AssetImage(imgPath);
                                
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                      alignment: Alignment.topCenter,
                                      filterQuality: FilterQuality.high,
                                    ),
                                  ),
                                ),
                                if (isAdmin)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Row(
                                      children: [
                                        Material(
                                          color: Colors.black54,
                                          shape: const CircleBorder(),
                                          clipBehavior: Clip.hardEdge,
                                          child: IconButton(
                                            icon: Icon(item.isPinned ? Icons.push_pin : Icons.push_pin_outlined, color: item.isPinned ? Theme.of(context).colorScheme.primary : Colors.white, size: 20),
                                            onPressed: () => _togglePin(item),
                                            tooltip: item.isPinned ? 'Unpin photo' : 'Pin to top',
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Material(
                                          color: Colors.black54,
                                          shape: const CircleBorder(),
                                          clipBehavior: Clip.hardEdge,
                                          child: IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                                            onPressed: () => _deletePhoto(item),
                                            tooltip: 'Delete photo',
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (item.isPinned)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.push_pin, color: Theme.of(context).colorScheme.primary, size: 20),
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
          ),
          const SizedBox(height: 60),
          OutlinedButton(
            onPressed: () {
              // Open full gallery or Instagram
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
              side: BorderSide(color: Theme.of(context).colorScheme.secondary),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            child: const Text('VIEW FULL GALLERY'),
          ),
        ],
      ),
    );
  }
}
