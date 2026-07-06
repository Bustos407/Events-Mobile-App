# Estado del proyecto — Event Finder (app de eventos por intereses)

Última actualización: 2026-07-06

## Qué es esto
Proyecto **solo para Android e iOS** (se eliminaron las carpetas `linux/`,
`macos/`, `windows/` y `web/` que Flutter genera por defecto — no se usan).

App Flutter (Android/iOS) que permite registrarse, elegir intereses, ver
eventos cercanos en un mapa estilo Waze, buscar eventos en otras ciudades
("modo viaje" para cuando viajas), y recibir notificaciones de eventos
próximos. A futuro: reventa/transferencia de boletos entre usuarios (fase 2,
todavía no implementada).

## Entorno de desarrollo (ya instalado en esta máquina)
- Flutter SDK 3.44.4 en `C:\src\flutter` (agregado al PATH de usuario)
- JDK 17 (Eclipse Temurin) en `C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot`
- Android SDK en `%LOCALAPPDATA%\Android\Sdk` (platform 34/36, build-tools, NDK, emulador)
- Emulador Android creado: `Pixel_7_API_34`
- Variables de entorno `JAVA_HOME` y `ANDROID_HOME` configuradas de forma persistente
- `flutter doctor` en verde para Android (falta Chrome, irrelevante para app móvil)

Para volver a compilar/correr en esta máquina, en PowerShell:
```powershell
$env:Path = [Environment]::GetEnvironmentVariable("Path","User") + ";" + [Environment]::GetEnvironmentVariable("Path","Machine")
$env:JAVA_HOME = [Environment]::GetEnvironmentVariable("JAVA_HOME","User")
$env:ANDROID_HOME = [Environment]::GetEnvironmentVariable("ANDROID_HOME","User")
cd "c:\Users\busto\Documents\Proyectos\Nuevo Proyecto"
flutter run -d emulator-5554        # instalar y correr en el emulador
flutter build apk --release         # generar el APK
```
Para abrir el emulador manualmente si no está corriendo:
```powershell
& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -avd Pixel_7_API_34
```

## Repositorio
Conectado y subido a: https://github.com/Bustos407/Events-Mobile-App
(rama `main`, primer commit ya hecho).

## Qué está hecho
- ✅ Registro / inicio de sesión con **sesión persistente** (mock local con
  `SharedPreferences` — **todavía no usa Firebase real**, ver pendientes)
- ✅ Onboarding de selección de intereses (Conciertos, Deportes, Videojuegos,
  Arte, Tecnología, Comida, Cine, Familia)
- ✅ Ubicación del usuario (`geolocator`, con timeout de 8s y fallback a
  Bogotá si no hay GPS/permiso)
- ✅ Pantalla "Cerca de ti": mapa minimalista tipo Waze (claro/oscuro,
  movible, con zoom) con burbujas de eventos por categoría, combinado con
  una lista deslizable debajo (tocar un evento centra el mapa ahí)
- ✅ Notificación simulada (SnackBar) de eventos próximos a comenzar cerca
- ✅ "Modo viaje": elegir una ciudad destino y ver **todos** los eventos ahí
  (no solo los de tus intereses — los que coinciden se marcan con ⭐, para
  poder descubrir cosas nuevas)
- ✅ Detalle de evento: imágenes (placeholder, ver pendientes), dirección,
  nombre del lugar, teléfono (con marcado directo), botón "Cómo llegar"
  (abre Google Maps con direcciones)
- ✅ Modo claro/oscuro/automático, con menú explícito y persistente
  (arranca siempre en Automático hasta que el usuario elija otra cosa)
- ✅ Optimizaciones de RAM: caché de imágenes limitado a 30MB, imágenes
  decodificadas a resolución reducida, minificación (R8/ProGuard) habilitada
  en el build de release
- ✅ Datos de eventos de prueba ubicados en **Colombia** (Bogotá, Medellín,
  Cali, Cartagena)
- ✅ APK de alpha generado (`build\app\outputs\flutter-apk\app-release.apk`,
  versión `0.0.1+1`)
- ✅ Probado funcionando en emulador Android (Pixel_7_API_34)

## Qué falta / pendiente
1. **Firebase real** (Auth, Firestore, Cloud Messaging): hoy todo es mock
   local con `SharedPreferences`. El usuario decidió posponerlo — falta que
   cree un proyecto en https://console.firebase.google.com y me pase el
   nombre/ID para conectarlo con FlutterFire CLI.
2. **Eventos reales**: hoy son 10 eventos hardcodeados en
   `lib/data/mock_events.dart`. Falta decidir e integrar la fuente real
   (API tipo Ticketmaster/Eventbrite + eventos creados por usuarios, según
   lo conversado al inicio).
3. **Imágenes de eventos**: actualmente son placeholders de `picsum.photos`.
   Falta implementar que los organizadores/usuarios puedan **subir sus
   propias fotos** (requiere backend/Storage, ligado al punto de Firebase).
4. **Categorías más explícitas / subcategorías**: el usuario pidió esto
   pero se dejó para después ("por el momento está bien así").
5. **Notificaciones push reales**: hoy es solo un SnackBar simulado dentro
   de la app. Notificaciones reales cuando la app está cerrada requieren
   Firebase Cloud Messaging (depende del punto 1).
6. **Reventa/transferencia de boletos entre usuarios** (ser "3ero" en la
   transacción): decidido explícitamente para una fase 2, no iniciado.
   Cuando se retome, definir alcance: ¿solo tablón de contacto entre
   usuarios, o pago dentro de la app con escrow (Stripe u otro)?
7. Sin pruebas automatizadas más allá del smoke test por defecto
   (`test/widget_test.dart`).
8. Sin firma de release "de verdad": el APK usa la keystore de debug
   (válido para alpha/pruebas, no para publicar en Play Store).

## Estructura del código
```
lib/
  main.dart                        # arranque, providers, tema
  models/                          # EventItem, UserProfile
  data/                            # interests.dart, mock_events.dart (eventos de prueba)
  services/                        # auth_service.dart (mock), location_service.dart
  providers/                       # auth_provider, events_provider, theme_provider
  screens/                         # splash, login, register, onboarding intereses,
                                    # home (tabs), nearby_map_screen (mapa+lista),
                                    # travel_search_screen (modo viaje), event_detail_screen
  widgets/                         # event_card.dart
```
