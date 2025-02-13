import "package:moxxyv2/ui/redux/global/state.dart";
import "package:moxxyv2/ui/redux/global/actions.dart";

GlobalState globalReducer(GlobalState state, dynamic action) {
  if (action is SetDoingWorkAction) {
    return state.copyWith(doingWork: action.state);
  }

  return state;
}
