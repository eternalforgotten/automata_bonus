import 'package:bonus_4/bonus_4.dart';

void main(List<String> arguments) {
  var automata =
      Automata('C:\\Users\\Никита\\Desktop\\4-bonus\\file1.txt', ['0', '1']);
  print(automata.alphabet);
  automata.nonDeterminedTransitionTable.forEach((line) {
    print(line + '\n');
  });
  automata.printDeterminedTransitionTable();
}
