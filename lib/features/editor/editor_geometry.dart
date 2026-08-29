import 'dart:math' as math;

import '../../core/models/docdr_template.dart';

class DocDrEditorGeometry {
  static DocDrElement move(DocDrElement e, double dx, double dy) => _copy(
        e,
        x: e.x + dx,
        y: e.y + dy,
      );

  static DocDrElement resize(DocDrElement e, double width, double height) => _copy(
        e,
        width: math.max(1, width),
        height: math.max(1, height),
      );

  static DocDrElement rotate(DocDrElement e, double degrees) => _copy(
        e,
        style: {...e.style, 'rotation': degrees},
      );

  static DocDrElement flipHorizontal(DocDrElement e) => _copy(
        e,
        style: {...e.style, 'flipHorizontal': !(e.style['flipHorizontal'] == true)},
      );

  static DocDrElement flipVertical(DocDrElement e) => _copy(
        e,
        style: {...e.style, 'flipVertical': !(e.style['flipVertical'] == true)},
      );

  static DocDrElement _copy(
    DocDrElement e, {
    double? x,
    double? y,
    double? width,
    double? height,
    Map<String, dynamic>? style,
  }) => DocDrElement(
        id: e.id,
        type: e.type,
        x: x ?? e.x,
        y: y ?? e.y,
        width: width ?? e.width,
        height: height ?? e.height,
        dataKey: e.dataKey,
        value: e.value,
        style: style ?? e.style,
      );
}
