import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';
part 'settings_state.g.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default('ar-EG') String locale,
    @Default(true) bool soundEnabled,
    @Default(<String>[
      'zoo',
      'bubble_pop',
      'shape_sorter',
      'finger_paint',
      'drive_vehicle',
    ])
    List<String> enabledGames,
  }) = _SettingsState;

  factory SettingsState.fromJson(Map<String, Object?> json) =>
      _$SettingsStateFromJson(json);
}
