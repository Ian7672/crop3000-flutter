import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

enum AppLanguage {
  indonesian,
  english,
  chinese,
  japanese,
  korean,
  arabic,
  russian,
  hindi;

  String get code {
    switch (this) {
      case AppLanguage.indonesian:
        return 'id';
      case AppLanguage.english:
        return 'en';
      case AppLanguage.chinese:
        return 'zh';
      case AppLanguage.japanese:
        return 'ja';
      case AppLanguage.korean:
        return 'ko';
      case AppLanguage.arabic:
        return 'ar';
      case AppLanguage.russian:
        return 'ru';
      case AppLanguage.hindi:
        return 'hi';
    }
  }

  String get displayName {
    switch (this) {
      case AppLanguage.indonesian:
        return 'Indonesia';
      case AppLanguage.english:
        return 'English';
      case AppLanguage.chinese:
        return '中文';
      case AppLanguage.japanese:
        return '日本語';
      case AppLanguage.korean:
        return '한국어';
      case AppLanguage.arabic:
        return 'العربية';
      case AppLanguage.russian:
        return 'Русский';
      case AppLanguage.hindi:
        return 'हिन्दी';
    }
  }

  Locale get locale => Locale(code);

  TextDirection get textDirection =>
      this == AppLanguage.arabic ? TextDirection.rtl : TextDirection.ltr;

  static List<Locale> get supportedLocales =>
      values.map((lang) => lang.locale).toList(growable: false);

  static AppLanguage fromCode(String code) {
    return values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.indonesian,
    );
  }
}

enum ProcessingIssue { notFound, decode, empty, encode, write, unknown }

class _ProcessingException implements Exception {
  const _ProcessingException(this.type);
  final ProcessingIssue type;
}

class AppStrings {
  AppStrings(this.language);

  final AppLanguage language;

  T _pick<T>({
    required T id,
    required T en,
    required T zh,
    required T ja,
    required T ko,
    required T ar,
    required T ru,
    required T hi,
  }) {
    switch (language) {
      case AppLanguage.indonesian:
        return id;
      case AppLanguage.english:
        return en;
      case AppLanguage.chinese:
        return zh;
      case AppLanguage.japanese:
        return ja;
      case AppLanguage.korean:
        return ko;
      case AppLanguage.arabic:
        return ar;
      case AppLanguage.russian:
        return ru;
      case AppLanguage.hindi:
        return hi;
    }
  }

  String get appTitle => _pick(
        id: 'Crop3000',
        en: 'Crop3000',
        zh: 'Crop3000',
        ja: 'Crop3000',
        ko: 'Crop3000',
        ar: 'Crop3000',
        ru: 'Crop3000',
        hi: 'Crop3000',
      );

  String get manualPathLabel => _pick(
        id: 'Path file manual',
        en: 'Manual file path',
        zh: '手动添加路径',
        ja: '手動パスを追加',
        ko: '수동 경로 추가',
        ar: 'إضافة مسار يدوي',
        ru: 'Добавить путь вручную',
        hi: 'मैनुअल पाथ जोड़ें',
      );

  String get manualPathHint => _pick(
        id: 'Tempel path file atau folder di sini',
        en: 'Paste a file or folder path here',
        zh: '在这里粘贴文件或文件夹路径',
        ja: 'ここにファイルやフォルダのパスを貼り付けてください',
        ko: '파일 또는 폴더 경로를 여기에 붙여넣으세요',
        ar: 'ألصق مسار ملف أو مجلد هنا',
        ru: 'Вставьте сюда путь к файлу или папке',
        hi: 'यहाँ फ़ाइल या फ़ोल्डर का पाथ चिपकाएँ',
      );

  String get manualPathAdd => _pick(
        id: 'Tambah',
        en: 'Add',
        zh: '添加',
        ja: '追加',
        ko: '추가',
        ar: 'إضافة',
        ru: 'Добавить',
        hi: 'जोड़ें',
      );

  String get browseButton => _pick(
        id: 'Pilih File',
        en: 'Choose Files',
        zh: '选择文件',
        ja: 'ファイルを選択',
        ko: '파일 선택',
        ar: 'اختيار ملفات',
        ru: 'Выбрать файлы',
        hi: 'फ़ाइल चुनें',
      );

  String get clearListButton => _pick(
        id: 'Bersihkan Daftar',
        en: 'Clear List',
        zh: '清空列表',
        ja: '一覧をクリア',
        ko: '목록 지우기',
        ar: 'مسح القائمة',
        ru: 'Очистить список',
        hi: 'सूची साफ़ करें',
      );

  String get targetSizeLabel => _pick(
        id: 'Ukuran keluaran (px)',
        en: 'Output size (px)',
        zh: '输出尺寸（像素）',
        ja: '出力サイズ（px）',
        ko: '출력 크기 (px)',
        ar: 'حجم الإخراج (بكسل)',
        ru: 'Размер вывода (px)',
        hi: 'आउटपुट आकार (px)',
      );

  String targetSizeHelper(int defaultTarget) => _pick(
        id: 'Default ${defaultTarget}px',
        en: 'Default ${defaultTarget}px',
        zh: '默认 ${defaultTarget}px',
        ja: 'デフォルト ${defaultTarget}px',
        ko: '기본값 ${defaultTarget}px',
        ar: 'الإعداد الافتراضي ${defaultTarget}px',
        ru: 'По умолчанию ${defaultTarget}px',
        hi: 'डिफ़ॉल्ट ${defaultTarget}px',
      );

  String get themeSectionTitle => _pick(
        id: 'Tema',
        en: 'Theme',
        zh: '主题',
        ja: 'テーマ',
        ko: '테마',
        ar: 'المظهر',
        ru: 'Тема',
        hi: 'थीम',
      );

  String get themeLight => _pick(
        id: 'Terang',
        en: 'Light',
        zh: '浅色',
        ja: 'ライト',
        ko: '라이트',
        ar: 'فاتح',
        ru: 'Светлая',
        hi: 'लाइट',
      );

  String get themeDark => _pick(
        id: 'Gelap',
        en: 'Dark',
        zh: '深色',
        ja: 'ダーク',
        ko: '다크',
        ar: 'داكن',
        ru: 'Тёмная',
        hi: 'डार्क',
      );

  String get themeSystem => _pick(
        id: 'Ikuti sistem',
        en: 'System',
        zh: '跟随系统',
        ja: 'システムに合わせる',
        ko: '시스템',
        ar: 'حسب النظام',
        ru: 'Системная',
        hi: 'सिस्टम',
      );

  String get compressionDropdownLabel => _pick(
        id: 'Mode Kompresi',
        en: 'Compression',
        zh: '压缩模式',
        ja: '圧縮モード',
        ko: '압축 모드',
        ar: 'وضع الضغط',
        ru: 'Режим сжатия',
        hi: 'संपीड़न मोड',
      );

  String get formatDropdownLabel => _pick(
        id: 'Format Simpan',
        en: 'Save format',
        zh: '保存格式',
        ja: '保存形式',
        ko: '저장 형식',
        ar: 'صيغة الحفظ',
        ru: 'Формат сохранения',
        hi: 'सेव फ़ॉर्मेट',
      );

  String get settingsTooltip => _pick(
        id: 'Pengaturan',
        en: 'Settings',
        zh: '设置',
        ja: '設定',
        ko: '설정',
        ar: 'الإعدادات',
        ru: 'Настройки',
        hi: 'सेटिंग्स',
      );

  String get settingsTitle => _pick(
        id: 'Pengaturan & Info',
        en: 'Settings & About',
        zh: '设置与信息',
        ja: '設定と情報',
        ko: '설정 및 정보',
        ar: 'الإعدادات والمعلومات',
        ru: 'Настройки и сведения',
        hi: 'सेटिंग्स और जानकारी',
      );

  String get languageMenuTitle => _pick(
        id: 'Bahasa',
        en: 'Language',
        zh: '语言',
        ja: '言語',
        ko: '언어',
        ar: 'اللغة',
        ru: 'Язык',
        hi: 'भाषा',
      );

  String get languageHelp => _pick(
        id: 'Pilih bahasa antarmuka.',
        en: 'Pick the UI language.',
        zh: '选择界面语言。',
        ja: 'UI の言語を選択してください。',
        ko: '인터페이스 언어를 선택하세요.',
        ar: 'اختر لغة الواجهة.',
        ru: 'Выберите язык интерфейса.',
        hi: 'इंटरफ़ेस की भाषा चुनें।',
      );

  String currentLanguageLabel(String name) => _pick(
        id: 'Bahasa aktif: $name',
        en: 'Current: $name',
        zh: '当前语言：$name',
        ja: '現在: $name',
        ko: '현재 언어: $name',
        ar: 'اللغة الحالية: $name',
        ru: 'Текущий: $name',
        hi: 'वर्तमान: $name',
      );

