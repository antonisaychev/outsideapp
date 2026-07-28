// Проверяет, что экраны админки отрисовываются: списки, пустые состояния,
// диалоги блокировки и новой категории. Данные подставляются через провайдеры,
// сеть не участвует.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outside_app/core/api/admin_api.dart';
import 'package:outside_app/features/admin/providers/admin_providers.dart';
import 'package:outside_app/features/admin/screens/admin_screen.dart';
import 'package:outside_app/l10n/app_localizations.dart';

Widget _app(Widget child, List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    locale: const Locale('ru'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  ),
);

void main() {
  final user = AdminUser(
    id: 'u1',
    email: 'anna@mail.com',
    username: 'anna',
    firstName: 'Анна',
    lastName: 'Иванова',
    role: 'user',
    isBlocked: false,
  );
  final blocked = AdminUser(
    id: 'u2',
    email: 'bot@spam.io',
    username: 'spambot',
    firstName: 'Spam',
    lastName: 'Bot',
    role: 'user',
    isBlocked: true,
    blockedReason: 'Реклама в личных сообщениях',
  );
  final adminUser = AdminUser(
    id: 'u3',
    email: 'root@outside.ink',
    username: 'root',
    firstName: 'Главный',
    lastName: 'Админ',
    role: 'admin',
    isBlocked: false,
  );
  final deleted = AdminUser(
    id: 'u4',
    email: 'deleted+u4@deleted.local',
    username: 'deleted_user',
    firstName: 'Бывший',
    lastName: 'Юзер',
    role: 'user',
    isBlocked: false,
    isDeleted: true,
  );
  final service = AdminService(
    id: 's1',
    title: 'Русская школа Sunrise',
    photoUrl: '',
    cityId: 1,
    categoryId: 1,
    status: 'pending',
    likesCount: 3,
    confirmCount: 18,
    authorUsername: 'oleg',
  );
  final report = AdminReport(
    kind: 'service',
    id: 'r1',
    reasonType: 'fraud',
    comment: 'Указан неверный номер',
    reporterId: 'u9',
    reporterUsername: 'maria',
    targetId: 's1',
    targetLabel: 'Байк-прокат Kuta',
  );
  final hidden = AdminService(
    id: 's2',
    title: 'Скрытая карточка',
    photoUrl: '',
    cityId: 1,
    categoryId: 1,
    status: 'hidden',
    likesCount: 0,
    confirmCount: 0,
    authorUsername: 'oleg',
  );
  final category = AdminCategory(
    id: 1,
    nameRu: 'Медицина',
    nameEn: 'Medicine',
    servicesCount: 12,
  );

  List<Override> overrides({bool empty = false}) => [
    adminUsersProvider.overrideWith(
      (ref) async => empty ? <AdminUser>[] : [user, blocked],
    ),
    adminServicesProvider.overrideWith(
      (ref) async => empty ? <AdminService>[] : [service, hidden],
    ),
    adminReportsProvider.overrideWith(
      (ref) async => empty ? <AdminReport>[] : [report],
    ),
    adminCategoriesProvider.overrideWith(
      (ref) async => empty ? <AdminCategory>[] : [category],
    ),
  ];

  testWidgets('вкладка «Пользователи» показывает людей и статус блокировки', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const AdminScreen(), overrides()));
    await tester.pumpAndSettle();

    expect(find.text('Администрирование'), findsOneWidget);
    expect(find.text('Анна Иванова'), findsOneWidget);
    expect(find.text('Заблокировать'), findsOneWidget);
    expect(find.text('Разблокировать'), findsOneWidget);
    expect(find.textContaining('Реклама в личных сообщениях'), findsOneWidget);
  });

  testWidgets('диалог блокировки требует причину', (tester) async {
    await tester.pumpWidget(_app(const AdminScreen(), overrides()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Заблокировать').first);
    await tester.pumpAndSettle();

    expect(find.text('Заблокировать пользователя?'), findsOneWidget);
    // Кнопка подтверждения заблокирована, пока причина пустая
    final confirm = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Заблокировать'),
    );
    expect(confirm.onPressed, isNull);

    await tester.enterText(find.byType(TextField).last, 'Спам');
    await tester.pumpAndSettle();
    final ready = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Заблокировать'),
    );
    expect(ready.onPressed, isNotNull);
  });

  testWidgets('вкладка «Сервисы»: у карточки на проверке есть «Одобрить»', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const AdminScreen(), overrides()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Сервисы'));
    await tester.pumpAndSettle();

    expect(find.text('Русская школа Sunrise'), findsOneWidget);
    expect(find.text('Одобрить'), findsOneWidget);
    expect(find.text('Скрыть'), findsOneWidget);
  });

  testWidgets('вкладка «Жалобы» показывает жалобу и кнопку действий', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const AdminScreen(), overrides()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Жалобы'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Байк-прокат Kuta'), findsOneWidget);
    expect(find.text('Принять меры'), findsOneWidget);
  });

  testWidgets('вкладка «Категории»: счётчик сервисов и диалог создания', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const AdminScreen(), overrides()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Категории').last);
    await tester.pumpAndSettle();

    expect(find.text('Медицина'), findsOneWidget);
    expect(find.text('12 сервисов'), findsOneWidget);

    await tester.tap(find.text('Создать'));
    await tester.pumpAndSettle();
    expect(find.text('Новая категория'), findsOneWidget);
  });

  testWidgets('пустые состояния не падают', (tester) async {
    await tester.pumpWidget(_app(const AdminScreen(), overrides(empty: true)));
    await tester.pumpAndSettle();
    expect(find.text('Никого не найдено'), findsOneWidget);

    await tester.tap(find.text('Жалобы'));
    await tester.pumpAndSettle();
    expect(find.text('Необработанных жалоб нет'), findsOneWidget);
  });
  testWidgets('заблокированные уходят в конец списка', (tester) async {
    // сортировка живёт в AdminApi.users, здесь проверяем саму отрисовку порядка
    await tester.pumpWidget(_app(const AdminScreen(), overrides()));
    await tester.pumpAndSettle();

    final anna = tester.getTopLeft(find.text('Анна Иванова')).dy;
    final bot = tester.getTopLeft(find.text('Spam Bot')).dy;
    expect(anna, lessThan(bot));
  });

  testWidgets('у скрытого сервиса кнопка «Отображать», у видимого — «Скрыть»', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const AdminScreen(), overrides()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Сервисы'));
    await tester.pumpAndSettle();

    expect(find.text('Отображать'), findsOneWidget);
    expect(find.text('Скрыть'), findsOneWidget);
    // корзина есть у обеих карточек
    expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));
  });

  testWidgets('удаление карточки спрашивает подтверждение', (tester) async {
    await tester.pumpWidget(_app(const AdminScreen(), overrides()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Сервисы'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();

    expect(find.text('Удалить карточку навсегда?'), findsOneWidget);
    expect(find.text('Да'), findsOneWidget);
    expect(find.text('Нет'), findsOneWidget);
  });

  testWidgets('жалоба показывает категорию, описание и заявителя', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const AdminScreen(), overrides()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Жалобы'));
    await tester.pumpAndSettle();

    expect(find.text('Категория: '), findsOneWidget);
    expect(find.text('Мошенничество'), findsOneWidget);
    expect(find.text('Указан неверный номер'), findsOneWidget);
    expect(find.text('@maria'), findsOneWidget);
  });

  testWidgets('пустое описание жалобы показывается как «н/д»', (tester) async {
    final noComment = AdminReport(
      kind: 'user',
      id: 'r2',
      reasonType: 'spam',
      comment: null,
      reporterId: 'u9',
      reporterUsername: 'oleg',
      targetId: 'u2',
      targetLabel: 'Spam Bot',
    );
    await tester.pumpWidget(
      _app(const AdminScreen(), [
        ...overrides(),
        adminReportsProvider.overrideWith((ref) async => [noComment]),
      ]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Жалобы'));
    await tester.pumpAndSettle();
    expect(find.text('н/д'), findsOneWidget);
  });

  testWidgets('удаление категории спрашивает «Да/Нет»', (tester) async {
    await tester.pumpWidget(_app(const AdminScreen(), overrides()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Категории').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();

    expect(find.text('Удалить категорию?'), findsOneWidget);
    expect(find.text('Да'), findsOneWidget);
  });

  testWidgets('в диалоге новой категории вместо «Отмена» крестик', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const AdminScreen(), overrides()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Категории').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Создать'));
    await tester.pumpAndSettle();

    expect(find.text('Новая категория'), findsOneWidget);
    expect(find.text('Отмена'), findsNothing);
    // крестик именно в диалоге: в списке категорий такие же иконки удаления
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byIcon(Icons.close),
      ),
      findsOneWidget,
    );
  });
  testWidgets('у админа и удалённого нет кнопки блокировки', (tester) async {
    await tester.pumpWidget(
      _app(const AdminScreen(), [
        ...overrides(),
        adminUsersProvider.overrideWith(
          (ref) async => [user, adminUser, deleted],
        ),
      ]),
    );
    await tester.pumpAndSettle();

    // кнопка осталась только у обычного пользователя
    expect(
      find.widgetWithText(OutlinedButton, 'Заблокировать'),
      findsOneWidget,
    );
    expect(find.text('Администратор'), findsOneWidget);
    expect(find.text('Удалён'), findsOneWidget);
  });
}
