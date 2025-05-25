import 'dart:io'; // Necesario para la clase File
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Obtiene la instancia del cliente Supabase que se inicializó en main.dart
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Sube un archivo de imagen al almacenamiento de Supabase y devuelve su URL pública.
  ///
  /// [imageFile]: El archivo de imagen a subir.
  /// [bucketName]: El nombre del bucket en Supabase Storage (ej. 'images').
  /// [path]: La ruta dentro del bucket donde se guardará el archivo (ej. 'uploads/').
  ///         Se recomienda usar un UUID o timestamp para el nombre del archivo.
  ///
  /// Retorna la URL pública de la imagen si la subida es exitosa, de lo contrario, null.
  Future<String?> uploadImage(File imageFile, String bucketName, String path) async {
    try {
      final String fileName = imageFile.path.split('/').last; // Obtiene el nombre del archivo original
      final String filePathInBucket = '$path/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // Sube el archivo al bucket especificado
      await _supabase.storage.from(bucketName).upload(
        filePathInBucket,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      // Obtiene la URL pública del archivo subido
      final String publicUrl = _supabase.storage.from(bucketName).getPublicUrl(filePathInBucket);
      return publicUrl;
    } on StorageException catch (e) {
      print('Error al subir imagen a Supabase Storage: ${e.message}');
      return null;
    } catch (e) {
      print('Error inesperado al subir imagen: $e');
      return null;
    }
  }

  /// Obtiene la URL pública de una imagen ya subida en Supabase Storage.
  ///
  /// [bucketName]: El nombre del bucket.
  /// [path]: La ruta completa del archivo dentro del bucket (ej. 'uploads/nombre_imagen.jpg').
  String getPublicImageUrl(String bucketName, String path) {
    return _supabase.storage.from(bucketName).getPublicUrl(path);
  }

  // TODO: Puedes añadir más métodos para interactuar con otras tablas (noticias, eventos, etc.)
  // Ejemplo:
  // Future<List<Map<String, dynamic>>> fetchNews() async {
  //   final response = await _supabase.from('news').select().order('created_at', ascending: false);
  //   return response;
  // }
}