  String settingsButtonLabel(String name) => _pick(
        id: 'Pengaturan ($name)',
        en: 'Settings ($name)',
        zh: '设置（$name）',
        ja: '設定（$name）',
        ko: '설정 ($name)',
        ar: 'الإعدادات ($name)',
        ru: 'Настройки ($name)',
        hi: 'सेटिंग्स ($name)',
      );

  String get helpButtonLabel => _pick(
        id: 'Panduan',
        en: 'Help',
        zh: 'Help',
        ja: 'Help',
        ko: 'Help',
        ar: 'Help',
        ru: 'Help',
        hi: 'Help',
      );

  String get helpTooltip => _pick(
        id: 'Buka panduan lengkap Crop3000',
        en: 'Open the full Crop3000 guide',
        zh: 'Open the full guide',
        ja: 'Open the full guide',
        ko: 'Open the full guide',
        ar: 'Open the full guide',
        ru: 'Open the full guide',
        hi: 'Open the full guide',
      );

  String get helpDialogTitle => _pick(
        id: 'Panduan Crop3000',
        en: 'Crop3000 Guide',
        zh: 'Crop3000 Guide',
        ja: 'Crop3000 Guide',
        ko: 'Crop3000 Guide',
        ar: 'Crop3000 Guide',
        ru: 'Crop3000 Guide',
        hi: 'Crop3000 Guide',
      );

  String get helpDialogDescription => _pick(
        id: 'Ikuti langkah berikut untuk menyiapkan dan memproses gambar dengan cepat:',
        en: 'Follow these steps to prepare and process images quickly:',
        zh: 'Follow these steps to prepare and process images quickly:',
        ja: 'Follow these steps to prepare and process images quickly:',
        ko: 'Follow these steps to prepare and process images quickly:',
        ar: 'Follow these steps to prepare and process images quickly:',
        ru: 'Follow these steps to prepare and process images quickly:',
        hi: 'Follow these steps to prepare and process images quickly:',
      );

  List<String> get helpDialogSteps => _pick(
        id: [
          'Tambahkan foto melalui drag & drop, tombol Pilih File, atau input path manual.',
          'Atur ukuran keluaran, format (JPG/PNG/BMP), dan mode kompresi sesuai kebutuhan.',
          'Gunakan menu Compression untuk menyeimbangkan kualitas vs ukuran file.',
          'Tekan Mulai dan biarkan proses berjalan di background; UI akan tetap responsif.',
        ],
        en: [
          'Add photos via drag & drop, the Choose Files button, or manual path input.',
          'Adjust output size, choose JPG/PNG/BMP, and pick the compression profile you need.',
          'Use the Compression menu to balance quality versus file size.',
          'Press Start to run the batch; heavy work stays in the background so the UI remains smooth.',
        ],
        zh: [
          'Add photos via drag & drop, the Choose Files button, or manual path input.',
          'Adjust output size, choose JPG/PNG/BMP, and pick the compression profile you need.',
          'Use the Compression menu to balance quality versus file size.',
          'Press Start to run the batch; heavy work stays in the background so the UI remains smooth.',
        ],
        ja: [
          'Add photos via drag & drop, the Choose Files button, or manual path input.',
          'Adjust output size, choose JPG/PNG/BMP, and pick the compression profile you need.',
          'Use the Compression menu to balance quality versus file size.',
          'Press Start to run the batch; heavy work stays in the background so the UI remains smooth.',
        ],
        ko: [
          'Add photos via drag & drop, the Choose Files button, or manual path input.',
          'Adjust output size, choose JPG/PNG/BMP, and pick the compression profile you need.',
          'Use the Compression menu to balance quality versus file size.',
          'Press Start to run the batch; heavy work stays in the background so the UI remains smooth.',
        ],
        ar: [
          'Add photos via drag & drop, the Choose Files button, or manual path input.',
          'Adjust output size, choose JPG/PNG/BMP, and pick the compression profile you need.',
          'Use the Compression menu to balance quality versus file size.',
          'Press Start to run the batch; heavy work stays in the background so the UI remains smooth.',
        ],
        ru: [
          'Add photos via drag & drop, the Choose Files button, or manual path input.',
          'Adjust output size, choose JPG/PNG/BMP, and pick the compression profile you need.',
          'Use the Compression menu to balance quality versus file size.',
          'Press Start to run the batch; heavy work stays in the background so the UI remains smooth.',
        ],
        hi: [
          'Add photos via drag & drop, the Choose Files button, or manual path input.',
          'Adjust output size, choose JPG/PNG/BMP, and pick the compression profile you need.',
          'Use the Compression menu to balance quality versus file size.',
          'Press Start to run the batch; heavy work stays in the background so the UI remains smooth.',
        ],
      );

  String get helpDialogFooter => _pick(
        id: 'Tip: Tombol bantuan bisa ditekan kapan pun untuk membaca ulang panduan atau membuka README.',
        en: 'Tip: Tap the help button anytime to revisit this guide or open the README.',
        zh: 'Tip: Tap the help button anytime to revisit this guide or open the README.',
        ja: 'Tip: Tap the help button anytime to revisit this guide or open the README.',
        ko: 'Tip: Tap the help button anytime to revisit this guide or open the README.',
        ar: 'Tip: Tap the help button anytime to revisit this guide or open the README.',
        ru: 'Tip: Tap the help button anytime to revisit this guide or open the README.',
        hi: 'Tip: Tap the help button anytime to revisit this guide or open the README.',
      );

  String get helpDialogOpenReadme => _pick(
        id: 'Buka README',
        en: 'Open README',
        zh: 'Open README',
        ja: 'Open README',
        ko: 'Open README',
        ar: 'Open README',
        ru: 'Open README',
        hi: 'Open README',
      );

  String get dropTitle => _pick(
        id: 'Letakkan gambar di sini',
        en: 'Drop your images here',
        zh: '把图片拖到这里',
        ja: 'ここに画像をドロップ',
        ko: '여기에 이미지를 놓으세요',
        ar: 'أفلت الصور هنا',
        ru: 'Перетащите изображения сюда',
        hi: 'चित्र यहाँ छोड़ें',
      );

  String dropSubtitle(int size) => _pick(
        id: 'Kami akan menjadikannya persegi ${size}px',
        en: 'We will crop them to ${size}px squares',
        zh: '将裁剪为 ${size}px 正方形',
        ja: '${size}px の正方形にトリミングします',
        ko: '${size}px 정사각형으로 자릅니다',
        ar: 'سنقصها إلى مربع $size بكسل',
        ru: 'Обрежем до квадрата ${size}px',
        hi: 'हम इसे ${size}px के वर्ग में काटेंगे',
      );

  String get dropInstructions => _pick(
        id: 'Seret file PNG/JPG atau klik tombol di bawah.',
        en: 'Drag PNG/JPG files or use the buttons below.',
        zh: '拖拽 PNG/JPG 文件或使用下方按钮。',
        ja: 'PNG/JPG をドラッグ＆ドロップ、または下のボタンから選択。',
        ko: 'PNG/JPG 파일을 드래그하거나 아래 버튼을 사용하세요.',
        ar: 'اسحب ملفات PNG/JPG أو استخدم الأزرار أدناه.',
        ru: 'Перетащите PNG/JPG или выберите через кнопки ниже.',
        hi: 'PNG/JPG फ़ाइलें खींचें या नीचे के बटन इस्तेमाल करें।',
      );

  String compressionLabel(CompressionMode mode) {
    final labels = _pick<Map<CompressionMode, String>>(
      id: {
        CompressionMode.none: 'Tanpa Kompresi',
        CompressionMode.balanced: 'Kompresi Seimbang',
        CompressionMode.aggressive: 'Kompresi Maksimal',
      },
      en: {
        CompressionMode.none: 'No compression',
        CompressionMode.balanced: 'Balanced compression',
        CompressionMode.aggressive: 'Maximum compression',
      },
      zh: {
        CompressionMode.none: '不压缩',
        CompressionMode.balanced: '平衡压缩',
        CompressionMode.aggressive: '最高压缩',
      },
      ja: {
        CompressionMode.none: '圧縮なし',
        CompressionMode.balanced: 'バランス圧縮',
        CompressionMode.aggressive: '最大圧縮',
      },
      ko: {
        CompressionMode.none: '압축 없음',
        CompressionMode.balanced: '균형 압축',
        CompressionMode.aggressive: '최대 압축',
      },
      ar: {
        CompressionMode.none: 'بدون ضغط',
        CompressionMode.balanced: 'ضغط متوازن',
        CompressionMode.aggressive: 'ضغط أقصى',
      },
      ru: {
        CompressionMode.none: 'Без сжатия',
        CompressionMode.balanced: 'Сбалансированное',
        CompressionMode.aggressive: 'Максимальное',
      },
      hi: {
        CompressionMode.none: 'बिना संपीड़न',
        CompressionMode.balanced: 'संतुलित संपीड़न',
        CompressionMode.aggressive: 'अधिकतम संपीड़न',
      },
    );
    return labels[mode]!;
  }

