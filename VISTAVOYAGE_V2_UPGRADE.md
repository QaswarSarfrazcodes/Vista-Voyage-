# VistaVoyage V2 — Complete Upgrade Guide

> Give this entire file to **Antigravity** and ask it to integrate everything into
> the existing VistaVoyage project. Every section below is self-contained:
> schema → model → services → screens → routes → prompts.

---

## 📋 What This Upgrade Does

1. **Moves all destinations to Supabase** — no more hardcoded list in Dart, app becomes lightweight
2. **Adds 20+ new destinations** — including Islamabad, Lahore, Karachi, Murree, Hunza, Skardu, Naran Kaghan + existing 10 international ones, each with a real image
3. **Adds a Map screen** — see all destinations on an interactive map (no Google API key needed — uses OpenStreetMap)
4. **Adds Profile screen** — edit name, view email, avatar
5. **Adds Support & FAQ screen** — expandable FAQ list + contact support
6. **Redesigns Home, Detail, and AI screens** with a brand-new color scheme
7. **New color scheme**: "Ocean Sunset" — teal + coral + gold, replacing the old blue/amber palette

---

## 🎨 1. New Design System — "Ocean Sunset"

Replace the old color tokens with these everywhere (Home, Detail, AI, Settings, Notifications, Login, Signup):

| Token | Old Value | **New Value** | Used On |
|---|---|---|---|
| Primary | `#3B82F6` | **`#0D9488`** (Deep Teal) | Buttons, links, active icons |
| Primary Dark | `#2563EB` | **`#0F766E`** (Darker Teal) | AppBar backgrounds |
| Accent | `#F5A623` | **`#FBBF24`** (Warm Gold) | Ratings, highlights, CTAs |
| Coral | *(new)* | **`#FF6B6B`** | Favorite heart, delete actions, error alternative |
| Red Error | `#E53935` | **`#DC2626`** | Error banners/borders (kept similar, slightly adjusted) |
| Charcoal | `#2D2D2D` | **`#1E293B`** | Body text |
| Gray | `#9E9E9E` | **`#64748B`** | Hints, secondary text |
| Surface BG | `#F9FAFB` | **`#F8FAFC`** | Scaffold background |
| Card Tint | `#DBEAFE` | **`#CCFBF1`** (Light Teal) | Chips, tag backgrounds |
| Dark Gradient | `#0F2044 → #1E3A5F` | **`#042F2E → #134E4A`** | Splash/Login/Signup backgrounds |

Fonts stay the same: `PlayfairDisplay` (titles) + `Nunito` (body).

Create this as a shared constants file so every screen references one source of truth:

### `lib/theme/app_colors.dart` (NEW FILE)

```dart
import 'package:flutter/material.dart';

/// VistaVoyage V2 — "Ocean Sunset" color system.
/// Import this everywhere instead of hardcoding hex colors.
class AppColors {
  AppColors._();

  static const Color primary       = Color(0xFF0D9488); // Deep Teal
  static const Color primaryDark   = Color(0xFF0F766E); // AppBars
  static const Color gold          = Color(0xFFFBBF24); // Ratings/CTAs
  static const Color coral         = Color(0xFFFF6B6B); // Favorites/delete
  static const Color error         = Color(0xFFDC2626);
  static const Color charcoal      = Color(0xFF1E293B);
  static const Color gray          = Color(0xFF64748B);
  static const Color surface       = Color(0xFFF8FAFC);
  static const Color cardTint      = Color(0xFFCCFBF1);
  static const Color divider       = Color(0xFFE2E8F0);

  static const List<Color> darkGradient = [Color(0xFF042F2E), Color(0xFF134E4A)];
}
```

---

## 🗄️ 2. Supabase Schema — Migration SQL

Run this in the **Supabase SQL Editor** (Dashboard → SQL Editor → New Query):

```sql
-- ── Destinations table (replaces hardcoded Dart list) ─────────────────────
create table if not exists destinations (
  id           text primary key,
  name         text not null,
  country      text not null,
  city         text,
  category     text default 'City',        -- City, Beach, Mountain, Historic, etc.
  image_url    text not null,
  description  text not null,
  rating       numeric(2,1) default 4.5,
  tags         text[] default '{}',
  highlights   text[] default '{}',
  best_time    text default '',
  avg_budget   text default '',
  latitude     double precision,
  longitude    double precision,
  created_at   timestamptz default now()
);

-- Public read access (anyone can browse destinations, even logged out)
alter table destinations enable row level security;

create policy "Public read access"
  on destinations for select
  using (true);

-- ── Profiles table (for Profile screen — extends Supabase auth.users) ────
create table if not exists profiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  full_name    text,
  avatar_url   text,
  bio          text default '',
  updated_at   timestamptz default now()
);

alter table profiles enable row level security;

create policy "Users can view their own profile"
  on profiles for select using (auth.uid() = id);

create policy "Users can update their own profile"
  on profiles for update using (auth.uid() = id);

create policy "Users can insert their own profile"
  on profiles for insert with check (auth.uid() = id);
```

