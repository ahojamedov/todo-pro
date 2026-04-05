import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Color getBgColor(String theme) => theme == 'dark' ? const Color(0xFF0A0A12) : const Color(0xFFF2F2F7);
Color getCardColor(String theme) => theme == 'dark' ? const Color(0xFF1C1C2E) : Colors.white;
Color getTextColor(String theme) => theme == 'dark' ? Colors.white : Colors.black;
const Color colorTextSecondary = Color(0xFF8E8E93);
const Color colorAccent = Color(0xFF7B78FF); 

String translate(String key, String lang) {
  final translations = {
    'ru': {
      'title': 'Мои задачи', 'all': 'Все', 'today': 'Сегодня', 'high': 'Важные', 'done': 'Готово',
      'stats_total': 'всего задач', 'stats_done': 'выполнено', 'on_today': 'На сегодня', 'all_arrow': 'все →',
      'add_task': 'Добавить задачу', 'profile': 'Профиль', 'home': 'Главная', 'calendar': 'Календарь', 'search': 'Поиск',
      'search_hint': 'Поиск заметок...',
      'settings': 'Настройки интерфейса', 'theme': 'Темная тема', 'font': 'Размер шрифта', 'color': 'Цвет акцента', 'lang': 'Язык приложения',
      'progress': 'Прогресс', 'quote_loading': 'Загрузка мотивации...', 'quote_error': 'Продолжай! Ты отлично справляешься!',
      'calendar_hint': 'Нажмите на день с задачами', 'edit_task': 'Редактировать задачу', 'no_tasks': 'Нет задач',
      'username': 'Имя пользователя', 'save': 'Сохранить',
      'new_note': 'Новая заметка', 'text_mode': 'Текст', 'list_mode': 'Список',
      'title_hint': 'Заголовок', 'text_hint': 'Текст заметки...', 'add_item': 'Добавить пункт'
    },
    'en': {
      'title': 'My Tasks', 'all': 'All', 'today': 'Today', 'high': 'Important', 'done': 'Done',
      'stats_total': 'total tasks', 'stats_done': 'completed', 'on_today': 'For today', 'all_arrow': 'all →',
      'add_task': 'Add Task', 'profile': 'Profile', 'home': 'Home', 'calendar': 'Calendar', 'search': 'Search',
      'search_hint': 'Search notes...',
      'settings': 'Interface Settings', 'theme': 'Dark Theme', 'font': 'Font Size', 'color': 'Accent Color', 'lang': 'App Language',
      'progress': 'Progress', 'quote_loading': 'Loading motivation...', 'quote_error': 'Keep going! You are doing great!',
      'calendar_hint': 'Tap on a day with tasks', 'edit_task': 'Edit Task', 'no_tasks': 'No tasks',
      'username': 'Username', 'save': 'Save',
      'new_note': 'New Note', 'text_mode': 'Text', 'list_mode': 'List',
      'title_hint': 'Title', 'text_hint': 'Note text...', 'add_item': 'Add item'
    },
    'tk': {
      'title': 'Meniň işlerim', 'all': 'Hemmesi', 'today': 'Şügün', 'high': 'Wajyp', 'done': 'Taýýar',
      'stats_total': 'ählisi', 'stats_done': 'ýerine ýetirildi', 'on_today': 'Şügün üçin', 'all_arrow': 'hemmesi →',
      'add_task': 'Iş goş', 'profile': 'Profil', 'home': 'Baş sahypa', 'calendar': 'Seneleýin', 'search': 'Gözleg',
      'search_hint': 'Gözleg...',
      'settings': 'Interfeýs sazlamalary', 'theme': 'Gije tertibi', 'font': 'Şriftiň ölçegi', 'color': 'Akcent reňki', 'lang': 'Programma dili',
      'progress': 'Ösüş', 'quote_loading': 'Motivasiýa ýüklenýär...', 'quote_error': 'Dowam et! Sen gowy başarýarsyň!',
      'calendar_hint': 'Işli günleriň üstüne basyň', 'edit_task': 'Işi üýtget', 'no_tasks': 'Iş ýok',
      'username': 'Ulanyjy ady', 'save': 'Sakla',
      'new_note': 'Täze ýazgy', 'text_mode': 'Tekst', 'list_mode': 'Sanaw',
      'title_hint': 'Sözbaşy', 'text_hint': 'Ýazgy tekst...', 'add_item': 'Bent goş'
    },
    'zh': {
      'title': '我的任务', 'all': '全部', 'today': '今天', 'high': '重要', 'done': '完成',
      'stats_total': '总计', 'stats_done': '已完成', 'on_today': '今日任务', 'all_arrow': '全部 →',
      'add_task': '添加任务', 'profile': '我的', 'home': '首页', 'calendar': '日历', 'search': '搜索',
      'search_hint': '搜索笔记...',
      'settings': '界面设置', 'theme': '深色模式', 'font': '字体大小', 'color': '主题颜色', 'lang': '语言',
      'progress': '统计', 'quote_loading': '正在加载动力...', 'quote_error': '继续加油！你做得很棒！',
      'calendar_hint': '点击有任务的日期', 'edit_task': '编辑任务', 'no_tasks': '没有任务',
      'username': '用户名', 'save': '保存',
      'new_note': '新笔记', 'text_mode': '文本', 'list_mode': '列表',
      'title_hint': '标题', 'text_hint': '笔记内容...', 'add_item': '添加项目'
    }
  };
  return translations[lang]?[key] ?? key;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация локализации
  await initializeDateFormatting('ru', null);
  await initializeDateFormatting('en', null);
  await initializeDateFormatting('zh', null);
  try { await initializeDateFormatting('tk', null); } catch (_) {}

  // Инициализация уведомлений в фоновом режиме, чтобы не вешать приложение
  _initNotifications();

  runApp(
    ChangeNotifierProvider(
      create: (_) => TodoProvider()..init(),
      child: const MyApp(),
    ),
  );
}

