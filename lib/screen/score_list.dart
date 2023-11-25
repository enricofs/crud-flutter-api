import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_enrico_api/screen/add_page.dart';
import 'package:http/http.dart' as http;

class ScoreListPage extends StatefulWidget {
  const ScoreListPage({super.key});

  @override
  State<ScoreListPage> createState() => _ScoreListPageState();
}

class _ScoreListPageState extends State<ScoreListPage> {
  bool isLoading = true;
  List scores = [];

  @override
  void initState() {
    super.initState();
    fetchScores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.blueAccent,
        title: const Center(
          child: Text(
            'Lista de Pontuações',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              shadows: [Shadow(color: Colors.transparent)],
              fontSize: 25,
            ),
          ),
        ),
      ),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fetchScores,
          color: Colors.black,
          child: Visibility(
            visible: scores.isNotEmpty,
            replacement: Center(
              child: Text(
                'Nenhuma Pontuação',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            child: ListView.builder(
              itemCount: scores.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                final score = scores[index] as Map;
                final id = score['id'] as int;
                return Card(
                  color: Colors.blue[50],
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade400,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    textColor: Colors.black,
                    title: Text(
                      score['nome'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      'ID: ${score['id']} | Placar: ${score['placar']}',
                      style: const TextStyle(color: Colors.black45),
                    ),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') {
                          //open edit page
                          navigateToEditPage(score);
                        } else if (value == 'delete') {
                          //open delete page
                          deleteById(id);
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Editar'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Excluir'),
                          ),
                        ];
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.black,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        label: const Text(
          'Adicionar Pontuação',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 1,
      ),
    );
  }

  Future<void> navigateToEditPage(Map score) async {
    final route = MaterialPageRoute(
      builder: (context) => AddPage(score: score),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchScores();
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => const AddPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchScores();
  }

  Future<void> deleteById(int id) async {
    final url = 'https://enricosantos.pythonanywhere.com/score/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      //remove the score
      final filtered = scores.where((element) => element['id'] != id).toList();
      setState(() {
        scores = filtered;
      });
      showSuccessMessage('Excluído com sucesso');
    } else {
      //Show error
      showErrorMessage('Não foi possível excluir');
    }
  }

  Future<void> fetchScores() async {
    const url = 'https://enricosantos.pythonanywhere.com/score/list';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List;
      setState(() {
        scores = json;
      });
    } else {
      //error
    }
    setState(() {
      isLoading = false;
    });
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
