import '../models/water_item.dart';

class WaterData {
  static List<WaterItem> getWaterItems() {
    return [
      WaterItem(
        id: '1',
        name: 'Pure Spring Water',
        description:
            'Natural spring water sourced from pristine mountain springs, filtered through natural rock formations for exceptional purity and taste.',
        price: 45.50,
        imageUrl:
            'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400',
        rating: 4.5,
        comments: 1287,
        distance: '1.7km',
        deliveryTime: '32min',
        category: 'Premium',
      ),
      WaterItem(
        id: '2',
        name: 'Mineral Rich Water',
        description:
            'Enhanced with essential minerals including calcium, magnesium, and potassium for optimal hydration and health benefits.',
        price: 12.88,
        imageUrl:
            'https://images.unsplash.com/photo-1581636625402-29b2a704ef13?w=400',
        rating: 4.5,
        comments: 1287,
        distance: '1.7km',
        deliveryTime: '32min',
        category: 'Enhanced',
      ),
      WaterItem(
        id: '3',
        name: 'Alkaline Water',
        description:
            'Premium alkaline water with pH 9.5+ to help balance body acidity and provide superior hydration for active lifestyles.',
        price: 33.0,
        imageUrl:
            'https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=400',
        rating: 4.5,
        comments: 1287,
        distance: '1.7km',
        deliveryTime: '32min',
        category: 'Premium',
      ),
    ];
  }
}