### Seed data — 20 destinations (Pakistani + international)

Run this after the table is created (Supabase SQL Editor):

```sql
insert into destinations (id, name, country, city, category, image_url, description, rating, tags, highlights, best_time, avg_budget, latitude, longitude) values

('islamabad', 'Islamabad', 'Pakistan', 'Islamabad', 'City',
 'https://images.unsplash.com/photo-1626621341169-a0e77534ee59?w=800',
 'Pakistan''s green, planned capital nestled at the foot of the Margalla Hills — home to the striking Faisal Mosque, peaceful lake views, and wide tree-lined avenues.',
 4.6, array['Capital','Nature','Modern','Peaceful'], array['Faisal Mosque','Margalla Hills','Rawal Lake','Pakistan Monument'],
 'March – May, Sep – Nov', 'PKR 6,000–15,000/day', 33.6844, 73.0479),

('lahore', 'Lahore', 'Pakistan', 'Lahore', 'Historic',
 'https://images.unsplash.com/photo-1601297183530-6870d483f7f5?w=800',
 'The cultural heart of Pakistan — Mughal-era forts, the majestic Badshahi Mosque, vibrant food streets, and centuries of history at every corner.',
 4.7, array['History','Food','Culture','Architecture'], array['Badshahi Mosque','Lahore Fort','Food Street','Shalimar Gardens'],
 'Oct – March', 'PKR 5,000–12,000/day', 31.5497, 74.3436),

('karachi', 'Karachi', 'Pakistan', 'Karachi', 'City',
 'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=800',
 'Pakistan''s largest city and economic hub, with a lively Arabian Sea coastline, bustling bazaars, and a rich mix of cultures and cuisines.',
 4.3, array['Coastal','Urban','Food','Nightlife'], array['Clifton Beach','Mazar-e-Quaid','Port Grand','Empress Market'],
 'Nov – Feb', 'PKR 5,000–14,000/day', 24.8607, 67.0011),

('murree', 'Murree', 'Pakistan', 'Murree', 'Mountain',
 'https://images.unsplash.com/photo-1626016926734-6a7ba9b5f6b1?w=800',
 'A charming colonial-era hill station offering pine forests, misty views, and a cool escape from the plains — Pakistan''s most beloved summer retreat.',
 4.4, array['Mountains','Nature','Family','Snow'], array['Mall Road','Patriata Chairlift','Kashmir Point','Pindi Point'],
 'March – Oct (Dec–Feb for snow)', 'PKR 6,000–15,000/day', 33.9070, 73.3943),

('hunza', 'Hunza Valley', 'Pakistan', 'Hunza', 'Mountain',
 'https://images.unsplash.com/photo-1605649487212-47bdab064df7?w=800',
 'A breathtaking valley surrounded by towering peaks including Rakaposhi — famous for turquoise rivers, ancient forts, and legendary hospitality.',
 4.9, array['Mountains','Scenic','Adventure','Peaceful'], array['Attabad Lake','Baltit Fort','Passu Cones','Eagle''s Nest'],
 'April – October', 'PKR 8,000–20,000/day', 36.3167, 74.6500),

('skardu', 'Skardu', 'Pakistan', 'Skardu', 'Mountain',
 'https://images.unsplash.com/photo-1589308078059-be1415eab4c3?w=800',
 'Gateway to K2 and the Karakoram giants — dramatic desert-mountain landscapes, glacial lakes, and some of the most epic scenery on Earth.',
 4.8, array['Adventure','Mountains','Trekking','Scenic'], array['Shangrila Resort','Deosai Plains','Satpara Lake','Shigar Fort'],
 'May – September', 'PKR 8,000–18,000/day', 35.2971, 75.6333),

('naran', 'Naran Kaghan', 'Pakistan', 'Naran', 'Mountain',
 'https://images.unsplash.com/photo-1606298855672-3efb63017be5?w=800',
 'A lush green valley leading to the legendary Saif-ul-Malook Lake, surrounded by snow-capped peaks and alpine meadows.',
 4.6, array['Nature','Lakes','Adventure','Family'], array['Saif-ul-Malook Lake','Babusar Top','Lulusar Lake','Kaghan Valley'],
 'June – September', 'PKR 6,000–14,000/day', 34.9078, 73.6478),

('paris', 'Paris', 'France', 'Paris', 'City',
 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800',
 'The City of Light dazzles with the iconic Eiffel Tower, world-class cuisine, magnificent art at the Louvre, and charming cobblestone streets along the Seine.',
 4.9, array['Romance','Art','Culture','Food'], array['Eiffel Tower','Louvre Museum','Notre-Dame Cathedral','Champs-Élysées'],
 'April – June, Sep – Oct', '$150–$300/day', 48.8566, 2.3522),

('tokyo', 'Tokyo', 'Japan', 'Tokyo', 'City',
 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800',
 'A neon-lit metropolis where ancient temples coexist with cutting-edge technology. Explore Shibuya crossing, taste authentic ramen, and witness Mount Fuji from afar.',
 4.8, array['Technology','Food','Culture','Nightlife'], array['Shibuya Crossing','Senso-ji Temple','Shinjuku','Tokyo Tower'],
 'March – May, Oct – Nov', '$100–$200/day', 35.6762, 139.6503),

('santorini', 'Santorini', 'Greece', 'Santorini', 'Beach',
 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800',
 'Perched on volcanic cliffs above the Aegean Sea, Santorini offers breathtaking sunsets, whitewashed villages, and crystal-clear waters perfect for exploration.',
 4.8, array['Beach','Romance','Scenic','History'], array['Oia Sunset','Caldera Views','Red Beach','Ancient Akrotiri'],
 'June – September', '$200–$400/day', 36.3932, 25.4615),

('dubai', 'Dubai', 'UAE', 'Dubai', 'City',
 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800',
 'A futuristic skyline rises from the desert — home to the world''s tallest building, luxury shopping malls, indoor ski slopes, and golden desert dunes at sunset.',
 4.7, array['Luxury','Shopping','Adventure','Modern'], array['Burj Khalifa','Dubai Mall','Desert Safari','Palm Jumeirah'],
 'November – March', '$200–$500/day', 25.2048, 55.2708),

('bali', 'Bali', 'Indonesia', 'Bali', 'Beach',
 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800',
 'The Island of the Gods enchants with terraced rice paddies, sacred temples, world-class surf breaks, and a vibrant arts scene amid lush tropical jungle.',
 4.7, array['Nature','Spiritual','Beach','Adventure'], array['Ubud Rice Terraces','Tanah Lot Temple','Kuta Beach','Mount Batur'],
 'April – October', '$60–$150/day', -8.3405, 115.0920),

('newyork', 'New York City', 'USA', 'New York', 'City',
 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=800',
 'The city that never sleeps — from Central Park to Times Square, Broadway shows, iconic skyline views, world-renowned museums, and a melting pot of global cuisines.',
 4.8, array['Urban','Culture','Food','Shopping'], array['Central Park','Times Square','Statue of Liberty','Brooklyn Bridge'],
 'April – June, Sep – Nov', '$200–$400/day', 40.7128, -74.0060),

('maldives', 'Maldives', 'Maldives', 'Malé', 'Beach',
 'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?w=800',
 'Paradise on Earth — overwater bungalows float above turquoise lagoons, coral reefs teem with marine life, and powdery white sand beaches stretch endlessly.',
 4.9, array['Beach','Luxury','Diving','Romance'], array['Overwater Villas','Coral Reefs','Whale Shark Diving','Sunset Cruises'],
 'November – April', '$400–$1000/day', 3.2028, 73.2207),

('rome', 'Rome', 'Italy', 'Rome', 'Historic',
 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800',
 'The Eternal City wears 2,000 years of history — the Colosseum, Roman Forum, Vatican Museums, and the Trevi Fountain create an open-air museum unlike any other.',
 4.8, array['History','Food','Art','Culture'], array['Colosseum','Vatican City','Trevi Fountain','Spanish Steps'],
 'April – June, Sep – Oct', '$120–$250/day', 41.9028, 12.4964),

('capetown', 'Cape Town', 'South Africa', 'Cape Town', 'Nature',
 'https://images.unsplash.com/photo-1580060839313-9d4e3c9d13b2?w=800',
 'Where mountains meet the ocean — Table Mountain towers over pristine beaches, Robben Island tells powerful stories, and the Cape Winelands offer world-class vintages.',
 4.7, array['Nature','Adventure','History','Wine'], array['Table Mountain','Cape Point','Robben Island','Boulders Beach Penguins'],
 'October – April', '$80–$180/day', -33.9249, 18.4241),

('istanbul', 'Istanbul', 'Turkey', 'Istanbul', 'Historic',
 'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=800',
 'Straddling two continents, Istanbul is a magical blend of East and West — the Blue Mosque and Hagia Sophia stand beside vibrant bazaars and Bosphorus cruises.',
 4.7, array['History','Culture','Food','Architecture'], array['Hagia Sophia','Grand Bazaar','Blue Mosque','Bosphorus Strait'],
 'April – May, Sep – Nov', '$60–$150/day', 41.0082, 28.9784),

('kyoto', 'Kyoto', 'Japan', 'Kyoto', 'Historic',
 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800',
 'Japan''s former imperial capital, filled with thousands of classical Buddhist temples, gardens, and traditional wooden houses.',
 4.8, array['History','Culture','Peaceful','Temples'], array['Fushimi Inari Shrine','Arashiyama Bamboo Grove','Kinkaku-ji','Gion District'],
 'March – May, Oct – Nov', '$90–$180/day', 35.0116, 135.7681),

('swiss_alps', 'Interlaken', 'Switzerland', 'Interlaken', 'Mountain',
 'https://images.unsplash.com/photo-1530122037265-a5f1f91d3b99?w=800',
 'Nestled between two turquoise lakes and the Jungfrau massif, Interlaken is the adventure capital of the Swiss Alps.',
 4.9, array['Mountains','Adventure','Scenic','Luxury'], array['Jungfraujoch','Lake Thun','Harder Kulm','Paragliding'],
 'June – September', '$200–$450/day', 46.6863, 7.8632);
```

