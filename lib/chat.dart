import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String correo;
  final String tipoUsuario;
  final String? medicoAsignado;

  const ChatPage({
    required this.correo,
    required this.tipoUsuario,
    this.medicoAsignado,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  List<dynamic> _messages = []; // Aseguramos que siempre sea una lista
  List<dynamic> _pacientesAsignados = []; // Aseguramos que siempre sea una lista
  bool _isLoading = false;
  String? _errorMessage;
  String? _usuarioId;
  String? _otroUsuarioId; // Será el médico asignado (para pacientes) o el paciente seleccionado (para médicos)
  String? _otroUsuarioNombre;

  @override
  void initState() {
    super.initState();
    _fetchUsuarioData();
  }

  Future<void> _fetchUsuarioData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Obtener el ID del usuario actual
      final usuarioResponse = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/pacientes/obtener-por-correo?correo=${widget.correo}'),
      );
      if (usuarioResponse.statusCode == 200) {
        final usuarioData = jsonDecode(usuarioResponse.body);
        if (usuarioData['success'] == true) {
          setState(() {
            _usuarioId = usuarioData['persona']['_id'];
          });

          if (widget.tipoUsuario == 'paciente') {
            // Para pacientes: verificar si tiene un médico asignado
            if (widget.medicoAsignado != null) {
              setState(() {
                _otroUsuarioId = widget.medicoAsignado;
              });
              // Obtener el nombre del médico
              final medicoResponse = await http.get(
                Uri.parse('http://10.0.2.2:3000/api/pacientes/obtener-por-id?id=$_otroUsuarioId'),
              );
              if (medicoResponse.statusCode == 200) {
                final medicoData = jsonDecode(medicoResponse.body);
                if (medicoData['success'] == true) {
                  setState(() {
                    _otroUsuarioNombre = medicoData['persona']['nombre_completo'];
                  });
                } else {
                  throw Exception('No se pudo obtener el nombre del médico');
                }
              } else {
                throw Exception('Error al obtener el nombre del médico: ${medicoResponse.statusCode}');
              }
              await _fetchMessages();
            } else {
              // Si el paciente no tiene médico asignado, mostrar un mensaje
              throw Exception('No tienes un médico asignado. Por favor, asigna un médico desde la pantalla principal.');
            }
          } else if (widget.tipoUsuario == 'medico') {
            // Para médicos: obtener la lista de pacientes asignados
            final pacientesResponse = await http.get(
              Uri.parse('http://10.0.2.2:3000/api/pacientes/obtener-pacientes-asignados?medicoId=$_usuarioId'),
            );
            if (pacientesResponse.statusCode == 200) {
              final pacientesData = jsonDecode(pacientesResponse.body);
              if (pacientesData['success'] == true) {
                setState(() {
                  _pacientesAsignados = pacientesData['pacientes'] ?? [];
                });
              } else {
                throw Exception('No se pudieron cargar los pacientes asignados');
              }
            } else {
              throw Exception('Error al cargar los pacientes asignados: ${pacientesResponse.statusCode}');
            }
          }
        } else {
          throw Exception('Usuario no encontrado: ${usuarioData['message'] ?? 'Error desconocido'}');
        }
      } else {
        throw Exception('Error al obtener el ID del usuario: ${usuarioResponse.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMessages() async {
    if (_usuarioId == null || _otroUsuarioId == null) return;

    try {
      // Determinar quién es el paciente y quién es el médico
      String pacienteId = widget.tipoUsuario == 'paciente' ? _usuarioId! : _otroUsuarioId!;
      String medicoId = widget.tipoUsuario == 'paciente' ? _otroUsuarioId! : _usuarioId!;

      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/mensajes/obtener?pacienteId=$pacienteId&medicoId=$medicoId'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _messages = data['mensajes'] ?? []; // Aseguramos que _messages sea una lista
          });
        } else {
          throw Exception('No se pudieron cargar los mensajes: ${data['error'] ?? 'Error desconocido'}');
        }
      } else {
        throw Exception('Error al cargar los mensajes: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _messages = []; // En caso de error, aseguramos que _messages sea una lista vacía
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_usuarioId == null || _otroUsuarioId == null || _messageController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/mensajes/enviar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'emisorId': _usuarioId,
          'receptorId': _otroUsuarioId,
          'contenido': _messageController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _messageController.clear();
          await _fetchMessages(); // Actualizar la lista de mensajes
        } else {
          throw Exception('Error al enviar el mensaje: ${data['error'] ?? 'Error desconocido'}');
        }
      } else {
        throw Exception('Error al enviar el mensaje: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _seleccionarPaciente(String pacienteId, String pacienteNombre) {
    setState(() {
      _otroUsuarioId = pacienteId;
      _otroUsuarioNombre = pacienteNombre;
      _messages = []; // Limpiar mensajes anteriores, aseguramos que sea una lista vacía
    });
    _fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tipoUsuario == 'paciente'
            ? "Chat con ${_otroUsuarioNombre ?? 'Médico'}"
            : "Chat con Paciente"),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red)))
              : widget.tipoUsuario == 'medico' && _otroUsuarioId == null
                  ? _buildPacienteSelector()
                  : _buildChat(),
    );
  }

  Widget _buildPacienteSelector() {
    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: _pacientesAsignados.length,
      itemBuilder: (context, index) {
        final paciente = _pacientesAsignados[index];
        return ListTile(
          title: Text(paciente['nombre_completo'] ?? 'Sin nombre'),
          subtitle: Text(paciente['correo'] ?? 'Sin correo'),
          onTap: () => _seleccionarPaciente(paciente['_id'], paciente['nombre_completo'] ?? 'Sin nombre'),
        );
      },
    );
  }

  Widget _buildChat() {
    return Column(
      children: [
        Expanded(
          child: (_messages.isEmpty) // Verificamos directamente, ya que _messages nunca será null
              ? Center(child: Text("No hay mensajes"))
              : ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final mensaje = _messages[index];
                    final esEnviadoPorUsuario = mensaje['emisor'] == _usuarioId;
                    return Align(
                      alignment: esEnviadoPorUsuario ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: esEnviadoPorUsuario ? Colors.teal.shade100 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: esEnviadoPorUsuario ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              mensaje['contenido'] ?? 'Mensaje vacío',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 5),
                            Text(
                              mensaje['fecha'] != null
                                  ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(mensaje['fecha']))
                                  : 'Fecha no disponible',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "Escribe un mensaje...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.send, color: Colors.teal),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}