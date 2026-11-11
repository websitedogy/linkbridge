import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Inter scale: title 22, section 16, body 13–14, caption 11–12.
abstract final class AppTypography {
  static TextStyle title({Color? color}) => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: color ?? AppColors.textPrimary,
  );

  static TextStyle section({Color? color}) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: color ?? AppColors.textPrimary,
  );

  static TextStyle body({Color? color}) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: color ?? AppColors.textPrimary,
  );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: color ?? AppColors.textSecondary,
  );

  static TextStyle caption({Color? color}) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: color ?? AppColors.textSecondary,
  );

  static TextStyle captionSmall({Color? color}) => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: color ?? AppColors.textSecondary,
  );

  static TextStyle button({Color? color}) => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: color ?? AppColors.onPrimary,
  );
}