> **Tip:** if any Unsplash URL 404s later, swap it for `https://picsum.photos/seed/<name>/800/600` as a guaranteed-working placeholder while you source real photos.

---

## 📦 3. Updated Model — `lib/models/destination_model.dart`

```dart
// lib/models/destination_model.dart
// V2: added category, latitude, longitude for Map screen support.

class DestinationModel {
  final String       id;
  final String       name;
  final String       country;
  final String       city;
  final String       category;      // City, Beach, Mountain, Historic, Nature
  final String       imageUrl;
  final bool         isAsset;
  final String       description;
  final double       rating;
  final List<String> tags;
  final List<String> highlights;
  final String       bestTime;
  final String       avgBudget;
  final double?      latitude;
  final double?      longitude;

  const DestinationModel({
    required this.id,
    required this.name,
    required this.country,
    this.city = '',
    this.category = 'City',
    required this.imageUrl,
    this.isAsset = false,
    required this.description,
    required this.rating,
    this.tags       = const [],
    this.highlights = const [],
    this.bestTime   = '',
    this.avgBudget  = '',
    this.latitude,
    this.longitude,
  });

  factory DestinationModel.fromMap(Map<String, dynamic> map) {
    return DestinationModel(
      id:          map['id'] as String? ?? '',
      name:        map['name'] as String? ?? '',
      country:     map['country'] as String? ?? '',
      city:        map['city'] as String? ?? '',
      category:    map['category'] as String? ?? 'City',
      imageUrl:    map['image_url'] as String? ?? map['imageUrl'] as String? ?? '',
      isAsset:     map['isAsset'] as bool? ?? false,
      description: map['description'] as String? ?? '',
      rating:      (map['rating'] as num?)?.toDouble() ?? 0.0,
      tags:        List<String>.from(map['tags'] ?? []),
      highlights:  List<String>.from(map['highlights'] ?? []),
      bestTime:    map['best_time'] as String? ?? map['bestTime'] as String? ?? '',
      avgBudget:   map['avg_budget'] as String? ?? map['avgBudget'] as String? ?? '',
      latitude:    (map['latitude'] as num?)?.toDouble(),
      longitude:   (map['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id':          id,
    'name':        name,
    'country':     country,
    'city':        city,
    'category':    category,
    'image_url':   imageUrl,
    'isAsset':     isAsset,
    'description': description,
    'rating':      rating,
    'tags':        tags,
    'highlights':  highlights,
    'best_time':   bestTime,
    'avg_budget':  avgBudget,
    'latitude':    latitude,
    'longitude':   longitude,
  };
}
```