  String compressionDescription(CompressionMode mode) {
    final descriptions = _pick<Map<CompressionMode, String>>(
      id: {
        CompressionMode.none: 'Menjaga kualitas asli, ukuran file bisa lebih besar.',
        CompressionMode.balanced: 'Ukuran turun tanpa banyak mengorbankan detail visual.',
        CompressionMode.aggressive: 'Ukuran jauh lebih kecil, detail halus bisa sedikit berkurang.',
      },
      en: {
        CompressionMode.none: 'Keeps original quality, larger file size.',
        CompressionMode.balanced: 'Reduces size while keeping detail.',
        CompressionMode.aggressive: 'Smallest size, fine details may drop.',
      },
      zh: {
        CompressionMode.none: '保持原始质量，文件更大。',
        CompressionMode.balanced: '降低体积并保持清晰。',
        CompressionMode.aggressive: '体积最小，细节可能下降。',
      },
      ja: {
        CompressionMode.none: '品質を維持、サイズ大きめ。',
        CompressionMode.balanced: '見た目を保ちつつ容量削減。',
        CompressionMode.aggressive: '最小サイズ、細部は少し失われます。',
      },
      ko: {
        CompressionMode.none: '원본 품질 유지, 용량 큼.',
        CompressionMode.balanced: '품질을 유지하며 용량 감소.',
        CompressionMode.aggressive: '가장 작게, 세부가 줄어들 수 있음.',
      },
      ar: {
        CompressionMode.none: 'يحافظ على الجودة الأصلية بحجم أكبر.',
        CompressionMode.balanced: 'حجم أصغر مع الحفاظ على التفاصيل.',
        CompressionMode.aggressive: 'أصغر حجم وقد تفقد بعض التفاصيل.',
      },
      ru: {
        CompressionMode.none: 'Сохраняет качество, файл больше.',
        CompressionMode.balanced: 'Меньше размер при хорошем качестве.',
        CompressionMode.aggressive: 'Минимальный размер, детали могут потеряться.',
      },
      hi: {
        CompressionMode.none: 'मूल गुणवत्ता, आकार बड़ा।',
        CompressionMode.balanced: 'गुणवत्ता रखते हुए आकार घटाए।',
        CompressionMode.aggressive: 'सबसे छोटा आकार, कुछ बारीकी घट सकती है।',
      },
    );
    return descriptions[mode]!;
  }

  String compressionNotSupported(String format) => _pick(
        id: 'Kompresi tidak tersedia untuk $format.',
        en: "Compression isn't available for $format.",
        zh: '$format 不支持压缩。',
        ja: '$format は圧縮できません。',
        ko: '$format 는 압축을 지원하지 않습니다.',
        ar: '$format لا يدعم الضغط.',
        ru: 'Сжатие недоступно для $format.',
        hi: '$format के लिए संपीड़न उपलब्ध नहीं।',
      );

  String get formatShortJpg => _pick(
        id: 'JPG',
        en: 'JPG',
        zh: 'JPG',
        ja: 'JPG',
        ko: 'JPG',
        ar: 'JPG',
        ru: 'JPG',
        hi: 'JPG',
      );

  String get formatShortPng => _pick(
        id: 'PNG',
        en: 'PNG',
        zh: 'PNG',
        ja: 'PNG',
        ko: 'PNG',
        ar: 'PNG',
        ru: 'PNG',
        hi: 'PNG',
      );

  String get formatShortBmp => _pick(
        id: 'BMP',
        en: 'BMP',
        zh: 'BMP',
        ja: 'BMP',
        ko: 'BMP',
        ar: 'BMP',
        ru: 'BMP',
        hi: 'BMP',
      );

  String formatLabel(OutputFormat format) {
    final labels = _pick<Map<OutputFormat, String>>(
      id: {
        OutputFormat.jpg: 'JPG (.jpg) - Default untuk foto',
        OutputFormat.png: 'PNG (.png) - Transparan & lossless',
        OutputFormat.bmp: 'BMP (.bmp) - Tanpa kompresi',
      },
      en: {
        OutputFormat.jpg: 'JPG (.jpg) - Photo friendly',
        OutputFormat.png: 'PNG (.png) - Transparent & lossless',
        OutputFormat.bmp: 'BMP (.bmp) - No compression',
      },
      zh: {
        OutputFormat.jpg: 'JPG (.jpg) - 照片默认',
        OutputFormat.png: 'PNG (.png) - 透明/无损',
        OutputFormat.bmp: 'BMP (.bmp) - 无压缩',
      },
      ja: {
        OutputFormat.jpg: 'JPG (.jpg) - 写真向け',
        OutputFormat.png: 'PNG (.png) - 透過・無劣化',
        OutputFormat.bmp: 'BMP (.bmp) - 非圧縮',
      },
      ko: {
        OutputFormat.jpg: 'JPG (.jpg) - 사진 기본값',
        OutputFormat.png: 'PNG (.png) - 투명/무손실',
        OutputFormat.bmp: 'BMP (.bmp) - 무압축',
      },
      ar: {
        OutputFormat.jpg: 'JPG (.jpg) - افتراضي للصور',
        OutputFormat.png: 'PNG (.png) - شفافية/بلا فقدان',
        OutputFormat.bmp: 'BMP (.bmp) - بلا ضغط',
      },
      ru: {
        OutputFormat.jpg: 'JPG (.jpg) — для фото',
        OutputFormat.png: 'PNG (.png) — прозрачность/без потерь',
        OutputFormat.bmp: 'BMP (.bmp) — без сжатия',
      },
      hi: {
        OutputFormat.jpg: 'JPG (.jpg) - फोटो के लिए',
        OutputFormat.png: 'PNG (.png) - पारदर्शी/लॉसलेस',
        OutputFormat.bmp: 'BMP (.bmp) - बिना संपीड़न',
      },
    );
    return labels[format]!;
  }

  String formatDescription(OutputFormat format) {
    final descriptions = _pick<Map<OutputFormat, String>>(
      id: {
        OutputFormat.jpg: 'Ukuran file kecil cocok untuk foto dan sharing.',
        OutputFormat.png: 'Kualitas tetap tajam dan mendukung transparansi.',
        OutputFormat.bmp: 'Format mentah tanpa kompresi, ukuran bisa besar.',
      },
      en: {
        OutputFormat.jpg: 'Smaller files, great for sharing.',
        OutputFormat.png: 'Crisp quality with transparency support.',
        OutputFormat.bmp: 'Raw format without compression; larger size.',
      },
      zh: {
        OutputFormat.jpg: '文件小，适合分享。',
        OutputFormat.png: '画面清晰并支持透明。',
        OutputFormat.bmp: '原始格式，体积较大。',
      },
      ja: {
        OutputFormat.jpg: '容量が小さく共有に最適。',
        OutputFormat.png: 'くっきり保存、透過対応。',
        OutputFormat.bmp: '生データで容量が大きい。',
      },
      ko: {
        OutputFormat.jpg: '용량이 작아 공유에 적합.',
        OutputFormat.png: '선명하고 투명도 지원.',
        OutputFormat.bmp: '원본 형식으로 용량이 큼.',
      },
      ar: {
        OutputFormat.jpg: 'حجم صغير مناسب للمشاركة.',
        OutputFormat.png: 'جودة واضحة مع دعم الشفافية.',
        OutputFormat.bmp: 'صيغة خام بحجم كبير.',
      },
      ru: {
        OutputFormat.jpg: 'Малый размер, удобно делиться.',
        OutputFormat.png: 'Чёткое качество и поддержка прозрачности.',
        OutputFormat.bmp: 'Не сжатый формат, файлы крупные.',
      },
      hi: {
        OutputFormat.jpg: 'छोटा आकार, साझा करना आसान.',
        OutputFormat.png: 'स्पष्ट गुणवत्ता और पारदर्शिता.',
        OutputFormat.bmp: 'कच्चा फ़ॉर्मेट, आकार बड़ा.',
      },
    );
    return descriptions[format]!;
  }

  String formatShortLabel(OutputFormat format) {
    switch (format) {
      case OutputFormat.jpg:
        return formatShortJpg;
      case OutputFormat.png:
        return formatShortPng;
      case OutputFormat.bmp:
        return formatShortBmp;
    }
  }

