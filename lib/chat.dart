import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String correo;
  final String tipoUsuario;
  final String? medicoAsignado;
  final String? pacienteCorreo;

  const ChatPage({
    required this.correo,
    required this.tipoUsuario,
    this.medicoAsignado,
    this.pacienteCorreo,
    Key? key,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _usuarioId;
  String? _otroUsuarioId;
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
            if (widget.medicoAsignado != null) {
              setState(() {
                _otroUsuarioId = widget.medicoAsignado;
              });
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
              throw Exception('No tienes un médico asignado. Por favor, asigna un médico desde la pantalla principal.');
            }
          } else if (widget.tipoUsuario == 'medico') {
            if (widget.pacienteCorreo != null) {
              final pacienteResponse = await http.get(
                Uri.parse('http://10.0.2.2:3000/api/pacientes/obtener-por-correo?correo=${widget.pacienteCorreo}'),
              );
              if (pacienteResponse.statusCode == 200) {
                final pacienteData = jsonDecode(pacienteResponse.body);
                if (pacienteData['success'] == true) {
                  setState(() {
                    _otroUsuarioId = pacienteData['persona']['_id'];
                    _otroUsuarioNombre = pacienteData['persona']['nombre_completo'];
                  });
                  await _fetchMessages();
                } else {
                  throw Exception('No se pudo obtener el paciente seleccionado');
                }
              } else {
                throw Exception('Error al obtener el paciente seleccionado: ${pacienteResponse.statusCode}');
              }
            } else {
              throw Exception('No se ha seleccionado un paciente para chatear');
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
      String pacienteId = widget.tipoUsuario == 'paciente' ? _usuarioId! : _otroUsuarioId!;
      String medicoId = widget.tipoUsuario == 'paciente' ? _otroUsuarioId! : _usuarioId!;

      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/mensajes/obtener?pacienteId=$pacienteId&medicoId=$medicoId'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _messages = data['mensajes'] ?? [];
          });
          _scrollToBottom();
        } else {
          throw Exception('No se pudieron cargar los mensajes: ${data['error'] ?? 'Error desconocido'}');
        }
      } else {
        throw Exception('Error al cargar los mensajes: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _messages = [];
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
          await _fetchMessages();
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.tipoUsuario == 'paciente'
              ? "Chat con ${_otroUsuarioNombre ?? 'Médico'}"
              : "Chat con ${_otroUsuarioNombre ?? 'Paciente'}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.teal))
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)))
                : _buildChat(),
      ),
    );
  }

  Widget _buildChat() {
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Text(
                    "No hay mensajes",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final mensaje = _messages[index];
                    final esEnviadoPorUsuario = mensaje['emisor'] == _usuarioId;
                    return Align(
                      alignment: esEnviadoPorUsuario ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: esEnviadoPorUsuario ? Colors.teal.shade400 : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                              esEnviadoPorUsuario ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              mensaje['contenido'] ?? 'Mensaje vacío',
                              style: TextStyle(
                                fontSize: 16,
                                color: esEnviadoPorUsuario ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              mensaje['fecha'] != null
                                  ? DateFormat('HH:mm').format(DateTime.parse(mensaje['fecha']))
                                  : 'Fecha no disponible',
                              style: TextStyle(
                                fontSize: 12,
                                color: esEnviadoPorUsuario ? Colors.white70 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "Escribe un mensaje...",
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.teal,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}