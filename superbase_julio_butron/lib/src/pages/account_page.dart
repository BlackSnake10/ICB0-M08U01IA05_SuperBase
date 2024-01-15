// ignore_for_file: use_build_context_synchronously, unused_local_variable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:superbase_julio_butron/main.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _tituloController = TextEditingController();
  final _autorController = TextEditingController();
  final _generoController = TextEditingController();
  final _emailController = TextEditingController();
  final _nombreController = TextEditingController();

  List<Map<String, dynamic>> allLibros = [];

  var _loading = true;

  Future<void> _getLibros() async {
    setState(() {
      _loading = true;
    });

    try {
      final data = await supabase.from('libro').select('id, titulo');
      allLibros = List<Map<String, dynamic>>.from(data as List);
    } on PostgrestException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } catch (error) {
      SnackBar(
        content: const Text('Unexpected error occurred'),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _addLibro() async {
    if (_tituloController.text.isNotEmpty && _autorController.text.isNotEmpty) {
      try {
        final response = await supabase.from('libro').insert({
          'titulo': _tituloController.text,
          'autor': _autorController.text,
          'genero': _generoController.text,
        });

        await _getLibros();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Libro añadido con éxito!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al añadir el libro: $error')),
        );
      }
    }
  }

  Future<void> _addLector() async {
    if (_emailController.text.isNotEmpty && _nombreController.text.isNotEmpty) {
      try {
        final response = await supabase.from('lector').insert({
          'id': supabase.auth.currentUser!.id,
          'email': _emailController.text,
          'nombre': _nombreController.text,
          'updated_at': DateTime.now().toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lector añadido con éxito!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al añadir el lector: $error')),
        );
      }
    }
  }

  Future<void> _deleteLibro(int libroId) async {
    try {
      final response = await supabase.from('libro').delete().eq('id', libroId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Libro eliminado con éxito!')),
      );

      await _getLibros();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el libro: $error')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getLibros();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    _generoController.dispose();
    _emailController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Libros')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _tituloController,
                      decoration: const InputDecoration(labelText: 'Título'),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _autorController,
                      decoration: const InputDecoration(labelText: 'Autor'),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _generoController,
                      decoration: const InputDecoration(labelText: 'Género'),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _emailController,
                      decoration:
                          const InputDecoration(labelText: 'Email del Lector'),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _nombreController,
                      decoration:
                          const InputDecoration(labelText: 'Nombre del Lector'),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: _loading
                          ? null
                          : () {
                              _addLibro();
                              _addLector();
                            },
                      child: Text(
                          _loading ? 'Guardando...' : 'Añadir Libro y Lector'),
                    ),
                    const SizedBox(height: 18),
                    ...allLibros.map((libroItem) {
                      final int libroId = libroItem['id'];
                      return Card(
                        child: ListTile(
                          title: Text(libroItem['titulo']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteLibro(libroId),
                            color: Theme.of(context).errorColor,
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () async {
                        await supabase.auth.signOut();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
