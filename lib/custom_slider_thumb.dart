// lib/custom_slider_thumb.dart
import 'package:flutter/material.dart';
import 'dart:math' as math; // 💡 [수정] 물결(Sine Wave)을 그리기 위한 수학 라이브러리 추가
import 'app_theme.dart';

// =============================================================================
// [1] 🌊 커스텀 트랙(막대): 시냇물이 흘러가는 애니메이션을 그리는 막대
// 💡 왜 만들었나요?: 막대 안에 물결 파동을 그려서 4번 컨셉(시냇물 흐름)을 구현하기 위함입니다.
// =============================================================================
class StreamFlowTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  // 💡 왜 적었나요?: 메인 화면에서 계속 돌아가고 있는 물결 애니메이션 컨트롤러를 전달받기 위함입니다.
  final Animation<double> waveAnimation;

  StreamFlowTrackShape({required this.waveAnimation});

  @override
  void paint(
      PaintingContext context,
      Offset offset, {
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required Animation<double> enableAnimation,
        required TextDirection textDirection,
        required Offset thumbCenter,
        Offset? secondaryOffset,
        bool isDiscrete = false,
        bool isEnabled = false,
        double additionalActiveTrackHeight = 2,
      }) {
    final Canvas canvas = context.canvas;

    // 1. 전체 막대(트랙)의 크기와 위치(Rect)를 가져옵니다. (trackHeight 설정값이 반영됨)
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // 막대 모서리를 완전히 둥글게 깎아 알약 모양(RRect)으로 만듭니다.
    final RRect trackRRect = RRect.fromRectAndRadius(trackRect, Radius.circular(trackRect.height / 2));

    // 2. 비활성화된 영역(손잡이 오른쪽)의 텅 빈 트랙을 칠합니다.
    final Paint inactivePaint = Paint()..color = AppColors.primary.withValues(alpha: 0.1);
    canvas.drawRRect(trackRRect, inactivePaint);

    // 3. 활성화된 영역(손잡이 왼쪽)의 사각형 영역을 계산합니다.
    final Rect activeRect = Rect.fromLTRB(trackRect.left, trackRect.top, thumbCenter.dx, trackRect.bottom);

    // 💡 [핵심 원리] 물결이 막대를 벗어나지 않도록 클리핑(가위질) 준비
    canvas.save(); // 캔버스 상태 저장
    canvas.clipRRect(trackRRect); // 이 영역 바깥으로 삐져나가는 그림은 모두 잘라냅니다.

    // 활성화된 영역의 바탕색(연한 녹색 물)을 칠합니다.
    final Paint activeBasePaint = Paint()..color = AppColors.primary.withValues(alpha: 0.3);
    canvas.drawRect(activeRect, activeBasePaint);

    // 4. 🌊 물결(Sine Wave) 그리기
    // 🛠️ [파라미터 조정 가이드] 물결의 진폭(높이)과 주파수(촘촘함)를 설정합니다.
    final double amplitude = trackRect.height / 4; // 물결 높이: 막대 두께의 1/4
    final double frequency = 30.0; // 물결 폭: 숫자가 작을수록 물결이 촘촘해집니다.

    // 애니메이션 값(0.0~1.0)에 따라 물결이 좌측으로 이동(위상 변화)하는 수학적 계산입니다.
    final double phaseShift = waveAnimation.value * 2 * math.pi;

    // 물결을 칠할 붓(흰색 반투명)을 준비합니다.
    final Paint wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    // 점을 이어서 물결 형태의 다각형(Path)을 만듭니다.
    Path wavePath = Path();
    wavePath.moveTo(activeRect.left, activeRect.bottom); // 시작점: 좌측 하단

    // 1픽셀씩 이동하면서 Sine 함수로 물결의 곡선을 점으로 찍어 연결합니다.
    for (double i = 0; i <= activeRect.width; i++) {
      double x = activeRect.left + i;
      // 💡 y축 좌표 구하기: 정중앙 높이(center.dy)를 기준으로 위아래로 출렁입니다.
      double y = trackRect.center.dy + math.sin((i / frequency) + phaseShift) * amplitude;
      wavePath.lineTo(x, y);
    }

    wavePath.lineTo(activeRect.right, activeRect.bottom); // 우측 하단으로 연결
    wavePath.close(); // 영역 닫기

    // 만들어진 물결(Path)을 캔버스에 그립니다.
    canvas.drawPath(wavePath, wavePaint);

    // 가위질(Clip) 설정을 해제하여 다른 위젯이 잘리지 않게 복원합니다.
    canvas.restore();
  }
}


// =============================================================================
// [2] ☁️ 커스텀 손잡이(Thumb): 조약돌과 플로팅 숫자 표시기
// 💡 지난번 코드의 구조를 유지하되, 컨셉에 맞춰 나이테 파동을 제거하고 이슬방울 느낌으로 다듬었습니다.
// =============================================================================
class StreamPebbleThumbShape extends SliderComponentShape {
  final double value;
  final double thumbRadius;

  const StreamPebbleThumbShape({
    required this.value,
    this.thumbRadius = 22.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
      PaintingContext context, Offset center, {
        required Animation<double> activationAnimation, required Animation<double> enableAnimation,
        required bool isDiscrete, required TextPainter labelPainter, required RenderBox parentBox,
        required SliderThemeData sliderTheme, required TextDirection textDirection,
        required double value, required double textScaleFactor, required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    // 1. 조약돌 모양 그리기 (테마 주황색)
    final Rect thumbRect = Rect.fromCenter(
        center: center,
        width: thumbRadius * 3.6,
        height: thumbRadius * 2.7,
    );
    final Path thumbPath = Path()..addOval(thumbRect);

    // 물방울 느낌을 위해 그림자를 살짝 부드럽고 넓게(Elevation 6.0) 퍼뜨립니다.
    canvas.drawShadow(thumbPath, Colors.black.withValues(alpha: 0.2), 6.0, true);

    final Paint fillPaint = Paint()..color = AppColors.sliderThumb..style = PaintingStyle.fill;
    canvas.drawPath(thumbPath, fillPaint);

    // 2. 둥둥 떠다니는 숫자 캡슐 그리기
    final int percentage = (value * 100).toInt();
    final String labelText = '$percentage%'; // 💡 [수정] 숫자에 퍼센트(%) 기호를 붙였습니다.

    // 🛠️ [파라미터 조정 가이드] 캡슐 위치: 두꺼워진 트랙을 피하기 위해 더 높이(32픽셀) 띄웁니다.
    final Offset labelCenter = Offset(center.dx, center.dy - thumbRadius - 32);

    final Paint labelBgPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.85) // 살짝 더 진하게 조정
      ..style = PaintingStyle.fill;

    // 🛠️ [파라미터 조정 가이드] % 기호가 들어갔으므로 캡슐 가로폭을 42.0으로 넓혔습니다.
    final Rect labelRect = Rect.fromCenter(center: labelCenter, width: 42.0, height: 26.0);
    final RRect roundedLabelRect = RRect.fromRectAndRadius(labelRect, const Radius.circular(13));

    canvas.drawShadow(Path()..addRRect(roundedLabelRect), Colors.black.withValues(alpha: 0.15), 3.0, true);
    canvas.drawRRect(roundedLabelRect, labelBgPaint);

    // 3. 텍스트 그리기
    final TextSpan span = TextSpan(
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      text: labelText,
    );

    final TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    tp.layout();

    final Offset textOffset = Offset(
      labelCenter.dx - (tp.width / 2),
      labelCenter.dy - (tp.height / 2),
    );
    tp.paint(canvas, textOffset);
  }
}
