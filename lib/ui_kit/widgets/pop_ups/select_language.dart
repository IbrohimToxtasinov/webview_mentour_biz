import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentour_web_view/cubits/settings/settings_cubit.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/utils/app_utils.dart';

class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return PopupMenuButton<Locale>(
          color: t.mentourItem0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (locale) {
            FocusScope.of(context).unfocus();
            context.read<SettingsCubit>().changeLocale(locale.languageCode);
            context.setLocale(locale);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: Locale('en'),
              child: Text(
                "English",
                style: TextStyle(color: t.mentourIconColor),
              ),
            ),
            PopupMenuItem(
              value: Locale('ru'),
              child: Text(
                "Русский",
                style: TextStyle(color: t.mentourIconColor),
              ),
            ),
            PopupMenuItem(
              value: Locale('uz'),
              child: Text(
                "O'zbekcha",
                style: TextStyle(color: t.mentourIconColor),
              ),
            ),
            PopupMenuItem(
              value: const Locale('tg'),
              child: Text(
                "Тоҷикӣ",
                style: TextStyle(color: t.mentourIconColor),
              ),
            ),
            PopupMenuItem(
              value: const Locale('ky'),
              child: Text(
                "Кыргызча",
                style: TextStyle(color: t.mentourIconColor),
              ),
            ),
          ],
          child: Row(
            children: [
              Icon(Icons.language, color: t.mentourIconColor, size: 18),
              const SizedBox(width: 6),
              Text(
                AppUtils.getCurrentLanguageLabel(state.language),
                style: TextStyle(color: t.mentourIconColor, fontSize: 14),
              ),
              Icon(Icons.keyboard_arrow_down, color: t.mentourIconColor),
            ],
          ),
        );
      },
    );
  }
}
