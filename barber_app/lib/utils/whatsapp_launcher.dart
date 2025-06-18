import 'package:url_launcher/url_launcher.dart';

class WhatsAppLauncher {
  static Future<bool> openWhatsApp(String phoneNumber, String message) async {
    // Formata a mensagem para URL (substitui espaços por %20, etc)
    final encodedMessage = Uri.encodeComponent(message);
    
    // Cria a URL do WhatsApp
    final whatsappUrl = 'https://wa.me/$phoneNumber?text=$encodedMessage';
    
    // Tenta abrir o WhatsApp
    final uri = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Não foi possível abrir o WhatsApp';
    }
  }
}