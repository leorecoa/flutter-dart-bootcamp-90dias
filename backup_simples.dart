import 'dart:io';
import 'dart:async';

void main(List<String> args) async {
  // Configurações padrão
  String diretorioOrigem = args.isNotEmpty ? args[0] : 'C:/Projetos';
  String diretorioDestino = args.length > 1 ? args[1] : 'C:/Backup';
  
  print('🔄 Iniciando backup simples...');
  print('📂 Origem: $diretorioOrigem');
  print('📂 Destino: $diretorioDestino');
  
  // Verifica se os diretórios existem
  final origem = Directory(diretorioOrigem);
  if (!await origem.exists()) {
    print('❌ Diretório de origem não encontrado!');
    return;
  }
  
  // Cria o diretório de destino se não existir
  final destino = Directory(diretorioDestino);
  if (!await destino.exists()) {
    await destino.create(recursive: true);
    print('📁 Diretório de destino criado');
  }
  
  // Cria uma pasta com a data atual para o backup
  final dataHoje = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD
  final pastaBackup = Directory('$diretorioDestino${Platform.pathSeparator}backup_$dataHoje');
  
  if (!await pastaBackup.exists()) {
    await pastaBackup.create();
  }
  
  // Contador de arquivos
  int totalArquivos = 0;
  int arquivosCopiadosComSucesso = 0;
  
  print('\n🔍 Iniciando cópia de arquivos...');
  
  // Inicia o backup
  try {
    await _copiarDiretorio(origem, pastaBackup, (status) {
      if (status.sucesso) arquivosCopiadosComSucesso++;
      totalArquivos++;
      print(status.mensagem);
    });
    
    print('\n✅ Backup concluído!');
    print('📊 Estatísticas:');
    print('   - Total de arquivos: $totalArquivos');
    print('   - Copiados com sucesso: $arquivosCopiadosComSucesso');
    print('   - Falhas: ${totalArquivos - arquivosCopiadosComSucesso}');
    print('   - Pasta de backup: ${pastaBackup.path}');
    
  } catch (e) {
    print('\n❌ Erro durante o backup: $e');
  }
}

Future<void> _copiarDiretorio(
    Directory origem, 
    Directory destino,
    Function(StatusCopia) callback) async {
  
  // Lista todos os arquivos e diretórios
  await for (final entidade in origem.list(recursive: false, followLinks: false)) {
    final nome = entidade.path.split(Platform.pathSeparator).last;
    
    // Ignora diretórios ocultos e temporários
    if (nome.startsWith('.') || nome == 'node_modules' || nome == 'build' || nome == 'dist') {
      continue;
    }
    
    if (entidade is Directory) {
      // Cria o diretório correspondente no destino
      final novoDiretorio = Directory('${destino.path}${Platform.pathSeparator}$nome');
      await novoDiretorio.create();
      
      // Copia recursivamente o conteúdo
      await _copiarDiretorio(entidade, novoDiretorio, callback);
      
    } else if (entidade is File) {
      // Copia o arquivo
      try {
        final novoArquivo = File('${destino.path}${Platform.pathSeparator}$nome');
        await entidade.copy(novoArquivo.path);
        callback(StatusCopia(true, '✓ Copiado: $nome'));
      } catch (e) {
        callback(StatusCopia(false, '✗ Falha ao copiar: $nome - $e'));
      }
    }
  }
}

class StatusCopia {
  final bool sucesso;
  final String mensagem;
  
  StatusCopia(this.sucesso, this.mensagem);
}