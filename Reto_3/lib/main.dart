import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/services.dart'; // Importa funciones matemáticas como min() y max()

// Función principal que inicia la aplicación Flutter
void main() {
  
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar app en modo pantalla completa inmersiva
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(MyApp());
}

// Widget principal de la aplicación (sin estado)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Triqui (Tic Tac Toe - Reto 3)', // Título de la aplicación
      theme: ThemeData(
        primarySwatch: Colors.blue, // Color principal de la app
        visualDensity: VisualDensity.adaptivePlatformDensity, // Densidad adaptativa
      ),
      home: TicTacToeGame(), // Widget de inicio (el juego)
      debugShowCheckedModeBanner: false,
    );
  }
}

// Widget del juego con estado (puede cambiar durante la ejecución)
class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

// Estado del widget del juego
class _TicTacToeGameState extends State<TicTacToeGame> {
  // Constantes para representar los jugadores y casillas vacías
  static const String HUMAN_PLAYER = 'X';    // Jugador humano usa 'X'
  static const String COMPUTER_PLAYER = 'O'; // Computadora usa 'O'
  static const String OPEN_SPOT = ' ';       // Casilla vacía

  // Variables de estado del juego
  List<String> _board = List.filled(9, OPEN_SPOT); // Tablero de 9 casillas inicialmente vacías
  String _gameStatus = 'Tu turno';                  // Mensaje de estado del juego
  bool _gameActive = true;                          // Indica si el juego está activo

