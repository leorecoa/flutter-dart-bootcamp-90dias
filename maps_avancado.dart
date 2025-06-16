void main() {
  // 1. Map com diferentes tipos de valores
  print('\n--- Maps com diferentes tipos ---');
  Map<String, dynamic> produto = {
    'nome': 'Notebook',
    'preco': 3500.00,
    'disponivel': true,
    'caracteristicas': ['8GB RAM', 'SSD 256GB'],
    'avaliacao': {'pontuacao': 4.5, 'total_reviews': 120}
  };
  print(produto);
  
  // 2. Acessando maps aninhados
  print('\n--- Acessando maps aninhados ---');
  print('Pontuação: ${produto['avaliacao']['pontuacao']}');
  
  // 3. Iterando sobre um Map
  print('\n--- Iterando sobre um Map ---');
  produto.forEach((chave, valor) {
    print('$chave: $valor');
  });
  
  // 4. Transformando Maps
  print('\n--- Transformando Maps ---');
  // Criando um novo Map com valores modificados
  Map<String, dynamic> produtoComDesconto = Map.from(produto);
  produtoComDesconto['preco'] = (produto['preco'] as double) * 0.9;
  print('Produto original: ${produto['preco']}');
  print('Produto com desconto: ${produtoComDesconto['preco']}');
  
  // 5. Mesclando Maps
  print('\n--- Mesclando Maps ---');
  Map<String, dynamic> infoAdicional = {
    'garantia': '12 meses',
    'loja': 'TechStore',
    'disponivel': false  // Vai sobrescrever o valor original
  };
  
  // Método 1: usando addAll
  Map<String, dynamic> produtoCompleto1 = Map.from(produto);
  produtoCompleto1.addAll(infoAdicional);
  print(produtoCompleto1);
  
  // Método 2: usando spread operator (...)
  Map<String, dynamic> produtoCompleto2 = {
    ...produto,
    ...infoAdicional
  };
  print(produtoCompleto2);
  
  // 6. Map.fromEntries - criando Maps a partir de pares chave-valor
  print('\n--- Map.fromEntries ---');
  var entradas = [
    MapEntry('id', 1001),
    MapEntry('categoria', 'Eletrônicos'),
    MapEntry('estoque', 15)
  ];
  var dadosProduto = Map.fromEntries(entradas);
  print(dadosProduto);
  
  // 7. Map.fromIterable - criando Maps a partir de uma lista
  print('\n--- Map.fromIterable ---');
  var cores = ['vermelho', 'verde', 'azul'];
  
  // Usando a própria cor como chave e valor
  var mapCores1 = Map.fromIterable(cores);
  print(mapCores1);
  
  // Personalizando chave e valor
  var mapCores2 = Map.fromIterable(
    cores,
    key: (cor) => cor[0], // Primeira letra como chave
    value: (cor) => cor.toUpperCase() // Valor em maiúsculas
  );
  print(mapCores2);
  
  // 8. Filtrando Maps
  print('\n--- Filtrando Maps ---');
  var numeros = {1: 'um', 2: 'dois', 3: 'três', 4: 'quatro', 5: 'cinco'};
  var numerosPares = numeros.entries
      .where((entry) => entry.key % 2 == 0)
      .fold({}, (map, entry) {
        map[entry.key] = entry.value;
        return map;
      });
  print(numerosPares);
  
  // 9. Operador de acesso condicional (?.)
  print('\n--- Acesso condicional ---');
  Map<String, dynamic>? usuarioNulo;
  print('Acesso seguro: ${usuarioNulo?['nome']}'); // Não causa erro
  
  // 10. Map.putIfAbsent - adiciona um valor apenas se a chave não existir
  print('\n--- putIfAbsent ---');
  var config = {'tema': 'escuro', 'fonte': 'Arial'};
  config.putIfAbsent('tamanho', () => 14);
  config.putIfAbsent('tema', () => 'claro'); // Não altera o valor existente
  print(config);
}