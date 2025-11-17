-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 17, 2025 at 06:35 AM
-- Server version: 10.4.22-MariaDB
-- PHP Version: 8.1.2

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `water_delivery_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `delivery_locations`
--

CREATE TABLE `delivery_locations` (
  `id` int(11) NOT NULL,
  `order_id` varchar(100) NOT NULL,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `delivery_locations`
--

INSERT INTO `delivery_locations` (`id`, `order_id`, `latitude`, `longitude`, `updated_at`) VALUES
(214, '123', '-1.30169280', '36.89697990', '2025-10-08 06:52:04'),
(216, '133', '-1.29319210', '36.89263360', '2025-10-08 14:06:09'),
(218, '135', '-1.29683640', '36.89361870', '2025-10-08 16:26:47'),
(220, '136', '-1.29683640', '36.89361870', '2025-10-08 16:28:31'),
(222, '140', '-1.44039730', '37.05055360', '2025-10-09 05:17:19'),
(223, '141', '-1.44013600', '37.05040800', '2025-10-09 06:44:34'),
(227, '149', '-1.27139840', '36.83450880', '2025-10-09 08:11:24'),
(229, '150', '-1.27139840', '36.83450880', '2025-10-09 09:25:25'),
(231, '151', '-1.30457770', '36.90034090', '2025-10-13 08:21:31');

-- --------------------------------------------------------

--
-- Table structure for table `mpesa_transactions`
--

CREATE TABLE `mpesa_transactions` (
  `id` int(11) NOT NULL,
  `checkout_request_id` varchar(100) DEFAULT NULL,
  `order_id` varchar(50) DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'pending',
  `response_code` varchar(10) DEFAULT NULL,
  `response_desc` text DEFAULT NULL,
  `mpesa_receipt` varchar(50) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `user_name` varchar(100) NOT NULL,
  `user_email` varchar(100) DEFAULT NULL,
  `user_phone` varchar(20) NOT NULL,
  `address` text NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `status` varchar(20) DEFAULT 'pending',
  `created_at` datetime DEFAULT current_timestamp(),
  `payment_method` varchar(20) DEFAULT 'cash_on_delivery',
  `payment_status` varchar(20) DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `user_name`, `user_email`, `user_phone`, `address`, `total_amount`, `status`, `created_at`, `payment_method`, `payment_status`) VALUES
(133, 'edu', 'edu@gmail.com', '0721290888', '-1.2933395241025563, 36.81307451716021', '130.00', 'pending', '2025-10-08 17:04:45', 'cash_on_delivery', 'pending'),
(135, 'edu', 'edu@gmail.com', '0721290888', '-1.288148088982125, 36.79181711752063', '325.00', 'pending', '2025-10-08 19:26:30', 'cash_on_delivery', 'pending'),
(136, 'edu', 'edu@gmail.com', '0721290888', '-1.288148088982125, 36.79181711752063', '65.00', 'pending', '2025-10-08 19:28:11', 'cash_on_delivery', 'pending'),
(137, 'edu', 'edu@gmail.com', '0721290888', '', '130.00', 'pending', '2025-10-09 08:05:37', 'cash_on_delivery', 'pending'),
(138, 'edu', 'edu@gmail.com', '0721290888', '', '65.00', 'pending', '2025-10-09 08:06:02', 'cash_on_delivery', 'pending'),
(139, 'Eden', 'eden@gmail.com', '0721290888', '', '65.00', 'pending', '2025-10-09 08:09:51', 'cash_on_delivery', 'pending'),
(140, 'Eden', 'eden@gmail.com', '0721290888', '', '65.00', 'pending', '2025-10-09 08:16:17', 'cash_on_delivery', 'pending'),
(141, 'Eden', 'eden@gmail.com', '0721290888', '-1.2846299150424447, 36.80878298273638', '130.00', 'pending', '2025-10-09 08:26:19', 'cash_on_delivery', 'pending'),
(142, 'Eden', 'eden@gmail.com', '0721290888', '-1.2846299150424447, 36.80878298273638', '65.00', 'pending', '2025-10-09 08:26:49', 'cash_on_delivery', 'pending'),
(143, 'Nhial James', 'mewarnhial@gmail.com', '0798983368', '', '130.00', 'pending', '2025-10-09 09:16:03', 'cash_on_delivery', 'pending'),
(144, 'Eden', 'eden@gmail.com', '0721290888', '', '130.00', 'pending', '2025-10-09 09:46:06', 'cash_on_delivery', 'pending'),
(145, 'Eden', 'eden@gmail.com', '0721290888', '', '65.00', 'pending', '2025-10-09 10:07:24', 'cash_on_delivery', 'pending'),
(146, 'Eden', 'eden@gmail.com', '0721290888', '', '65.00', 'pending', '2025-10-09 10:10:56', 'cash_on_delivery', 'pending'),
(147, 'Eden', 'eden@gmail.com', '0721290888', '', '65.00', 'pending', '2025-10-09 10:32:35', 'cash_on_delivery', 'pending'),
(148, 'Eden', 'eden@gmail.com', '0721290888', '', '120.00', 'pending', '2025-10-09 10:38:42', 'cash_on_delivery', 'pending'),
(149, 'Eden', 'eden@gmail.com', '0721290888', '', '65.00', 'pending', '2025-10-09 11:10:50', 'cash_on_delivery', 'pending'),
(150, 'Eden', 'eden@gmail.com', '0721290888', '', '345.00', 'pending', '2025-10-09 12:23:23', 'cash_on_delivery', 'pending'),
(151, 'Eden', 'eden@gmail.com', '0721290888', '', '65.00', 'pending', '2025-10-13 11:18:41', 'cash_on_delivery', 'pending'),
(152, 'Eden', 'eden@gmail.com', '0721290888', '', '130.00', 'pending', '2025-11-17 07:33:46', 'cash_on_delivery', 'pending');

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `product_id` varchar(50) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `product_id`, `quantity`, `price`) VALUES
(140, 133, '19', 2, '65.00'),
(142, 135, '19', 5, '65.00'),
(143, 136, '17', 1, '65.00'),
(144, 137, '19', 2, '65.00'),
(145, 138, '18', 1, '65.00'),
(146, 139, '19', 1, '65.00'),
(147, 140, '17', 1, '65.00'),
(148, 141, '19', 2, '65.00'),
(149, 142, '18', 1, '65.00'),
(150, 143, '17', 2, '65.00'),
(151, 144, '17', 2, '65.00'),
(152, 145, '18', 1, '65.00'),
(153, 146, '18', 1, '65.00'),
(154, 147, '19', 1, '65.00'),
(155, 148, '8', 1, '120.00'),
(156, 149, '19', 1, '65.00'),
(157, 150, '13', 1, '75.00'),
(158, 150, '12', 2, '75.00'),
(159, 150, '8', 1, '120.00'),
(160, 151, '19', 1, '65.00'),
(161, 152, '17', 2, '65.00');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `image_url` varchar(255) DEFAULT NULL,
  `category` varchar(50) NOT NULL,
  `rating` decimal(3,1) DEFAULT 0.0,
  `comments` int(11) DEFAULT 0,
  `distance` varchar(20) DEFAULT '—',
  `delivery_time` varchar(20) DEFAULT '—',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `image_filename` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `name`, `description`, `price`, `image_url`, `category`, `rating`, `comments`, `distance`, `delivery_time`, `created_at`, `image_filename`) VALUES
(1, 'Aquamist Oxyrich Still 1L', 'Premium oxygenated still water with enhanced mineral content.', '80.00', 'uploads/still_water.jpeg', 'Still', '4.5', 127, '1.2 km', '15 mins', '2025-08-29 15:13:31', 'still_water.jpeg'),
(2, 'Aquamist Oxyrich Still 500ml', 'Premium oxygenated still water (500ml).', '30.00', 'uploads/still_water1.jpg', 'Still', '4.5', 127, '1.2 km', '15 mins', '2025-08-29 15:13:31', 'still_water1.jpg'),
(3, 'Aquamist Sparkling 500ml', 'Refreshing sparkling water with natural carbonation.', '60.00', 'uploads/sparkling_500.jpg', 'Sparkling', '4.7', 89, '0.8 km', '12 mins', '2025-08-29 15:13:31', 'sparkling_500.jpg'),
(4, 'Aquamist Sparkling 1L', 'Large bottle of premium sparkling water.', '95.00', 'uploads/sparkling_1l.jpg', 'Sparkling', '4.6', 156, '0.8 km', '12 mins', '2025-08-29 15:13:31', 'sparkling_1l.jpg'),
(5, 'Natural Mineral 300ml (24 pack)', 'Natural mineral water 24-pack.', '480.00', 'uploads/mineral_pack.jpeg', 'Mineral', '4.8', 234, '2.1 km', '25 mins', '2025-08-29 15:13:31', 'mineral_pack.jpeg'),
(6, 'Spring Water 500ml', 'Pure spring water with balanced minerals.', '50.00', 'uploads/spring_500.webp', 'Mineral', '4.4', 98, '1.5 km', '18 mins', '2025-08-29 15:13:31', 'spring_500.webp'),
(7, 'Mineral Water 1L', 'Premium mineral water with electrolytes.', '85.00', 'uploads/mineral_1l.webp', 'Mineral', '4.5', 167, '1.5 km', '18 mins', '2025-08-29 15:13:31', 'mineral_1l.webp'),
(8, 'Mineral Water 1.5L', 'Large mineral water bottle.', '120.00', 'uploads/mineral_1.5l.jpg', 'Mineral', '4.6', 143, '1.5 km', '18 mins', '2025-08-29 15:13:31', 'mineral_1.5l.jpg'),
(9, 'Mineral Water 5L', 'Family size mineral water bottle.', '280.00', 'uploads/mineral_5l.jpeg', 'Mineral', '4.7', 201, '1.5 km', '18 mins', '2025-08-29 15:13:31', 'mineral_5l.jpeg'),
(10, 'Refillable Bottle 18.9L', 'Large refillable water bottle for home/office.', '350.00', 'uploads/refillable_18l.jpeg', 'Mineral', '4.9', 87, '3.2 km', '35 mins', '2025-08-29 15:13:31', 'refillable_18l.jpeg'),
(11, 'Frutz Orange 500ml', 'Fresh orange juice made from premium oranges.', '75.00', 'uploads/orange_juice.jpg', 'Juices', '4.6', 178, '1.8 km', '20 mins', '2025-08-29 15:13:31', 'orange_juice.jpg'),
(12, 'Frutz Mango 500ml', 'Tropical mango juice with rich flavor.', '75.00', 'uploads/mango_juice.jpg', 'Juices', '4.7', 192, '1.8 km', '20 mins', '2025-08-29 15:13:31', 'mango_juice.jpg'),
(13, 'Frutz Apple 500ml', 'Crisp apple juice with natural extract.', '75.00', 'uploads/apple_juice.jpg', 'Juices', '4.5', 134, '1.8 km', '20 mins', '2025-08-29 15:13:31', 'apple_juice.jpg'),
(14, 'Frutz Tropical 500ml', 'Exotic blend of tropical fruits.', '75.00', 'uploads/tropical_juice.jpeg', 'Juices', '4.8', 156, '1.8 km', '20 mins', '2025-08-29 15:13:31', 'tropical_juice.jpeg'),
(15, 'Frutz Pineapple 500ml', 'Sweet tangy pineapple juice.', '75.00', 'uploads/pineapple_juice.jpg', 'Juices', '4.6', 167, '1.8 km', '20 mins', '2025-08-29 15:13:31', 'pineapple_juice.jpg'),
(16, 'Flavored Water Peach 500ml', 'Lightly flavored peach water.', '65.00', 'uploads/peach_water.jpg', 'Flavored', '4.4', 98, '1.0 km', '15 mins', '2025-08-29 15:13:31', 'peach_water.jpg'),
(17, 'Flavored Water Lemon 500ml', 'Refreshing lemon-flavored water.', '65.00', 'uploads/lemon_water.webp', 'Flavored', '4.5', 123, '1.0 km', '15 mins', '2025-08-29 15:13:31', 'lemon_water.webp'),
(18, 'Flavored Water Mango 500ml', 'Tropical mango flavored water.', '65.00', 'uploads/mango_water.jpg', 'Flavored', '4.6', 145, '1.0 km', '15 mins', '2025-08-29 15:13:31', 'mango_water.jpg'),
(19, 'Flavored Water Apple 500ml', 'Crisp apple flavored water.', '65.00', 'uploads/apple_water.jpg', 'Flavored', '4.3', 87, '1.0 km', '15 mins', '2025-08-29 15:13:31', 'apple_water.jpg'),
(20, 'Flavored Water Strawberry 500ml', 'Sweet strawberry flavored water.', '65.00', 'uploads/strawberry_water.jpg', 'Flavored', '4.7', 176, '1.0 km', '15 mins', '2025-08-29 15:13:31', 'strawberry_water.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `address` text DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `phone`, `password`, `address`) VALUES
(34, 'Zablon', 'zablon@gmail.com', '0758432404', '$2y$10$14gQxxdCjjUvbXiBqc8v6.7kXPcSo6IdvOC98JpfxJvexnrnNGB5O', ''),
(41, 'edu', 'edu@gmail.com', '0721290888', '$2y$10$FdLnD07i4q2gSkUxmvRzpuvboZ3lVzs6F0NSbePcHj9ciIU8pkDnW', ''),
(42, 'Eden', 'eden@gmail.com', '0721290888', '$2y$10$ntzGsrbFyB4UxkB.nFE1fe7.2h34u//BDk4Ew/Gt.kO3DqGZ15fgO', ''),
(43, 'Nhial James', 'mewarnhial@gmail.com', '0798983368', '$2y$10$4joaXelUxwne7B.E7vvEjeqOBZozsayuYP76pf5uiESQOcabh1cHK', '');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `delivery_locations`
--
ALTER TABLE `delivery_locations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `order_id` (`order_id`),
  ADD KEY `order_id_2` (`order_id`);

--
-- Indexes for table `mpesa_transactions`
--
ALTER TABLE `mpesa_transactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `checkout_request_id` (`checkout_request_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `delivery_locations`
--
ALTER TABLE `delivery_locations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=239;

--
-- AUTO_INCREMENT for table `mpesa_transactions`
--
ALTER TABLE `mpesa_transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=153;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=162;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
