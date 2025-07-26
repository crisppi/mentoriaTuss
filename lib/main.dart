import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

void main() {
  runApp(MentoriaApp());
}

class MentoriaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  void _login() async {
    final email = emailController.text.trim();
    final senha = senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Preencha todos os campos.")),
      );
      return;
    }
    print("Enviando email=$email senha=$senha");

    final url = Uri.parse('http://192.168.6.223/mentoriaTuss/login.php');

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Conectando ao servidor...")),
      );

      final response = await http.post(

        url,
        body: {
          'email': email,
          'senha': senha,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Conectado com o servidor.")),
        );

        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Conectado com o banco de dados.")),
          );

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PesquisaTussScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['mensagem'] ?? "Credenciais inválidas.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao se conectar ao servidor.")),
        );
      }
    } catch (e) {
      print("Erro de rede: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro de rede: $e")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.purple.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Login",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "E-mail",
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.black,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: senhaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Senha",
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.black,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text("Login", style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PesquisaTussScreen extends StatefulWidget {
  @override
  _PesquisaTussScreenState createState() => _PesquisaTussScreenState();
}

class _PesquisaTussScreenState extends State<PesquisaTussScreen> {
  List<dynamic> dados = [];
  List<dynamic> resultados = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    try {
      String jsonString = await rootBundle.loadString('assets/tabela_mentoria.json');
      setState(() {
        dados = json.decode(jsonString);
        resultados = List.from(dados);
      });
    } catch (e) {
      print("Erro ao carregar o JSON: $e");
    }
  }

  void filtrarPesquisa(String query) {
    setState(() {
      resultados = dados.where((item) {
        return item['tuss'].toString().toLowerCase().contains(query.toLowerCase()) ||
            (item['procedimento'] != null && item['procedimento'].toString().toLowerCase().contains(query.toLowerCase()));
      }).toList();
    });
  }

  void _navegarParaDetalhes() {
    if (resultados.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetalhesTussScreen(dados: resultados[0]), // Navega para o primeiro item da lista
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nenhum item encontrado para exibir detalhes!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pesquisa Tuss - Descrição Cirúrgica"),
        backgroundColor: Colors.transparent, // AppBar transparente
        elevation: 0, // Remove a sombra do AppBar
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.purple.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Pesquisar",
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                style: TextStyle(color: Colors.white),
                onChanged: filtrarPesquisa,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: resultados.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.black.withOpacity(0.5),
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(
                        "${resultados[index]['tuss']} - ${resultados[index]['nome_procedimento'] ?? 'N/A'}",
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalhesTussScreen(dados: resultados[index]),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navegarParaDetalhes,
        child: Icon(Icons.arrow_forward),
        tooltip: 'Ver detalhes',
      ),
    );
  }
}

class DetalhesTussScreen extends StatelessWidget {
  final Map<String, dynamic> dados;

  DetalhesTussScreen({required this.dados});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalhes da Descrição Cirúrgica"),
        backgroundColor: Colors.transparent, // AppBar transparente
        elevation: 0, // Remove a sombra do AppBar
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.purple.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("TUSS: ${dados['tuss']}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 10),
              Text("Especialidade: ${dados['especialidade']}", style: TextStyle(fontSize: 18, color: Colors.white)),
              SizedBox(height: 10),
              Text("Descrição Cirúrgica:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 5),
              Container(
                height: 300, // Altura aumentada
                child: TextField(
                  controller: TextEditingController(text: dados['descricao_cirurgica']),
                  maxLines: null, // Permite múltiplas linhas
                  readOnly: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text("Informações Adicionais:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 5),
              Container(
                height: 300, // Altura
                child: TextField(
                  controller: TextEditingController(text: dados['informacoes_adicionais']),
                  maxLines: null, // Permite múltiplas linhas
                  readOnly: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}