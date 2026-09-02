import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('MonetaryAmount', () {
    test('round-trips through fromJson/toJson', () {
      const json = {'amount': '2500', 'currency': 'USD'};
      final amount = MonetaryAmount.fromJson(json);
      expect(amount.amount, '2500');
      expect(amount.currency, 'USD');
      expect(amount.toJson(), json);
    });

    test('copyWith replaces values', () {
      const amount = MonetaryAmount(amount: '100', currency: 'USD');
      final updated = amount.copyWith(amount: '200');
      expect(updated.amount, '200');
      expect(updated.currency, 'USD');
    });

    test('equality and hashCode', () {
      const a = MonetaryAmount(amount: '100', currency: 'USD');
      const b = MonetaryAmount(amount: '100', currency: 'USD');
      const c = MonetaryAmount(amount: '200', currency: 'USD');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('Budget', () {
    test('limit round-trips', () {
      const json = {
        'type': 'limit',
        'max_list_cost': {'amount': '2500', 'currency': 'USD'},
      };
      final budget = Budget.fromJson(json);
      expect(budget, isA<BudgetLimit>());
      final limit = budget as BudgetLimit;
      expect(limit.maxListCost.amount, '2500');
      expect(budget.toJson(), json);
    });

    test('Budget.limit factory builds a BudgetLimit', () {
      final budget = Budget.limit(
        maxListCost: const MonetaryAmount(amount: '2500', currency: 'USD'),
      );
      expect(budget, isA<BudgetLimit>());
      expect(
        (budget as BudgetLimit).maxListCost,
        const MonetaryAmount(amount: '2500', currency: 'USD'),
      );
    });

    test('copyWith replaces maxListCost', () {
      const limit = BudgetLimit(
        maxListCost: MonetaryAmount(amount: '100', currency: 'USD'),
      );
      final updated = limit.copyWith(
        maxListCost: const MonetaryAmount(amount: '200', currency: 'USD'),
      );
      expect(updated.maxListCost.amount, '200');
    });

    test('unknown type falls back to UnknownBudget', () {
      const json = {'type': 'mystery', 'foo': 'bar'};
      final budget = Budget.fromJson(json);
      expect(budget, isA<UnknownBudget>());
      expect(budget.toJson(), json);
    });

    test('equality and hashCode', () {
      const a = BudgetLimit(
        maxListCost: MonetaryAmount(amount: '100', currency: 'USD'),
      );
      const b = BudgetLimit(
        maxListCost: MonetaryAmount(amount: '100', currency: 'USD'),
      );
      const c = BudgetLimit(
        maxListCost: MonetaryAmount(amount: '200', currency: 'USD'),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });
}
