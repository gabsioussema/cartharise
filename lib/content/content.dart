import '../domain/content.dart';
import 'en.dart';

/// The content library for a language. English is the launch language; other
/// locales fall back to it until a reviewed translation exists (F-053).
ContentLibrary contentFor(String languageCode) => switch (languageCode) {
  _ => englishContent,
};
