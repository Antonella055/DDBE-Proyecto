import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ayudantia_software/features/home/presentation/widgets/custom_appbar.dart';

class AyudantiaPage extends StatelessWidget {
  const AyudantiaPage({super.key});

  void _abrirPDF() async {
    final Uri url = Uri.parse('https://tu-servidor.com/ayudantia.pdf');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'No se pudo abrir el PDF';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        scaffoldKey: GlobalKey<ScaffoldState>(),
        linkTextColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            // Columna izquierda
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Programa de Ayudantía',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Es un programa de intercambio de valor para los estudiantes de pregrado y postgrado de la universidad. '
                    'Los estudiantes colaborarán en actividades académicas (Programa de Mentoría) o administrativas dentro del campus universitario, '
                    'bajo la supervisión del personal de la universidad.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha de postulación',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Las postulaciones para este programa se realizarán desde la semana 2 hasta la semana 4.\n'
                          'Postulación al Programa de Ayudantía 2526-1',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Puedes navegar a otra vista si hace falta
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Conocer más'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Columna derecha
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/pdf_captura.jpg',
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _abrirPDF,
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Leer más',
                        style: TextStyle(
                          color: Colors.orange,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
