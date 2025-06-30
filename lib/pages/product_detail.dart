import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  final bool fromOrder;

  const ProductDetailPage({
    super.key,
    required this.product,
    this.fromOrder = false,
  });

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/${product.imageUrl}',
                width: double.infinity,
                height: 250,
                fit: BoxFit.fitHeight,
                errorBuilder: (context, error, stack) =>
                    const Icon(Icons.broken_image, size: 100),
              ),
            ),

            const SizedBox(height: 16),

            // Name & Price
            Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            Row(children: [
              if (product.originalPrice != null) ...[
                Text("₹${product.originalPrice!.toStringAsFixed(0)}",
                    style: const TextStyle(fontSize: 18, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                const SizedBox(width: 8),
              ],
              Text("₹${product.price.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 22, color: Colors.green, fontWeight: FontWeight.bold)),
            ]),

            const SizedBox(height: 16),

            // Description Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 229, 209, 254),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 6, offset: const Offset(0,3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Product Description",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  const SizedBox(height: 8),
                  Text(_getDescription(product.name), style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Important Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: const Text(
                "Note: This service is for refilled, unbranded RO water in reusable cans and is compliant with FSSAI regulations. All cans are thoroughly cleaned before each use.Brand supplied depends on stock availability in your area.",
                style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.black54),
              ),
            ),

            const SizedBox(height: 24),

            // Add to Cart (conditionally rendered)
            if (!fromOrder)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text(
                    "Add to Cart",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => _showQuantityDialog(context, cart),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ... rest of class remains unchanged ...

  void _showQuantityDialog(BuildContext context, CartProvider cart) {
    int quantity = 1;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Quantity"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: StatefulBuilder(
          builder: (context, setState) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                quantity.toString(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => setState(() => quantity++),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final priceValue = product.price.toDouble(); // ensure double
              cart.addToCart(
                product.id,                 // ✅ ID (String)
                product.name,               // ✅ Name (String)
                priceValue,                 // ✅ Price (double)
                quantity,                   // ✅ Quantity (int)
                product.imageUrl,           // ✅ Image URL (String)
              );
              Navigator.pop(context);  // you may want this before or after
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$quantity x ${product.name} added to cart')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  String _getDescription(String productName) {
    if (productName.contains("Refilled RO")) {
      return "\u2705 Experience the convenience of safe, clean, and fresh RO-purified drinking water delivered directly to your doorstep — just like your local refill shop, now with the ease of app-based ordering.\n\nOur 20-litre cans are filled with high-quality RO-purified drinking water, tested periodically to ensure safety, taste, and hygiene.\n\nThis is an unbranded refill service designed to meet your daily hydration needs at an affordable price.\n\nWhether it’s for your home, office, or commercial use, our water is dispensed in clean, reusable 20-litre jars, sanitized regularly and handled with care by trained delivery personnel.\n\n✅ What’s Included: \n\u2022 20 litres of RO-purified drinking water\n\u2022 Delivered in reusable cans (customer-provided or company-assigned)\n\u2022 Quality tested as per FSSAI drinking water standards\n\u2022Clean handling and doorstep delivery\n\n\ud83d\udce6 Home Delivery Included\n\u2022For buildings without lift access, an additional ₹3 per floor will be charged\n\u2022Example: 3rd floor without lift = ₹9 additional delivery charge (payable on delivery)\n\n\ud83d\udca7 Why Choose Us:\n\u2022 Affordable and safe RO water\n\u2022 No need to carry heavy cans — we come to you\n\u2022 Fast and reliable service via our mobile app\n\u2022Subscription options available for daily/alternate-day refills";
    } else if (productName.contains("Branded Drinking Water")) {
      return "\u2705 Enjoy the assurance of sealed, BIS-certified branded drinking water delivered straight to your doorstep.\nWe supply trusted and approved brands to ensure safety, purity, and peace of mind with every sip.\nEach can is factory-sealed, tamper-proof, and tested as per IS:14543 standards, making it ideal for home, office, clinics, and commercial spaces where hygiene and brand trust matter.\n\n\✅ What’s Included:\n\u2022 20 litres branded water Can (sealed)\n\u2022BIS-certified drinking water (IS:14543)\n\u2022Quality tested as per FSSAI drinking water standards\n\u2022Original packaging from manufacturer (no refills)\n\u2022 📦 Delivery Details:\n\n\Home Delivery Included\n\u2022For buildings without lift access, an additional ₹3 per floor will be charged\n\u2022Example: 3rd floor without lift = ₹9 additional delivery charge (payable on delivery)\n\n💧 Why Choose Us:\n\u2022Factory-sealed for complete safety\n\u2022Trusted quality from leading water brandsIdeal for infants, elders, offices, and sensitive environments\n\u2022Backed by BIS and FSSAI complianceFast and reliable service via our mobile app\n\u2022Subscription options available for daily/alternate-day refills";
    } else if (productName.contains("Premium")) {
      return "\u2705 For those who demand the best, we bring you premium quality, factory-sealed 20-litre branded water cans from India’s most trusted names.\nThis includes premium variants like Bisleri Vedica, Kinley Club, Aquafina Select, or equivalent top-tier brands known for their ultra-purification, mineral balance, and unmatched taste.\nEach can is BIS-certified, FSSAI-compliant, and sealed at source, ensuring the highest standards of purity and safety.\nIdeal for households with infants or elders, high-end offices, wellness centers, clinics, and anyone who values premium hydration.\n\n✅ What’s Included: \n\u2022 20 litres Premium branded water Can (sealed)\n\u2022 BIS-certified drinking water (IS:14543)\n\u2022Quality tested as per FSSAI drinking water standards\n\u2022High-purity RO + UV + Ozonation treated water\n\u2022Delivered fresh from authorized supplier\n\n📦 Delivery Details:\n\n\Home Delivery Included\n\u2022For buildings without lift access, an additional ₹3 per floor will be charged\n\u2022Example: 3rd floor without lift = ₹9 additional delivery charge (payable on delivery)\n\n💧 Why Choose Us:\n\u2022Superior purification & mineral enrichment\n\u2022Factory-sealed for complete safety\n\u2022Trusted by hospitals, corporates, and premium residences\n\u2022Backed by BIS and FSSAI complianceFast and reliable service via our mobile app\n\u2022Subscription options available for daily/alternate-day refills";
    }
    return product.description;
  }
}