---

## 🔌 4. Updated Service — `lib/services/supabase_data_service.dart`

Replaces the old hardcoded `seedDestinations` list — now pulls everything from Supabase. Keeps a **2-item emergency fallback only** (not 10) in case of total offline failure, so the app never crashes.

```dart
// lib/services/supabase_data_service.dart
// V2: destinations now live in Supabase — app is lightweight, no hardcoded data.

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/destination_model.dart';
import 'supabase_service.dart';

class SupabaseDataService {
  static SupabaseClient get _db => SupabaseService.client;
  static String get _uid => SupabaseService.currentUserId!;

  // Tiny emergency fallback — only used if Supabase is fully unreachable.
  static final List<DestinationModel> _emergencyFallback = [
    const DestinationModel(
      id: 'islamabad', name: 'Islamabad', country: 'Pakistan', city: 'Islamabad',
      category: 'City',
      imageUrl: 'https://images.unsplash.com/photo-1626621341169-a0e77534ee59?w=800',
      description: 'Pakistan\'s green, planned capital at the foot of the Margalla Hills.',
      rating: 4.6, tags: ['Capital', 'Nature'],
    ),
    const DestinationModel(
      id: 'paris', name: 'Paris', country: 'France', city: 'Paris',
      category: 'City',
      imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800',
      description: 'The City of Light — Eiffel Tower, cuisine, and art.',
      rating: 4.9, tags: ['Romance', 'Art'],
    ),
  ];

  // ── Destinations ──────────────────────────────────────────────────────────
  Future<List<DestinationModel>> getDestinations() async {
    try {
      final data = await _db
          .from('destinations')
          .select()
          .order('rating', ascending: false)
          .timeout(const Duration(seconds: 10));
      if ((data as List).isEmpty) return _emergencyFallback;
      return data
          .map((d) => DestinationModel.fromMap(d as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _emergencyFallback;
    }
  }

  /// Filter by category tab (Home screen chips): 'All', 'City', 'Beach', 'Mountain', 'Historic', 'Nature'
  Future<List<DestinationModel>> getDestinationsByCategory(String category) async {
    if (category == 'All') return getDestinations();
    try {
      final data = await _db
          .from('destinations')
          .select()
          .eq('category', category)
          .order('rating', ascending: false);
      return (data as List)
          .map((d) => DestinationModel.fromMap(d as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Favorites (unchanged behavior) ────────────────────────────────────────
  Future<void> addFavorite(DestinationModel dest) async {
    await _db.from('favorites').upsert({
      'user_id':   _uid,
      'dest_id':   dest.id,
      'dest_data': dest.toMap(),
    });
  }

  Future<void> removeFavorite(String destId) async {
    await _db.from('favorites').delete().eq('user_id', _uid).eq('dest_id', destId);
  }

  Future<List<DestinationModel>> getUserFavorites() async {
    try {
      final data = await _db.from('favorites').select('dest_data').eq('user_id', _uid);
      return (data as List)
          .map((row) => DestinationModel.fromMap(Map<String, dynamic>.from(row['dest_data'])))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> isFavorited(String destId) async {
    try {
      final data = await _db.from('favorites').select('dest_id').eq('user_id', _uid).eq('dest_id', destId);
      return (data as List).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ── Profile (NEW — for Profile screen) ────────────────────────────────────
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final data = await _db.from('profiles').select().eq('id', _uid).maybeSingle();
      return data;
    } catch (_) {
      return null;
    }
  }

  Future<void> upsertProfile({required String fullName, String? bio, String? avatarUrl}) async {
    await _db.from('profiles').upsert({
      'id':         _uid,
      'full_name':  fullName,
      'bio':        bio ?? '',
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
```

