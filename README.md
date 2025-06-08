- Sobre o Projeto
    * O AFT-PLC-WEB é uma solução completa de IoT industrial desenvolvida pela Alfatronic para monitoramento em tempo real de equipamentos industriais. 
    O sistema conecta máquinas equipadas com o dispositivo TRM6-MAX a uma plataforma cloud, permitindo gestão eficiente e análise de dados operacionais.

- Objetivos Principais
    * Otimização Operacional: Reduzir quebras e aumentar tempo produtivo das máquinas
    * Monitoramento Remoto: Acompanhar equipamentos em tempo real de qualquer lugar
    * Redução de Custos: Eliminar necessidade de modem GSM dedicado por equipamento
    * Análise Inteligente: Identificar padrões de uso e pontos de melhoria

- Funcionalidades
    * Gestão de Usuários
        ** Sistema hierárquico de 3 níveis (Administrador → Gerente → Operador)
        ** Cadastro, edição e exclusão de contas
        ** Recuperação de senha com validação multinível
        ** Controle de permissões por tipo de usuário

- Gestão de Equipamentos
    * Cadastro completo com número de série, modelo e data de fabricação
    * Upload de fotos para identificação visual
    * Associação de operadores autorizados
    * Histórico completo de operações

- Monitoramento e Análise
    * Dashboard responsivo com visualização em tempo real
    * Sistema de notificações para situações de risco
    * Filtros avançados para análise de dados
    * Exportação de relatórios em formato .xlsx e .csv
    * Logs detalhados com geolocalização

- Conectividade
    * Conexão via Bluetooth entre celular e equipamento
    * Uso de GPS do celular para localização
    * Sincronização automática com a nuvem
    * Funcionamento offline com sincronização posterior

- Tecnologias Utilizadas
    * Mobile
        ** Flutter - Framework multiplataforma
        ** Dart - Linguagem de programação
        ** Bluetooth Low Energy - Comunicação com equipamentos
        ** GPS/Location Services - Geolocalização

    * Backend
        ** Firebase Auth - Autenticação de usuários
        ** Cloud Firestore - Banco de dados NoSQL
        ** Cloud Functions - Processamento serverless
        ** Firebase Storage - Armazenamento de arquivos

    * Web
        ** Flutter Web - Dashboard administrativo
        ** Responsive Design - Interface adaptativa

- Plataformas Suportadas
    * Android (5.0+)
    * iOS (11.0+)
    * Web (Chrome, Firefox, Safari, Edge)
    * Windows Desktop

┌─────────────┐     Bluetooth       ┌─────────────┐       Internet      ┌─────────────┐
│ Equipamento │ ◄─────────────────► │   Celular   │ ◄─────────────────► │   Firebase  │
│  TRM6-MAX   │                     │  Operador   │                     │    Cloud    │
└─────────────┘                     └─────────────┘                     └─────────────┘
                                           │                                     ▲
                                           │ GPS                                 │
                                           ▼                                     │
                                    ┌─────────────┐                              │
                                    │ Localização │                              │
                                    └─────────────┘                              │
                                                                                 │
┌─────────────┐                                                                  │
│  Dashboard  │ ◄────────────────────────────────────────────────────────────────┘
│     Web     │
└─────────────┘

