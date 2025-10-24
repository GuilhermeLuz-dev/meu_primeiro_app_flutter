import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Analisador de texto",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        body: Column( // Use Column para empilhar o conteúdo e o rodapé
          children: [
            Expanded( // Expanded para que o conteúdo rolável ocupe o espaço restante
              child: SingleChildScrollView(
                child: const InputExample(),
              ),
            ),
            SafeArea( // Garante que o rodapé não seja cortado
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                color: Colors.blue.shade800,
                child: const Text(
                  "Produzido por Guilherme Luz Rocha",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class InputExample extends StatefulWidget {
  const InputExample({super.key});

  @override
  State<InputExample> createState() => _InputExampleState();
}

class _InputExampleState extends State<InputExample> {
  final TextEditingController _controller = TextEditingController();

  //Declarando variáveis
  String valorDigitado = "";
  int qntCaracteres = 0;
  int qntCaracteresSemEspaco = 0;
  String textoSemEspaco = '';
  int qntTotalPalavras = 0;
  int qntPalavrasRelevantes = 0;
  double tempLeitura = 0.0;
  int tempMedioLeituraMin = 200;
  String resultado = '';
  bool remover = false;

  final List<String> palavrasLigacao = [
    "a", "o", "e", "de", "da", "do", "das", "dos", "em", "no", "na",
    "nas", "nos", "um", "uma", "uns", "umas", "com", "sem", "por",
    "para", "ao", "à", "se",
  ];

  String removerAcentos(String texto) {
    return texto
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c')
        .replaceAll('ñ', 'n')
        .replaceAll('Á', 'A')
        .replaceAll('À', 'A')
        .replaceAll('Ã', 'A')
        .replaceAll('Â', 'A')
        .replaceAll('Ä', 'A')
        .replaceAll('É', 'E')
        .replaceAll('È', 'E')
        .replaceAll('Ê', 'E')
        .replaceAll('Ë', 'E')
        .replaceAll('Í', 'I')
        .replaceAll('Ì', 'I')
        .replaceAll('Î', 'I')
        .replaceAll('Ï', 'I')
        .replaceAll('Ó', 'O')
        .replaceAll('Ò', 'O')
        .replaceAll('Õ', 'O')
        .replaceAll('Ô', 'O')
        .replaceAll('Ö', 'O')
        .replaceAll('Ú', 'U')
        .replaceAll('Ù', 'U')
        .replaceAll('Û', 'U')
        .replaceAll('Ü', 'U')
        .replaceAll('Ç', 'C')
        .replaceAll('Ñ', 'N');
  }

  void _atualizarValores() {
    setState(() {
      valorDigitado = _controller.text;
      if(valorDigitado.trim().isEmpty){
        const snackBar = SnackBar(
          content: Text(
            'A caixa de texto está vazia. Por favor, insira um texto.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red, // Cor para indicar alerta/erro
          duration: Duration(seconds: 3),
        );

        // 2. Exibe o SnackBar
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      String textoProcessado = removerAcentos(valorDigitado).trim();

      qntCaracteres = textoProcessado.length;
      textoSemEspaco = textoProcessado.replaceAll(RegExp(r'\s+'), '');
      qntCaracteresSemEspaco = textoSemEspaco.length;

      if (textoProcessado.isEmpty) {
        qntTotalPalavras = 0;
        qntPalavrasRelevantes = 0;
        tempLeitura = 0.0;
        resultado = '';
      } else {
        List<String> palavras = textoProcessado.split(RegExp(r'\s+'));
        qntTotalPalavras = palavras.length;

        String textoLimpo = textoProcessado.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
        List<String> palavrasRelevantes = textoLimpo
            .split(RegExp(r'\s+'))
            .where((palavra) => palavra.isNotEmpty && !palavrasLigacao.contains(palavra))
            .toList();
        qntPalavrasRelevantes = palavrasRelevantes.length;

        tempLeitura = qntTotalPalavras / tempMedioLeituraMin;

        Map<String, int> frequencia = {};
        for (var palavra in palavrasRelevantes) {
          frequencia[palavra] = (frequencia[palavra] ?? 0) + 1;
        }

        List<MapEntry<String, int>> palavrasOrdenadas = frequencia.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        resultado = palavrasOrdenadas.take(10).map((e) => "${e.key}: ${e.value}").join("\n");
      }
    });
  }

  void _limparCaixaTexto(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // 1. TÍTULO
          title: const Text('Excluir Item'),

          // 2. CONTEÚDO (MENSAGEM)
          content: const Text('Você realmente deseja excluir este item?'),

          // 3. AÇÕES (BOTÕES)
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                // Fecha o diálogo e retorna 'false'
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // Fecha o diálogo e retorna 'true'
                Navigator.of(context).pop(true);
                // Lógica para excluir o item viria aqui ou no 'then' (veja abaixo)
                setState(() {
                  _controller.text = "";
                });
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _controller,
              maxLines: 20,
              minLines: 5,
              decoration: InputDecoration(
                labelText: 'Digite ou cole seu texto aqui...',
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _atualizarValores,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              elevation: 5,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size(300, 50),
            ),
            child: const Text(
              'Verificar texto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _limparCaixaTexto,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              elevation: 5,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size(300, 50),
            ),
            child: const Text(
              'Limpar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Text(
                "Relatório:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Caracteres (com espaço):", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      Text("$qntCaracteres", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white))
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Caracteres sem espaço:", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      Text("$qntCaracteresSemEspaco", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white))
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Palavras relevantes:",  textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      Text("$qntPalavrasRelevantes",  textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white))
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Tempo de leitura:',  textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      Text('${tempLeitura.toStringAsFixed(2)} min',  textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(6),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text("Palavras mais frequentes:", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    const SizedBox(height: 5),
                    Text(
                      resultado,
                      style: const TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}