---

## 🏠 5. Redesigned Home Screen — `lib/screens/home_screen.dart`

New in this version: category filter chips, Map button in AppBar, new color scheme.

```dart
// lib/screens/home_screen.dart — V2 Redesign ("Ocean Sunset" theme)
import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../services/supabase_service.dart';
import '../services/supabase_data_service.dart';
import '../theme/app_colors.dart';
import '../widgets/destination_card.dart';
import 'settings_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DestinationModel> _all      = [];
  List<DestinationModel> _filtered = [];
  bool   _loading  = true;
  String _query    = '';
  String _category = 'All';
  final _searchCtrl = TextEditingController();

  static const _categories = ['All', 'City', 'Beach', 'Mountain', 'Historic', 'Nature'];

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await SupabaseDataService().getDestinationsByCategory(_category);
    setState(() { _all = result; _applySearch(); _loading = false; });
  }

  void _applySearch() {
    final low = _query.toLowerCase();
    _filtered = _all.where((d) =>
      d.name.toLowerCase().contains(low) || d.country.toLowerCase().contains(low)).toList();
  }

  void _onSearch(String q) { setState(() { _query = q; _applySearch(); }); }

  void _onCategoryTap(String cat) {
    setState(() => _category = cat);
    _load();
  }

  Future<void> _logout() async {
    await SupabaseService.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get _userName {
    final user = SupabaseService.currentUser;
    final name = user?.userMetadata?['full_name'] as String?;
    if (name != null && name.isNotEmpty) return name.split(' ').first;
    final email = user?.email ?? '';
    return email.isNotEmpty ? email.split('@').first : 'Traveler';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white, elevation: 0,
        title: const Text('VistaVoyage ✈', style: TextStyle(
          fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(icon: const Icon(Icons.map_outlined), tooltip: 'Map',
            onPressed: () => Navigator.pushNamed(context, '/map', arguments: _all)),
          IconButton(icon: const Icon(Icons.settings_outlined), tooltip: 'Settings',
            onPressed: () => showSettingsMenu(context)),
          IconButton(icon: const Icon(Icons.favorite_border), tooltip: 'Favorites',
            onPressed: () => Navigator.pushNamed(context, '/favorites')),
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Logout', onPressed: _logout),
        ]),
      body: RefreshIndicator(color: AppColors.primary, onRefresh: _load,
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: Container(
            color: AppColors.primaryDark,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleAvatar(radius: 20, backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : 'V',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Nunito'))),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_greeting, style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Nunito')),
                  Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.w600, fontFamily: 'Nunito')),
                ]),
              ]),
              const SizedBox(height: 16),
              const Text('Explore Destinations!', style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Nunito', color: Colors.white)),
              const SizedBox(height: 16),
              Container(height: 48,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))]),
                child: TextField(controller: _searchCtrl, onChanged: _onSearch,
                  style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, color: AppColors.charcoal),
                  decoration: InputDecoration(
                    hintText: 'Search destinations or countries…',
                    hintStyle: const TextStyle(color: AppColors.gray, fontSize: 14, fontFamily: 'Nunito'),
                    prefixIcon: const Icon(Icons.search, color: AppColors.gray, size: 20),
                    suffixIcon: _query.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear, color: AppColors.gray, size: 18),
                          onPressed: () { _searchCtrl.clear(); _onSearch(''); })
                      : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)))),
            ]))),

          // ── Category chips (NEW) ────────────────────────────────────────
          SliverToBoxAdapter(child: SizedBox(height: 46,
            child: ListView.builder(scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (ctx, i) {
                final cat = _categories[i];
                final selected = cat == _category;
                return Padding(padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat, style: TextStyle(fontFamily: 'Nunito', fontSize: 13,
                      fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.charcoal)),
                    selected: selected,
                    onSelected: (_) => _onCategoryTap(cat),
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: selected ? AppColors.primary : AppColors.divider),
                  ));
              }))),

          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(_query.isEmpty ? 'Popular Destinations' : 'Results (${_filtered.length})',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, fontFamily: 'Nunito', color: AppColors.charcoal)),
              if (_query.isEmpty)
                Text('${_all.length} places', style: const TextStyle(
                  fontSize: 13, color: AppColors.primary, fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
            ]))),

          if (_loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
          else if (_filtered.isEmpty)
            SliverFillRemaining(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(_query.isEmpty ? 'No destinations found.\nPull to refresh.' : 'No results for "$_query"',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: AppColors.gray, fontFamily: 'Nunito')),
            ])))
          else
            SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(delegate: SliverChildBuilderDelegate(
                (ctx, i) => DestinationCard(destination: _filtered[i],
                  onTap: () => Navigator.pushNamed(context, '/detail', arguments: _filtered[i])),
                childCount: _filtered.length))),
        ])));
  }
}
```

