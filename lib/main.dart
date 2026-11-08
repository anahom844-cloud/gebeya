import 'package:flutter/material.dart';

void main() => runApp(const GebeyaApp());

class Product {
  final String id, name, seller, city, category, emoji;
  final int price;
  const Product(this.id, this.name, this.price, this.seller, this.city,
      this.category, this.emoji);
}

const categories = ['ሁሉም', 'ኤሌክትሮኒክስ', 'ልብስ', 'ምግብ', 'ቤት', 'መኪና'];

final products = ValueNotifier<List<Product>>([
  const Product('1', 'ሳምሰንግ ስልክ A55', 32000, 'አቤል ሞባይል', 'አዲስ አበባ', 'ኤሌክትሮኒክስ', '📱'),
  const Product('2', 'የሀበሻ ቀሚስ', 4500, 'ሰላም ፋሽን', 'ባህር ዳር', 'ልብስ', '👗'),
  const Product('3', 'ንጹህ የጎጃም ማር (1ኪ.ግ)', 900, 'ጎጃም ማር', 'ደብረ ማርቆስ', 'ምግብ', '🍯'),
  const Product('4', 'የሲዳማ ቡና (1ኪ.ግ)', 1100, 'ሲዳማ ቡና', 'ሀዋሳ', 'ምግብ', '☕'),
  const Product('5', 'ላፕቶፕ HP 15', 48000, 'ቴክ ሀብ', 'አዲስ አበባ', 'ኤሌክትሮኒክስ', '💻'),
  const Product('6', 'የሶፋ ስብስብ', 25000, 'ቤት ዲዛይን', 'አዳማ', 'ቤት', '🛋️'),
  const Product('7', 'ቶዮታ ኮሮላ 2012', 1450000, 'ሞተር ሀውስ', 'አዲስ አበባ', 'መኪና', '🚗'),
  const Product('8', 'ጋቢ (ጥጥ)', 1800, 'ሸማ ማህበር', 'ጋሞ', 'ልብስ', '🧣'),
]);

final cart = ValueNotifier<Map<String, int>>({});

void addToCart(Product p) {
  final m = Map<String, int>.from(cart.value);
  m[p.id] = (m[p.id] ?? 0) + 1;
  cart.value = m;
}

void changeQty(String id, int d) {
  final m = Map<String, int>.from(cart.value);
  final q = (m[id] ?? 0) + d;
  if (q <= 0) {
    m.remove(id);
  } else {
    m[id] = q;
  }
  cart.value = m;
}

String birr(int n) {
  final s = n.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  return '$s ብር';
}

