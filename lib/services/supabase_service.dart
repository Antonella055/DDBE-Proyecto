import 'dart:io'; // Necesario para la clase File
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ayudantia_software/features/home/data/news_model.dart'; // Importa el modelo de noticia

final userId = Supabase.instance.client.auth.currentUser?.id;

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
  Future<String?> uploadImage(
    File imageFile,
    String bucketName,
    String path,
  ) async {
    try {
      final String fileName =
          imageFile.path
              .split('/')
              .last; // Obtiene el nombre del archivo original
      final String filePathInBucket =
          '$path/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // Sube el archivo al bucket especificado
      await _supabase.storage
          .from(bucketName)
          .upload(
            filePathInBucket,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Obtiene la URL pública del archivo subido
      final String publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(filePathInBucket);
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
      final String publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(path);
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
          .from(
            'news_articles',
          ) // Asegúrate de que 'news_articles' sea el nombre correcto de tu tabla
          .select('*')
          .order('published_at', ascending: false);

      // Mapea la respuesta JSON a una lista de objetos NewsArticle
      return response.map((json) => NewsArticle.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching news articles: $e');
      rethrow; // Relanza la excepción para que sea manejada en el UI, por ejemplo, mostrando un mensaje de error.
    }
  }

  Future<List<Map<String, dynamic>>> getCalendario() async {
    final response = await _supabase
        .from('calendario')
        .select()
        .order('dia', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addActivity({
    required DateTime dia,
    required String evento,
    required String descripcion,
    required String lugar,
    required String hora, // formato "HH:mm:ss"
  }) async {
    await _supabase.from('calendario').insert({
      'dia': dia.toIso8601String().split('T')[0],
      'evento': evento,
      'descripcion': descripcion,
      'lugar': lugar,
      'hora': hora,
    });
  }

  Future<void> deleteActivity(int id) async {
    await _supabase.from('calendario').delete().eq('id', id);
  }

  Future<void> updateActivity({
    required int id,
    required String evento,
    required String descripcion,
    required String lugar,
    required String hora,
  }) async {
    await _supabase
        .from('calendario')
        .update({
          'evento': evento,
          'descripcion': descripcion,
          'lugar': lugar,
          'hora': hora,
        })
        .eq('id', id);
  }

  /// inicio de registrar horas
  Future<void> registrarHoras({
    required String idEstudiante,
    required DateTime fecha,
    required int horas,
    required String descripcion,
  }) async {
    final Map<String, dynamic> data = {
      'idEstudiante': idEstudiante,
      'fecha': fecha.toIso8601String().split('T')[0],
      'horas': horas,
      'descripcion': descripcion,
    };

    await _supabase.from('horasCulminadas').insert(data);
  }

  Future<List<Map<String, dynamic>>> obtenerHorasPorIdEstudiante(
    String idEstudiante,
  ) async {
    final data = await _supabase
        .from('horasCulminadas')
        .select()
        .eq('idEstudiante', idEstudiante);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> eliminarHoraCulminada(int idhora) async {
    await _supabase.from('horasCulminadas').delete().eq('idhora', idhora);
  }

  Future<void> editarHoraCulminada(
    int idhora,
    DateTime fecha,
    int horas,
    String descripcion,
  ) async {
    await _supabase
        .from('horasCulminadas')
        .update({
          'fecha': fecha.toIso8601String().split('T')[0],
          'horas': horas,
          'descripcion': descripcion,
        })
        .eq('idhora', idhora);
  }

  /// final de horas registradas
  /// mostrar las horas de los estudiantes del profesor
  Future<List<Map<String, dynamic>>> obtenerHorasDeEstudiantesDelProfesor(
    String profesorId, {
    int? mes,
  }) async {
    try {
      final response = await _supabase
          .from('horas_culminadas') // Asegúrate que este es el nombre correcto
          .select('''
            horas, 
            fecha, 
            descripcion, 
            estudiantes:id_estudiante(nombre, apellido)  // Relación explícita
          ''')
          .eq('id_profesor', profesorId);

      // Conversión segura a List<Map<String, dynamic>>
      final List<Map<String, dynamic>> result = [];

      for (final item in response) {
        // Manejo completo de nulos
        final estudianteData =
            item['estudiantes'] is Map
                ? item['estudiantes'] as Map<String, dynamic>
                : {'nombre': 'Estudiante no disponible'};

        result.add({
          'horas': item['horas'] ?? 0,
          'fecha': item['fecha'] ?? '',
          'descripcion': item['descripcion'] ?? '',
          'estudiantes': estudianteData,
        });
      }

      return result;
    } catch (e) {
      print('Error al obtener horas: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> obtenerEstudiantesDelProfesor(
    String profesorId,
  ) async {
    try {
      final response = await _supabase
          .from('students')
          .select('''
            id, 
            carnet,
            profiles: ID (full_name, avatar_url)
          ''')
          .eq('id_supervisor', profesorId);

      return List<Map<String, dynamic>>.from(response).map((estudiante) {
        return {
          'id': estudiante['id'],
          'carnet': estudiante['carnet'],
          'nombre': estudiante['profiles']?['full_name'] ?? 'Sin nombre',
          'avatar_url': estudiante['profiles']?['avatar_url'],
        };
      }).toList();
    } catch (e) {
      print('Error al obtener estudiantes: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getStudentsByProfessorId(String professorId) async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from('students')
          .select('*, profiles(full_name, email)')
          .eq('id_supervisor', professorId)
          .order('created_at', ascending: true);

      print('Supabase response for students: $response'); // <- Añade esto

      return response.map((student) {
        print('Processing student: $student'); // <- Añade esto
        final Map<String, dynamic>? profile = student['profiles'] as Map<String, dynamic>?;
        print('Profile part: $profile'); // <- Añade esto

        if (profile != null) {
          student['full_name'] = profile['full_name'];
          student['email'] = profile['email'];
        } else {
          student['full_name'] = 'Nombre no disponible';
          student['email'] = 'Email no disponible';
        }
        return student;
      }).toList();

    } catch (e) {
      print('Error al obtener estudiantes: $e');
      return [];
    }
  }
}
