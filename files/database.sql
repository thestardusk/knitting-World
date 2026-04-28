

-- 1. Create & select database
CREATE DATABASE IF NOT EXISTS knitting_world
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE knitting_world;

-- ── 2. USERS (admin / sellers) ─────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id         INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  username   VARCHAR(80)     NOT NULL UNIQUE,
  password   VARCHAR(255)    NOT NULL,        -- bcrypt hash
  role       ENUM('admin','seller') NOT NULL DEFAULT 'admin',
  created_at DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB;

-- Default admin:  username=admin  password=admin123  (bcrypt hash)
INSERT IGNORE INTO users (username, password, role) VALUES
('admin', '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lMti', 'admin');
-- ^ bcrypt hash of 'admin123' with salt rounds=10

-- ── 3. CATEGORIES ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS categories (
  id   INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  name VARCHAR(120)  NOT NULL,
  img  VARCHAR(500)  DEFAULT '',
  PRIMARY KEY (id)
) ENGINE=InnoDB;

INSERT IGNORE INTO categories (id, name, img) VALUES
(1, 'Yarns',       'https://images.unsplash.com/photo-1558171813-0f9f9b2d4488?w=600&q=70'),
(2, 'Needles',     'https://images.unsplash.com/photo-1593020257327-a4e4f28d0e67?w=600&q=70'),
(3, 'Kits',        'https://images.unsplash.com/photo-1604599340287-2042b9ea9a73?w=600&q=70'),
(4, 'Accessories', 'https://images.unsplash.com/photo-1605369176878-e5b9f432a5d7?w=600&q=70'),
(5, 'Patterns',    'https://images.unsplash.com/photo-1618354691792-d1d42acfd860?w=600&q=70'),
(6, 'Finished',    'https://images.unsplash.com/photo-1584736286279-b9d9ac50e0b1?w=600&q=70');

-- ── 4. PRODUCTS ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS products (
  id          INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  name        VARCHAR(200)     NOT NULL,
  price       DECIMAL(10,2)    NOT NULL,
  description TEXT             DEFAULT '',
  image       VARCHAR(500)     DEFAULT '',
  category_id INT UNSIGNED     DEFAULT NULL,
  badge       VARCHAR(60)      DEFAULT '',
  created_at  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP
                               ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  INDEX idx_category (category_id),
  CONSTRAINT fk_product_category
    FOREIGN KEY (category_id) REFERENCES categories(id)
    ON DELETE SET NULL
) ENGINE=InnoDB;

INSERT IGNORE INTO products (id, name, price, category_id, description, image, badge) VALUES
(1,  'Merino Wool Bundle',         849.00,  1, 'Soft 100% merino, 3-ply, perfect for sweaters and shawls.',                         'https://images.unsplash.com/photo-1558171813-0f9f9b2d4488?w=500&q=70',  'Bestseller'),
(2,  'Bamboo Circular Set',       1249.00,  2, 'Smooth bamboo tips on flexible cables — 60 & 80 cm lengths.',                       'https://images.unsplash.com/photo-1593020257327-a4e4f28d0e67?w=500&q=70',  ''),
(3,  'Beginner Starter Kit',       699.00,  3, 'Everything you need to knit your first scarf: yarn, needles, guide.',               'https://images.unsplash.com/photo-1604599340287-2042b9ea9a73?w=500&q=70',  'New'),
(4,  'Alpaca Blend Skein',         599.00,  1, 'Luxurious alpaca-wool blend in 20 rich seasonal colours.',                          'https://images.unsplash.com/photo-1605369176878-e5b9f432a5d7?w=500&q=70',  ''),
(5,  'Stitch Marker Set',          199.00,  4, '40-piece colourful stitch markers in a travel-friendly case.',                      'https://images.unsplash.com/photo-1618354691792-d1d42acfd860?w=500&q=70',  ''),
(6,  'Cabled Sweater Pattern',     299.00,  5, 'Intermediate cable knit sweater pattern with video tutorials.',                     'https://images.unsplash.com/photo-1584736286279-b9d9ac50e0b1?w=500&q=70',  'Popular'),
(7,  'Hand-Knit Wool Shawl',      1799.00,  6, 'Artisan-made shawl in rust & cream — one of a kind.',                              'https://images.unsplash.com/photo-1620799140188-3b2a02fd9a77?w=500&q=70',  'Handmade'),
(8,  'Cotton Summer Yarn',         399.00,  1, 'Breathable 100% cotton, ideal for lightweight summer projects.',                    'https://images.unsplash.com/photo-1597394997483-1cda1a4d79a5?w=500&q=70',  ''),
(9,  'Interchangeable Needle Kit', 2199.00, 2, 'Complete set of stainless steel tips with multiple cable lengths.',                 'https://images.unsplash.com/photo-1593020257327-a4e4f28d0e67?w=500&q=70',  'Premium'),
(10, 'Cozy Socks Kit',             549.00,  3, 'Beginner-friendly sock kit with self-striping yarn and pattern.',                   'https://images.unsplash.com/photo-1604599340287-2042b9ea9a73?w=500&q=70',  '');

-- ── 5. Useful Views ─────────────────────────────────────────
CREATE OR REPLACE VIEW v_products_full AS
  SELECT
    p.id, p.name, p.price, p.description, p.image, p.badge,
    c.id   AS category_id,
    c.name AS category_name,
    p.created_at, p.updated_at
  FROM products p
  LEFT JOIN categories c ON p.category_id = c.id;

-- ── 6. Quick checks ─────────────────────────────────────────
-- SELECT * FROM users;
-- SELECT * FROM categories;
-- SELECT * FROM v_products_full;
