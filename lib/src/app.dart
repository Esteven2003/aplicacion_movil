import 'package:flutter/material.dart';
import 'main_app.dart'; // Asegúrate de importar main_app.dart

class Homepage extends StatefulWidget {
  const Homepage({super.key, required this.themeNotifier});

  final ValueNotifier<ThemeMode> themeNotifier;

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // Agrega controladores para capturar los datos
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _iniciarSesion() {
    // Aquí puedes agregar validaciones
    String usuario = _usuarioController.text;
    String password = _passwordController.text;
    
    debugPrint("Usuario: $usuario");
    debugPrint("Contraseña: $password");

    // Navegar a la aplicación principal
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainApp(
          themeNotifier: widget.themeNotifier,
        ),
      ),
    );
  }

  void _registrate() {
    debugPrint("Botón Regístrate presionado");
    // Aquí puedes navegar a una pantalla de registro
  }

  void _salir() {
    debugPrint("Botón Salir presionado");
    // Cerrar la aplicación
    // Navigator.of(context).pop(); // O usar SystemNavigator.pop() para cerrar completamente
  }

  void _toggleTheme() {
    final isDark = widget.themeNotifier.value == ThemeMode.dark;
    widget.themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: widget.themeNotifier,
              builder: (context, mode, _) {
                final isDark = mode == ThemeMode.dark;
                final colorScheme = Theme.of(context).colorScheme;
                return IconButton(
                  onPressed: _toggleTheme,
                  tooltip:
                      isDark ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
                  icon: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: colorScheme.onSecondaryContainer,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.secondaryContainer,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 100.0,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: const NetworkImage(
                "https://vstatic.vietnam.vn/vietnam/resource/IMAGE/2025/4/28/6f3a83b7fe4141e7a430823f5efc1a92",
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Login",
              style: TextStyle(
                fontFamily: 'NerkoOne',
                fontSize: 50.0,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            SizedBox(height: 40),

            // CAMPO DE USUARIO
            Container(
              width: 300.0,
              child: TextField(
                controller: _usuarioController, // Agregado controller
                enableInteractiveSelection: true,
                decoration: InputDecoration(
                  hintText: "USUARIO",
                  labelText: "Usuario",
                  prefixIcon: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2.0,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 15.0,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.0),

            // CAMPO DE CONTRASEÑA
            Container(
              width: 300.0,
              child: TextField(
                controller: _passwordController, // Agregado controller
                obscureText: true,
                enableInteractiveSelection: true,
                decoration: InputDecoration(
                  hintText: "CONTRASEÑA",
                  labelText: "Contraseña",
                  suffixIcon: Icon(
                    Icons.visibility,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2.0,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 15.0,
                  ),
                ),
              ),
            ),

            SizedBox(height: 30.0),

            // BOTÓN PRINCIPAL - INICIAR SESIÓN (ACTUALIZADO)
            Container(
              width: 300.0,
              height: 50.0,
              child: ElevatedButton(
                onPressed: _iniciarSesion, // Cambiado a la nueva función
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 179, 64, 255),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 5.0,
                ),
                child: Text(
                  "INICIAR SESIÓN",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            SizedBox(height: 15.0),

            // FILA CON LOS DOS BOTONES SECUNDARIOS (ACTUALIZADOS)
            Container(
              width: 300.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BOTÓN REGÍSTRATE
                  Container(
                    width: 140.0,
                    height: 45.0,
                    child: ElevatedButton(
                      onPressed: _registrate, // Cambiado a la nueva función
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 64, 179, 255),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 3.0,
                      ),
                      child: Text(
                        "REGÍSTRATE",
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  // BOTÓN SALIR
                  Container(
                    width: 140.0,
                    height: 45.0,
                    child: ElevatedButton(
                      onPressed: _salir, // Cambiado a la nueva función
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 3.0,
                      ),
                      child: Text(
                        "SALIR",
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}