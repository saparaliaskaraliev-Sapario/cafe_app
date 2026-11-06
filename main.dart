import 'package:flutter/material.dart';

void main() => runApp(const CafeApp());

class Dish {
  final String name;
  final String description;
  final int price;
  final IconData icon;
  const Dish(this.name, this.description, this.price, this.icon);
}

const menu = [
  Dish('Бургер', 'Говяжья котлета, сыр, овощи', 350, Icons.lunch_dining),
  Dish('Пицца', 'Пепперони, 30 см', 520, Icons.local_pizza),
  Dish('Шаурма', 'Курица, овощи, соус', 250, Icons.restaurant),
  Dish('Картошка фри', 'Большая порция', 150, Icons.fastfood),
  Dish('Кофе', 'Американо 300 мл', 120, Icons.coffee),
  Dish('Чай', 'Чёрный или зелёный', 80, Icons.emoji_food_beverage),
  Dish('Чизкейк', 'Классический', 200, Icons.cake),
];

class CafeApp extends StatelessWidget {
  const CafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Кафе',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        useMaterial3: true,
      ),
      home: const MenuPage(),
    );
  }
}

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final Map<Dish, int> cart = {};

  int get total =>
      cart.entries.fold(0, (sum, e) => sum + e.key.price * e.value);
  int get count => cart.values.fold(0, (sum, v) => sum + v);

  void add(Dish d) => setState(() => cart[d] = (cart[d] ?? 0) + 1);

  void remove(Dish d) {
    setState(() {
      final c = (cart[d] ?? 0) - 1;
      if (c <= 0) {
        cart.remove(d);
      } else {
        cart[d] = c;
      }
    });
  }

  Future<void> openCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CartPage(cart: cart)),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Меню')),
      body: ListView.builder(
        itemCount: menu.length,
        itemBuilder: (context, i) {
          final dish = menu[i];
          final qty = cart[dish] ?? 0;
          return ListTile(
            leading: CircleAvatar(child: Icon(dish.icon)),
            title: Text(dish.name),
            subtitle: Text('${dish.description}\n${dish.price} ₽'),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (qty > 0) ...[
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => remove(dish),
                  ),
                  Text('$qty', style: const TextStyle(fontSize: 16)),
                ],
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () => add(dish),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: count == 0
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  onPressed: openCart,
                  icon: const Icon(Icons.shopping_cart),
                  label: Text('Корзина: $count шт. • $total ₽'),
                ),
              ),
            ),
    );
  }
}

class CartPage extends StatefulWidget {
  final Map<Dish, int> cart;
  const CartPage({super.key, required this.cart});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int get total => widget.cart.entries
      .fold(0, (sum, e) => sum + e.key.price * e.value);

  void checkout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Заказ оформлен'),
        content: Text('Сумма: $total ₽. Спасибо!'),
        actions: [
          TextButton(
            onPressed: () {
              widget.cart.clear();
              Navigator.pop(context); // закрыть диалог
              Navigator.pop(context); // вернуться в меню
            },
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.cart.entries.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Корзина')),
      body: items.isEmpty
          ? const Center(child: Text('Корзина пуста'))
          : ListView(
              children: [
                for (final e in items)
                  ListTile(
                    leading: Icon(e.key.icon),
                    title: Text(e.key.name),
                    subtitle: Text('${e.key.price} ₽ × ${e.value}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => setState(() {
                            if (e.value <= 1) {
                              widget.cart.remove(e.key);
                            } else {
                              widget.cart[e.key] = e.value - 1;
                            }
                          }),
                        ),
                        Text('${e.key.price * e.value} ₽'),
                      ],
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton(
                  onPressed: checkout,
                  child: Text('Оформить заказ • $total ₽'),
                ),
              ),
            ),
    );
  }
}
