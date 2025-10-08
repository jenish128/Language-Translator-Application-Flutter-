// lib/phrasebook_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

class PhrasebookScreen extends StatefulWidget {
  const PhrasebookScreen({Key? key}) : super(key: key);

  @override
  State<PhrasebookScreen> createState() => _PhrasebookScreenState();
}

class PhraseEntry {
  final int id; // simple numeric id
  String original;
  String translated;
  String category;
  DateTime createdAt;

  PhraseEntry({
    required this.id,
    required this.original,
    required this.translated,
    required this.category,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'original': original,
    'translated': translated,
    'category': category,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PhraseEntry.fromJson(Map<String, dynamic> j) {
    return PhraseEntry(
      id: j['id'] as int,
      original: j['original'] ?? '',
      translated: j['translated'] ?? '',
      category: j['category'] ?? 'Others',
      createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class _PhrasebookScreenState extends State<PhrasebookScreen>
    with TickerProviderStateMixin {
  static const _storageKey = 'phrasebook_entries_v1';
  final FlutterTts _tts = FlutterTts();

  // Animation list key: we use AnimatedList for nice insert/remove animations
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  List<PhraseEntry> _entries = [];
  String _filterCategory = 'All';
  final List<String> _categories = ['All', 'Travel', 'Work', 'Study', 'Others'];

  // category -> emoji/icon
  final Map<String, String> _categoryEmoji = {
    'Travel': '✈️',
    'Work': '💼',
    'Study': '📚',
    'Others': '⭐',
  };

  bool _loading = true;

  // controllers reused for add/edit sheet
  TextEditingController? _originalController;
  TextEditingController? _translatedController;
  String? _editingCategory;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadEntries();
  }

  Future<void> _initTts() async {
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _loadEntries() async {
    setState(() {
      _loading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        final loaded = list
            .map((e) => PhraseEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        // Put loaded into _entries
        setState(() {
          _entries = loaded;
          _loading = false;
        });
      } catch (_) {
        setState(() {
          _entries = [];
          _loading = false;
        });
      }
    } else {
      setState(() {
        _entries = [];
        _loading = false;
      });
    }
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> _addOrEditEntry({PhraseEntry? edit}) async {
    // prepare controllers
    _originalController = TextEditingController(text: edit?.original ?? '');
    _translatedController = TextEditingController(text: edit?.translated ?? '');
    _editingCategory = edit?.category ?? 'Travel';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.62,
          maxChildSize: 0.95,
          minChildSize: 0.25,
          builder: (context, sc) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                  16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: ListView(
                controller: sc,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(edit == null ? 'Add Phrase' : 'Edit Phrase',
                          style: Theme.of(context).textTheme.titleLarge),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(ctx);
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _originalController,
                    decoration: const InputDecoration(
                      labelText: 'Original text',
                      prefixIcon: Icon(Icons.record_voice_over),
                    ),
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _translatedController,
                    decoration: const InputDecoration(
                      labelText: 'Translated text',
                      prefixIcon: Icon(Icons.translate),
                    ),
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _editingCategory,
                    items: _categories
                        .where((c) => c != 'All')
                        .map((c) => DropdownMenuItem(
                      value: c,
                      child: Row(
                        children: [
                          Text(_categoryEmoji[c] ?? ''),
                          const SizedBox(width: 8),
                          Text(c),
                        ],
                      ),
                    ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _editingCategory = v);
                    },
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: Text(edit == null ? 'Save Phrase' : 'Update Phrase'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final orig = _originalController!.text.trim();
                      final trans = _translatedController!.text.trim();
                      final category = _editingCategory ?? 'Others';
                      if (orig.isEmpty || trans.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Both fields are required')),
                        );
                        return;
                      }

                      if (edit == null) {
                        // insert at top
                        final newId = DateTime.now().millisecondsSinceEpoch;
                        final entry = PhraseEntry(
                            id: newId,
                            original: orig,
                            translated: trans,
                            category: category);
                        setState(() {
                          _entries.insert(0, entry);
                        });
                        // animate insert
                        _listKey.currentState
                            ?.insertItem(0, duration: const Duration(milliseconds: 450));
                      } else {
                        final idx = _entries.indexWhere((e) => e.id == edit.id);
                        if (idx >= 0) {
                          setState(() {
                            _entries[idx].original = orig;
                            _entries[idx].translated = trans;
                            _entries[idx].category = category;
                          });
                        }
                      }

                      await _saveEntries();
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    // dispose controllers
    _originalController?.dispose();
    _translatedController?.dispose();
    _originalController = null;
    _translatedController = null;
    _editingCategory = null;
  }

  Future<void> _deleteEntry(PhraseEntry e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete phrase?'),
        content: Text('Delete "${e.original}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      final idx = _entries.indexWhere((it) => it.id == e.id);
      if (idx >= 0) {
        final removed = _entries.removeAt(idx);
        _listKey.currentState?.removeItem(
          idx,
              (context, animation) => _animatedTile(removed, animation),
          duration: const Duration(milliseconds: 400),
        );
        await _saveEntries();
      }
    }
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.speak(text);
    } catch (_) {}
  }

  // Note: export/import functions removed per request (two icons removed from header)

  List<PhraseEntry> get _filteredEntries {
    if (_filterCategory == 'All') return _entries;
    return _entries.where((e) => e.category == _filterCategory).toList();
  }

  Widget _categoryChip(String c) {
    final selected = c == _filterCategory;
    final emoji = _categoryEmoji[c] ?? '';
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji),
          const SizedBox(width: 6),
          Text(c),
        ],
      ),
      selected: selected,
      selectedColor: Colors.teal.shade300,
      onSelected: (_) => setState(() => _filterCategory = c),
      backgroundColor: Colors.white.withOpacity(0.9),
      elevation: selected ? 4 : 1,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500),
    );
  }

  Widget _animatedTile(PhraseEntry e, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          child: ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              child: Text(
                _categoryEmoji[e.category] ?? '⭐',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            title: Text(e.original, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(e.translated),
            trailing: PopupMenuButton<int>(
              onSelected: (v) async {
                if (v == 1) {
                  await Clipboard.setData(ClipboardData(text: e.original));
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Original copied')));
                } else if (v == 2) {
                  await Clipboard.setData(ClipboardData(text: e.translated));
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Translated copied')));
                } else if (v == 3) {
                  _speak(e.translated);
                } else if (v == 4) {
                  _addOrEditEntry(edit: e);
                } else if (v == 5) {
                  _deleteEntry(e);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 1, child: Text('Copy original')),
                const PopupMenuItem(value: 2, child: Text('Copy translated')),
                const PopupMenuItem(value: 3, child: Text('Speak translation')),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 4, child: Text('Edit')),
                const PopupMenuItem(value: 5, child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build header / top UI (export/import icons removed)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.bookmark, size: 28, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Phrasebook',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('Save frequently used translations for offline quick access',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          // Removed export/import IconButtons as requested
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // gradient appbar-style header
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // custom header with gradient background
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.teal.shade600, Colors.purple.shade600]),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            padding: const EdgeInsets.only(top: 18, bottom: 6),
            child: SafeArea(child: _buildHeader()),
          ),

          const SizedBox(height: 10),

          // category chips
          SizedBox(
            height: 56,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final c = _categories[i];
                return _categoryChip(c);
              },
            ),
          ),

          const SizedBox(height: 10),

          // --- list section (safe snapshot + AnimatedList) ---
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: () {
                // take a local snapshot of filtered entries to avoid concurrent modifications
                final items = _filteredEntries;
                if (items.isEmpty) {
                  return Padding(
                    key: const ValueKey('empty'),
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('No saved phrases yet', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('Tap the Add button to create a phrase', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  );
                }

                // Use AnimatedList for insert/remove animation. We still guard index access inside itemBuilder.
                return Padding(
                  key: const ValueKey('list'),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedList(
                    key: _listKey,
                    initialItemCount: items.length,
                    itemBuilder: (context, index, animation) {
                      // defensive guard: if index somehow is out-of-bounds, return an invisible placeholder
                      if (index < 0 || index >= items.length) {
                        return const SizedBox.shrink();
                      }
                      final e = items[index];
                      // Use your animated tile builder that accepts the entry + animation
                      return _animatedTile(e, animation);
                    },
                  ),
                );
              }(), // immediate-invoked function so AnimatedSwitcher can have unique keys
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEditEntry(),
        label: const Text('Add Phrase'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.purple.shade600,
      ),
    );
  }
}
