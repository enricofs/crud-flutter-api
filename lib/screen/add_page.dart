import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddPage extends StatefulWidget {
  const AddPage({super.key, this.score});
  final Map? score;

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController scoreController = TextEditingController();

  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    final score = widget.score;
    if (score != null) {
      isEdit = true;
      final name = score['nome'];
      final scoreValue = score['placar'];
      nameController.text = name;
      scoreController.text = scoreValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          isEdit ? 'Editar Pontuação' : 'Adicionar Pontuação',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'Nome',
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: scoreController,
            decoration: const InputDecoration(hintText: 'Placar'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ], // Adicionado esta linha para aceitar apenas números
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: isEdit ? updateScore : submitScore,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                isEdit ? 'Atualizar' : 'Enviar',
                style: TextStyle(fontSize: 20),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> updateScore() async {
    final score = widget.score;
    if (score == null) {
      print("Dados de pontuação ausentes");
      return;
    }
    final name = nameController.text;
    final id = score['id'];
    final scoreValue = int.parse(scoreController.text);
    final body = {
      "nome": name,
      "placar": scoreValue,
    };

    final url = 'https://enricosantos.pythonanywhere.com/score/$id';
    final uri = Uri.parse(url);
    final response = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      showSuccessMessage('Atualizado com sucesso');
    } else {
      showErrorMessage('Falha na atualização');
      if (kDebugMode) {
        print(response.body);
      }
    }
  }

  Future<void> submitScore() async {
    final name = nameController.text;
    final scoreValue = int.parse(scoreController.text);
    final body = {
      "nome": name,
      "placar": scoreValue,
    };

    const url = 'https://enricosantos.pythonanywhere.com/score';
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      nameController.text = '';
      scoreController.text = '';
      showSuccessMessage('Criado com sucesso');
    } else {
      showErrorMessage('Falha na criação');
      if (kDebugMode) {
        print(response.body);
      }
    }
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
      content: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
      backgroundColor: Colors.green[300],
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
      backgroundColor: Colors.red[400],
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
