import 'dart:io';

class Automata {
  List<String> nonDeterminedTransitionTable;
  List<String> alphabet;
  List<String> nonDeterminedStates = [];
  List<String> determinedTransitionTable = [];
  Map<String, Map<String, List<String>>> _oldStates;
  final _spacesPattern = RegExp(r'\s+');

  final Set<Set<String>> _newStates = {};
  final Set<Set<String>> _determinedStates = {};

  //initializes, reads table from file and determine the given automata
  Automata(String fileName) {
    var file = File(fileName);
    var lines = file.readAsLinesSync();
    alphabet = lines[0].split(_spacesPattern).skip(1).toList();
    nonDeterminedTransitionTable = lines.skip(1).toList();
    nonDeterminedTransitionTable.forEach((line) {
      assert(line.split(_spacesPattern).length - 1 == alphabet.length);
    });
    _oldStates = _initializeNonDeterminedStates();
    _determineAutomata();
  }

  ///Makes a map of non-determined states and their transitions
  Map<String, Map<String, List<String>>> _initializeNonDeterminedStates() {
    // ignore: omit_local_variable_types
    Map<String, Map<String, List<String>>> states = {};
    nonDeterminedTransitionTable.forEach((line) {
      var array = line.split(_spacesPattern);
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
  //determines the non-determined automata
  void _determineAutomata() {
    Set<Set<String>> currentStates = {};
    var startState = nonDeterminedStates[0];
    var setStartState = Set.of({startState});
    _determinedStates.add(setStartState);
    var startTransition = '';
    startTransition +=
        setStartState.toString() + ':' + _nicePrintStringSpaces(setStartState);
    for (var i = 0; i < alphabet.length; i++) {
      var newState = _oldStates[startState][alphabet[i]].toSet();
      if (_symmetricDifference(setStartState, newState).isNotEmpty) {
        currentStates.add(newState);
        _newStates.add(newState);
        _determinedStates.add(newState);
      }
      startTransition +=
          newState.toString().trim() + _nicePrintStringSpaces(newState);
    }
    determinedTransitionTable.add(startTransition);

    while (_newStates.isNotEmpty) {
      currentStates.forEach((state) {
        _addComplexState(state);
        _newStates.removeWhere(
            (compState) => _symmetricDifference(compState, state).isEmpty);
      });
      currentStates.clear();
      currentStates.addAll(_newStates);
    }
  }
  //adds determined states to determined transition table
  void _addComplexState(Set<String> complexState) {
    if (complexState.isEmpty) return;
    _addIfNotContains(complexState, true);
    var transition = '';
    transition +=
        complexState.toString() + ':' + _nicePrintStringSpaces(complexState);
    for (var i = 0; i < alphabet.length; i++) {
      Set<String> resultState = {};
      complexState.forEach((stateSymbol) {
        var newState = _oldStates[stateSymbol][alphabet[i]].toSet();
        if (newState.length != 1 || newState.first != '-') {
          resultState = resultState.union(newState);
        }
      });
      transition +=
          resultState.toString() + _nicePrintStringSpaces(resultState);
      _addIfNotContains(resultState, false);
    }
    if (!determinedTransitionTable.contains(transition))
      determinedTransitionTable.add(transition);
  }

  void _addIfNotContains(Set<String> state, bool allMode) {
    bool add = true;
    _determinedStates.forEach((added) {
      var equal = _symmetricDifference(added, state).isEmpty;
      if (equal) {
        add = false;
      }
    });
    if (add) {
      allMode ? _determinedStates.add(state) :_newStates.add(state);
    }
  }

  Set<T> _symmetricDifference<T>(Set<T> set1, Set<T> set2) {
    return set1.difference(set2).union(set2.difference(set1));
  }

  void printDeterminedTransitionTable() {
    print('Determined transition table');
    determinedTransitionTable.forEach((line) {
      print(line);
    });
    print('\n');
  }

  void printNonDeterminedTransitionTable() {
    print('Non-determined transition table');
    nonDeterminedTransitionTable.forEach((line) {
      print(line);
    });
    print('\n');
  }

  String _nicePrintStringSpaces(Set state) {
    var string = '';
    if (state.isNotEmpty) {
      string = '   ' * (nonDeterminedStates.length - state.length);
    } else {
      string = '          ';
    }
    return string;
  }
}
