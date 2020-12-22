import 'package:bonus_4/bonus_4.dart';

void main(List<String> arguments) {
  var automata =
      Automata('C:\\Users\\Никита\\Desktop\\4-bonus\\file1.txt');
  print(automata.alphabet.toString() + ' - alphabet' + '\n');
  automata.printNonDeterminedTransitionTable();
  automata.printDeterminedTransitionTable();
}
