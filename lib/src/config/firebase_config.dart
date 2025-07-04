import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Classe de configuração central para todos os serviços Firebase
/// Facilita o acesso e permite configurações específicas por ambiente
class FirebaseConfig {
  // Instâncias singleton dos serviços Firebase
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final FirebaseStorage storage = FirebaseStorage.instance;
  
  // Nomes das coleções no Firestore
  static const String usersCollection = 'users';
  static const String equipmentsCollection = 'equipments';
  static const String equipmentLogsCollection = 'equipment_logs';
  static const String companiesCollection = 'companies';
  static const String notificationsCollection = 'notifications';
  
  // Configurações de timeout e retry
  static const Duration authTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  
  // Paths do Storage
  static String equipmentImagePath(String companyId, String equipmentId, String fileName) {
    return 'companies/$companyId/equipments/$equipmentId/$fileName';
  }
  
  static String userProfileImagePath(String userId, String fileName) {
    return 'users/$userId/profile/$fileName';
  }
  
  static String documentPath(String companyId, String fileName) {
    return 'documents/$companyId/$fileName';
  }
  
  // Configurações do Firestore para melhor performance
  static void configureFirestore() {
    firestore.settings = const Settings(
      persistenceEnabled: true, // Habilita cache offline
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // Cache ilimitado
    );
  }
  
  // Configurações de autenticação
  static void configureAuth() {
    // Configura a linguagem para português
    auth.setLanguageCode('pt-BR');
    
    // Configura persistência de sessão
    auth.setPersistence(Persistence.LOCAL);
  }
  
  // Método para inicializar todas as configurações
  static void initialize() {
    configureFirestore();
    configureAuth();
    
    // Listener para mudanças no estado de autenticação
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        print('Firebase Config: Usuário deslogado');
      } else {
        print('Firebase Config: Usuário logado - ${user.email}');
      }
    });
  }
  
  // Helpers para verificação de conexão
  static Future<bool> checkConnection() async {
    try {
      // Tenta fazer uma operação simples no Firestore
      await firestore
          .collection('connection_test')
          .doc('test')
          .get(const GetOptions(source: Source.server));
      return true;
    } catch (e) {
      print('Firebase Config: Sem conexão com o servidor');
      return false;
    }
  }
  
  // Método para limpar cache local (útil para debugging)
  static Future<void> clearLocalCache() async {
    await firestore.clearPersistence();
    await auth.signOut();
  }
  
  // Configurações de ambiente (desenvolvimento vs produção)
  static bool get isDevelopment {
    // Você pode usar essa flag para alternar entre ambientes
    const bool inDebugMode = true; // Mude para false em produção
    return inDebugMode;
  }
  
  // URLs e endpoints específicos por ambiente
  static String get apiBaseUrl {
    if (isDevelopment) {
      return 'http://localhost:5001/aft-plc-web/us-central1';
    } else {
      return 'https://us-central1-aft-plc-web.cloudfunctions.net';
    }
  }
}