- Estruturação do projeto
aft-plc-web/
├── android/                        # Configurações específicas Android
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── kotlin/com/alfatronic/aft_plc_web/
│   │   │   │   └── MainActivity.kt
│   │   │   └── AndroidManifest.xml
│   │   └── build.gradle.kts
│   └── build.gradle.kts
│
├── ios/                           # Configurações específicas iOS
│   ├── Runner/
│   │   ├── AppDelegate.swift
│   │   ├── Info.plist
│   │   └── Runner-Bridging-Header.h
│   └── Runner.xcodeproj/
│
├── web/                           # Assets e configurações Web
│   ├── index.html
│   ├── manifest.json
│   ├── favicon.png
│   └── icons/
│       ├── icon-192.png
│       └── icon-512.png
│
├── windows/                       # Configurações Windows Desktop
│   └── runner/
│
├── lib/                          # Todo código Dart compartilhado
│   ├── main.dart                 # Entrada principal
│   ├── main_development.dart     # Entrada ambiente dev
│   ├── main_production.dart      # Entrada ambiente prod
│   │
│   ├── src/
│   │   ├── core/                 # Funcionalidades centrais
│   │   │   ├── constants/
│   │   │   │   ├── app_colors.dart
│   │   │   │   ├── app_strings.dart
│   │   │   │   └── app_dimensions.dart
│   │   │   ├── errors/
│   │   │   │   ├── exceptions.dart
│   │   │   │   └── failures.dart
│   │   │   ├── network/
│   │   │   │   └── network_info.dart
│   │   │   ├── services/
│   │   │   │   ├── bluetooth_service.dart
│   │   │   │   ├── location_service.dart
│   │   │   │   └── notification_service.dart
│   │   │   ├── utils/
│   │   │   │   ├── date_formatter.dart
│   │   │   │   ├── validators.dart
│   │   │   │   └── platform_utils.dart
│   │   │   └── widgets/
│   │   │       ├── loading_widget.dart
│   │   │       ├── error_widget.dart
│   │   │       └── custom_button.dart
│   │   │
│   │   ├── config/               # Configurações do app
│   │   │   ├── routes/
│   │   │   │   ├── app_router.dart
│   │   │   │   └── route_guards.dart
│   │   │   ├── themes/
│   │   │   │   ├── app_theme.dart
│   │   │   │   └── responsive_config.dart
│   │   │   ├── firebase/
│   │   │   │   └── firebase_options.dart
│   │   │   └── environment.dart
│   │   │
│   │   └── features/             # Funcionalidades por domínio
│   │       ├── auth/             # Autenticação
│   │       │   ├── data/
│   │       │   │   ├── datasources/
│   │       │   │   │   └── auth_remote_datasource.dart
│   │       │   │   ├── models/
│   │       │   │   │   └── user_model.dart
│   │       │   │   └── repositories/
│   │       │   │       └── auth_repository_impl.dart
│   │       │   ├── domain/
│   │       │   │   ├── entities/
│   │       │   │   │   └── user.dart
│   │       │   │   ├── repositories/
│   │       │   │   │   └── auth_repository.dart
│   │       │   │   └── usecases/
│   │       │   │       ├── login_usecase.dart
│   │       │   │       ├── logout_usecase.dart
│   │       │   │       └── recover_password_usecase.dart
│   │       │   └── presentation/
│   │       │       ├── pages/
│   │       │       │   ├── login_page.dart
│   │       │       │   └── recover_password_page.dart
│   │       │       ├── widgets/
│   │       │       │   └── login_form.dart
│   │       │       └── providers/
│   │       │           └── auth_provider.dart
│   │       │
│   │       ├── equipment/        # Gestão de Equipamentos
│   │       │   ├── data/
│   │       │   │   ├── datasources/
│   │       │   │   │   ├── equipment_remote_datasource.dart
│   │       │   │   │   └── bluetooth_datasource.dart
│   │       │   │   ├── models/
│   │       │   │   │   ├── equipment_model.dart
│   │       │   │   │   └── equipment_log_model.dart
│   │       │   │   └── repositories/
│   │       │   │       └── equipment_repository_impl.dart
│   │       │   ├── domain/
│   │       │   │   ├── entities/
│   │       │   │   │   ├── equipment.dart
│   │       │   │   │   └── equipment_log.dart
│   │       │   │   ├── repositories/
│   │       │   │   │   └── equipment_repository.dart
│   │       │   │   └── usecases/
│   │       │   │       ├── create_equipment_usecase.dart
│   │       │   │       ├── update_equipment_usecase.dart
│   │       │   │       ├── delete_equipment_usecase.dart
│   │       │   │       └── connect_bluetooth_usecase.dart
│   │       │   └── presentation/
│   │       │       ├── pages/
│   │       │       │   ├── equipment_list_page.dart
│   │       │       │   ├── equipment_detail_page.dart
│   │       │       │   └── equipment_form_page.dart
│   │       │       ├── widgets/
│   │       │       │   ├── equipment_card.dart
│   │       │       │   └── bluetooth_connection_widget.dart
│   │       │       └── providers/
│   │       │           └── equipment_provider.dart
│   │       │
│   │       ├── dashboard/        # Dashboard e Relatórios
│   │       │   ├── data/
│   │       │   │   ├── datasources/
│   │       │   │   │   └── dashboard_remote_datasource.dart
│   │       │   │   ├── models/
│   │       │   │   │   └── dashboard_data_model.dart
│   │       │   │   └── repositories/
│   │       │   │       └── dashboard_repository_impl.dart
│   │       │   ├── domain/
│   │       │   │   ├── entities/
│   │       │   │   │   └── dashboard_data.dart
│   │       │   │   ├── repositories/
│   │       │   │   │   └── dashboard_repository.dart
│   │       │   │   └── usecases/
│   │       │   │       ├── get_dashboard_data_usecase.dart
│   │       │   │       └── export_report_usecase.dart
│   │       │   └── presentation/
│   │       │       ├── pages/
│   │       │       │   ├── dashboard_page.dart
│   │       │       │   └── reports_page.dart
│   │       │       ├── widgets/
│   │       │       │   ├── chart_widget.dart
│   │       │       │   ├── stats_card.dart
│   │       │       │   └── filter_widget.dart
│   │       │       └── providers/
│   │       │           └── dashboard_provider.dart
│   │       │
│   │       ├── users/            # Gestão de Usuários
│   │       │   ├── data/
│   │       │   │   ├── datasources/
│   │       │   │   │   └── users_remote_datasource.dart
│   │       │   │   ├── models/
│   │       │   │   │   ├── operator_model.dart
│   │       │   │   │   └── manager_model.dart
│   │       │   │   └── repositories/
│   │       │   │       └── users_repository_impl.dart
│   │       │   ├── domain/
│   │       │   │   ├── entities/
│   │       │   │   │   ├── operator.dart
│   │       │   │   │   ├── manager.dart
│   │       │   │   │   └── user_role.dart
│   │       │   │   ├── repositories/
│   │       │   │   │   └── users_repository.dart
│   │       │   │   └── usecases/
│   │       │   │       ├── create_user_usecase.dart
│   │       │   │       ├── update_user_usecase.dart
│   │       │   │       ├── delete_user_usecase.dart
│   │       │   │       ├── assign_equipment_usecase.dart
│   │       │   │       └── change_user_role_usecase.dart
│   │       │   └── presentation/
│   │       │       ├── pages/
│   │       │       │   ├── users_list_page.dart
│   │       │       │   ├── user_detail_page.dart
│   │       │       │   └── user_form_page.dart
│   │       │       ├── widgets/
│   │       │       │   ├── user_card.dart
│   │       │       │   ├── role_selector.dart
│   │       │       │   └── equipment_assignment_widget.dart
│   │       │       └── providers/
│   │       │           └── users_provider.dart
│   │       │
│   │       └── notifications/    # Sistema de Notificações
│   │           ├── data/
│   │           │   ├── datasources/
│   │           │   │   ├── notifications_remote_datasource.dart
│   │           │   │   └── push_notifications_datasource.dart
│   │           │   ├── models/
│   │           │   │   ├── notification_model.dart
│   │           │   │   └── notification_settings_model.dart
│   │           │   └── repositories/
│   │           │       └── notifications_repository_impl.dart
│   │           ├── domain/
│   │           │   ├── entities/
│   │           │   │   ├── notification.dart
│   │           │   │   ├── notification_type.dart
│   │           │   │   └── notification_settings.dart
│   │           │   ├── repositories/
│   │           │   │   └── notifications_repository.dart
│   │           │   └── usecases/
│   │           │       ├── send_notification_usecase.dart
│   │           │       ├── mark_as_read_usecase.dart
│   │           │       ├── get_notifications_usecase.dart
│   │           │       └── update_settings_usecase.dart
│   │           └── presentation/
│   │               ├── pages/
│   │               │   ├── notifications_page.dart
│   │               │   └── notification_settings_page.dart
│   │               ├── widgets/
│   │               │   ├── notification_item.dart
│   │               │   ├── notification_badge.dart
│   │               │   └── notification_filter.dart
│   │               └── providers/
│   │                   └── notifications_provider.dart
│   │
│   └── app.dart                  # Configuração principal do App
│
├── test/                         # Testes unitários e de widget
│   ├── unit/
│   │   ├── auth/
│   │   ├── equipment/
│   │   └── dashboard/
│   ├── widget/
│   └── integration/
│
├── assets/                       # Assets do projeto
│   ├── images/
│   │   ├── logo/
│   │   ├── icons/
│   │   └── illustrations/
│   ├── fonts/
│   └── animations/
│       └── lottie/
│
├── firebase/                     # Configurações Firebase
│   ├── firestore.rules
│   ├── firestore.indexes.json
│   └── storage.rules
│
├── .env.example                  # Exemplo de variáveis de ambiente
├── .gitignore
├── analysis_options.yaml         # Configurações do Dart Analyzer
├── pubspec.yaml                  # Dependências e metadados
└── README.md
