import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wolfmobile/API/APIService.dart';
import 'package:wolfmobile/screen/home_screen.dart';
import 'package:location/location.dart';

class InsertScreen extends StatefulWidget {
  @override
  _InsertScreenState createState() => _InsertScreenState();
}

class _InsertScreenState extends State<InsertScreen> {
  final APIService _apiService = APIService();
  List<Map<String, String>> _products = [];
  String? _selectedDescription;
  String _productId = '';
  String _type = '';
  String _value = '';
  String _latitude = '';
  String _longitude = '';
  
  Location _location = Location();
  String _statusMessage = '';
  Color _statusMessageColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _fetchProductData();
  }

  Future<void> _fetchProductData() async {
    try {
      final products = await _apiService.getProducts();
      setState(() {
        _products = products.map<Map<String, String>>((product) {
          return {
            "productid": product['productid'],
            "description": product['description'],
            "type": product['type'],
          };
        }).toList();

        if (_products.isNotEmpty) {
          _selectedDescription = _products[0]['description'];
          _updateFields(_selectedDescription!);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar os produtos: $e')),
      );
    }
  }

  void _updateFields(String description) {
    final selectedProduct =
        _products.firstWhere((product) => product['description'] == description);
    setState(() {
      _productId = selectedProduct['productid']!;
      _type = selectedProduct['type']!;
    });
  }

  Future<void> _checkIn() async {
    // Verificar permissão de localização
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Serviço de localização não disponível.')),
        );
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de localização não concedida.')),
        );
        return;
      }
    }

    // Obter localização
    LocationData locationData = await _location.getLocation();
    setState(() {
      _latitude = locationData.latitude.toString();
      _longitude = locationData.longitude.toString();
    });
  }

  void _clearFields() {
  setState(() {
    // Limpar os campos
    _value = '';
    _latitude = '';
    _longitude = '';
  });
}

 Future<void> _sendData() async {
  try {
    // Chamar o método de inserção
    final response = await _apiService.postInserir(
      _productId,
      _value,
      _latitude,
      _longitude,
      _type
    );

    // Verificar a resposta
    final responseBody = jsonDecode(response.body);
    final successMessage = responseBody['success']; // Mensagem de sucesso
    final responseCode = responseBody['response']; // Código de resposta

    if (successMessage == 'Dados inseridos com sucesso.' && responseCode.trim() == 'OK') {
      // Se a resposta for bem-sucedida
      setState(() {
        _statusMessage = 'Inserido com sucesso';
        _statusMessageColor = Colors.green;
      });

      _value = '';
      _latitude = '';
      _longitude = '';
      _selectedDescription = _products.isNotEmpty ? _products[0]['description'] : null;
      if (_selectedDescription != null) {
        _updateFields(_selectedDescription!);
      }

      // Exibir a mensagem de sucesso por 3 segundos
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inserido com sucesso'),
          duration: Duration(seconds: 3), // Define o tempo de exibição
        ),
      );

      // Limpar a mensagem após 3 segundos
      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        _statusMessage = ''; // Limpar mensagem após o tempo
      });
    } else {
      // Caso a resposta não seja um sucesso esperado
      setState(() {
        _statusMessage = 'Erro ao inserir';
        _statusMessageColor = Colors.red;
      });
    }
  } catch (e) {
    // Erro no processo
    setState(() {
      _statusMessage = 'Erro ao inserir: $e';
      _statusMessageColor = Colors.red;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Inserir',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description Dropdown
            DropdownButtonFormField<String>(
              value: _selectedDescription,
              items: _products
                  .map((product) => DropdownMenuItem<String>(
                        value: product['description'],
                        child: Text(product['description']!),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  _updateFields(value);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
              ),
              isExpanded: true,
            ),
            const SizedBox(height: 16),

            // Value Field
            TextField(
              decoration: const InputDecoration(
                labelText: 'Valor',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _value = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Latitude Field
            TextField(
              decoration: const InputDecoration(
                labelText: 'Latitude',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              controller: TextEditingController(text: _latitude),
            ),
            const SizedBox(height: 16),

            // Longitude Field
            TextField(
              decoration: const InputDecoration(
                labelText: 'Longitude',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              controller: TextEditingController(text: _longitude),
            ),
            const SizedBox(height: 16),

            // Check-In Button
            ElevatedButton(
              onPressed: _checkIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('Check-In'),
            ),
            const SizedBox(height: 16),

            // Enviar Button
            ElevatedButton(
              onPressed: _sendData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('Enviar'),
            ),
            const SizedBox(height: 16),

            // Status Message
            Text(
              _statusMessage,
              style: TextStyle(
                color: _statusMessageColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}