  String get emptyPendingList => _pick(
        id: 'Belum ada file. Tarik & lepas atau pilih file.',
        en: 'No files yet. Drag & drop or pick files.',
        zh: '暂无文件。拖拽或选择要处理的图片。',
        ja: 'ファイルがありません。ドラッグするか選択してください。',
        ko: '파일이 없습니다. 드래그하거나 선택하세요.',
        ar: 'لا توجد ملفات بعد. اسحبها أو اخترها.',
        ru: 'Файлы не выбраны. Перетащите или добавьте их.',
        hi: 'अभी कोई फ़ाइल नहीं। ड्रैग करें या चुनें।',
      );

  String fileListTitle(int count) => _pick(
        id: 'Daftar file ($count)',
        en: 'Files ($count)',
        zh: '文件列表（$count）',
        ja: 'ファイル一覧 ($count)',
        ko: '파일 목록 ($count)',
        ar: 'قائمة الملفات ($count)',
        ru: 'Список файлов ($count)',
        hi: 'फ़ाइल सूची ($count)',
      );

  String get removeFromList => _pick(
        id: 'Hapus',
        en: 'Remove',
        zh: '移除',
        ja: '削除',
        ko: '제거',
        ar: 'إزالة',
        ru: 'Удалить',
        hi: 'हटाएँ',
      );

  String progressLabel(int processed, int total, String percent) => _pick(
        id: '$processed dari $total selesai ($percent%)',
        en: '$processed of $total done ($percent%)',
        zh: '$processed / $total 已完成（$percent%）',
        ja: '$processed / $total 完了（$percent%）',
        ko: '$processed / $total 완료 ($percent%)',
        ar: '$processed من $total تم ($percent%)',
        ru: '$processed из $total выполнено ($percent%)',
        hi: '$processed / $total पूरा ($percent%)',
      );

  String get tipText => _pick(
        id: 'Tip: tempel path atau seret banyak file sekaligus.',
        en: 'Tip: paste a path or drop multiple files at once.',
        zh: '提示：可以直接粘贴路径或一次拖入多张图片。',
        ja: 'ヒント: パス貼り付けや複数ドラッグにも対応しています。',
        ko: '팁: 경로 붙여넣기나 여러 파일 드래그도 가능합니다.',
        ar: 'تلميح: يمكنك لصق المسار أو سحب عدة ملفات دفعة واحدة.',
        ru: 'Подсказка: можно вставить путь или перетащить несколько файлов.',
        hi: 'टिप: पाथ चिपकाएँ या कई फ़ाइलें एक साथ ड्रैग करें।',
      );

  String historyTitle(int count) => _pick(
        id: 'Riwayat ($count)',
        en: 'History ($count)',
        zh: '处理记录（$count）',
        ja: '履歴 ($count)',
        ko: '기록 ($count)',
        ar: 'السجل ($count)',
        ru: 'История ($count)',
        hi: 'इतिहास ($count)',
      );

  String get browseErrorPrefix => _pick(
        id: 'Gagal membuka file:',
        en: "Couldn't open files:",
        zh: '无法打开文件：',
        ja: 'ファイルを開けませんでした:',
        ko: '파일을 열 수 없습니다:',
        ar: 'تعذر فتح الملفات:',
        ru: 'Не удалось открыть файлы:',
        hi: 'फ़ाइल खोल नहीं सके:',
      );

  String browseError(String error) => '$browseErrorPrefix $error';

  String get processingButton => _pick(
        id: 'Memproses...',
        en: 'Processing...',
        zh: '处理中...',
        ja: '処理中...',
        ko: '처리 중...',
        ar: 'جارٍ المعالجة...',
        ru: 'Обработка...',
        hi: 'प्रोसेस हो रहा है...',
      );

  String get startButton => _pick(
        id: 'Mulai',
        en: 'Start',
        zh: '开始',
        ja: '開始',
        ko: '시작',
        ar: 'ابدأ',
        ru: 'Начать',
        hi: 'शुरू करें',
      );

  String invalidSize(int defaultSize) => _pick(
        id: 'Ukuran tidak valid, pakai ${defaultSize}px.',
        en: 'Invalid size, fallback to ${defaultSize}px.',
        zh: '尺寸无效，已改为 ${defaultSize}px。',
        ja: 'サイズが無効です。${defaultSize}px を使用します。',
        ko: '잘못된 크기입니다. ${defaultSize}px를 사용합니다.',
        ar: 'حجم غير صالح، تم استخدام ${defaultSize}px.',
        ru: 'Недопустимый размер, используем ${defaultSize}px.',
        hi: 'आकार गलत है, ${defaultSize}px उपयोग होगा.',
      );

  String get unsupportedFormatMessage => _pick(
        id: 'Format tidak didukung.',
        en: 'Unsupported format.',
        zh: '不支持的格式。',
        ja: '未対応の形式です。',
        ko: '지원하지 않는 형식입니다.',
        ar: 'صيغة غير مدعومة.',
        ru: 'Формат не поддерживается.',
        hi: 'असमर्थित फ़ॉर्मेट।',
      );

  String compressionLogSuffix(CompressionMode mode) {
    final suffix = _pick<Map<CompressionMode, String>>(
      id: {
        CompressionMode.none: '(tanpa kompresi)',
        CompressionMode.balanced: '(kompresi seimbang)',
        CompressionMode.aggressive: '(kompresi maksimal)',
      },
      en: {
        CompressionMode.none: '(no compression)',
        CompressionMode.balanced: '(balanced)',
        CompressionMode.aggressive: '(maximum)',
      },
      zh: {
        CompressionMode.none: '(不压缩)',
        CompressionMode.balanced: '(平衡压缩)',
        CompressionMode.aggressive: '(最高压缩)',
      },
      ja: {
        CompressionMode.none: '(圧縮なし)',
        CompressionMode.balanced: '(バランス圧縮)',
        CompressionMode.aggressive: '(最大圧縮)',
      },
      ko: {
        CompressionMode.none: '(압축 없음)',
        CompressionMode.balanced: '(균형 압축)',
        CompressionMode.aggressive: '(최대 압축)',
      },
      ar: {
        CompressionMode.none: '(بدون ضغط)',
        CompressionMode.balanced: '(ضغط متوازن)',
        CompressionMode.aggressive: '(ضغط أقصى)',
      },
      ru: {
        CompressionMode.none: '(без сжатия)',
        CompressionMode.balanced: '(сбаланс.)',
        CompressionMode.aggressive: '(макс. сжатие)',
      },
      hi: {
        CompressionMode.none: '(बिना संपीड़न)',
        CompressionMode.balanced: '(संतुलित संपीड़न)',
        CompressionMode.aggressive: '(अधिकतम संपीड़न)',
      },
    );
    return suffix[mode]!;
  }

  String successLog(int targetSize, String format, {required String compressionNote}) {
    final text = _pick<String>(
      id: 'Berhasil: ${targetSize}px $format $compressionNote',
      en: 'Saved ${targetSize}px $format $compressionNote',
      zh: '已保存 ${targetSize}px $format $compressionNote',
      ja: '${targetSize}px の $format を保存しました $compressionNote',
      ko: '${targetSize}px $format 저장 완료 $compressionNote',
      ar: 'تم الحفظ ${targetSize}px $format $compressionNote',
      ru: 'Сохранено ${targetSize}px $format $compressionNote',
      hi: '${targetSize}px $format सहेजा गया $compressionNote',
    );
    return text.trim();
  }

