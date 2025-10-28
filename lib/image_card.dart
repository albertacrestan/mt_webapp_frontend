import 'dart:typed_data';
import 'package:flutter/material.dart';

Widget imageCard(String title, Uint8List? bytes) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: bytes != null
                      ? Center(
                          child: Image.memory(
                            bytes,
                            fit: BoxFit.contain,
                          ),
                        )
                      : const Center(child: Text('Nessuna immagine')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }