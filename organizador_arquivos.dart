import 'dart:io';
import 'dart:async';

void main() async {
  // Configurações
  final diretorioMonitorado = Directory('C:/Downloads'); // Altere para o diretório que deseja monitorar
  final Map<String, String> regrasOrganizacao = {
    'pdf': 'Documentos',
    'doc': 'Documentos',
    'docx': 'Documentos',
    'txt': 'Documentos',
    'jpg': 'Imagens',
    'jpeg': 'Imagens',
    'png': 'Imagens',
    'gif': 'Imagens',
    'mp3': 'Musicas',
    'wav': 'Musicas',
    'mp4': 'Videos',
    'avi': 'Videos',
    'mkv': 'Videos',
    'zip': 'Compactados',
    'rar': 'Compactados',
    'exe': 'Programas',
    'msi': 'Programas',
  };

  print('🔍 Iniciando organizador de arquivos...');
  print('📁 Monitorando: ${diretorioMonitorado.path}');
  
  // Verifica se o diretório existe
  if (!await diretorioMonitorado.exists()) {
    print('❌ Diretório não encontrado!');
    return;
  }

  // Cria as pastas de destino se não existirem
  for (final pasta in regrasOrganizacao.values.toSet()) {
    final dir = Directory('${diretorioMonitorado.path}/$pasta');
    if (!await dir.exists()) {
      await dir.create();
      print('📁 Pasta criada: $pasta');
    }
  }

  // Processa arquivos existentes
  print('\n🔍 Verificando arquivos existentes...');
  await processarArquivosExistentes(diretorioMonitorado, regrasOrganizacao);
  
  // Monitora novos arquivos
  print('\n👀 Monitorando novos arquivos...');
  print('⏱️ Pressione Ctrl+C para encerrar o programa\n');
  
  final watcher = diretorioMonitorado.watch(events: FileSystemEvent.create);
  
  await for (final event in watcher) {
    if (event is FileSystemCreateEvent && !event.isDirectory) {
      final arquivo = File(event.path);
      await organizarArquivo(arquivo, regrasOrganizacao, diretorioMonitorado.path);
    }
  }
}

Future<void> processarArquivosExistentes(Directory diretorio, Map<String, String> regras) async {
  try {
    await for (final entidade in diretorio.list(followLinks: false)) {
      if (entidade is File) {
        final arquivo = File(entidade.path);
        await organizarArquivo(arquivo, regras, diretorio.path);
      }
    }
    print('✅ Arquivos existentes processados!');
  } catch (e) {
    print('❌ Erro ao processar arquivos existentes: $e');
  }
}

Future<void> organizarArquivo(File arquivo, Map<String, String> regras, String diretorioBase) async {
  try {
    final nome = arquivo.path.split(Platform.pathSeparator).last;
    final extensao = nome.contains('.') ? nome.split('.').last.toLowerCase() : '';
    
    // Ignora arquivos sem extensão ou que já estão em subpastas
    if (extensao.isEmpty || arquivo.path.contains('${Platform.pathSeparator}Documentos${Platform.pathSeparator}') ||
        arquivo.path.contains('${Platform.pathSeparator}Imagens${Platform.pathSeparator}')) {
      return;
    }
    
    // Verifica se existe uma regra para esta extensão
    if (regras.containsKey(extensao)) {
      final pastaDestino = regras[extensao]!;
      final novoCaminho = '$diretorioBase${Platform.pathSeparator}$pastaDestino${Platform.pathSeparator}$nome';
      
      // Verifica se o arquivo já existe no destino
      final arquivoDestino = File(novoCaminho);
      if (await arquivoDestino.exists()) {
        // Adiciona timestamp ao nome para evitar sobrescrever
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final nomeBase = nome.substring(0, nome.lastIndexOf('.'));
        final novoNome = '$nomeBase-$timestamp.$extensao';
        final novoCaminhoUnico = '$diretorioBase${Platform.pathSeparator}$pastaDestino${Platform.pathSeparator}$novoNome';
        await arquivo.copy(novoCaminhoUnico);
        await arquivo.delete();
        print('📦 Movido: $nome → $pastaDestino/$novoNome (renomeado)');
      } else {
        await arquivo.rename(novoCaminho);
        print('📦 Movido: $nome → $pastaDestino/$nome');
      }
    }
  } catch (e) {
    print('❌ Erro ao organizar arquivo ${arquivo.path}: $e');
  }
}