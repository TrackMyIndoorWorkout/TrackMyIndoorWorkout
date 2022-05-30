// ignore_for_file: type=lint
// ignore_for_file: directives_ordering
import 'package:build_runner_core/build_runner_core.dart' as _i1;
import 'package:floor_generator/builder.dart' as _i2;
import 'package:mockito/src/builder.dart' as _i3;
import 'package:source_gen/builder.dart' as _i4;
import 'dart:isolate' as _i5;
import 'package:build_runner/build_runner.dart' as _i6;
import 'dart:io' as _i7;

final _builders = <_i1.BuilderApplication>[
  _i1.apply(r'floor_generator:floor_generator', [_i2.floorBuilder],
      _i1.toDependentsOf(r'floor_generator'),
      hideOutput: true, appliesBuilders: const [r'source_gen:combining_builder']),
  _i1.apply(r'mockito:mockBuilder', [_i3.buildMocks], _i1.toDependentsOf(r'mockito'),
      hideOutput: false),
  _i1.apply(r'source_gen:combining_builder', [_i4.combiningBuilder], _i1.toNoneByDefault(),
      hideOutput: false, appliesBuilders: const [r'source_gen:part_cleanup']),
  _i1.applyPostProcess(r'source_gen:part_cleanup', _i4.partCleanup)
];
void main(List<String> args, [_i5.SendPort? sendPort]) async {
  var result = await _i6.run(args, _builders);
  sendPort?.send(result);
  _i7.exitCode = result;
}
