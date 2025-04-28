import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  final String baseUrl = 'http://10.0.2.2:3000';

  // Login
  Future<Map<String, dynamic>> login(Map<String, String> credentials) async {
    final url = Uri.parse('$baseUrl/api/pacientes/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(credentials),
    );
    print('Respuesta del servidor al hacer login: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'success': data['success'],
        'tipoUsuario': data['tipoUsuario'],
        'medicoAsignado': data['medicoAsignado'],
        'usuarioId': data['usuarioId'],
      };
    } else {
      return json.decode(response.body);
    }
  }

  // Registrar paciente
  Future<Map<String, dynamic>> savePaciente(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/pacientes/save-data');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al guardar el paciente: ${response.body}');
    }
  }

  // Registrar médico
  Future<Map<String, dynamic>> registrarMedico(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/pacientes/registrar-medico');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    print('Respuesta del servidor al registrar médico: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return {
        'success': responseBody['success'] ?? true,
        'error': responseBody['error'] ?? null,
      };
    } else {
      final responseBody = json.decode(response.body);
      return {
        'success': false,
        'error': responseBody['error'] ?? 'Error al registrar el médico: ${response.body}',
      };
    }
  }

  // Asignar médico a paciente
  Future<Map<String, dynamic>> asignarMedico(String pacienteCorreo, String medicoCorreo) async {
    final url = Uri.parse('$baseUrl/api/pacientes/asignar-medico');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'pacienteCorreo': pacienteCorreo,
        'medicoCorreo': medicoCorreo,
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al asignar el médico: ${response.body}');
    }
  }

  // Obtener médicos disponibles
  Future<List<dynamic>> getMedicosDisponibles() async {
    final url = Uri.parse('$baseUrl/api/pacientes/medicos-disponibles');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['medicos'];
      } else {
        throw Exception(data['error'] ?? 'Error al obtener médicos disponibles');
      }
    } else {
      throw Exception('Error al obtener médicos disponibles: ${response.body}');
    }
  }

  // Registrar disponibilidad
  Future<Map<String, dynamic>> registrarDisponibilidad(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/pacientes/registrar-disponibilidad');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'correo': data['correo'],
        'dia': data['dia'],
        'horario': data['horario'],
        'consultorio': data['consultorio'],
      }),
    );
    print('Solicitando registrar disponibilidad a: $url');
    print('Datos enviados: ${json.encode(data)}');
    print('Respuesta del servidor: ${response.statusCode} - ${response.body}');
    final responseBody = json.decode(response.body);
    if (response.statusCode == 201) {
      return responseBody;
    } else {
      throw Exception(responseBody['error'] ?? 'Error al registrar la disponibilidad: ${response.body}');
    }
  }

  // Obtener disponibilidades
  Future<List<dynamic>> getDisponibilidades(String medicoCorreo) async {
    final url = Uri.parse('$baseUrl/api/pacientes/disponibilidad');
    print('Solicitando disponibilidades a: $url');
    final response = await http.get(url);
    print('Respuesta del servidor (disponibilidades): ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final disponibilidades = json.decode(response.body);
      final filteredDisponibilidades = disponibilidades.where((disp) => disp['correo'] == medicoCorreo).toList();
      return filteredDisponibilidades;
    } else {
      throw Exception('Error al obtener las disponibilidades: ${response.body}');
    }
  }

  // Agendar una cita
  Future<Map<String, dynamic>> agendarCita(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/pacientes/agendar-cita');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'pacienteCorreo': data['pacienteCorreo'],
        'medicoCorreo': data['medicoCorreo'],
        'dia': data['dia'],
        'horario': data['horario'],
      }),
    );
    final responseBody = json.decode(response.body);
    if (response.statusCode == 201) {
      return responseBody;
    } else {
      throw Exception(responseBody['error'] ?? 'Error al agendar la cita: ${response.body}');
    }
  }

  // Obtener citas
  Future<List<dynamic>> getCitas(String correo, String tipoUsuario) async {
    final url = Uri.parse('$baseUrl/api/pacientes/citas?correo=$correo&tipoUsuario=$tipoUsuario');
    final response = await http.get(url);
    print('URL solicitada: $url');
    print('Respuesta del servidor: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['citas'] ?? [];
      } else {
        throw Exception(data['message'] ?? 'Error al obtener las citas');
      }
    } else {
      throw Exception('Error al obtener las citas: ${response.body}');
    }
  }

  // Obtener datos de un paciente por correo
  Future<Map<String, dynamic>> getPacienteByCorreo(String correo) async {
    final url = Uri.parse('$baseUrl/api/pacientes/datos?correo=$correo');
    final response = await http.get(url);
    print('Solicitando datos del paciente a: $url');
    print('Respuesta del servidor (datos paciente): ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> pacientes = json.decode(response.body);
      if (pacientes.isNotEmpty) {
        return pacientes[0] as Map<String, dynamic>;
      } else {
        throw Exception('Paciente no encontrado');
      }
    } else {
      throw Exception('Error al obtener el paciente: ${response.body}');
    }
  }

  // Obtener persona por ID
  Future<Map<String, dynamic>> obtenerPorId(String id) async {
    final url = Uri.parse('$baseUrl/api/pacientes/obtener-por-id?id=$id');
    final response = await http.get(url);
    print('Solicitando datos de la persona por ID a: $url');
    print('Respuesta del servidor (obtener por ID): ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['persona'];
      } else {
        throw Exception(data['message'] ?? 'Persona no encontrada');
      }
    } else {
      throw Exception('Error al obtener la persona por ID: ${response.body}');
    }
  }

  // Obtener mensajes
  Future<List<Map<String, String>>> getMessages(String userId) async {
    final url = Uri.parse('$baseUrl/api/mensajes/$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return List<Map<String, String>>.from(json.decode(response.body));
    } else {
      throw Exception('Error al obtener mensajes: ${response.body}');
    }
  }

  // Enviar mensaje
  Future<void> sendMessage(String userId, String message) async {
    final url = Uri.parse('$baseUrl/api/mensajes/enviar');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'to': userId, 'message': message}),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al enviar mensaje: ${response.body}');
    }
  }

  // Eliminar disponibilidad
  Future<Map<String, dynamic>> eliminarDisponibilidad(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/pacientes/eliminar-disponibilidad');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'correo': data['correo'],
        'dia': data['dia'],
        'horario': data['horario'],
      }),
    );
    print('Solicitando eliminar disponibilidad a: $url');
    print('Datos enviados: ${json.encode(data)}');
    print('Respuesta del servidor: ${response.statusCode} - ${response.body}');
    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      return responseBody;
    } else {
      throw Exception(responseBody['error'] ?? 'Error al eliminar la disponibilidad: ${response.body}');
    }
  }

  // Actualizar disponibilidad
  Future<Map<String, dynamic>> actualizarDisponibilidad(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/pacientes/actualizar-disponibilidad');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'correo': data['correo'],
        'diaAntiguo': data['diaAntiguo'],
        'horarioAntiguo': data['horarioAntiguo'],
        'diaNuevo': data['diaNuevo'],
        'horarioNuevo': data['horarioNuevo'],
        'consultorio': data['consultorio'],
      }),
    );
    print('Solicitando actualizar disponibilidad a: $url');
    print('Datos enviados: ${json.encode(data)}');
    print('Respuesta del servidor: ${response.statusCode} - ${response.body}');
    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      return responseBody;
    } else {
      throw Exception(responseBody['error'] ?? 'Error al actualizar la disponibilidad: ${response.body}');
    }
  }

  // Obtener historial médico por correo
  Future<List<dynamic>> getHistorialMedico(String correo) async {
    final url = Uri.parse('$baseUrl/api/historial/obtener-por-correo?correo=$correo');
    final response = await http.get(url);
    print('Solicitando historial médico a: $url');
    print('Respuesta del servidor (historial): ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['historial'] ?? [];
      } else {
        throw Exception(data['error'] ?? 'Error al obtener el historial médico');
      }
    } else {
      throw Exception('Error al obtener el historial médico: ${response.statusCode} - ${response.body}');
    }
  }

  // Guardar una entrada en el historial médico
  Future<Map<String, dynamic>> guardarEntradaHistorial(
      String correoRegistrador, String tipo, String pacienteCorreo, Map<String, dynamic> datos) async {
    final url = Uri.parse('$baseUrl/api/historial/guardar-entrada');
    print('Solicitando guardar entrada en historial a: $url');
    print('Datos enviados: ${json.encode({
      'correo': correoRegistrador,
      'tipo': tipo,
      'pacienteCorreo': pacienteCorreo,
      'datos': datos,
    })}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'correo': correoRegistrador,
        'tipo': tipo,
        'pacienteCorreo': pacienteCorreo,
        'datos': datos,
      }),
    );

    print('Respuesta del servidor (guardar entrada): ${response.statusCode} - ${response.body}');
    final responseBody = json.decode(response.body);

    if (response.statusCode == 200 && responseBody['success'] == true) {
      return responseBody;
    } else {
      // Mejor manejo de errores para casos específicos, como IDs inválidos
      String errorMessage = responseBody['error'] ?? 'Error al guardar la entrada en el historial';
      if (responseBody['error']?.contains('diagnóstico especificado no existe') ?? false) {
        errorMessage = 'El diagnóstico seleccionado no existe en el historial del paciente.';
      } else if (responseBody['error']?.contains('tratamiento especificado no existe') ?? false) {
        errorMessage = 'El tratamiento seleccionado no existe en el historial del paciente.';
      }
      throw Exception(errorMessage);
    }
  }

  // Subir un documento al historial médico
  Future<Map<String, dynamic>> subirDocumento(
      String correoRegistrador, String pacienteCorreo, File file) async {
    final url = Uri.parse('$baseUrl/api/historial/subir-documento');
    final request = http.MultipartRequest('POST', url);
    request.fields['correo'] = correoRegistrador;
    request.fields['pacienteCorreo'] = pacienteCorreo;
    request.files.add(
      await http.MultipartFile.fromPath(
        'documento',
        file.path,
        contentType: MediaType('application', 'pdf'),
      ),
    );
    print('Subiendo documento a: $url');
    print('Archivo: ${file.path}');
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    print('Código de estado al subir documento: ${response.statusCode}');
    print('Respuesta del servidor: $responseBody');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(responseBody);
      if (decoded['success'] == true) {
        return decoded;
      } else {
        throw Exception(decoded['error'] ?? 'Error al subir el documento');
      }
    } else {
      throw Exception('Error al subir el documento: ${response.statusCode} - $responseBody');
    }
  }

  // Subir un resultado de análisis al historial médico
  Future<Map<String, dynamic>> subirResultadoAnalisis(
      String correoRegistrador, String pacienteCorreo, String ordenId, File file) async {
    final url = Uri.parse('$baseUrl/api/historial/subir-resultado-analisis');
    final request = http.MultipartRequest('POST', url);
    request.fields['correo'] = correoRegistrador;
    request.fields['pacienteCorreo'] = pacienteCorreo;
    request.fields['orden_id'] = ordenId;
    request.files.add(
      await http.MultipartFile.fromPath(
        'documento',
        file.path,
        contentType: MediaType('application', 'pdf'),
      ),
    );
    print('Subiendo resultado de análisis a: $url');
    print('Archivo: ${file.path}, Orden ID: $ordenId');
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    print('Código de estado al subir resultado: ${response.statusCode}');
    print('Respuesta del servidor: $responseBody');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(responseBody);
      if (decoded['success'] == true) {
        return decoded;
      } else {
        throw Exception(decoded['error'] ?? 'Error al subir el resultado de análisis');
      }
    } else {
      throw Exception('Error al subir el resultado de análisis: ${response.statusCode} - $responseBody');
    }
  }

  // Descargar un documento del historial médico
  Future<String> descargarDocumento(String historialId, String documentoId) async {
    final url = Uri.parse('$baseUrl/api/historial/descargar-documento/$historialId/$documentoId');
    print('Descargando documento desde: $url');
    final response = await http.get(url);
    print('Código de estado al descargar documento: ${response.statusCode}');
    print('Encabezados de respuesta: ${response.headers}');

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/documento-$documentoId.pdf';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      print('Documento descargado y guardado en: $filePath');
      return filePath;
    } else {
      throw Exception('Error al descargar el documento: ${response.statusCode} - ${response.body}');
    }
  }

  // Generar diagnóstico con IA
  Future<Map<String, dynamic>> generarDiagnostico(String symptomsText) async {
    final url = Uri.parse('$baseUrl/api/historial/generar-diagnostico');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'symptomsText': symptomsText,
      }),
    );
    print('Solicitando diagnóstico a: $url');
    print('Datos enviados: ${json.encode({'symptomsText': symptomsText})}');
    print('Respuesta del servidor (diagnóstico): ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Error al generar diagnóstico: ${response.statusCode} - ${response.body}');
    }
  }

  // Obtener pacientes asignados a un médico
  Future<List<dynamic>> getPacientesAsignados(String medicoId) async {
    final url = Uri.parse('$baseUrl/api/pacientes/obtener-pacientes-asignados?medicoId=$medicoId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['pacientes'] ?? [];
      } else {
        throw Exception(data['error'] ?? 'Error al obtener los pacientes asignados');
      }
    } else {
      throw Exception('Error al obtener los pacientes asignados: ${response.body}');
    }
  }

  // Obtener lista de pacientes
  Future<List<dynamic>> getPacientes() async {
    final url = Uri.parse('$baseUrl/api/pacientes?rol=Paciente');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener pacientes: ${response.body}');
    }
  }

  // Obtener notificaciones
  Future<List<dynamic>> getNotificaciones() async {
    final url = Uri.parse('$baseUrl/api/notificaciones');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener notificaciones: ${response.body}');
    }
  }

  // Registrar alarma
  Future<void> registrarAlarma(String correo, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/alarmas');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'correo': correo, ...data}),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al registrar alarma: ${response.body}');
    }
  }

  // Actualizar datos de persona (para Configuración)
  Future<Map<String, dynamic>> updatePersona(String correo, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/pacientes/update');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'correo': correo, ...data}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al actualizar persona: ${response.body}');
    }
  }

  // Otorgar permiso a otro médico para ver el historial
  Future<Map<String, dynamic>> otorgarPermisoHistorial(String pacienteCorreo, String medicoCorreo) async {
    final url = Uri.parse('$baseUrl/api/pacientes/otorgar-permiso');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'pacienteCorreo': pacienteCorreo,
        'medicoCorreo': medicoCorreo,
      }),
    );
    print('Solicitando otorgar permiso a: $url');
    print('Datos enviados: ${json.encode({
      'pacienteCorreo': pacienteCorreo,
      'medicoCorreo': medicoCorreo,
    })}');
    print('Respuesta del servidor (otorgar permiso): ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Error al otorgar permiso: ${response.body}');
    }
  }
}