---

## 📍 6. NEW — Map Screen — `lib/screens/map_screen.dart`

Uses `flutter_map` (OpenStreetMap tiles) — **no API key required**, unlike Google Maps.

### Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter_map: ^7.0.2
  latlong2: ^0.9.1
```

```dart
// lib/screens/map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/destination_model.dart';
import '../theme/app_colors.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final destinations = ModalRoute.of(context)!.settings.arguments as List<DestinationModel>;
    final withCoords = destinations.where((d) => d.latitude != null && d.longitude != null).toList();

    final center = withCoords.isNotEmpty
        ? LatLng(withCoords.first.latitude!, withCoords.first.longitude!)
        : const LatLng(30.3753, 69.3451); // Pakistan center fallback

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white, elevation: 0,
        title: const Text('Explore on Map', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
      ),
      body: FlutterMap(
        options: MapOptions(initialCenter: center, initialZoom: 3.2),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.vistavoyage.app',
          ),
          MarkerLayer(markers: withCoords.map((d) => Marker(
            point: LatLng(d.latitude!, d.longitude!),
            width: 44, height: 44,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/detail', arguments: d),
              child: Column(children: [
                Icon(Icons.location_on, color: AppColors.coral, size: 36),
              ]),
            ),
          )).toList()),
        ],
      ),
    );
  }
}
```

### Register route in `main.dart`:
```dart
import 'screens/map_screen.dart';
// ...
'/map': (_) => const MapScreen(),
```

---

## 👤 7. NEW — Profile Screen — `lib/screens/profile_screen.dart`

```dart
// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/supabase_data_service.dart';
import '../theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _bioCtrl  = TextEditingController();
  bool _loading = true;
  bool _saving  = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final profile = await SupabaseDataService().getProfile();
    final user = SupabaseService.currentUser;
    _nameCtrl.text = profile?['full_name'] as String? ??
        (user?.userMetadata?['full_name'] as String? ?? '');
    _bioCtrl.text = profile?['bio'] as String? ?? '';
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await SupabaseDataService().upsertProfile(fullName: _nameCtrl.text.trim(), bio: _bioCtrl.text.trim());
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Profile updated!', style: TextStyle(fontFamily: 'Nunito')),
        backgroundColor: AppColors.primary));
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = SupabaseService.currentUser?.email ?? '';
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white, elevation: 0,
        title: const Text('My Profile', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
            CircleAvatar(radius: 48, backgroundColor: AppColors.cardTint,
              child: Text(_nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : 'V',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary, fontFamily: 'Nunito'))),
            const SizedBox(height: 24),
            TextField(controller: _nameCtrl,
              decoration: InputDecoration(labelText: 'Full Name', filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 14),
            TextField(controller: TextEditingController(text: email), enabled: false,
              decoration: InputDecoration(labelText: 'Email', filled: true, fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 14),
            TextField(controller: _bioCtrl, maxLines: 3,
              decoration: InputDecoration(labelText: 'Bio', filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: _saving ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Save Changes', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)))),
          ])),
    );
  }
}
```

### Register route:
```dart
'/profile': (_) => const ProfileScreen(),
```

---

## ❓ 8. NEW — Support & FAQ Screen — `lib/screens/support_screen.dart`

```dart
// lib/screens/support_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const _faqs = [
    {'q': 'How do I save a destination to favorites?',
     'a': 'Tap the heart icon on any destination\'s detail screen. It will appear in your Favorites tab instantly.'},
    {'q': 'Can I use VistaVoyage offline?',
     'a': 'Browsing requires internet to fetch destinations from our database, but previously viewed favorites remain visible if cached.'},
    {'q': 'How does the AI Travel Assistant work?',
     'a': 'It uses an AI language model to generate custom itineraries, food tips, and travel advice based on your selected destination.'},
    {'q': 'How do I turn off notifications?',
     'a': 'Go to Settings → Notifications → toggle off "Enable Push Notifications".'},
    {'q': 'Is my data secure?',
     'a': 'Yes — all data is stored securely via Supabase with row-level security, meaning only you can access your favorites and profile.'},
    {'q': 'How do I delete my account?',
     'a': 'Please contact support below and we\'ll process your account deletion request within 48 hours.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white, elevation: 0,
        title: const Text('Support & FAQs', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Frequently Asked Questions', style: TextStyle(
          fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.charcoal)),
        const SizedBox(height: 12),
        ..._faqs.map((f) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
          child: ExpansionTile(
            title: Text(f['q']!, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.charcoal)),
            iconColor: AppColors.primary, collapsedIconColor: AppColors.gray,
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [Align(alignment: Alignment.centerLeft,
              child: Text(f['a']!, style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.gray, height: 1.5)))],
          ))),
        const SizedBox(height: 20),
        const Text('Still need help?', style: TextStyle(
          fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.charcoal)),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.cardTint, borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Contact our support team and we\'ll get back to you within 24 hours.',
              style: TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.charcoal)),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              icon: const Icon(Icons.email_outlined, size: 18),
              label: const Text('Email Support', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
              onPressed: () {
                // TODO: hook up url_launcher -> mailto:support@vistavoyage.app
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
          ])),
      ]),
    );
  }
}
```

### Register route:
```dart
'/support': (_) => const SupportScreen(),
```

### Wire into Settings Menu (`settings_menu.dart`) — add this item:
```dart
_menuItem(context, icon: Icons.help_outline, label: 'Help & Support',
  onTap: () {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/support');
  }),
