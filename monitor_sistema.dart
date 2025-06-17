import 'dart:io';
import 'dart:async';

void main() async {
  print('📊 Monitor de Sistema Simples');
  print('---------------------------');
  
  // Intervalo de atualização em segundos
  const intervaloAtualizacao = 5;
  
  // Contador para alternar entre exibições detalhadas
  int contador = 0;
  
  // Timer para atualização periódica
  Timer.periodic(Duration(seconds: intervaloAtualizacao), (timer) async {
    // Limpa a tela
    if (Platform.isWindows) {
      await Process.run('cls', [], runInShell: true);
    } else {
      await Process.run('clear', []);
    }
    
    print('📊 Monitor de Sistema Simples (Atualizado: ${DateTime.now().toString().split('.')[0]})');
    print('---------------------------');
    
    // Informações do sistema
    await _mostrarInfoSistema();
    
    // Uso de CPU
    await _mostrarUsoCPU();
    
    // Uso de memória
    await _mostrarUsoMemoria();
    
    // A cada 3 atualizações, mostra processos
    if (contador % 3 == 0) {
      await _mostrarProcessos();
    }
    
    // A cada 6 atualizações, mostra uso de disco
    if (contador % 6 == 0) {
      await _mostrarUsoDisco();
    }
    
    contador++;
    
    print('\nAtualizando a cada $intervaloAtualizacao segundos. Pressione Ctrl+C para sair.');
  });
}

Future<void> _mostrarInfoSistema() async {
  try {
    print('\n💻 Informações do Sistema:');
    
    // Nome do computador
    final hostname = Platform.isWindows 
        ? (await Process.run('hostname', [])).stdout.toString().trim()
        : (await Process.run('hostname', [])).stdout.toString().trim();
    
    // Sistema operacional
    final os = Platform.operatingSystem;
    final osVersion = Platform.operatingSystemVersion;
    
    print('Nome: $hostname');
    print('Sistema: $os $osVersion');
    print('Diretório atual: ${Directory.current.path}');
  } catch (e) {
    print('Erro ao obter informações do sistema: $e');
  }
}

Future<void> _mostrarUsoCPU() async {
  try {
    print('\n🔄 Uso de CPU:');
    
    if (Platform.isWindows) {
      final resultado = await Process.run('powershell', [
        '-Command', 
        "Get-Counter '\\Processor(_Total)\\% Processor Time' | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue"
      ]);
      
      final usoCPU = double.tryParse(resultado.stdout.toString().trim()) ?? 0;
      print('Uso total: ${usoCPU.toStringAsFixed(1)}%');
    } else {
      final resultado = await Process.run('sh', [
        '-c',
        """top -bn1 | grep "Cpu(s)" | sed "s/.*, *\\([0-9.]*\\)%* id.*/\\1/" | awk '{print 100 - \$1}'"""
      ]);
      final usoCPU = double.tryParse(resultado.stdout.toString().trim()) ?? 0;
      print('Uso total: ${usoCPU.toStringAsFixed(1)}%');
    }
  } catch (e) {
    print('Erro ao obter uso de CPU: $e');
  }
}

Future<void> _mostrarUsoMemoria() async {
  try {
    print('\n💾 Uso de Memória:');
    
    if (Platform.isWindows) {
      final resultado = await Process.run('powershell', [
        '-Command', 
        "Get-CimInstance Win32_OperatingSystem | Select-Object TotalVisibleMemorySize,FreePhysicalMemory"
      ]);
      
      final linhas = resultado.stdout.toString().trim().split('\n');
      if (linhas.length >= 3) {
        final valores = linhas[2].trim().split(RegExp(r'\s+'));
        if (valores.length >= 2) {
          final totalKB = int.tryParse(valores[0]) ?? 0;
          final livreKB = int.tryParse(valores[1]) ?? 0;
          final usadoKB = totalKB - livreKB;
          
          final totalGB = totalKB / 1024 / 1024;
          final usadoGB = usadoKB / 1024 / 1024;
          final livreGB = livreKB / 1024 / 1024;
          
          print('Total: ${totalGB.toStringAsFixed(2)} GB');
          print('Usado: ${usadoGB.toStringAsFixed(2)} GB (${(usadoKB * 100 / totalKB).toStringAsFixed(1)}%)');
          print('Livre: ${livreGB.toStringAsFixed(2)} GB');
        }
      }
    } else {
      final resultado = await Process.run('sh', ['-c', 'free -m']);
      final linhas = resultado.stdout.toString().trim().split('\n');
      if (linhas.length >= 2) {
        final valores = linhas[1].trim().split(RegExp(r'\s+'));
        if (valores.length >= 4) {
          final totalMB = int.tryParse(valores[1]) ?? 0;
          final usadoMB = int.tryParse(valores[2]) ?? 0;
          final livreMB = int.tryParse(valores[3]) ?? 0;
          
          final totalGB = totalMB / 1024;
          final usadoGB = usadoMB / 1024;
          final livreGB = livreMB / 1024;
          
          print('Total: ${totalGB.toStringAsFixed(2)} GB');
          print('Usado: ${usadoGB.toStringAsFixed(2)} GB (${(usadoMB * 100 / totalMB).toStringAsFixed(1)}%)');
          print('Livre: ${livreGB.toStringAsFixed(2)} GB');
        }
      }
    }
  } catch (e) {
    print('Erro ao obter uso de memória: $e');
  }
}

