// Exemplo prático de tipagem em Dart
// Sistema de gerenciamento de produtos

// 1. Enums para tipos específicos
enum Categoria { eletronicos, vestuario, alimentos, livros }

enum StatusProduto { disponivel, esgotado, preVenda }

// 2. Classes com tipagem forte
class Avaliacao {
  final double pontuacao;
  final int totalReviews;
  
  Avaliacao(this.pontuacao, this.totalReviews);
  
  @override
  String toString() => '$pontuacao/5 ($totalReviews reviews)';
}

class Produto {
  final String id;
  final String nome;
  double preco;
  StatusProduto status;
  final Categoria categoria;
  List<String> caracteristicas;
  Avaliacao? avaliacao;  // Nullable - pode não ter avaliação
  
  Produto({
    required this.id,
    required this.nome,
    required this.preco,
    required this.categoria,
    this.status = StatusProduto.disponivel,
    this.caracteristicas = const [],
    this.avaliacao,
  });
  
  // Método que retorna um Map tipado
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'preco': preco,
      'status': status.toString(),
      'categoria': categoria.toString(),
      'caracteristicas': caracteristicas,
      'avaliacao': avaliacao != null 
          ? {'pontuacao': avaliacao!.pontuacao, 'total': avaliacao!.totalReviews} 
          : null,
    };
  }
  
  // Factory constructor que cria um produto a partir de um Map
  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      id: map['id'],
      nome: map['nome'],
      preco: map['preco'],
      categoria: _parseCategoriaFromString(map['categoria']),
      status: _parseStatusFromString(map['status']),
      caracteristicas: List<String>.from(map['caracteristicas'] ?? []),
      avaliacao: map['avaliacao'] != null 
          ? Avaliacao(
              map['avaliacao']['pontuacao'], 
              map['avaliacao']['total']
            ) 
          : null,
    );
  }
  
  // Métodos auxiliares para converter strings em enums
  static Categoria _parseCategoriaFromString(String value) {
    return Categoria.values.firstWhere(
      (e) => e.toString() == value,
      orElse: () => Categoria.eletronicos,
    );
  }
  
  static StatusProduto _parseStatusFromString(String value) {
    return StatusProduto.values.firstWhere(
      (e) => e.toString() == value,
      orElse: () => StatusProduto.disponivel,
    );
  }
}

// 3. Classe genérica para resultados de operações
class Resultado<T> {
  final bool sucesso;
  final String mensagem;
  final T? dados;
  
  Resultado({
    required this.sucesso,
    required this.mensagem,
    this.dados,
  });
  
  // Construtor para sucesso
  factory Resultado.sucesso(T dados) {
    return Resultado(
      sucesso: true,
      mensagem: 'Operação realizada com sucesso',
      dados: dados,
    );
  }
  
  // Construtor para erro
  factory Resultado.erro(String mensagem) {
    return Resultado<T>(
      sucesso: false,
      mensagem: mensagem,
    );
  }
}

// 4. Interface para repositório de produtos
abstract class ProdutoRepositorio {
  Resultado<List<Produto>> listarTodos();
  Resultado<Produto> buscarPorId(String id);
  Resultado<Produto> adicionar(Produto produto);
  Resultado<Produto> atualizar(Produto produto);
  Resultado<bool> remover(String id);
}

// 5. Implementação do repositório usando Map
class ProdutoRepositorioMemoria implements ProdutoRepositorio {
  // Map tipado para armazenar produtos
  final Map<String, Produto> _produtos = {};
  
  @override
  Resultado<List<Produto>> listarTodos() {
    try {
      return Resultado.sucesso(_produtos.values.toList());
    } catch (e) {
      return Resultado.erro('Erro ao listar produtos: $e');
    }
  }
  
  @override
  Resultado<Produto> buscarPorId(String id) {
    try {
      final produto = _produtos[id];
      if (produto == null) {
        return Resultado.erro('Produto não encontrado');
      }
      return Resultado.sucesso(produto);
    } catch (e) {
      return Resultado.erro('Erro ao buscar produto: $e');
    }
  }
  
  @override
  Resultado<Produto> adicionar(Produto produto) {
    try {
      if (_produtos.containsKey(produto.id)) {
        return Resultado.erro('Produto com ID ${produto.id} já existe');
      }
      _produtos[produto.id] = produto;
      return Resultado.sucesso(produto);
    } catch (e) {
      return Resultado.erro('Erro ao adicionar produto: $e');
    }
  }
  