Future<void> _initNotifications() async {
  try {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'todo_push_v6', 
      'Важные уведомления',
      description: 'Этот канал используется для срочных пуш-уведомлений со звуком.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
      // Запрашиваем разрешения асинхронно
      androidPlugin.requestNotificationsPermission();
      androidPlugin.requestExactAlarmsPermission();
    }
  } catch (e) {
    debugPrint("Notification Init Error: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TodoProvider>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Do It',
      locale: Locale(prov.language),
      themeMode: prov.theme == 'light' ? ThemeMode.light : ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: prov.accentColor,
        textTheme: GoogleFonts.interTextTheme().copyWith(
          bodyLarge: TextStyle(fontSize: prov.fontSize),
          bodyMedium: TextStyle(fontSize: prov.fontSize - 2),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: getBgColor('dark'),
        colorSchemeSeed: prov.accentColor,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
          bodyLarge: TextStyle(fontSize: prov.fontSize, color: Colors.white),
          bodyMedium: TextStyle(fontSize: prov.fontSize - 2, color: colorTextSecondary),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Увеличили задержку до 2 секунд для более плавного входа
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const AuthGate(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF5E5CE6).withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF5E5CE6), shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        const Text('продуктивность · 2025', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Hero(
                      tag: 'app_icon',
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF8B78FF), Color(0xFFB147D1), Color(0xFFE94BD1)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFFE94BD1).withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 35, left: 25,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _iconBar(70, Colors.white.withOpacity(0.9)),
                                  const SizedBox(height: 8),
                                  _iconBar(50, Colors.white.withOpacity(0.6)),
                                  const SizedBox(height: 8),
                                  _iconBar(80, Colors.white),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 15, right: 15,
                              child: Container(
                                width: 35, height: 35,
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.check, color: Color(0xFFB147D1), size: 24, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text('Do', style: TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.w900, height: 0.9)),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF7B78FF), Color(0xFFE94BD1)],
                    ).createShader(bounds),
                    child: const Text('It Now', style: TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.w900, height: 0.9)),
                  ),
                  const SizedBox(height: 30),
                  const Divider(color: Color(0xFF5E5CE6), thickness: 0.5, endIndent: 100),
                  const SizedBox(height: 30),
                  const Text(
                    'Организуй день, выполняй цели\nи забудь про хаос в голове.',
                    style: TextStyle(color: Color(0xFF8E8E93), fontSize: 16, height: 1.5, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _categoryTag('Работа', const Color(0xFF1DB954)),
                        const SizedBox(width: 12),
                        _categoryTag('Личное', const Color(0xFFE94BD1)),
                        const SizedBox(width: 12),
                        _categoryTag('Здоровье', const Color(0xFFFFCC00)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C2E),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ПРОГРЕСС СЕГОДНЯ', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                            SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text('5', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                                Text(' из 12 задач', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 50, height: 50,
                              child: CircularProgressIndicator(value: 0.42, strokeWidth: 4, backgroundColor: Colors.white10, color: const Color(0xFFE94BD1)),
                            ),
                            const Text('42%', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('следующая задача', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 10, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF7B78FF), shape: BoxShape.circle)),
                                  const SizedBox(width: 8),
                                  const Text('Встреча с командой - 14:00', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF7B78FF), Color(0xFFE94BD1)]),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text('старт →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(
              bottom: 16,
              left: 0, right: 0,
              child: Text('Do It - версия 1.0', textAlign: TextAlign.center, style: TextStyle(color: Colors.white10, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, color: color, size: 12),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _iconBar(double width, Color color) {
    return Container(width: width, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)));
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _auth = LocalAuthentication();
  bool _isAuth = false;

  @override
  void initState() {
    super.initState();
    _checkLock();
  }

  void _checkLock() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('app_lock') ?? false) {
      try {
        bool auth = await _auth.authenticate(localizedReason: 'Подтвердите личность', options: const AuthenticationOptions(stickyAuth: true));
        if (auth) setState(() => _isAuth = true);
      } catch (e) {
        setState(() => _isAuth = true); // В случае ошибки биометрии пускаем в приложение
      }
    } else {
      setState(() => _isAuth = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isAuth ? const MainScreen() : Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, color: Colors.white54, size: 64),
            const SizedBox(height: 24),
            const Text('Приложение заблокировано', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: _checkLock, child: const Text('Разблокировать')),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String _filter = 'all';
  String _searchQuery = '';
  bool _isSearching = false;

  String t(String key, TodoProvider prov) {
    return translate(key, prov.language);
  }

  String _formatTkDate(DateTime date) {
    final days = ['Ýekşenbe', 'Duşenbe', 'Sişenbe', 'Çarşenbe', 'Penşenbe', 'Juma', 'Şenbe'];
    final months = [
      'Ýanwar', 'Fewral', 'Mart', 'Aprel', 'Maý', 'Iýun',
      'Iýul', 'Awgust', 'Sentyabr', 'Oktyabr', 'Noyabr', 'Dekabr'
    ];
    return "${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]}".toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TodoProvider>();
    final now = DateTime.now();
    String dateStr;
    if (prov.language == 'tk') {
      dateStr = _formatTkDate(now);
    } else {
      try {
        dateStr = DateFormat('EEEE, d MMMM', prov.language).format(now).toUpperCase();
      } catch (e) {
        dateStr = DateFormat('EEEE, d MMMM', 'en').format(now).toUpperCase();
      }
    }

    final List<Widget> pages = [
      _buildHome(prov, dateStr),
      _buildCalendar(prov),
      _buildDone(prov),
      _buildProfile(context, prov),
    ];

    return Scaffold(
      backgroundColor: getBgColor(prov.theme),
      body: pages[_currentIndex > 3 ? 0 : _currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex > 3 ? 0 : _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: getCardColor(prov.theme),
        selectedItemColor: prov.accentColor,
        unselectedItemColor: colorTextSecondary,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_filled), label: t('home', prov)),
          BottomNavigationBarItem(icon: const Icon(Icons.calendar_today_rounded), label: t('calendar', prov)),
          BottomNavigationBarItem(icon: const Icon(Icons.check_circle_outline), label: t('done', prov)),
          BottomNavigationBarItem(icon: const Icon(Icons.person_outline_rounded), label: t('profile', prov)),
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () => _showTypeSelection(context, prov),
        backgroundColor: prov.accentColor,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ) : null,
    );
  }

  void _showTypeSelection(BuildContext context, TodoProvider prov) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: getCardColor(prov.theme),
        title: Text(translate('new_note', prov.language), style: TextStyle(color: getTextColor(prov.theme))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.text_fields, color: prov.accentColor),
              title: Text(translate('text_mode', prov.language), style: TextStyle(color: getTextColor(prov.theme))),
              onTap: () async {
                Navigator.pop(ctx);
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const NoteEditorPage(initialType: 'text')));
                prov.fetchTasks();
              },
            ),
            ListTile(
              leading: Icon(Icons.list, color: prov.accentColor),
              title: Text(translate('list_mode', prov.language), style: TextStyle(color: getTextColor(prov.theme))),
              onTap: () async {
                Navigator.pop(ctx);
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const NoteEditorPage(initialType: 'list')));
                prov.fetchTasks();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHome(TodoProvider prov, String dateStr) {
    final now = DateTime.now();
    final filteredTasks = prov.tasks.where((task) {
      // Сначала фильтрация по поиску
      if (_searchQuery.isNotEmpty) {
        final title = (task['title'] ?? '').toString().toLowerCase();
        final desc = (task['description'] ?? '').toString().toLowerCase();
        final subtasksRaw = (task['subtasks'] ?? '[]').toString();
        bool subtasksMatch = false;
        try {
          final List sub = jsonDecode(subtasksRaw);
          subtasksMatch = sub.any((item) => (item['text'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase()));
        } catch (_) {}
        
        if (!title.contains(_searchQuery.toLowerCase()) && 
            !desc.contains(_searchQuery.toLowerCase()) &&
            !subtasksMatch) {
          return false;
        }
      }

      final isCompleted = task['is_completed'] == 1;

      if (_filter == 'all') return !isCompleted; // Показываем только активные в общем списке
      
      if (_filter == 'today') {
        final dueDateStr = task['due_date'];
        final createdAtStr = task['created_at'];
        
        DateTime? compareDate;
        if (dueDateStr != null && dueDateStr.isNotEmpty) {
          compareDate = DateTime.tryParse(dueDateStr);
        } else if (createdAtStr != null && createdAtStr.isNotEmpty) {
          compareDate = DateTime.tryParse(createdAtStr);
        }
        
        if (compareDate == null) return false;
        final isSameDay = compareDate.day == now.day && 
                          compareDate.month == now.month && 
                          compareDate.year == now.year;
        
        return isSameDay && !isCompleted; // В "Сегодня" только активные
      }
      
      if (_filter == 'high') return task['priority'] == 'high' && !isCompleted; // В "Важные" только активные
      if (_filter == 'done') return isCompleted; // В "Готово" только выполненные
      return true;
    }).toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!_isSearching)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dateStr, style: const TextStyle(color: colorTextSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        const SizedBox(height: 4),
                        Text(t('title', prov), style: TextStyle(color: getTextColor(prov.theme), fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
                      ],
                    ),
                  ),
                if (_isSearching)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: getCardColor(prov.theme),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextField(
                        autofocus: true,
                        style: TextStyle(color: getTextColor(prov.theme)),
                        decoration: InputDecoration(
                          hintText: t('search_hint', prov),
                          hintStyle: const TextStyle(color: colorTextSecondary),
                          border: InputBorder.none,
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(_isSearching ? Icons.close : Icons.search, color: getTextColor(prov.theme)),
                  onPressed: () => setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) _searchQuery = '';
                  }),
                ),
                if (!_isSearching)
                  GestureDetector(
                    onTap: () => setState(() => _currentIndex = 3),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: prov.accentColor,
                      child: Text(
                        prov.userName.isNotEmpty ? prov.userName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _Tab(label: t('all', prov), isActive: _filter == 'all', onTap: () => setState(() => _filter = 'all')),
                  const SizedBox(width: 10),
                  _Tab(label: t('today', prov), isActive: _filter == 'today', onTap: () => setState(() => _filter = 'today')),
                  const SizedBox(width: 10),
                  _Tab(label: t('high', prov), isActive: _filter == 'high', onTap: () => setState(() => _filter = 'high')),
                  const SizedBox(width: 10),
                  _Tab(label: t('done', prov), isActive: _filter == 'done', onTap: () => setState(() => _filter = 'done')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(child: _StatCard(title: '${prov.tasks.length}', subtitle: t('stats_total', prov), color: prov.accentColor, icon: Icons.assignment_outlined)),
                const SizedBox(width: 16),
                Expanded(child: _StatCard(title: '${prov.tasks.where((t)=>t['is_completed']==1).length}', subtitle: t('stats_done', prov), color: const Color(0xFF1DB954), icon: Icons.check_circle_outline)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _filter == 'all' ? t('all', prov) : (_filter == 'today' ? t('on_today', prov) : t(_filter, prov)),
                  style: TextStyle(color: getTextColor(prov.theme), fontSize: 20, fontWeight: FontWeight.bold)
                ),
                if (_filter == 'all') Text(t('all_arrow', prov), style: const TextStyle(color: colorTextSecondary, fontSize: 14)),
              ],
            ),
          ),
          Expanded(
            child: filteredTasks.isEmpty 
              ? Center(child: Text(t('no_tasks', prov), style: TextStyle(color: colorTextSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: filteredTasks.length,
                  itemBuilder: (ctx, i) {
                    final task = filteredTasks[i];
                    return _TaskTile(
                      task: task, 
                      prov: prov,
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorPage(task: task)));
                        prov.fetchTasks();
                      },
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(TodoProvider prov) {
    final now = DateTime.now();
    final Map<int, List<Map>> tasksByDay = {};
    for (var task in prov.tasks) {
      if (task['due_date'] != null && task['due_date'].isNotEmpty) {
        try {
          final d = DateTime.parse(task['due_date']);
          if (d.month == now.month && d.year == now.year) {
            tasksByDay.putIfAbsent(d.day, () => []).add(task);
          }
        } catch (_) {}
      }
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(t('calendar', prov), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 10, crossAxisSpacing: 10),
              itemCount: DateTime(now.year, now.month + 1, 0).day,
              itemBuilder: (ctx, i) {
                final day = i + 1;
                final tasksOnDay = tasksByDay[day] ?? [];
                final hasTask = tasksOnDay.isNotEmpty;
                final isToday = day == now.day;

                return GestureDetector(
                  onTap: hasTask ? () => _showDayTasks(context, day, tasksOnDay, prov) : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: hasTask ? prov.accentColor : getCardColor(prov.theme),
                      borderRadius: BorderRadius.circular(12),
                      border: isToday ? Border.all(color: prov.accentColor, width: 2) : null,
                      boxShadow: hasTask ? [BoxShadow(color: prov.accentColor.withOpacity(0.3), blurRadius: 4)] : null,
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: hasTask ? Colors.white : getTextColor(prov.theme),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              t('calendar_hint', prov),
              textAlign: TextAlign.center,
              style: const TextStyle(color: colorTextSecondary),
            ),
          )
        ],
      ),
    );
  }

  void _showDayTasks(BuildContext context, int day, List<Map> tasks, TodoProvider prov) {
    showModalBottomSheet(
      context: context,
      backgroundColor: getBgColor(prov.theme),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$day ${DateFormat('MMMM', prov.language == 'tk' ? 'en' : prov.language).format(DateTime(DateTime.now().year, DateTime.now().month, day))}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorAccent)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: tasks.length,
                  itemBuilder: (ctx, i) => _TaskTile(
                    task: tasks[i], 
                    prov: prov,
                    onTap: () {
                      Navigator.pop(context); // Close day tasks sheet
                      Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorPage(task: tasks[i])));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDone(TodoProvider prov) {
    final doneTasks = prov.tasks.where((t) => t['is_completed'] == 1).toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Text(t('done', prov), style: TextStyle(color: getTextColor(prov.theme), fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
          ),
          Expanded(
            child: doneTasks.isEmpty
                ? Center(child: Text(t('no_tasks', prov), style: TextStyle(color: colorTextSecondary)))
                : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: doneTasks.length,
              itemBuilder: (ctx, i) {
                final task = doneTasks[i];
                return _TaskTile(
                  task: task,
                  prov: prov,
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorPage(task: task)));
                    prov.fetchTasks();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(TodoProvider prov) {
    final total = prov.tasks.length;
    final done = prov.tasks.where((t) => t['is_completed'] == 1).length;
    final progress = total == 0 ? 0.0 : done / total;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('progress', prov), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
            const SizedBox(height: 40),
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: getCardColor(prov.theme),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: prov.accentColor.withOpacity(0.1), blurRadius: 20)],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 150, height: 150,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 12,
                            backgroundColor: prov.accentColor.withOpacity(0.1),
                            color: prov.accentColor,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: getTextColor(prov.theme)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '$done / $total ${t('stats_done', prov)}',
                      style: const TextStyle(color: colorTextSecondary, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Divider(color: colorTextSecondary, thickness: 0.5),
            const SizedBox(height: 40),
            Expanded(
              child: FutureBuilder<String>(
                future: prov.getMotivationQuote(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: Text(t('quote_loading', prov), style: const TextStyle(color: colorTextSecondary)));
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.format_quote_rounded, color: colorTextSecondary, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        snapshot.data ?? t('quote_error', prov),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          color: getTextColor(prov.theme),
                          height: 1.4,
                        ),
                      ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, TodoProvider prov) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(t('profile', prov), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 32),
          _settingCard(t('username', prov), prov.userName, Icons.person, () => _showNameEdit(context, prov), prov),
          const SizedBox(height: 16),
          Text(t('settings', prov), style: const TextStyle(color: colorTextSecondary, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _settingTile(t('theme', prov), Switch(value: prov.theme == 'dark', onChanged: (v) => prov.setTheme(v ? 'dark' : 'light')), prov),
          _settingTile(t('font', prov), Row(
            children: [
              IconButton(onPressed: () => prov.setFontSize(prov.fontSize - 1), icon: const Icon(Icons.remove)),
              Text(prov.fontSize.toInt().toString()),
              IconButton(onPressed: () => prov.setFontSize(prov.fontSize + 1), icon: const Icon(Icons.add)),
            ],
          ), prov),
          _settingTile(t('color', prov), Wrap(
            children: [const Color(0xFF7B78FF), Colors.blue, Colors.purple, Colors.orange, Colors.green, Colors.red].map((c) => GestureDetector(
              onTap: () => prov.setAccentColor(c),
              child: Container(
                margin: const EdgeInsets.all(4),
                width: 24, height: 24,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: prov.accentColor.value == c.value ? Border.all(color: getTextColor(prov.theme), width: 2) : null),
              ),
            )).toList(),
          ), prov),
          const SizedBox(height: 16),
          Text(t('lang', prov), style: const TextStyle(color: colorTextSecondary, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _languageTile('Русский', 'ru', prov),
          _languageTile('English', 'en', prov),
          _languageTile('Türkmen dili', 'tk', prov),
          _languageTile('中文 (Chinese)', 'zh', prov),

          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => prov.testNotification(),
            icon: const Icon(Icons.volume_up),
            label: const Text('Проверить звук уведомлений'),
            style: ElevatedButton.styleFrom(
              backgroundColor: prov.accentColor.withOpacity(0.1),
              foregroundColor: prov.accentColor,
              elevation: 0,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ],
      ),
    );
  }

  void _showNameEdit(BuildContext context, TodoProvider prov) {
    final ctrl = TextEditingController(text: prov.userName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: getCardColor(prov.theme),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: ctrl, autofocus: true, style: TextStyle(color: getTextColor(prov.theme)), decoration: InputDecoration(labelText: t('username', prov), labelStyle: const TextStyle(color: colorTextSecondary))),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () { prov.setUserName(ctrl.text); Navigator.pop(ctx); }, style: ElevatedButton.styleFrom(backgroundColor: prov.accentColor, foregroundColor: Colors.white), child: Text(t('save', prov))),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _settingCard(String title, String val, IconData icon, VoidCallback onTap, TodoProvider prov) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: getCardColor(prov.theme), borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Icon(icon, color: prov.accentColor),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: colorTextSecondary, fontSize: 12)),
              Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: getTextColor(prov.theme))),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _settingTile(String title, Widget trailing, TodoProvider prov) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(color: getCardColor(prov.theme), borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(title, style: TextStyle(color: getTextColor(prov.theme))), trailing],
      ),
    );
  }

  Widget _languageTile(String label, String code, TodoProvider prov) {
    return GestureDetector(
      onTap: () => prov.setLanguage(code),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: prov.language == code ? prov.accentColor.withOpacity(0.2) : getCardColor(prov.theme), borderRadius: BorderRadius.circular(15), border: prov.language == code ? Border.all(color: prov.accentColor) : null),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: prov.language == code ? FontWeight.bold : FontWeight.normal, color: getTextColor(prov.theme))),
            if (prov.language == code) Icon(Icons.check, color: prov.accentColor),
          ],
        ),
      ),
    );
  }
}

