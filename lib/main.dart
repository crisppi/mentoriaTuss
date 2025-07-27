import 'package:flutter/material.dart';
import 'dart:convert';
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

    final url = Uri.parse('http://192.168.15.93/mentoriaPhp/login.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
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

  Widget _buildTextField(TextEditingController controller, String label, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.black.withOpacity(0.4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade900, Colors.deepPurple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.monitor_heart , size: 65, color: Colors.white),
                SizedBox(height: 22),
                Text(
                  "Acessoria TUSS",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 32),
                _buildTextField(emailController, "E-mail", false),
                SizedBox(height: 16),
                _buildTextField(senhaController, "Senha", true),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                  ),
                  child: Text("Entrar", style: TextStyle(fontSize: 18, color: Colors.white)),
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
    final url = Uri.parse('http://192.168.15.93/mentoriaPhp/get_procedimentos.php');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          dados = json.decode(response.body);
          resultados = List.from(dados);
        });
      } else {
        print("Erro ao buscar dados: ${response.statusCode}");
      }
    } catch (e) {
      print("Erro ao carregar do servidor: $e");
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