```
Also add to Settings Screen's "About" section:
```dart
_buildTile(icon: Icons.help_outline, title: 'Support & FAQs',
  onTap: () => Navigator.pushNamed(context, '/support')),
```

---

## 🎨 9. Detail & AI Screen — Recolor Instructions

Rather than rewrite these two large files from scratch, do a **find-and-replace** across `detail_screen.dart` and `ai_screen.dart`:

| Find | Replace With |
|---|---|
| `Color(0xFF3B82F6)` | `AppColors.primary` |
| `Color(0xFF2563EB)` | `AppColors.primaryDark` |
| `Color(0xFFF5A623)` | `AppColors.gold` |
| `Color(0xFF9E9E9E)` | `AppColors.gray` |
| `Color(0xFF2D2D2D)` | `AppColors.charcoal` |
| `Color(0xFFDBEAFE)` | `AppColors.cardTint` |
| `Color(0xFFF9FAFB)` | `AppColors.surface` |

Add this import at the top of both files:
```dart
import '../theme/app_colors.dart';
```

**Bonus for Detail screen:** add a "View on Map" button under highlights (only if lat/lng exist):
```dart
if (dest.latitude != null && dest.longitude != null) ...[
  const SizedBox(height: 12),
  SizedBox(width: double.infinity, height: 48, child: OutlinedButton.icon(
    icon: const Icon(Icons.map_outlined, size: 18),
    label: const Text('View on Map', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
    onPressed: () => Navigator.pushNamed(context, '/map', arguments: [dest]),
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: AppColors.primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
],
```

---

## 🧩 10. Route Registration Summary — `lib/main.dart`

```dart
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/support_screen.dart';

routes: {
  '/splash':        (_) => const SplashScreen(),
  '/login':         (_) => const LoginScreen(),
  '/signup':        (_) => const SignupScreen(),
  '/home':          (_) => const HomeScreen(),
  '/detail':        (_) => const DetailScreen(),
  '/favorites':     (_) => const FavoritesScreen(),
  '/ai':            (_) => const AiScreen(),
  '/settings':      (_) => const SettingsScreen(),
  '/notifications': (_) => const NotificationsScreen(),
  '/map':           (_) => const MapScreen(),        // NEW
  '/profile':       (_) => const ProfileScreen(),     // NEW
  '/support':       (_) => const SupportScreen(),     // NEW
},
```

Also add the Profile item to the Settings Menu (`settings_menu.dart`):
```dart
_menuItem(context, icon: Icons.person_outline, label: 'Profile / Account',
  onTap: () {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/profile');   // was previously a TODO
  }),
```

---

## 📦 11. Full `pubspec.yaml` Additions

```yaml
dependencies:
  flutter_map: ^7.0.2
  latlong2: ^0.9.1
  flutter_local_notifications: ^17.0.0
  permission_handler: ^11.3.0
```

Then:
```bash
flutter pub get
```

---

## ✅ 12. Antigravity Integration Prompt

Copy-paste this prompt directly into Antigravity along with this whole `.md` file:

```
I'm upgrading my VistaVoyage Flutter + Supabase app. Please integrate everything
described in the attached VISTAVOYAGE_V2_UPGRADE.md file into my existing project:

1. Run the SQL in Section 2 against my Supabase project (destinations + profiles
   tables, RLS policies, and the 20-destination seed data).
2. Create lib/theme/app_colors.dart exactly as shown in Section 1.
3. Replace lib/models/destination_model.dart with the version in Section 3.
4. Replace lib/services/supabase_data_service.dart with the version in Section 4
   (remove the old 10-item hardcoded seedDestinations list entirely).
5. Replace lib/screens/home_screen.dart with the redesigned version in Section 5.
6. Create lib/screens/map_screen.dart as shown in Section 6, and add
   flutter_map + latlong2 to pubspec.yaml.
7. Create lib/screens/profile_screen.dart as shown in Section 7.
8. Create lib/screens/support_screen.dart as shown in Section 8, and wire it
   into the settings menu and settings screen as instructed.
9. Apply the color find-and-replace from Section 9 to detail_screen.dart and
   ai_screen.dart, and add the "View on Map" button to the detail screen.
10. Register all new routes in main.dart as shown in Section 10.
11. Run flutter pub get, then flutter analyze and fix any resulting errors
    before telling me it's done.

Preserve all existing functionality (auth, favorites, notifications, AI chat) —
this is a visual + architecture upgrade, not a feature removal.
```

---

## 📋 Quick Checklist

- [ ] Run Supabase SQL migration (destinations + profiles tables)
- [ ] Run seed data insert (20 destinations)
- [ ] Create `app_colors.dart`
- [ ] Update `destination_model.dart`
- [ ] Update `supabase_data_service.dart` (remove hardcoded list)
- [ ] Replace `home_screen.dart` with redesigned version
- [ ] Create `map_screen.dart` + add `flutter_map`/`latlong2` to pubspec
- [ ] Create `profile_screen.dart`
- [ ] Create `support_screen.dart` + wire into settings
- [ ] Recolor `detail_screen.dart` and `ai_screen.dart`
- [ ] Add "View on Map" button to detail screen
- [ ] Register all new routes in `main.dart`
- [ ] `flutter pub get` → `flutter analyze` → fix errors → test on device

---

*Generated for VistaVoyage V2 — Flutter + Supabase, "Ocean Sunset" redesign.*
