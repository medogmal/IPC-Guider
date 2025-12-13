import 'dart:typed_data';
import 'dart:io' show File;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/design_tokens.dart';
import '../../../core/widgets/back_button.dart';
import '../data/isolation_providers.dart';
import '../domain/organism_precaution.dart';

// Conditional imports for web-specific functionality have been removed to fix the APK build.
// import 'package:flutter/foundation.dart' show kIsWeb;
// // ignore: avoid_web_libraries_in_flutter
// import 'dart:html' as html if (dart.library.io) 'dart:io';

class IsolationDetailScreen extends ConsumerStatefulWidget {
  final String entityId;
  const IsolationDetailScreen({super.key, required this.entityId});

  @override
  ConsumerState<IsolationDetailScreen> createState() => _IsolationDetailScreenState();
}

class _IsolationDetailScreenState extends ConsumerState<IsolationDetailScreen> {
  final GlobalKey _signageKey = GlobalKey();

  OrganismPrecaution? _findById(List<OrganismPrecaution> items, String id) {
    try {
      return items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List> _capturePngBytes() async {
    final boundary = _signageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
    // NOTE: Container around RepaintBoundary has solid white background for contrast.
  }

  Future<void> _saveOrShareSignage() async {
    try {
      final bytes = await _capturePngBytes();
      final filename = 'isolation_signage_${widget.entityId}.png';

      // The web-specific code below has been commented out to fix the APK build.
      // if (kIsWeb) {
      //   final blob = html.Blob([bytes], 'image/png');
      //   final url = html.Url.createObjectUrlFromBlob(blob);
      //   final anchor = html.AnchorElement(href: url)..download = filename;
      //   anchor.click();
      //   html.Url.revokeObjectUrl(url);
      //   if (!mounted) return;
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Signage downloaded as PNG')),
      //   );
      //   return;
      // }

      final dir = await path_provider.getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null
          ? (box.localToGlobal(ui.Offset.zero) & box.size)
          : const ui.Rect.fromLTWH(0, 0, 1, 1);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Isolation signage',
        sharePositionOrigin: origin,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting PNG: $e')),
      );
    }
  }

  Future<void> _openRef(RefLink ref) async {
    if (ref.url.isEmpty) return;
    final uri = Uri.tryParse(ref.url);
    if (uri == null) return;
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(isolationAllProvider);

    return all.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (items) {
        final item = _findById(items, widget.entityId);
        if (item == null) {
          return const Scaffold(body: Center(child: Text('Not found')));
        }
        return Scaffold(
          appBar: AppBackAppBar(
            title: item.organism,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Exportable area with solid white background for strong contrast
              RepaintBoundary(
                key: _signageKey,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12), // <- fixed EdgeInsets
                  child: _SignageCard(item: item),
                ),
              ),
              const SizedBox(height: 16),

              const Text('References', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: item.references.map((r) {
                  final hasUrl = r.url.isNotEmpty;
                  return hasUrl
                      ? OutlinedButton.icon(
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: Text(r.label, overflow: TextOverflow.ellipsis),
                          onPressed: () => _openRef(r),
                        )
                      : Chip(label: Text(r.label));
                }).toList(),
              ),

              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saveOrShareSignage,
                icon: const Icon(Icons.image_outlined),
                label: const Text('Save / Share Signage (PNG)'),
              ),

              // Bottom padding for mobile responsiveness
              const SizedBox(height: 48),
            ],
          ),
        );
      },
    );
  }
}

class _SignageCard extends StatelessWidget {
  final OrganismPrecaution item;
  const _SignageCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final primary = item.isolationTypes.isNotEmpty
        ? item.isolationTypes.first.isolationColor
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.55), width: 1.2),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.black87, fontSize: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.organism,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),

            // Isolation chips (without decorative dots)
            Wrap(
              spacing: 6,
              children: item.isolationTypes.map((t) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: t.isolationColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(t, style: const TextStyle(fontSize: 12, color: Colors.white)),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            const Text('Required PPE:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.ppe.map((p) => _PpePill(text: p)).toList(),
            ),

            const SizedBox(height: 10),

            // Inline bold labels
            _infoRow('Duration', item.durationText),
            if (item.discontinueNotes.isNotEmpty)
              _infoRow('Discontinuation', item.discontinueNotes),
            if (item.specialConsiderations.isNotEmpty)
              _infoRow('Clinical Notes / Special Considerations', item.specialConsiderations),
          ],
        ),
      ),
    );
  }

  // Bold label + inline value
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _PpePill extends StatelessWidget {
  final String text;
  const _PpePill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87)),
    );
  }
}
