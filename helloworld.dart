void main() {
  Map<int, String> nomes = {
    1: 'Leandro',
    2: 'Jessé',
  };
  print(nomes);

  // A variável usuario é um mapa que contém informações sobre o usuário.
  // Ela possui três chaves: 'nome', 'idade' e 'dev'.
  Map<String, dynamic> usuario = {
    'nome': 'Leandro',
    'idade': 39,
    'dev': true
  };
  print(usuario['dev']);
  // Imprime o valor associado à chave 'dev' do mapa 'usuario'.
  print(usuario['idade'] = 39);
  // Altera o valor associado à chave 'idade' do mapa 'usuario' para 25.
  print(usuario);
  // Imprime o mapa 'usuario' atualizado.
  print(usuario.length);
  // Imprime o número de pares chave-valor presentes no mapa 'usuario'.
  print(usuario.keys);
  // Imprime uma lista contendo todas as chaves presentes no mapa 'usuario'.
  print(usuario.values);
  // Imprime uma lista contendo todos os valores associados às chaves no mapa 'usuario'.
  print(usuario.containsKey('nome'));
  // Verifica se o mapa 'usuario' contém a chave 'nome' e imprime true ou false.
  print(usuario.containsValue(false));
  // Verifica se o mapa 'usuario' contém o valor false e imprime true ou false.
  print(usuario.remove('dev'));
  // Remove a chave 'dev' do mapa 'usuario' e imprime o valor associado à chave removida.
  print(usuario);
  // Imprime o mapa 'usuario' após a remoção da chave 'dev'.
  print(usuario.isEmpty);
  // Verifica se o mapa 'usuario' está vazio e imprime true ou false.
}