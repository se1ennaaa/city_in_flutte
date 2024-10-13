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
    final searchQuery = ref.watch(searchQueryProvider); // Получаем значение строки поиска

    return Scaffold(
      appBar: AppBar(
        title: Text('City List'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search cities',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Обновляем состояние строки поиска
                ref.read(searchQueryProvider.notifier).state = value;
                ref.refresh(cityListProvider); // Обновляем список городов
              },
            ),
          ),
        ),
      ),
      body: cityListAsyncValue.when(
        data: (cities) {
          /// Фильтруем города по строке поиска
          final filteredCities = cities.where((city) => city.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
          return ListView.builder(
            itemCount: filteredCities.length,
            itemBuilder: (context, index) {
              final city = filteredCities[index];
              return ListTile(
                title: Text(city.name),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