  String processingError(ProcessingIssue type) {
    final messages = _pick<Map<ProcessingIssue, String>>(
      id: {
        ProcessingIssue.notFound: 'File tidak ditemukan.',
        ProcessingIssue.decode: 'Format gambar tidak dikenali.',
        ProcessingIssue.empty: 'Gambar kosong.',
        ProcessingIssue.encode: 'Gagal memproses gambar.',
        ProcessingIssue.write: 'Tidak bisa menyimpan file.',
        ProcessingIssue.unknown: 'Terjadi kesalahan tidak dikenal.',
      },
      en: {
        ProcessingIssue.notFound: 'File not found.',
        ProcessingIssue.decode: "Image can't be read.",
        ProcessingIssue.empty: 'Image is empty.',
        ProcessingIssue.encode: 'Failed to process image.',
        ProcessingIssue.write: "Couldn't save the file.",
        ProcessingIssue.unknown: 'Unexpected error occurred.',
      },
      zh: {
        ProcessingIssue.notFound: '未找到文件。',
        ProcessingIssue.decode: '无法解析图像。',
        ProcessingIssue.empty: '图像为空。',
        ProcessingIssue.encode: '处理图像失败。',
        ProcessingIssue.write: '保存文件失败。',
        ProcessingIssue.unknown: '发生未知错误。',
      },
      ja: {
        ProcessingIssue.notFound: 'ファイルが見つかりません。',
        ProcessingIssue.decode: '画像を読み込めません。',
        ProcessingIssue.empty: '画像が空です。',
        ProcessingIssue.encode: '画像の処理に失敗しました。',
        ProcessingIssue.write: 'ファイルを保存できません。',
        ProcessingIssue.unknown: '不明なエラーが発生しました。',
      },
      ko: {
        ProcessingIssue.notFound: '파일을 찾을 수 없습니다.',
        ProcessingIssue.decode: '이미지를 읽을 수 없습니다.',
        ProcessingIssue.empty: '이미지가 비어 있습니다.',
        ProcessingIssue.encode: '이미지 처리에 실패했습니다.',
        ProcessingIssue.write: '파일을 저장할 수 없습니다.',
        ProcessingIssue.unknown: '알 수 없는 오류가 발생했습니다.',
      },
      ar: {
        ProcessingIssue.notFound: 'الملف غير موجود.',
        ProcessingIssue.decode: 'تعذر قراءة الصورة.',
        ProcessingIssue.empty: 'الصورة فارغة.',
        ProcessingIssue.encode: 'فشل في معالجة الصورة.',
        ProcessingIssue.write: 'تعذر حفظ الملف.',
        ProcessingIssue.unknown: 'حدث خطأ غير معروف.',
      },
      ru: {
        ProcessingIssue.notFound: 'Файл не найден.',
        ProcessingIssue.decode: 'Не удаётся прочитать изображение.',
        ProcessingIssue.empty: 'Пустое изображение.',
        ProcessingIssue.encode: 'Ошибка обработки изображения.',
        ProcessingIssue.write: 'Не удалось сохранить файл.',
        ProcessingIssue.unknown: 'Неизвестная ошибка.',
      },
      hi: {
        ProcessingIssue.notFound: 'फ़ाइल नहीं मिली।',
        ProcessingIssue.decode: 'चित्र पढ़ा नहीं जा सका।',
        ProcessingIssue.empty: 'चित्र खाली है।',
        ProcessingIssue.encode: 'चित्र प्रोसेस नहीं हो सका।',
        ProcessingIssue.write: 'फ़ाइल सहेज नहीं सके।',
        ProcessingIssue.unknown: 'अज्ञात त्रुटि।',
      },
    );
    return messages[type]!;
  }

  String failureLog(String readable) => _pick(
        id: 'Gagal: $readable',
        en: 'Failed: $readable',
        zh: '失败：$readable',
        ja: '失敗: $readable',
        ko: '실패: $readable',
        ar: 'فشل: $readable',
        ru: 'Ошибка: $readable',
        hi: 'विफल: $readable',
      );

  String get aboutTitle => _pick(
        id: 'Tentang',
        en: 'About',
        zh: '关于',
        ja: 'このアプリについて',
        ko: '정보',
        ar: 'حول التطبيق',
        ru: 'О программе',
        hi: 'परिचय',
      );

  String get aboutDescription => _pick(
        id: 'Dikembangkan oleh Ian7672. Kode sumber tersedia di GitHub.',
        en: 'Built by Ian7672. Source code is available on GitHub.',
        zh: '由 Ian7672 开发，源代码在 GitHub。',
        ja: 'Ian7672 が開発。ソースは GitHub にあります。',
        ko: 'Ian7672가 개발했으며 소스는 GitHub에 있습니다.',
        ar: 'تم التطوير بواسطة Ian7672. الشفرة متاحة على GitHub.',
        ru: 'Разработано Ian7672. Код на GitHub.',
        hi: 'Ian7672 द्वारा विकसित। स्रोत GitHub पर उपलब्ध है।',
      );

  String get githubLabel => _pick(
        id: 'Buka GitHub',
        en: 'Open GitHub',
        zh: '打开 GitHub',
        ja: 'GitHub を開く',
        ko: 'GitHub 열기',
        ar: 'فتح GitHub',
        ru: 'Открыть GitHub',
        hi: 'GitHub खोलें',
      );

  String get donateTitle => _pick(
        id: 'Dukung proyek',
        en: 'Support the project',
        zh: '支持项目',
        ja: 'プロジェクトを支援',
        ko: '프로젝트 후원',
        ar: 'ادعم المشروع',
        ru: 'Поддержать проект',
        hi: 'प्रोजेक्ट को समर्थन दें',
      );

  String get donateSubtitle => _pick(
        id: 'Bantu pengembangan lewat tautan berikut.',
        en: 'Keep development going via the links below.',
        zh: '通过以下链接支持开发。',
        ja: '以下のリンクからご支援いただけます。',
        ko: '아래 링크로 개발을 지원할 수 있습니다.',
        ar: 'يمكنك دعم التطوير عبر الروابط أدناه.',
        ru: 'Поддержите разработку по ссылкам ниже.',
        hi: 'नीचे दिए लिंक से विकास में मदद करें।',
      );

  String get donateTrakteerLabel => _pick(
        id: 'Donasi via Trakteer',
        en: 'Donate via Trakteer',
        zh: '通过 Trakteer 捐助',
        ja: 'Trakteer で支援',
        ko: 'Trakteer로 후원',
        ar: 'تبرع عبر Trakteer',
        ru: 'Пожертвовать через Trakteer',
        hi: 'Trakteer से दान करें',
      );

  String get donateKoFiLabel => _pick(
        id: 'Donasi via Ko-fi',
        en: 'Donate via Ko-fi',
        zh: '通过 Ko-fi 捐助',
        ja: 'Ko-fi で支援',
        ko: 'Ko-fi로 후원',
        ar: 'تبرع عبر Ko-fi',
        ru: 'Пожертвовать через Ko-fi',
        hi: 'Ko-fi से दान करें',
      );

  String get okButton => _pick(
        id: 'Oke',
        en: 'OK',
        zh: '确定',
        ja: 'OK',
        ko: '확인',
        ar: 'حسناً',
        ru: 'ОК',
        hi: 'ठीक है',
      );

  String get openLinkError => _pick(
        id: 'Tidak bisa membuka tautan.',
        en: "Couldn't open the link.",
        zh: '无法打开链接。',
        ja: 'リンクを開けませんでした。',
        ko: '링크를 열 수 없습니다.',
        ar: 'تعذر فتح الرابط.',
        ru: 'Не удалось открыть ссылку.',
        hi: 'लिंक नहीं खोल सके।',
      );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storedMode = _ThemeStorage.read(prefs);
  final storedLanguage = _LanguageStorage.read(prefs);
  runApp(
    CropApp(
      prefs: prefs,
      initialThemeMode: storedMode,
      initialLanguage: storedLanguage,
    ),
  );
}

class CropApp extends StatefulWidget {
  const CropApp({
    super.key,
    required this.prefs,
    required this.initialThemeMode,
    required this.initialLanguage,
  });

  final SharedPreferences prefs;
  final ThemeMode initialThemeMode;
  final AppLanguage initialLanguage;

  @override
  State<CropApp> createState() => _CropAppState();
}

class _CropAppState extends State<CropApp> {
  late ThemeMode _themeMode;
  late AppLanguage _language;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
    _language = widget.initialLanguage;
  }

  Future<void> _handleThemeChanged(ThemeMode newMode) async {
    if (_themeMode == newMode) return;
    setState(() {
      _themeMode = newMode;
    });
    await _ThemeStorage.write(widget.prefs, newMode);
  }

  Future<void> _handleLanguageChanged(AppLanguage newLanguage) async {
    if (_language == newLanguage) return;
    setState(() {
      _language = newLanguage;
    });
    await _LanguageStorage.write(widget.prefs, newLanguage);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(_language);
    return MaterialApp(
      title: strings.appTitle,
      debugShowCheckedModeBanner: false,
      locale: _language.locale,
      supportedLocales: AppLanguage.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        return Directionality(
          textDirection: _language.textDirection,
          child: content,
        );
      },
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: CropHomePage(
        themeMode: _themeMode,
        onThemeChanged: _handleThemeChanged,
        language: _language,
        onLanguageChanged: _handleLanguageChanged,
        strings: strings,
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blueGrey,
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      useMaterial3: true,
      scaffoldBackgroundColor: colorScheme.surface,
    );
  }
}