class NoteEditorPage extends StatefulWidget {
  final Map? task;
  final String initialType;
  const NoteEditorPage({super.key, this.task, this.initialType = 'text'});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late List<Map<String, dynamic>> _subtasks;
  bool _isHighPriority = false;
  DateTime? _dueDate;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?['title'] ?? '');
    _descController = TextEditingController(text: widget.task?['description'] ?? '');
    _subtasks = List<Map<String, dynamic>>.from(jsonDecode(widget.task?['subtasks'] ?? '[]'));
    _isHighPriority = widget.task?['priority'] == 'high';
    _dueDate = widget.task?['due_date'] != null ? DateTime.parse(widget.task!['due_date']) : null;
  }

  Future<void> _save(TodoProvider prov) async {
    if (_isSaved) return;
    
    final titleText = _titleController.text.trim();
    final descText = _descController.text.trim();
    
    if (titleText.isEmpty && descText.isEmpty && _subtasks.isEmpty) {
      setState(() => _isSaved = true);
      return;
    }
    
    setState(() => _isSaved = true);
    final title = titleText.isEmpty ? 'Без названия' : titleText;
    if (widget.task == null) {
      await prov.addTask(
        title,
        description: _descController.text,
        type: widget.initialType,
        subtasks: jsonEncode(_subtasks),
        priority: _isHighPriority ? 'high' : 'low',
        dueDate: _dueDate,
      );
    } else {
      await prov.updateTask(
        widget.task!['id'],
        title,
        description: _descController.text,
        type: widget.task!['type'] ?? 'text',
        subtasks: jsonEncode(_subtasks),
        priority: _isHighPriority ? 'high' : 'low',
        dueDate: _dueDate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.read<TodoProvider>();
    final isDark = prov.theme == 'dark';
    final type = widget.task?['type'] ?? widget.initialType;

    return PopScope(
      canPop: _isSaved,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _save(prov);
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: getBgColor(prov.theme),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: getTextColor(prov.theme)),
            onPressed: () async {
              await _save(prov);
              if (mounted) Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(_isHighPriority ? Icons.star : Icons.star_border, color: _isHighPriority ? Colors.orange : getTextColor(prov.theme)),
              onPressed: () => setState(() => _isHighPriority = !_isHighPriority),
            ),
            IconButton(
              icon: Icon(Icons.calendar_today, color: _dueDate != null ? prov.accentColor : getTextColor(prov.theme)),
              onPressed: () async {
                final d = await showDatePicker(context: context, initialDate: _dueDate ?? DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 365)));
                if (d != null) {
                  final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()));
                  if (t != null) {
                    setState(() => _dueDate = DateTime(d.year, d.month, d.day, t.hour, t.minute));
                  }
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _titleController,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: getTextColor(prov.theme)),
                decoration: InputDecoration(
                  hintText: translate('title_hint', prov.language),
                  hintStyle: TextStyle(color: colorTextSecondary.withOpacity(0.5)),
                  border: InputBorder.none,
                ),
              ),
            ),
            Expanded(
              child: type == 'text' 
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _descController,
                      maxLines: null,
                      style: TextStyle(fontSize: 18, color: getTextColor(prov.theme)),
                      decoration: InputDecoration(
                        hintText: translate('text_hint', prov.language),
                        hintStyle: TextStyle(color: colorTextSecondary.withOpacity(0.5)),
                        border: InputBorder.none,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      ..._subtasks.asMap().entries.map((entry) {
                        int idx = entry.key;
                        return Row(
                          children: [
                            Checkbox(
                              value: entry.value['completed'],
                              activeColor: prov.accentColor,
                              onChanged: (v) => setState(() => _subtasks[idx]['completed'] = v),
                            ),
                            Expanded(
                              child: TextFormField(
                                key: ValueKey('task_$idx'),
                                initialValue: entry.value['text'],
                                style: TextStyle(
                                  color: getTextColor(prov.theme),
                                  decoration: entry.value['completed'] ? TextDecoration.lineThrough : null,
                                ),
                                decoration: const InputDecoration(border: InputBorder.none),
                                onFieldSubmitted: (val) {
                                  setState(() => _subtasks[idx]['text'] = val);
                                },
                                onChanged: (val) => _subtasks[idx]['text'] = val,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20, color: Colors.redAccent),
                              onPressed: () => setState(() => _subtasks.removeAt(idx)),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => setState(() => _subtasks.add({'text': '', 'completed': false})),
                          icon: const Icon(Icons.add),
                          label: Text(translate('add_item', prov.language)),
                          style: TextButton.styleFrom(foregroundColor: prov.accentColor),
                        ),
                      ),
                    ],
                  ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await _save(prov);
            if (mounted) Navigator.pop(context);
          },
          backgroundColor: prov.accentColor,
          child: const Icon(Icons.check, color: Colors.white),
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Map task;
  final TodoProvider prov;
  final VoidCallback? onTap;
  const _TaskTile({required this.task, required this.prov, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDone = task['is_completed'] == 1;
    final type = task['type'] ?? 'text';
    String subtitleText = '';
    
    if (type == 'text') {
      subtitleText = task['description'] ?? '';
    } else {
      try {
        final List subtasks = jsonDecode(task['subtasks'] ?? '[]');
        if (subtasks.isNotEmpty) {
          final doneCount = subtasks.where((s) => s['completed'] == true).length;
          subtitleText = '$doneCount / ${subtasks.length}';
        }
      } catch (_) {
        subtitleText = '';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: getCardColor(prov.theme), borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        onTap: onTap,
        onLongPress: () => prov.deleteTask(task['id']),
        leading: GestureDetector(
          onTap: () => prov.toggleTask(task['id'], isDone),
          child: Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: isDone ? prov.accentColor : Colors.transparent,
              border: Border.all(color: prov.accentColor, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isDone ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
          ),
        ),
        title: Text(task['title'], style: TextStyle(color: getTextColor(prov.theme), decoration: isDone ? TextDecoration.lineThrough : null, fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitleText.isNotEmpty)
              Text(subtitleText, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: colorTextSecondary, fontSize: 13)),
            if (task['due_date'] != null && task['due_date'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Builder(builder: (context) {
                  try {
                    final date = DateTime.parse(task['due_date']);
                    return Text(
                      DateFormat('d MMMM HH:mm', prov.language == 'tk' ? 'en' : prov.language).format(date),
                      style: TextStyle(color: prov.accentColor, fontSize: 12),
                    );
                  } catch (_) {
                    return const SizedBox.shrink();
                  }
                }),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(task['priority'] == 'high' ? Icons.star : Icons.star_border, color: task['priority'] == 'high' ? Colors.orange : colorTextSecondary),
              onPressed: () => prov.togglePriority(task['id'], task['priority']),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: () => prov.deleteTask(task['id']),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.isActive, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(color: isActive ? context.watch<TodoProvider>().accentColor : getCardColor(context.watch<TodoProvider>().theme), borderRadius: BorderRadius.circular(15)),
        child: Text(label, style: TextStyle(color: isActive ? Colors.white : colorTextSecondary, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, subtitle;
  final Color color;
  final IconData icon;
  const _StatCard({required this.title, required this.subtitle, required this.color, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(24), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(subtitle, style: TextStyle(color: color.withOpacity(0.7), fontSize: 12)),
        ],
      ),
    );
  }
}

class TodoProvider extends ChangeNotifier {
  static Database? _db;
  List<Map> _tasks = [];
  String _theme = 'dark';
  double _fontSize = 18;
  Color _accentColor = const Color(0xFF7B78FF);
  String _language = 'ru';
  String _userName = '';

  List<Map> get tasks => _tasks;
  String get theme => _theme;
  double get fontSize => _fontSize;
  Color get accentColor => _accentColor;
  String get language => _language;
  String get userName => _userName;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _theme = prefs.getString('theme') ?? 'dark';
    _fontSize = prefs.getDouble('font_size') ?? 18;
    _accentColor = Color(prefs.getInt('accent_color') ?? const Color(0xFF7B78FF).value);
    _language = prefs.getString('language') ?? 'ru';
    _userName = prefs.getString('user_name') ?? 'User';
    await fetchTasks();
  }

  void setTheme(String t) { _theme = t; _save('theme', t); notifyListeners(); }
  void setFontSize(double s) { _fontSize = s; _saveDouble('font_size', s); notifyListeners(); }
  void setAccentColor(Color c) { _accentColor = c; _saveInt('accent_color', c.value); notifyListeners(); }
  void setLanguage(String l) { _language = l; _save('language', l); notifyListeners(); }
  
  void _save(String k, String v) async { (await SharedPreferences.getInstance()).setString(k, v); }
  void _saveDouble(String k, double v) async { (await SharedPreferences.getInstance()).setDouble(k, v); }
  void _saveInt(String k, int v) async { (await SharedPreferences.getInstance()).setInt(k, v); }

  Future<String> getMotivationQuote() async {
    try {
      final response = await http.get(Uri.parse('https://api.quotable.io/random?tags=motivational')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String quote = data['content'];
        String author = data['author'];
        if (language == 'en') return '\"$quote\" — $author';
        final transRes = await http.get(Uri.parse('https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(quote)}&langpair=en|${language == 'tk' ? 'tr' : language}')).timeout(const Duration(seconds: 3));
        if (transRes.statusCode == 200) {
          final transData = json.decode(transRes.body);
          String translated = transData['responseData']['translatedText'];
          return '\"$translated\" — $author';
        }
        return '\"$quote\" — $author';
      }
    } catch (_) {}
    final fallbacks = {
      'ru': 'Твоё ограничение — это только твоё воображение.',
      'en': "Your limitation—it's only your imagination.",
      'tk': 'Seniň çägiň — diňe seniň hyýalyňdyr.',
      'zh': '你的极限——只是你的想象力。'
    };
    return fallbacks[language] ?? fallbacks['en']!;
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    notifyListeners();
  }

  Future<Database> _getDb() async {
    if (_db != null && _db!.isOpen) return _db!;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'todo_safe.db');
    debugPrint("Opening database at $path");
    _db = await openDatabase(
      path,
      version: 8,
      onCreate: (db, v) async {
        debugPrint("Creating tasks table (v$v)");
        await db.execute('CREATE TABLE tasks(id TEXT PRIMARY KEY, title TEXT, description TEXT, type TEXT, subtasks TEXT, is_completed INTEGER, priority TEXT, created_at TEXT, due_date TEXT)');
      },
      onUpgrade: (db, oldV, newV) async {
        debugPrint("Upgrading database from $oldV to $newV");
        var columns = await db.rawQuery('PRAGMA table_info(tasks)');
        var names = columns.map((c) => c['name'] as String).toList();
        final required = {
          'title': 'TEXT',
          'description': 'TEXT',
          'type': 'TEXT DEFAULT "text"',
          'subtasks': 'TEXT',
          'is_completed': 'INTEGER DEFAULT 0',
          'priority': 'TEXT DEFAULT "low"',
          'created_at': 'TEXT',
          'due_date': 'TEXT'
        };
        for (var col in required.entries) {
          if (!names.contains(col.key)) {
            debugPrint("Adding missing column: ${col.key}");
            await db.execute('ALTER TABLE tasks ADD COLUMN ${col.key} ${col.value}');
          }
        }
      }
    );
    return _db!;
  }

  Future<void> fetchTasks() async {
    try {
      final db = await _getDb();
      // Сортировка: сначала активные (is_completed = 0), потом выполненные (1), внутри групп по дате создания
      _tasks = await db.query('tasks', orderBy: 'is_completed ASC, created_at DESC');
      debugPrint("Fetched ${_tasks.length} tasks from database");
      notifyListeners();
    } catch (e) {
      debugPrint("Fetch Tasks Error: $e");
    }
  }

  Future<void> addTask(String title, {String description = '', String type = 'text', String subtasks = '[]', String priority = 'low', DateTime? dueDate}) async {
    try {
      final db = await _getDb();
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final data = {
        'id': id,
        'title': title,
        'description': description,
        'type': type,
        'subtasks': subtasks,
        'priority': priority,
        'is_completed': 0,
        'created_at': DateTime.now().toIso8601String(),
        'due_date': dueDate?.toIso8601String(),
      };
      final res = await db.insert('tasks', data, conflictAlgorithm: ConflictAlgorithm.replace);
      debugPrint("Added task result: $res | ID: $id");
      if (dueDate != null) { _scheduleNotification(int.parse(id) % 100000, title, dueDate); }
      await fetchTasks();
    } catch (e) {
      debugPrint("Add Task Error: $e");
    }
  }

  Future<void> updateTask(String id, String title, {String description = '', String type = 'text', String subtasks = '[]', String priority = 'low', DateTime? dueDate}) async {
    try {
      final db = await _getDb();
      final data = {
        'title': title,
        'description': description,
        'type': type,
        'subtasks': subtasks,
        'priority': priority,
        'due_date': dueDate?.toIso8601String(),
      };
      final res = await db.update('tasks', data, where: 'id = ?', whereArgs: [id]);
      debugPrint("Updated task result: $res | ID: $id");
      try { await flutterLocalNotificationsPlugin.cancel(int.parse(id) % 100000); } catch (_) {}
      if (dueDate != null) { _scheduleNotification(int.parse(id) % 100000, title, dueDate); }
      await fetchTasks();
    } catch (e) {
      debugPrint("Update Task Error: $e");
    }
  }

  void _scheduleNotification(int notificationId, String title, DateTime date) async {
    final scheduledDate = tz.TZDateTime.from(date, tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId, 'Do It: Внимание!', title, scheduledDate,
      const NotificationDetails(android: AndroidNotificationDetails('todo_push_v6', 'Важные уведомления', channelDescription: 'Срочные пуш-уведомления со звуком', importance: Importance.max, priority: Priority.max, playSound: true, enableVibration: true, ticker: 'Напоминание', styleInformation: BigTextStyleInformation(''), fullScreenIntent: true, category: AndroidNotificationCategory.alarm, visibility: NotificationVisibility.public, audioAttributesUsage: AudioAttributesUsage.alarm)),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> testNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails('todo_push_v6', 'Важные уведомления', channelDescription: 'Срочные пуш-уведомления со звуком', importance: Importance.max, priority: Priority.max, playSound: true, enableVibration: true, fullScreenIntent: true, audioAttributesUsage: AudioAttributesUsage.alarm, category: AndroidNotificationCategory.alarm);
    await flutterLocalNotificationsPlugin.show(999, 'Проверка звука', 'Если вы это слышите, значит пуш-уведомления настроены верно!', const NotificationDetails(android: androidPlatformChannelSpecifics));
  }

  Future<void> togglePriority(String id, String currentPriority) async {
    final db = await _getDb();
    await db.update('tasks', {'priority': currentPriority == 'high' ? 'low' : 'high'}, where: 'id = ?', whereArgs: [id]);
    await fetchTasks();
  }

  Future<void> toggleTask(String id, bool current) async {
    final db = await _getDb();
    await db.update('tasks', {'is_completed': current ? 0 : 1}, where: 'id = ?', whereArgs: [id]);
    await fetchTasks();
  }

  Future<void> deleteTask(String id) async {
    final db = await _getDb();
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
    await fetchTasks();
  }

  Future<void> toggleSubtask(String taskId, int index) async {
    final task = _tasks.firstWhere((t) => t['id'] == taskId);
    List subtasks = jsonDecode(task['subtasks'] ?? '[]');
    subtasks[index]['completed'] = !subtasks[index]['completed'];
    await updateTask(taskId, task['title'], description: task['description'] ?? '', type: task['type'] ?? 'text', subtasks: jsonEncode(subtasks), priority: task['priority'], dueDate: task['due_date'] != null ? DateTime.parse(task['due_date']) : null);
  }
}