  // Contadores de victorias y empates
  int _playerWins = 0;    // Victorias del jugador
  int _computerWins = 0;  // Victorias de la computadora
  int _ties = 0;          // Empates

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior de la aplicación
      appBar: AppBar(
        title: Text('Triqui'),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
      ),
      body: Column(
        children: [
          // Mensaje de estado del juego
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              _gameStatus,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                // Color cambia según el estado del juego
                color: _gameActive ? Colors.blue[700] : Colors.red[600],
              ),
            ),
          ),

          // Sección de contadores de puntuación
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribuye uniformemente
              children: [
                _buildCounter("Jugador", _playerWins, Colors.blue[700]!),
                _buildCounter("Empates", _ties, Colors.grey[700]!),
                _buildCounter("Máquina", _computerWins, Colors.red[600]!),
              ],
            ),
          ),

          // Tablero del juego
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1, // Mantiene el tablero cuadrado
                child: Container(
                  margin: EdgeInsets.all(20),
                  child: GridView.builder(
                    // Configuración de la cuadrícula 3x3
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,     // 3 columnas
                      crossAxisSpacing: 4,   // Espacio entre columnas
                      mainAxisSpacing: 4,    // Espacio entre filas
                    ),
                    itemCount: 9, // 9 casillas en total
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _onCellTapped(index), // Maneja el toque en la casilla
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue[50],        // Color de fondo claro
                            border: Border.all(
                              color: Colors.blue[300]!,    // Color del borde
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8), // Bordes redondeados
                          ),
                          child: Center(
                            child: Text(
                              _board[index], // Muestra el contenido de la casilla (X, O o vacío)
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                // Color diferente para X (azul) y O (rojo)
                                color: _board[index] == HUMAN_PLAYER 
                                    ? Colors.blue[700] 
                                    : Colors.red[600],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Botón para iniciar nuevo juego
          Padding(
            padding: EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _resetGame, // Función para reiniciar el juego
              child: Text(
                'Nuevo Juego',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],  // Color de fondo del botón
                foregroundColor: Colors.white,     // Color del texto
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Bordes redondeados
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Función auxiliar para construir los contadores de puntuación
  Widget _buildCounter(String title, int count, Color color) {
    return Column(
      children: [
        // Título del contador (ej: "Jugador")
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
        // Número del contador
        Text(
          "$count",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  // Maneja cuando el jugador toca una casilla
  void _onCellTapped(int index) {
    // Verifica si el juego está activo y la casilla está vacía
    if (!_gameActive || _board[index] != OPEN_SPOT) {
      return; // Sale si no se puede hacer el movimiento
    }

    // Realiza el movimiento del jugador
    setMove(HUMAN_PLAYER, index);
    
    // Verifica si hay ganador después del movimiento del jugador
    int winner = checkForWinner();
    if (winner != 0) {
      _handleGameEnd(winner); // Termina el juego si hay ganador
      return;
    }

    // Actualiza el estado para mostrar turno de la computadora
    setState(() {
      _gameStatus = 'Turno de la computadora...';
    });

    // Espera 500ms antes del movimiento de la computadora (para UX)
    Future.delayed(Duration(milliseconds: 500), () {
      if (_gameActive) {
        int computerMove = getComputerMove(); // Calcula el mejor movimiento
        setMove(COMPUTER_PLAYER, computerMove); // Realiza el movimiento
        
        // Verifica ganador después del movimiento de la computadora
        int winner = checkForWinner();
        if (winner != 0) {
          _handleGameEnd(winner); // Termina el juego si hay ganador
        } else {
          // Vuelve al turno del jugador
          setState(() {
            _gameStatus = 'Tu turno';
          });
        }
      }
    });
  }

  // Maneja el final del juego actualizando contadores y estado
  void _handleGameEnd(int winner) {
    setState(() {
      _gameActive = false; // Desactiva el juego
      switch (winner) {
        case 1: // Empate
          _gameStatus = '¡Empate!';
          _ties++;
          break;
        case 2: // Ganó el jugador
          _gameStatus = '¡Ganaste!';
          _playerWins++;
          break;
        case 3: // Ganó la computadora
          _gameStatus = '¡La computadora ganó!';
          _computerWins++;
          break;
      }
    });
  }

  // Reinicia el juego para una nueva partida
  void _resetGame() {
    setState(() {
      clearBoard();              // Limpia el tablero
      _gameStatus = 'Tu turno';  // Resetea el mensaje
      _gameActive = true;        // Reactiva el juego
    });
  }

  // Limpia todas las casillas del tablero
  void clearBoard() {
    _board = List.filled(9, OPEN_SPOT);
  }

  // Coloca una marca (X u O) en una posición del tablero
  void setMove(String player, int location) {
    // Verifica que la posición sea válida y esté vacía
    if (location >= 0 && location < 9 && _board[location] == OPEN_SPOT) {
      setState(() {
        _board[location] = player; // Coloca la marca del jugador
      });
    }
  }

  // Calcula el mejor movimiento para la computadora usando Minimax
  int getComputerMove() {
    int bestScore = -1000; // Inicializa con el peor puntaje posible
    int bestMove = 0;      // Movimiento por defecto

    // Evalúa cada casilla vacía
    for (int i = 0; i < 9; i++) {
      if (_board[i] == OPEN_SPOT) {
        // Simula el movimiento
        _board[i] = COMPUTER_PLAYER;
        // Calcula el puntaje usando Minimax
        int score = _minimax(_board, 0, false);
        // Deshace el movimiento simulado
        _board[i] = OPEN_SPOT;
        
        // Si encuentra un mejor movimiento, lo guarda
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }
    
    return bestMove; // Retorna la mejor posición
  }

  // Algoritmo Minimax para IA: evalúa recursivamente todos los movimientos posibles
  int _minimax(List<String> board, int depth, bool isMaximizing) {
    int winner = checkForWinner(); // Verifica el estado actual
    
    // Casos base: si hay ganador o empate
    if (winner == 3) return 10 - depth; // Computadora gana (prefiere ganar rápido)
    if (winner == 2) return depth - 10; // Jugador gana (malo para la computadora)
    if (winner == 1) return 0;          // Empate (neutral)

    if (isMaximizing) {
      // Turno de la computadora: busca maximizar el puntaje
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (board[i] == OPEN_SPOT) {
          board[i] = COMPUTER_PLAYER;                    // Simula movimiento
          int score = _minimax(board, depth + 1, false); // Recursión
          board[i] = OPEN_SPOT;                          // Deshace movimiento
          bestScore = max(score, bestScore);             // Toma el máximo
        }
      }
      return bestScore;
    } else {
      // Turno del jugador: busca minimizar el puntaje de la computadora
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (board[i] == OPEN_SPOT) {
          board[i] = HUMAN_PLAYER;                      // Simula movimiento del jugador
          int score = _minimax(board, depth + 1, true); // Recursión
          board[i] = OPEN_SPOT;                         // Deshace movimiento
          bestScore = min(score, bestScore);            // Toma el mínimo
        }
      }
      return bestScore;
    }
  }

  // Verifica si hay ganador en el tablero actual
  int checkForWinner() {
    // Todas las combinaciones ganadoras posibles en 3 en raya
    List<List<int>> winPatterns = [
      // Filas horizontales
      [0, 1, 2], [3, 4, 5], [6, 7, 8], 
      // Columnas verticales
      [0, 3, 6], [1, 4, 7], [2, 5, 8], 
      // Diagonales
      [0, 4, 8], [2, 4, 6]             
    ];

    // Verifica cada patrón ganador
    for (List<int> pattern in winPatterns) {
      String first = _board[pattern[0]]; // Primera casilla del patrón
      // Si las tres casillas del patrón tienen la misma marca (y no están vacías)
      if (first != OPEN_SPOT &&
          first == _board[pattern[1]] &&
          first == _board[pattern[2]]) {
        // Retorna 2 si ganó el jugador, 3 si ganó la computadora
        return first == HUMAN_PLAYER ? 2 : 3;
      }
    }

    // Si no hay casillas vacías y no hay ganador, es empate
    if (!_board.contains(OPEN_SPOT)) {
      return 1; // Empate
    }
    
    return 0; // Juego continúa
  }
}