import 'package:bonus/bonus.dart';

void main(List<String> arguments) {
  //non-determined -> determined
  var automata =
      Automata('C:\\Users\\Никита\\Desktop\\4-bonus\\file1.txt');
  print(automata.alphabet.toString() + ' - alphabet' + '\n');
  automata.printNonDeterminedTransitionTable();
  automata.printDeterminedTransitionTable();
}
