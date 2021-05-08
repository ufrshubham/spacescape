import 'package:flame/components.dart';

// This class represents a command that will be run
// on every component of type T added to game instance.
class Command<T extends Component> {
  // A callback function to be run on
  // components of type T.
  void Function(T target) action;

  Command({required this.action});

  // Runs the callback on given component
  // if it is of type T.
  void run(Component c) {
    if (c is T) {
      action.call(c);
    }
  }
}