class CropHomePage extends StatefulWidget {
  const CropHomePage({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    required this.language,
    required this.onLanguageChanged,
    required this.strings,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final AppStrings strings;

  @override
  State<CropHomePage> createState() => _CropHomePageState();
}

class _CropHomePageState extends State<CropHomePage> {
  static const int _defaultTargetSize = 3000;
  static const int _maxWorkerCap = 4;
  static const String _githubUrl = 'https://github.com/Ian7672';
  static const String _trakteerUrl = 'https://trakteer.id/Ian7672';
  static const String _koFiUrl = 'https://ko-fi.com/Ian7672';
  static const String _guideUrl = 'https://github.com/Ian7672/crop3000-flutter/blob/main/README.md';
  bool _isDragging = false;
  bool _isProcessing = false;
  CompressionMode _compressionMode = CompressionMode.balanced;
  OutputFormat _outputFormat = OutputFormat.jpg;
  int _processedCount = 0;
  int _totalToProcess = 0;
  final List<_LogEntry> _logs = [];
  final List<String> _pendingFiles = [];
  final Set<String> _pendingLookup = <String>{};
  final TextEditingController _manualPathController = TextEditingController();
  final TextEditingController _sizeController =
      TextEditingController(text: _defaultTargetSize.toString());
  _ProcessingPool? _processingPool;

  AppStrings get _strings => widget.strings;

  double get _progressValue {
    if (_totalToProcess == 0) return 0;
    return _processedCount / _totalToProcess;
  }

  @override
  void dispose() {
    _manualPathController.dispose();
    _sizeController.dispose();
    _processingPool?.dispose();
    _processingPool = null;
    super.dispose();
  }

  Future<_ProcessingPool> _ensureProcessingPool() async {
    final desiredSize = _preferredWorkerCount;
    final existing = _processingPool;
    if (existing != null && existing.size == desiredSize) {
      return existing;
    }
    existing?.dispose();
    final pool = await _ProcessingPool.start(desiredSize);
    _processingPool = pool;
    return pool;
  }

  int get _preferredWorkerCount {
    final cores = Platform.numberOfProcessors;
    final safeCores = cores > 2 ? cores - 1 : cores;
    return math.max(1, math.min(_maxWorkerCap, safeCores));
  }

  Widget _buildManualInput(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _manualPathController,
            enabled: !_isProcessing,
            decoration: InputDecoration(
              labelText: _strings.manualPathLabel,
              hintText: _strings.manualPathHint,
              border: const OutlineInputBorder(),
            ),
            minLines: 1,
            maxLines: 2,
            onSubmitted: (_) => _addManualPath(),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: _isProcessing ? null : _addManualPath,
          child: Text(_strings.manualPathAdd),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          onPressed: _isProcessing ? null : _browseFiles,
          icon: const Icon(Icons.folder_open),
          label: Text(_strings.browseButton),
        ),
        OutlinedButton.icon(
          onPressed: _pendingFiles.isEmpty || _isProcessing
              ? null
              : () {
                  setState(() {
                    _pendingFiles.clear();
                    _pendingLookup.clear();
                  });
          },
          icon: const Icon(Icons.clear_all),
          label: Text(_strings.clearListButton),
        ),
      ],
    );
  }

  Widget _buildTargetSizeInput() {
    return TextField(
      controller: _sizeController,
      enabled: !_isProcessing,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: _strings.targetSizeLabel,
        helperText: _strings.targetSizeHelper(_defaultTargetSize),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildThemeSwitcher(ThemeData theme) {
    final secondaryTextColor = theme.colorScheme.onSurface.withValues(alpha: 0.7);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _strings.themeSectionTitle,
          style: theme.textTheme.titleSmall?.copyWith(color: secondaryTextColor),
        ),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(
              value: ThemeMode.light,
              icon: Icon(Icons.light_mode),
              label: Text(_strings.themeLight),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: Icon(Icons.dark_mode),
              label: Text(_strings.themeDark),
            ),
            ButtonSegment(
              value: ThemeMode.system,
              icon: Icon(Icons.brightness_6),
              label: Text(_strings.themeSystem),
            ),
          ],
          style: SegmentedButton.styleFrom(
            visualDensity: VisualDensity.comfortable,
          ),
          showSelectedIcon: false,
          selected: <ThemeMode>{widget.themeMode},
          onSelectionChanged: (selection) {
            if (selection.isEmpty) return;
            widget.onThemeChanged(selection.first);
          },
        ),
      ],
    );
  }

  Widget _buildCompressionMenu(ThemeData theme) {
    final helperStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final supportsCompression = _outputFormat.supportsCompression;
    final helperText = supportsCompression
        ? _strings.compressionDescription(_compressionMode)
        : _strings.compressionNotSupported(_strings.formatShortLabel(_outputFormat));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<CompressionMode>(
          value: _compressionMode,
          decoration: InputDecoration(
            labelText: _strings.compressionDropdownLabel,
            border: const OutlineInputBorder(),
          ),
          items: CompressionMode.values
              .map(
                (mode) => DropdownMenuItem(
                  value: mode,
                  child: Text(_strings.compressionLabel(mode)),
                ),
              )
              .toList(growable: false),
          onChanged: _isProcessing || !supportsCompression
              ? null
              : (value) {
                  if (value == null) return;
                  setState(() {
                    _compressionMode = value;
                  });
                },
        ),
        const SizedBox(height: 6),
        Text(helperText, style: helperStyle),
      ],
    );
  }

  Widget _buildFormatMenu(ThemeData theme) {
    final helperStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<OutputFormat>(
          value: _outputFormat,
          decoration: InputDecoration(
            labelText: _strings.formatDropdownLabel,
            border: const OutlineInputBorder(),
          ),
          items: OutputFormat.values
              .map(
                (format) => DropdownMenuItem(
                  value: format,
                  child: Text(_strings.formatLabel(format)),
                ),
              )
              .toList(growable: false),
          onChanged: _isProcessing
              ? null
              : (value) {
                  if (value == null) return;
                  setState(() {
                    _outputFormat = value;
                  });
                },
        ),
        const SizedBox(height: 6),
        Text(_strings.formatDescription(_outputFormat), style: helperStyle),
      ],
    );
  }

  Widget _buildSettingsMenu(ThemeData theme) {
    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.end,
        children: [
          Tooltip(
            message: _strings.helpTooltip,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.help_outline),
              label: Text(_strings.helpButtonLabel),
              onPressed: _openHelpDialog,
            ),
          ),
          Tooltip(
            message: _strings.settingsTooltip,
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.settings),
              label: Text(_strings.settingsButtonLabel(widget.language.displayName)),
              onPressed: _openSettingsDialog,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSettingsDialog() async {
    final theme = Theme.of(context);
    final strings = _strings;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.settingsTitle),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(strings.languageMenuTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(strings.languageHelp, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                ...AppLanguage.values.map(
                  (lang) => RadioListTile<AppLanguage>(
                    value: lang,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    groupValue: widget.language,
                    title: Directionality(
                      textDirection: lang.textDirection,
                      child: Text(lang.displayName),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        widget.onLanguageChanged(value);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Text(strings.aboutTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(strings.aboutDescription, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.code),
                  title: Text(strings.githubLabel),
                  subtitle: const Text('Ian7672'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _launchUrl(_githubUrl),
                ),
                const SizedBox(height: 4),
                Text(strings.donateTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(strings.donateSubtitle, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _launchUrl(_trakteerUrl),
                      icon: const Icon(Icons.favorite),
                      label: Text(strings.donateTrakteerLabel),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _launchUrl(_koFiUrl),
                      icon: const Icon(Icons.local_cafe),
                      label: Text(strings.donateKoFiLabel),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(strings.okButton),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openHelpDialog() async {
    final strings = _strings;
    final steps = strings.helpDialogSteps;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.helpDialogTitle),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(strings.helpDialogDescription),
                const SizedBox(height: 12),
                ...List.generate(steps.length, (index) {
                  final text = steps[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${index + 1}. ', style: Theme.of(context).textTheme.bodyMedium),
                        Expanded(
                          child: Text(
                            text,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Text(
                  strings.helpDialogFooter,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => _launchUrl(_guideUrl),
                    icon: const Icon(Icons.menu_book_outlined),
                    label: Text(strings.helpDialogOpenReadme),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(strings.okButton),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.openLinkError)),
      );
    }
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    if (!_isProcessing || _totalToProcess == 0) {
      return const SizedBox.shrink();
    }
    final progress = _progressValue.clamp(0.0, 1.0);
    final percent = (progress * 100).clamp(0, 100).toStringAsFixed(0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(
          value: progress.toDouble(),
        ),
        const SizedBox(height: 8),
        Text(
          _strings.progressLabel(_processedCount, _totalToProcess, percent),
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPendingFilesPanel(ThemeData theme) {
    if (_pendingFiles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.35 : 0.15,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          _strings.emptyPendingList,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.5 : 0.2,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _strings.fileListTitle(_pendingFiles.length),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _pendingFiles.length,
              itemBuilder: (context, index) {
                final path = _pendingFiles[index];
                final fileName = _fileNameFromPath(path);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.insert_drive_file_outlined),
                  title: Text(fileName),
                  subtitle: Text(
                    path,
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: _strings.removeFromList,
                    onPressed: _isProcessing ? null : () => _removePendingAt(index),
                  ),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return FilledButton.icon(
      onPressed: _pendingFiles.isEmpty || _isProcessing ? null : _startProcessing,
      icon: _isProcessing
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            )
          : const Icon(Icons.play_arrow_rounded),
      label: Text(_isProcessing ? _strings.processingButton : _strings.startButton),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaffoldColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.surfaceContainerHighest
        : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 520;
          final horizontalPadding = isCompact ? 12.0 : 24.0;
          final verticalPadding = isCompact ? 16.0 : 32.0;
          final panelPadding = EdgeInsets.symmetric(
            horizontal: isCompact ? 20 : 32,
            vertical: isCompact ? 28 : 40,
          );

          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: math.min(constraints.maxWidth, 720.0),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: DropTarget(
                      onDragDone: (details) {
                        setState(() {
                          _isDragging = false;
                          _mergePaths(details.files.map((file) => file.path));
                        });
                      },
                      onDragEntered: (_) => setState(() => _isDragging = true),
                      onDragExited: (_) => setState(() => _isDragging = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: panelPadding,
                        decoration: BoxDecoration(
                          color: _isDragging
                              ? theme.colorScheme.primary.withValues(alpha: 0.1)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _isDragging
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline.withValues(alpha: 0.4),
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildSettingsMenu(theme),
                            const SizedBox(height: 16),
                            Center(
                              child: Icon(
                                Icons.cloud_upload_outlined,
                                size: 64,
                                color: _isDragging
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _strings.dropTitle,
                              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _strings.dropSubtitle(_defaultTargetSize),
                              style: theme.textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _strings.dropInstructions,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            _buildThemeSwitcher(theme),
                            const SizedBox(height: 16),
                            _buildFormatMenu(theme),
                            const SizedBox(height: 16),
                            _buildCompressionMenu(theme),
                            const SizedBox(height: 16),
                            _buildManualInput(theme),
                            const SizedBox(height: 16),
                            _buildActionButtons(theme),
                            const SizedBox(height: 16),
                            _buildTargetSizeInput(),
                            const SizedBox(height: 16),
                            _buildPendingFilesPanel(theme),
                            const SizedBox(height: 24),
                            _buildStartButton(),
                            if (_isProcessing) ...[
                              const SizedBox(height: 16),
                              _buildProgressIndicator(theme),
                            ],
                            const SizedBox(height: 24),
                            if (_logs.isEmpty)
                              Text(
                                _strings.tipText,
                                style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                textAlign: TextAlign.center,
                              )
                            else
                              _buildLogList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogList() {
    return SizedBox(
      height: 260,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _strings.historyTitle(_logs.length),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _logs.length,
              separatorBuilder: (_, __) => const Divider(height: 12),
              itemBuilder: (context, index) {
                final log = _logs[_logs.length - 1 - index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      log.success ? Icons.check_circle : Icons.error_outline,
                      color: log.success ? Colors.green : Colors.redAccent,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.fileName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            log.message,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addManualPath() {
    final path = _manualPathController.text.trim();
    if (path.isEmpty) return;
    setState(() {
      _mergePaths([path]);
    });
    _manualPathController.clear();
  }

  void _removePendingAt(int index) {
    if (index < 0 || index >= _pendingFiles.length) return;
    setState(() {
      final removed = _pendingFiles.removeAt(index);
      _pendingLookup.remove(removed.toLowerCase());
    });
  }

  void _mergePaths(Iterable<String> rawPaths) {
    for (final raw in rawPaths) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) continue;
      final key = trimmed.toLowerCase();
      if (_pendingLookup.add(key)) {
        _pendingFiles.add(trimmed);
      }
    }
  }

  Future<void> _browseFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: const ['png', 'jpg', 'jpeg'],
      );
      if (result == null) return;
      final paths = result.files.where((file) => file.path != null).map((file) => file.path!).toList();
      if (paths.isEmpty) return;
      setState(() {
        _mergePaths(paths);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.browseError('$error'))),
      );
    }
  }

  Future<void> _startProcessing() async {
    if (_pendingFiles.isEmpty || _isProcessing) return;
    final targetSize = _resolveTargetSize();
    final files = List<String>.from(_pendingFiles);
    setState(() {
      _isProcessing = true;
      _processedCount = 0;
      _totalToProcess = files.length;
    });
    await _processFiles(files, targetSize, _compressionMode, _outputFormat);
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _pendingFiles.clear();
      _pendingLookup.clear();
      _processedCount = 0;
      _totalToProcess = 0;
    });
  }

  int _resolveTargetSize() {
    final parsed = int.tryParse(_sizeController.text.trim());
    if (parsed == null || parsed < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_strings.invalidSize(_defaultTargetSize)),
        ),
      );
      _sizeController.text = _defaultTargetSize.toString();
      return _defaultTargetSize;
    }
    return parsed;
  }

  Future<void> _processFiles(
    List<String> paths,
    int targetSize,
    CompressionMode compressionMode,
    OutputFormat outputFormat,
  ) async {
    if (paths.isEmpty) return;
    final tasks = Queue<String>()..addAll(paths);
    final pool = await _ensureProcessingPool();
    final concurrency = math.max(1, math.min(tasks.length, pool.size));

    Future<void> runWorker() async {
      while (tasks.isNotEmpty) {
        final taskPath = tasks.removeFirst();
        final result = await _processSinglePath(
          taskPath,
          targetSize,
          compressionMode,
          outputFormat,
          pool,
        );
        if (!mounted) continue;
        setState(() {
          _processedCount = math.min(_processedCount + 1, _totalToProcess);
          _logs.add(result);
        });
      }
    }

    await Future.wait(List.generate(concurrency, (_) => runWorker()));
  }

  Future<_LogEntry> _processSinglePath(
    String path,
    int targetSize,
    CompressionMode compressionMode,
    OutputFormat outputFormat,
    _ProcessingPool pool,
  ) async {
    final texts = _strings;
    final lower = path.toLowerCase();
    final inputName = _fileNameFromPath(path);
    if (!_isSupported(lower)) {
      return _LogEntry(
        fileName: inputName,
        message: texts.unsupportedFormatMessage,
        success: false,
      );
    }

    final pngLevel = compressionMode.pngLevel;
    final jpgQuality = compressionMode.jpgQuality;
    final destinationPath = _deriveOutputPath(path, outputFormat);
    final destinationName = _fileNameFromPath(destinationPath);
    try {
      final workerResult = await pool.process(
        sourcePath: path,
        destinationPath: destinationPath,
        targetSize: targetSize,
        pngLevel: pngLevel,
        jpgQuality: jpgQuality,
        format: outputFormat,
      );
      if (workerResult.success) {
        final compressionNote =
            outputFormat.supportsCompression ? texts.compressionLogSuffix(compressionMode) : '';
        final successMessage = texts.successLog(
          targetSize,
          texts.formatShortLabel(outputFormat),
          compressionNote: compressionNote,
        );
        return _LogEntry(
          fileName: destinationName,
          message: successMessage,
          success: true,
        );
      }
      final readable = workerResult.issue != null
          ? texts.processingError(workerResult.issue!)
          : workerResult.error ?? texts.processingError(ProcessingIssue.unknown);
      return _LogEntry(
        fileName: inputName,
        message: texts.failureLog(readable),
        success: false,
      );
    } catch (error) {
      final readable = error is _ProcessingException
          ? texts.processingError(error.type)
          : error.toString();
      return _LogEntry(
        fileName: inputName,
        message: texts.failureLog(readable),
        success: false,
      );
    }
  }

  String _fileNameFromPath(String path) {
    return path.split(RegExp(r'[\\\\/]')).last;
  }

  String _deriveOutputPath(String originalPath, OutputFormat format) {
    final lastSlash = math.max(originalPath.lastIndexOf('/'), originalPath.lastIndexOf('\\'));
    final lastDot = originalPath.lastIndexOf('.');
    final hasExtension = lastDot > lastSlash;
    final base = hasExtension ? originalPath.substring(0, lastDot) : originalPath;
    return '$base.${format.extension}';
  }

  bool _isSupported(String lowerPath) {
    return lowerPath.endsWith('.png') ||
        lowerPath.endsWith('.jpg') ||
        lowerPath.endsWith('.jpeg');
  }
}

class _LogEntry {
  _LogEntry({
    required this.fileName,
    required this.message,
    required this.success,
  });

  final String fileName;
  final String message;
  final bool success;
}

const int _preResizeMultiple = 4;

class _ProcessingPool {
  _ProcessingPool._(this._workers);

  final List<_ProcessingWorker> _workers;
  int _next = 0;

  int get size => _workers.length;

  static Future<_ProcessingPool> start(int size) async {
    final workers = <_ProcessingWorker>[];
    for (var i = 0; i < size; i++) {
      workers.add(await _ProcessingWorker.spawn());
    }
    return _ProcessingPool._(workers);
  }

  Future<_WorkerResult> process({
    required String sourcePath,
    required String destinationPath,
    required int targetSize,
    required int pngLevel,
    required int jpgQuality,
    required OutputFormat format,
  }) {
    if (_workers.isEmpty) {
      return _runInline(
        sourcePath: sourcePath,
        destinationPath: destinationPath,
        targetSize: targetSize,
        pngLevel: pngLevel,
        jpgQuality: jpgQuality,
        format: format,
      );
    }
    final worker = _workers[_next];
    _next = (_next + 1) % _workers.length;
    return worker.process(
      sourcePath: sourcePath,
      destinationPath: destinationPath,
      targetSize: targetSize,
      pngLevel: pngLevel,
      jpgQuality: jpgQuality,
      format: format,
    );
  }

  void dispose() {
    for (final worker in _workers) {
      worker.dispose();
    }
  }

  Future<_WorkerResult> _runInline({
    required String sourcePath,
    required String destinationPath,
    required int targetSize,
    required int pngLevel,
    required int jpgQuality,
    required OutputFormat format,
  }) async {
    try {
      await _cropAndSave(
        sourcePath,
        destinationPath,
        targetSize,
        pngLevel,
        jpgQuality,
        format,
      );
      return const _WorkerResult(success: true);
    } catch (error) {
      if (error is _ProcessingException) {
        return _WorkerResult(success: false, issue: error.type);
      }
      return _WorkerResult(success: false, error: error.toString());
    }
  }
}

class _ProcessingWorker {
  _ProcessingWorker._(this._isolate, this._sendPort);

  final Isolate _isolate;
  final SendPort _sendPort;

  static Future<_ProcessingWorker> spawn() async {
    final ready = ReceivePort();
    final isolate = await Isolate.spawn(_processingWorkerMain, ready.sendPort);
    final sendPort = await ready.first as SendPort;
    ready.close();
    return _ProcessingWorker._(isolate, sendPort);
  }

  Future<_WorkerResult> process({
    required String sourcePath,
    required String destinationPath,
    required int targetSize,
    required int pngLevel,
    required int jpgQuality,
    required OutputFormat format,
  }) {
    final response = ReceivePort();
    _sendPort.send([
      response.sendPort,
      sourcePath,
      destinationPath,
      targetSize,
      pngLevel,
      jpgQuality,
      format.index,
    ]);
    return response.first.then((message) {
      response.close();
      return _WorkerResult.fromMessage(message);
    });
  }

  void dispose() {
    _sendPort.send(null);
    _isolate.kill(priority: Isolate.immediate);
  }
}

class _WorkerResult {
  const _WorkerResult({
    required this.success,
    this.issue,
    this.error,
  });

  final bool success;
  final ProcessingIssue? issue;
  final String? error;

  factory _WorkerResult.fromMessage(dynamic message) {
    final data = message as List<dynamic>;
    final issueIndex = data[1] as int?;
    return _WorkerResult(
      success: data[0] as bool,
      issue: issueIndex == null ? null : ProcessingIssue.values[issueIndex],
      error: data[2] as String?,
    );
  }
}

Future<void> _processingWorkerMain(SendPort initialPort) async {
  final commandPort = ReceivePort();
  initialPort.send(commandPort.sendPort);
  await for (final dynamic message in commandPort) {
    if (message == null) {
      break;
    }
    final data = message as List<dynamic>;
    final responsePort = data[0] as SendPort;
    final sourcePath = data[1] as String;
    final destinationPath = data[2] as String;
    final targetSize = data[3] as int;
    final pngLevel = data[4] as int;
    final jpgQuality = data[5] as int;
    final formatIndex = data[6] as int;
    final format = OutputFormat.values[formatIndex];
    try {
      await _cropAndSave(
        sourcePath,
        destinationPath,
        targetSize,
        pngLevel,
        jpgQuality,
        format,
      );
      responsePort.send([true, null, null]);
    } catch (error) {
      if (error is _ProcessingException) {
        responsePort.send([false, error.type.index, null]);
      } else {
        responsePort.send([false, null, error.toString()]);
      }
    }
  }
  commandPort.close();
}

enum CompressionMode {
  none,
  balanced,
  aggressive,
}

extension on CompressionMode {
  int get pngLevel {
    switch (this) {
      case CompressionMode.none:
        return 0;
      case CompressionMode.balanced:
        return 6;
      case CompressionMode.aggressive:
        return 9;
    }
  }

  int get jpgQuality {
    switch (this) {
      case CompressionMode.none:
        return 100;
      case CompressionMode.balanced:
        return 85;
      case CompressionMode.aggressive:
        return 70;
    }
  }

}

enum OutputFormat {
  jpg,
  png,
  bmp,
}

extension on OutputFormat {
  String get extension {
    switch (this) {
      case OutputFormat.jpg:
        return 'jpg';
      case OutputFormat.png:
        return 'png';
      case OutputFormat.bmp:
        return 'bmp';
    }
  }

  bool get supportsCompression {
    switch (this) {
      case OutputFormat.jpg:
      case OutputFormat.png:
        return true;
      case OutputFormat.bmp:
        return false;
    }
  }
}

class _ThemeStorage {
  static const String _key = 'theme_mode';

  static ThemeMode read(SharedPreferences prefs) {
    final stored = prefs.getString(_key);
    if (stored == null) return ThemeMode.system;
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  static Future<void> write(SharedPreferences prefs, ThemeMode mode) {
    return prefs.setString(_key, mode.name);
  }
}

class _LanguageStorage {
  static const String _key = 'app_language';

  static AppLanguage read(SharedPreferences prefs) {
    final stored = prefs.getString(_key);
    if (stored == null) return AppLanguage.indonesian;
    return AppLanguage.fromCode(stored);
  }

  static Future<void> write(SharedPreferences prefs, AppLanguage language) {
    return prefs.setString(_key, language.code);
  }
}

Future<void> _cropAndSave(
  String sourcePath,
  String destinationPath,
  int targetSize,
  int pngLevel,
  int jpgQuality,
  OutputFormat outputFormat,
) async {
  final file = File(sourcePath);
  if (!await file.exists()) {
    throw const _ProcessingException(ProcessingIssue.notFound);
  }

  final bytes = await file.readAsBytes();
  img.Image? decoded;
  try {
    decoded = img.decodeImage(bytes);
  } catch (_) {
    decoded = null;
  }
  if (decoded == null) {
    throw const _ProcessingException(ProcessingIssue.decode);
  }

  img.Image working = decoded;
  var minSide = math.min(working.width, working.height);
  if (minSide == 0) {
    throw const _ProcessingException(ProcessingIssue.empty);
  }

  final preResizeLimit = targetSize * _preResizeMultiple;
  if (minSide > preResizeLimit) {
    final scale = preResizeLimit / minSide;
    final scaledWidth = math.max(1, (working.width * scale).round());
    final scaledHeight = math.max(1, (working.height * scale).round());
    working = img.copyResize(
      working,
      width: scaledWidth,
      height: scaledHeight,
      interpolation: img.Interpolation.linear,
    );
    minSide = math.min(working.width, working.height);
  }

  final cropX = ((working.width - minSide) / 2).round();
  final cropY = ((working.height - minSide) / 2).round();

  final square = img.copyCrop(
    working,
    x: math.max(0, cropX),
    y: math.max(0, cropY),
    width: minSide,
    height: minSide,
  );

  final interpolation = minSide - targetSize > targetSize
      ? img.Interpolation.linear
      : img.Interpolation.cubic;
  final resized = minSide == targetSize
      ? square
      : img.copyResize(
          square,
          width: targetSize,
          height: targetSize,
          interpolation: interpolation,
        );

  final level = pngLevel.clamp(0, 9).toInt();
  final quality = jpgQuality.clamp(1, 100).toInt();
  Uint8List encoded;
  try {
    switch (outputFormat) {
      case OutputFormat.jpg:
        encoded = Uint8List.fromList(
          img.encodeJpg(
            resized,
            quality: quality,
          ),
        );
        break;
      case OutputFormat.png:
        encoded = Uint8List.fromList(
          img.encodePng(
            resized,
            level: level,
          ),
        );
        break;
      case OutputFormat.bmp:
        encoded = Uint8List.fromList(
          img.encodeBmp(resized),
        );
        break;
    }
  } catch (_) {
    throw const _ProcessingException(ProcessingIssue.encode);
  }

  final destinationFile = File(destinationPath);
  try {
    await destinationFile.writeAsBytes(encoded, flush: true);
  } catch (_) {
    throw const _ProcessingException(ProcessingIssue.write);
  }
  final normalizedSource = sourcePath.toLowerCase();
  final normalizedDest = destinationPath.toLowerCase();
  if (normalizedSource != normalizedDest) {
    try {
      await file.delete();
    } catch (_) {
      // Ignore delete failures; user can clean manually.
    }
  }
}