  @override
  Resultado<Produto> atualizar(Produto produto) {
    try {
      if (!_produtos.containsKey(produto.id)) {
        return Resultado.erro('Produto não encontrado');
      }
      _produtos[produto.id] = produto;
      return Resultado.sucesso(produto);
    } catch (e) {
      return Resultado.erro('Erro ao atualizar produto: $e');
    }
  }
  
  @override
  Resultado<bool> remover(String id) {
    try {
      if (!_produtos.containsKey(id)) {
        return Resultado.erro('Produto não encontrado');
      }
      _produtos.remove(id);
      return Resultado.sucesso(true);
    } catch (e) {
      return Resultado.erro('Erro ao remover produto: $e');
    }
  }
}

// 6. Serviço que usa o repositório
class ProdutoServico {
  final ProdutoRepositorio _repositorio;
  
  ProdutoServico(this._repositorio);
  
  // Método que aplica desconto em produtos
  Resultado<Produto> aplicarDesconto(String id, double percentual) {
    try {
      // Validação de tipo
      if (percentual < 0 || percentual > 100) {
        return Resultado.erro('Percentual deve estar entre 0 e 100');
      }
      
      // Busca o produto
      final resultado = _repositorio.buscarPorId(id);
      if (!resultado.sucesso) {
        return resultado;
      }
      
      // Aplica o desconto
      final produto = resultado.dados!;
      produto.preco = produto.preco * (1 - percentual / 100);
      
      // Atualiza o produto
      return _repositorio.atualizar(produto);
    } catch (e) {
      return Resultado.erro('Erro ao aplicar desconto: $e');
    }
  }
}

// Função principal para demonstrar o uso
void main() {
  // Criando o repositório e o serviço
  final repositorio = ProdutoRepositorioMemoria();
  final servico = ProdutoServico(repositorio);
  
  // Criando produtos com tipagem forte
  final notebook = Produto(
    id: 'p001',
    nome: 'Notebook Pro',
    preco: 3500.00,
    categoria: Categoria.eletronicos,
    caracteristicas: ['8GB RAM', 'SSD 256GB'],
    avaliacao: Avaliacao(4.5, 120),
  );
  
  final camiseta = Produto(
    id: 'p002',
    nome: 'Camiseta Casual',
    preco: 79.90,
    categoria: Categoria.vestuario,
    status: StatusProduto.esgotado,
  );
  
  // Adicionando produtos
  print('\n--- Adicionando produtos ---');
  var resultado1 = repositorio.adicionar(notebook);
  var resultado2 = repositorio.adicionar(camiseta);
  
  print('Adicionou notebook: ${resultado1.sucesso}');
  print('Adicionou camiseta: ${resultado2.sucesso}');
  
  // Listando produtos
  print('\n--- Listando produtos ---');
  var listagem = repositorio.listarTodos();
  if (listagem.sucesso) {
    for (var produto in listagem.dados!) {
      print('${produto.id}: ${produto.nome} - R\$${produto.preco.toStringAsFixed(2)}');
    }
  }
  
  // Aplicando desconto
  print('\n--- Aplicando desconto ---');
  var descontoResultado = servico.aplicarDesconto('p001', 10);
  if (descontoResultado.sucesso) {
    print('Preço com desconto: R\$${descontoResultado.dados!.preco.toStringAsFixed(2)}');
  } else {
    print('Erro: ${descontoResultado.mensagem}');
  }
  
  // Convertendo para Map e de volta para objeto
  print('\n--- Convertendo para Map e de volta ---');
  var notebookMap = notebook.toMap();
  print('Map: $notebookMap');
  
  var notebookReconstruido = Produto.fromMap(notebookMap);
  print('Reconstruído: ${notebookReconstruido.nome}, ${notebookReconstruido.preco}');
  
  // Demonstrando null safety
  print('\n--- Demonstrando null safety ---');
  print('Notebook tem avaliação: ${notebook.avaliacao != null}');
  print('Camiseta tem avaliação: ${camiseta.avaliacao != null}');
  
  // Acesso seguro
  print('Avaliação notebook: ${notebook.avaliacao?.pontuacao ?? "Sem avaliação"}');
  print('Avaliação camiseta: ${camiseta.avaliacao?.pontuacao ?? "Sem avaliação"}');
}