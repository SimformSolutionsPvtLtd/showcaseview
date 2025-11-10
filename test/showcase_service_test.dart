import 'package:flutter_test/flutter_test.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:showcaseview/src/showcase/showcase_service.dart';
import 'package:showcaseview/src/utils/constants.dart';

void main() {
  group('ShowcaseService scope management', () {
    setUp(() {
      // Clear all registered showcases before each test
      for (final scope in List<String>.from(ShowcaseService.instance.scopes)) {
        try {
          ShowcaseService.instance.unregister(scope: scope);
        } catch (e) {
          // Ignore errors during cleanup
        }
      }
    });

    test('First registration should update currentScope from initialScope', () {
      expect(ShowcaseService.instance.currentScope, Constants.initialScope);

      ShowcaseView.register(scope: 'firstScope');

      expect(ShowcaseService.instance.currentScope, 'firstScope');
    });

    test('Subsequent registrations should not update currentScope', () {
      ShowcaseView.register(scope: 'firstScope');
      expect(ShowcaseService.instance.currentScope, 'firstScope');

      ShowcaseView.register(scope: 'secondScope');
      expect(
        ShowcaseService.instance.currentScope,
        'firstScope',
        reason: 'currentScope should remain as firstScope',
      );

      ShowcaseView.register(scope: 'thirdScope');
      expect(
        ShowcaseService.instance.currentScope,
        'firstScope',
        reason: 'currentScope should still be firstScope',
      );
    });

    test('All scopes should be registered correctly', () {
      ShowcaseView.register(scope: 'scope1');
      ShowcaseView.register(scope: 'scope2');
      ShowcaseView.register(scope: 'scope3');

      expect(ShowcaseService.instance.isRegistered(scope: 'scope1'), true);
      expect(ShowcaseService.instance.isRegistered(scope: 'scope2'), true);
      expect(ShowcaseService.instance.isRegistered(scope: 'scope3'), true);
    });

    test('Each scope should maintain its own ShowcaseView instance', () {
      ShowcaseView.register(
        scope: 'scope1',
        onFinish: () {
          // This will be called when scope1 finishes
        },
      );

      ShowcaseView.register(
        scope: 'scope2',
        onFinish: () {
          // This will be called when scope2 finishes
        },
      );

      final view1 = ShowcaseView.getNamed('scope1');
      final view2 = ShowcaseView.getNamed('scope2');

      expect(
        view1,
        isNot(equals(view2)),
        reason: 'Different scopes should have different ShowcaseView instances',
      );
    });
  });
}
