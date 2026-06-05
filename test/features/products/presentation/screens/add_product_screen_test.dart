import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:product_management_app/services/local_storage/local_storage_service.dart';
import 'package:product_management_app/features/products/presentation/screens/add_product_screen.dart';

void main() {
  late SharedPreferences sharedPreferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MaterialApp(
        home: AddProductScreen(),
      ),
    );
  }

  testWidgets('Should display validation errors when submitting an empty form', (WidgetTester tester) async {
    // Arrange: Build our app and trigger a frame
    await tester.pumpWidget(createWidgetUnderTest());

    // Verify initial state has no errors
    expect(find.text('Product name is required'), findsNothing);
    expect(find.text('Price is required'), findsNothing);

    // Act: Find the submit button and tap it
    final submitButton = find.byType(FilledButton);
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    
    // Trigger a frame to allow animations/state to update
    await tester.pumpAndSettle();

    // Assert: Verify the validation logic triggered the error messages
    expect(find.text('Product name is required'), findsOneWidget);
    expect(find.text('Description is required'), findsOneWidget);
    expect(find.text('Price is required'), findsOneWidget);
    expect(find.text('Category is required'), findsOneWidget);
  });

  testWidgets('Should display numeric error when price is invalid text', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Act: Enter non-numeric text into the price field
    final priceField = find.widgetWithText(TextFormField, 'Enter price');
    await tester.enterText(priceField, 'Not a number');

    final submitButton = find.byType(FilledButton);
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Assert: Verify the specific numeric validation triggered
    expect(find.text('Price must be numeric'), findsOneWidget);
  });
}