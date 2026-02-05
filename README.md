# terracode_app
Tecnologías Implementadas:
Flutter: Framework principal.
Firebase Auth: Manejo de sesiones (Login/Registro).
Cloud Firestore: Base de datos para guardar información extra del usuario (Nombre, Teléfono, Rol).
Riverpod: Gestión de estado (para acceder al repositorio de autenticación).

📂 Estructura y Archivos Clave:

lib/core/constants/app_theme.dart: Define la paleta de colores y tipografía.

lib/core/widgets/:
custom_input.dart: Cajas de texto estilizadas y reutilizables.
custom_button.dart: Botones estandarizados con estado de carga.
lib/features/auth/data/auth_repository.dart: El "cerebro" que conecta con Firebase.

lib/features/auth/presentation/:
login_screen.dart: Pantalla de inicio de sesión con diseño final.
register_screen.dart: Pantalla de registro con lógica de guardado de datos en Firestore.
lib/main.dart: El "Portero" (StreamBuilder) que mantiene la sesión activa.

✅ Funcionalidades Listas:

Registro de nuevos usuarios (guarda automáticamente el rol de "seller" por defecto).
Inicio de Sesión con validación en Firebase.
Persistencia de sesión (la app recuerda al usuario al cerrarla y volverla a abrir).
Navegación fluida entre Login y Registro.