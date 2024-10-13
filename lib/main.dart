import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'city_provider.dart';
void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'City List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CityListScreen(),
    );
  }
}

class CityListScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityListAsyncValue = ref.watch(cityListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('City List'),
      ),
      body: cityListAsyncValue.when(
        data: (cities) => ListView.builder(
          itemCount: cities.length,
          itemBuilder: (context, index) {
            final city = cities[index];
            return ListTile(
              title: Text(city.name),
            );
          },
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