Future<void> _mostrarProcessos() async {
  try {
    print('\n🔍 Processos (Top 5 por uso de CPU):');
    
    if (Platform.isWindows) {
      final resultado = await Process.run('powershell', [
        '-Command', 
        "Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 ProcessName,CPU,WorkingSet"
      ]);
      
      final linhas = resultado.stdout.toString().trim().split('\n');
      for (var i = 2; i < linhas.length; i++) {
        final valores = linhas[i].trim().split(RegExp(r'\s+'));
        if (valores.length >= 3) {
          final nome = valores[0];
          final cpu = double.tryParse(valores[1]) ?? 0;
          final memoria = int.tryParse(valores[2]) ?? 0;
          final memoriaMB = memoria / 1024 / 1024;
          
          print('${i-1}. $nome - CPU: ${cpu.toStringAsFixed(1)}, Memória: ${memoriaMB.toStringAsFixed(1)} MB');
        }
      }
    } else {
      final resultado = await Process.run('sh', ['-c', 'ps aux --sort=-%cpu | head -6']);
      final linhas = resultado.stdout.toString().trim().split('\n');
      for (var i = 1; i < linhas.length; i++) {
        final valores = linhas[i].trim().split(RegExp(r'\s+'));
        if (valores.length >= 11) {
          final cpu = double.tryParse(valores[2]) ?? 0;
          final mem = double.tryParse(valores[3]) ?? 0;
          final comando = valores.sublist(10).join(' ');
          
          print('${i}. $comando - CPU: ${cpu.toStringAsFixed(1)}%, Memória: ${mem.toStringAsFixed(1)}%');
        }
      }
    }
  } catch (e) {
    print('Erro ao obter lista de processos: $e');
  }
}

Future<void> _mostrarUsoDisco() async {
  try {
    print('\n💽 Uso de Disco:');
    
    if (Platform.isWindows) {
      final resultado = await Process.run('powershell', [
        '-Command', 
        "Get-PSDrive -PSProvider FileSystem | Select-Object Name,Used,Free"
      ]);
      
      final linhas = resultado.stdout.toString().trim().split('\n');
      for (var i = 2; i < linhas.length; i++) {
        final valores = linhas[i].trim().split(RegExp(r'\s+'));
        if (valores.length >= 3) {
          final nome = valores[0];
          final usado = int.tryParse(valores[1]) ?? 0;
          final livre = int.tryParse(valores[2]) ?? 0;
          
          if (usado > 0 || livre > 0) {
            final total = usado + livre;
            final usadoGB = usado / 1024 / 1024 / 1024;
            final totalGB = total / 1024 / 1024 / 1024;
            final percentUsado = total > 0 ? (usado * 100 / total).toStringAsFixed(1) : '0.0';
            
            print('Unidade $nome: ${usadoGB.toStringAsFixed(1)} GB usado de ${totalGB.toStringAsFixed(1)} GB ($percentUsado%)');
          }
        }
      }
    } else {
      final resultado = await Process.run('sh', ['-c', 'df -h --output=source,size,used,avail,pcent | grep -v "tmpfs"']);
      final linhas = resultado.stdout.toString().trim().split('\n');
      for (var i = 1; i < linhas.length; i++) {
        final valores = linhas[i].trim().split(RegExp(r'\s+'));
        if (valores.length >= 5) {
          final dispositivo = valores[0];
          final tamanho = valores[1];
          final usado = valores[2];
          final percentual = valores[4];
          
          print('$dispositivo: $usado usado de $tamanho ($percentual)');
        }
      }
    }
  } catch (e) {
    print('Erro ao obter uso de disco: $e');
  }
}