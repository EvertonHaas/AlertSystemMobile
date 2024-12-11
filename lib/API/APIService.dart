import 'dart:convert';
import 'package:http/http.dart' as http;

class APIService {
  final String _baseUrl = "http://177.44.248.15/api";

  Future<http.Response> login(String login, String senha) async {
    final url = Uri.parse("$_baseUrl/login");

    final body = jsonEncode({
      "email": login,
      "senha": senha,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: body,
      );

      return response;
    } catch (e) {
      throw Exception("Falha ao realizar login: $e");
    }
  }

  Future<List<dynamic>> getProducts() async {
    final url = Uri.parse("$_baseUrl/products");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception("Falha ao carregar produtos: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Falha ao carregar produtos: $e");
    }
  }
  dynamic parseValue(String value, String type) {
    switch (type) {
      case 'TEXT':
        return value; // Retorna como string
      case 'LOGIC':
        return value.toLowerCase() == 'true'; // Converte para boolean
      case 'INT':
        return int.parse(value); // Converte para inteiro
      case 'FLOAT':
        return double.parse(value); // Converte para ponto flutuante
      default:
        throw ArgumentError('Tipo não suportado: $type');
    }
  }

  Future<http.Response> postInserir(
      String productid,
      String value,
      String latitude,
      String longitude,
      String type,
      ) async {
    final url = Uri.parse("$_baseUrl/insert");

    // Função para converter o valor com base no tipo
    dynamic parseValue(String value, String type) {
      switch (type) {
        case 'TEXT':
          return value; // Retorna como string
        case 'LOGIC':
          return value.toLowerCase() == 'true'; // Converte para boolean
        case 'INT':
          return int.parse(value); // Converte para inteiro
        case 'FLOAT':
          return double.parse(value); // Converte para ponto flutuante
        default:
          throw ArgumentError('Tipo não suportado: $type');
      }
    }

    // Montando o corpo da requisição
    final body = jsonEncode({
      "productid": productid,
      "value": parseValue(value, type),
      "latitude": double.parse(latitude),
      "longitude": double.parse(longitude),
    });

    try {
      // Logando os parâmetros de entrada
      print('Iniciando a chamada POST para \$_baseUrl/insert');
      print('Parâmetros enviados: productid=$productid, value=$value, latitude=$latitude, longitude=$longitude, type=$type');

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: body,
      );

      // Logando a resposta
      print('Resposta da chamada POST: ${response.statusCode}');
      print('Resposta: ${response.body}');

      // Verificando o status da resposta
      if (response.statusCode == 201) {
        print('Inserção bem-sucedida.');
      } else {
        print('Erro na inserção. Código de status: ${response.statusCode}');
        print('Resposta do servidor: ${response.body}');
      }

      return response;
    } catch (e, stacktrace) {
      // Logando erros e o stacktrace em caso de falha
      print('Erro ao realizar a chamada POST: $e');
      print('Stacktrace: $stacktrace');
      throw Exception("Falha ao inserir dados: $e");
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    final url = Uri.parse("$_baseUrl/stats");

    try {
      print('Iniciando a chamada GET para $_baseUrl/stats');

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
        },
      );

      print('Resposta da chamada GET: ${response.statusCode}');
      print('Resposta: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception("Falha ao obter estatísticas: ${response.statusCode}");
      }
    } catch (e, stacktrace) {
      print('Erro ao realizar a chamada GET: $e');
      print('Stacktrace: $stacktrace');
      throw Exception("Falha ao obter estatísticas: $e");
    }
  }
  
}