class GebeyaApp extends StatelessWidget {
  const GebeyaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'ገበያ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF078930),
              secondary: const Color(0xFFFCDD09)),
        ),
        home: const Shell(),
      );
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    const pages = [HomePage(), CartPage(), SellPage()];
    return Scaffold(
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.storefront), label: 'ገበያ'),
          NavigationDestination(
            label: 'ጋሪ',
            icon: ValueListenableBuilder(
              valueListenable: cart,
              builder: (_, m, __) => Badge(
                isLabelVisible: m.isNotEmpty,
                label: Text('${m.values.fold(0, (a, b) => a + b)}'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
          ),
          const NavigationDestination(
              icon: Icon(Icons.add_business), label: 'ሽጥ'),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String q = '', cat = 'ሁሉም';
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Product>>(
      valueListenable: products,
      builder: (_, list, __) {
        final shown = list
            .where((p) =>
                (cat == 'ሁሉም' || p.category == cat) && p.name.contains(q))
            .toList();
        return Column(children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => q = v),
              decoration: InputDecoration(
                hintText: 'ምርት ይፈልጉ...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                for (final c in categories)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                        label: Text(c),
                        selected: cat == c,
                        onSelected: (_) => setState(() => cat = c)),
                  )
              ],
            ),
          ),
          Expanded(
            child: shown.isEmpty
                ? const Center(child: Text('ምንም ምርት አልተገኘም'))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10),
                    itemCount: shown.length,
                    itemBuilder: (_, i) => ProductCard(shown[i]),
                  ),
          ),
        ]);
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product p;
  const ProductCard(this.p, {super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => DetailPage(p))),
      child: Card(
        elevation: 0,
        color: cs.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Center(
                    child:
                        Text(p.emoji, style: const TextStyle(fontSize: 64)))),
            Text(p.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(birr(p.price),
                style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            Row(children: [
              const Icon(Icons.location_on, size: 14),
              Expanded(
                  child: Text(p.city,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis)),
            ]),
          ]),
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Product p;
  const DetailPage(this.p, {super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(p.name)),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Center(child: Text(p.emoji, style: const TextStyle(fontSize: 120))),
        const SizedBox(height: 16),
        Text(p.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(birr(p.price),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold)),
        const Divider(height: 32),
        ListTile(
            leading: const Icon(Icons.store),
            title: Text(p.seller),
            subtitle: const Text('ሻጭ')),
        ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(p.city),
            subtitle: const Text('አካባቢ')),
        ListTile(
            leading: const Icon(Icons.category),
            title: Text(p.category),
            subtitle: const Text('ምድብ')),
      ]),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: () {
            addToCart(p);
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ወደ ጋሪ ታክሏል ✓')));
          },
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('ወደ ጋሪ ጨምር'),
        ),
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, int>>(
      valueListenable: cart,
      builder: (_, m, __) {
        if (m.isEmpty) return const Center(child: Text('ጋሪዎ ባዶ ነው 🛒'));
        final items = m.entries.map((e) {
          final p = products.value.firstWhere((x) => x.id == e.key);
          return (p, e.value);
        }).toList();
        final total = items.fold<int>(0, (s, i) => s + i.$1.price * i.$2);
        return Column(children: [
          Expanded(
            child: ListView(children: [
              for (final (p, q) in items)
                ListTile(
                  leading: Text(p.emoji, style: const TextStyle(fontSize: 32)),
                  title: Text(p.name),
                  subtitle: Text(birr(p.price * q)),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => changeQty(p.id, -1)),
                    Text('$q'),
                    IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => changeQty(p.id, 1)),
                  ]),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('ጠቅላላ', style: TextStyle(fontSize: 18)),
                    Text(birr(total),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ]),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: () => _checkout(context, total),
                    child: const Text('ክፍያ ፈጽም')),
              ),
            ]),
          ),
        ]);
      },
    );
  }

  void _checkout(BuildContext context, int total) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, children: [
        const Padding(
            padding: EdgeInsets.all(16),
            child: Text('የክፍያ ዘዴ ይምረጡ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        for (final (icon, name) in [
          (Icons.phone_android, 'Telebirr'),
          (Icons.account_balance, 'CBE Birr'),
          (Icons.payments, 'ሲደርስ በጥሬ ገንዘብ'),
        ])
          ListTile(
            leading: Icon(icon),
            title: Text(name),
            onTap: () {
              Navigator.pop(ctx);
              cart.value = {};
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('ትዕዛዝዎ ተቀብሏል 🎉'),
                  content: Text('${birr(total)} በ$name ይከፈላል።\nአመሰግናለሁ!'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('እሺ'))
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 12),
      ]),
    );
  }
}

class SellPage extends StatefulWidget {
  const SellPage({super.key});
  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final name = TextEditingController(),
      price = TextEditingController(),
      city = TextEditingController();
  String cat = categories[1];

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      Text('ምርትዎን ይሽጡ', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 16),
      TextField(
          controller: name,
          decoration: const InputDecoration(
              labelText: 'የምርት ስም', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(
          controller: price,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              labelText: 'ዋጋ (ብር)', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(
          controller: city,
          decoration: const InputDecoration(
              labelText: 'ከተማ', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: cat,
        decoration: const InputDecoration(
            labelText: 'ምድብ', border: OutlineInputBorder()),
        items: [
          for (final c in categories.skip(1))
            DropdownMenuItem(value: c, child: Text(c))
        ],
        onChanged: (v) => setState(() => cat = v!),
      ),
      const SizedBox(height: 20),
      FilledButton(
        onPressed: () {
          final pr = int.tryParse(price.text.trim());
          if (name.text.trim().isEmpty || pr == null) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ስም እና ዋጋ በትክክል ያስገቡ')));
            return;
          }
          products.value = [
            Product(
                DateTime.now().millisecondsSinceEpoch.toString(),
                name.text.trim(),
                pr,
                'እኔ',
                city.text.trim().isEmpty ? 'አዲስ አበባ' : city.text.trim(),
                cat,
                '🛍️'),
            ...products.value
          ];
          name.clear();
          price.clear();
          city.clear();
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ምርትዎ ተለጥፏል ✓')));
        },
        child: const Text('ለጥፍ'),
      ),
    ]);
  }
}
