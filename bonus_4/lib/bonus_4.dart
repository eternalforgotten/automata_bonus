import 'dart:io';

class Automata {
  List<String> nonDeterminedTransitionTable;
  List<String> alphabet;
  List<String> nonDeterminedStates = [];
  List<String> determinedTransitionTable = [];
  Map<String, Map<String, List<String>>> oldStates;

  Set<Set<String>> newStates = {};
  Set<Set<String>> absoluteAllNewStates = {};

  //initializes and read table from file
  Automata(String fileName, List<String> alphabet) {
    this.alphabet = alphabet;
    var file = File(fileName);
    nonDeterminedTransitionTable = file.readAsLinesSync().skip(1).toList();
    nonDeterminedTransitionTable.forEach((line) {
      assert(line.split(RegExp(r'\s+')).length - 1 == alphabet.length);
    });
    oldStates = _initializeNonDeterminedStates();
    _determineAutomata();
  }

  ///Makes a map of states and their transitions
  Map<String, Map<String, List<String>>> _initializeNonDeterminedStates() {
    // ignore: omit_local_variable_types
    Map<String, Map<String, List<String>>> states = {};
    nonDeterminedTransitionTable.forEach((line) {
      var array = line.split(RegExp(r'\s+'));
      nonDeterminedStates.add(array[0]);
      states.putIfAbsent(array[0], () {
        // ignore: omit_local_variable_types
        Map<String, List<String>> symbolsAndValues = {};
        for (var i = 1; i < array.length; i++) {
          symbolsAndValues.putIfAbsent(alphabet[i - 1], () {
            return array[i].split(',');
          });
        }
        return symbolsAndValues;
      });
    });
    return states;
  }

  void _determineAutomata() {
    Set<Set<String>> currentStates = {};
    var startState = nonDeterminedStates[0];
    var setStartState = Set.of({startState});
    absoluteAllNewStates.add(setStartState);
    var startTransition = '';
    startTransition += setStartState.toString() + ':  ';
    for (var i = 0; i < alphabet.length; i++) {
      var newState = oldStates[startState][alphabet[i]].toSet();
      if (_symmetricDifference(setStartState, newState).isNotEmpty) {
        currentStates.add(newState);
        newStates.add(newState);
        absoluteAllNewStates.add(newState);
      }
      startTransition += newState.toString().trim() + '  ';
    }
    determinedTransitionTable.add(startTransition);

    while (newStates.isNotEmpty) {
      currentStates.forEach((state) {
        _addComplexState(state);
        newStates.removeWhere(
            (compState) => _symmetricDifference(compState, state).isEmpty);
      });
      currentStates.clear();
      currentStates.addAll(newStates);
      print(newStates.toString());
    }
  }

  void _addComplexState(Set<String> complexState) {
    if (complexState.isEmpty) return;
    absoluteAllNewStates.add(complexState);
    var transition = '';
    transition += complexState.toString() + ':  ';
    for (var i = 0; i < alphabet.length; i++) {
      Set<String> resultState = {};
      complexState.forEach((stateSymbol) {
        var newState = oldStates[stateSymbol][alphabet[i]].toSet();
        if (newState.length != 1 || newState.first != '-') {
          resultState = resultState.union(newState);
        }
      });
      transition += resultState.toString() + '  ';
      _addIfNotContains(resultState);
    }
    determinedTransitionTable.add(transition);
  }

  void _addIfNotContains(Set<String> state) {
    bool add = true;
    absoluteAllNewStates.forEach((added) {
      var equal = _symmetricDifference(added, state).isEmpty;
      if (equal) {
        add = false;
      }
    });
    if (add) {
      newStates.add(state);
    }
  }

  Set<T> _symmetricDifference<T>(Set<T> set1, Set<T> set2) {
    return set1.difference(set2).union(set2.difference(set1));
  }

  void printDeterminedTransitionTable() {
    determinedTransitionTable.forEach((line) {
      print(line);
    });
  }
}
