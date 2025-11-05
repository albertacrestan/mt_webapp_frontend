import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:medtech_webapp/image_card.dart';
import 'repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? originalBytes;
  Uint8List? processedBytes;
  String? fileName;
  String mode = 'Arteriosa';
  bool processing = false;

  // Point backendUrl to your Gradio Space predict endpoint:
  // e.g. Uri.parse('https://<your-username>.hf.space/api/predict')
  final Repository repository = Repository(
    backendUrl: Uri.parse('https://albertacrestan-mt-webapp-backend.hf.space/api/predict/'),
  );

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        originalBytes = result.files.first.bytes;
        fileName = result.files.first.name;
        processedBytes = null; // reset previous result
      });
    }
  }

  Future<void> onElaboraPressed() async {
    if (originalBytes == null) return;

    setState(() => processing = true);
    try {
      // use the Gradio-specific method
      final result = await repository.sendImageToGradio(
        imageBytes: originalBytes!,
        mode: mode,
      );
      setState(() {
        processedBytes = result;
      });
    } catch (e, st) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore elaborazione: ${e.toString()}')),
      );
      // ignore: avoid_print
      print('processImage error: $e\n$st');
    } finally {
      setState(() => processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Medical Phase Simulator'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: pickImage,
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Scegli file'),
                    ),
                    const SizedBox(width: 12),
                    // make filename take remaining space so controls sit at the right
                    Expanded(
                      child: Text(
                        fileName ?? 'Nessun file selezionato',
                        style: const TextStyle(color: Colors.black54),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // controls kept minimal width and naturally align to the right
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Arteriosa',
                              groupValue: mode,
                              onChanged: (v) => setState(() => mode = v!),
                            ),
                            const Text('Arteriosa'),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Venosa',
                              groupValue: mode,
                              onChanged: (v) => setState(() => mode = v!),
                            ),
                            const Text('Venosa'),
                          ],
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: (originalBytes == null || processing) ? null : onElaboraPressed,
                          child: processing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Elabora Immagine'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Row(
                children: [
                  imageCard('Originale', originalBytes),
                  imageCard('Elaborata', processedBytes),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
