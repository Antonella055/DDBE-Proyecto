import 'dart:io'; // Necesario para la clase File
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ayudantia_software/features/home/data/news_model.dart'; // Importa el modelo de noticia

class SupabaseService {
  // Obtiene la instancia del cliente Supabase que se inicializó en main.dart
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Sube un archivo de imagen al almacenamiento de Supabase y devuelve su URL pública.
  ///
  /// [imageFile]: El archivo de imagen a subir.
  /// [bucketName]: El nombre del bucket en Supabase Storage (ej. 'images').
  /// [path]: La ruta dentro del bucket donde se guardará el archivo (ej. 'uploads/').
  ///        Se recomienda usar un UUID o timestamp para el nombre del archivo.
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
    // Tu implementación original ya maneja esto, solo la encapsulamos con try-catch para robustez.
    try {
      final String publicUrl = _supabase.storage.from(bucketName).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print('Error al obtener URL pública de Supabase Storage: $e');
      return ''; // Retorna una cadena vacía o un placeholder en caso de error.
    }
  }

  // NEW: Método para obtener noticias
  /// Fetches a list of news articles from the 'news_articles' table in Supabase.
  ///
  /// Returns a Future that resolves to a List of NewsArticle objects.
  /// Throws an exception if there's an error during the fetch operation.
  Future<List<NewsArticle>> fetchNewsArticles() async {
    try {
      // Realiza la consulta a la tabla 'news_articles'
      // Selecciona todas las columnas y ordena por 'published_at' de forma descendente.
      // Si no tienes 'published_at', puedes omitir .order() o usar otra columna.
      final List<Map<String, dynamic>> response = await _supabase
          .from('news_articles') // Asegúrate de que 'news_articles' sea el nombre correcto de tu tabla
          .select('*')
          .order('published_at', ascending: false); 

      // Mapea la respuesta JSON a una lista de objetos NewsArticle
      return response.map((json) => NewsArticle.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching news articles: $e');
      rethrow; // Relanza la excepción para que sea manejada en el UI, por ejemplo, mostrando un mensaje de error.
    }
  }
}