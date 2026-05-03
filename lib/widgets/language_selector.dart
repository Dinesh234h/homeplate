import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: 'en', // Mock value for now
          items: const [
            DropdownMenuItem(value: 'en', child: Text('English', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            DropdownMenuItem(value: 'hi', child: Text('हिन्दी', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            DropdownMenuItem(value: 'kn', child: Text('ಕನ್ನಡ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          ],
          onChanged: (val) {
            // Implement language change logic if needed
          },
          icon: const Icon(Icons.language, size: 16, color: AppTheme.primary),
        ),
      ),
    );
  }
}
