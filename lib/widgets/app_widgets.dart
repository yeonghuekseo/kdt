// lib/app_widgets.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';

// 🌟 [모듈화 적용 1] 앱 전체 화면의 공통 뼈대가 되는 베이스 스캐폴드 생성
class EcoGlassScaffold extends StatelessWidget {
  final Widget title;
  final Widget? leading;
  final List<Widget>? actions;
  // 🌟 [모듈화 적용 2] 내부 화면(body)을 그릴 때 자동 계산된 상/하단 여백을 넘겨주는 빌더 함수
  final Widget Function(BuildContext context, double topPadding, double bottomPadding) builder;

  const EcoGlassScaffold({
    super.key,
    required this.title,
    required this.builder,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    // 🌟 [모듈화 적용 3] 여기서 단 한 번만 기기별(노치, 소프트키) 안전 여백을 계산합니다.
    final double topPadding = kToolbarHeight + MediaQuery.of(context).padding.top + 16.0;
    final double bottomPadding = MediaQuery.of(context).padding.bottom + 16.0;

    return Scaffold(
      extendBodyBehindAppBar: true, // 🌟 배경을 앱바 뒤로 꽉 차게 밀어넣음
      appBar: GlassAppBar(
        title: title,
        leading: leading,
        actions: actions,
      ),
      // 🌟 계산된 패딩값을 builder를 통해 내부 컨텐츠로 전달
      body: builder(context, topPadding, bottomPadding),
    );
  }
}

//투명도 + 블러(Glassmorphism)가 적용된 공통 앱바
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;

  const GlassAppBar({super.key, required this.title, this.actions, this.leading});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          title: title,
          actions: actions,
          leading: leading,
          backgroundColor: AppColors.primary.withValues(alpha: 0.85),
          elevation: 0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// [공통 위젯 1] 메인 라운드 채우기 버튼
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double height;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.height = 54.0,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, //강조를 위해 녹색사용
          foregroundColor: Colors.white,
          elevation: 2, //살짝 떠오른 느낌의 그림자
          //[디자인 포인트] 나뭇잎 모양 유지
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
              topRight: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// [공통 위젯 2] 텍스트 이동 버튼 (예: 회원가입 링크)
class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomTextButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.linkText,
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

/// [공통 위젯 3] 공통 입력 필드 (비밀번호 토글 기능 선택 지원)
class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isPassword;
  final TextInputType keyboardType;
  //Form 유효성 검사를 위한 validator 콜백함수 정의
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _isObscure : false,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      decoration: AppTheme.inputDecoration(
        widget.labelText,
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _isObscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: AppColors.primary,
          ),
          onPressed: () =>setState(() => _isObscure = !_isObscure),
        )
            : null,
      ),
    );
  }
}