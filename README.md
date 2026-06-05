# ShopVista — Product Management App

A production-quality Flutter application demonstrating scalable architecture, API integration, state management, offline support, and a polished Material 3 user experience.

## 📱 Features

- **Product Listing** — Browse products in a responsive grid with images, ratings, prices (₹), and categories
- **Product Search** — Real-time search with 500ms debounce using the DummyJSON search API
- **Product Details** — Full product view with image carousel, description, stock, rating, brand, reviews
- **Add Product** — Create new products with validated form fields
- **Edit Product** — Update existing products with pre-filled form data
- **Delete Product** — Remove products with confirmation dialog and immediate UI update
- **Dark/Light/System Theme** — Three theme modes with persistent user preference and system auto-detection
- **Offline Support** — Cached product data displayed when offline with a connectivity banner
- **Recently Viewed** — Track and display recently viewed products

## 🏗️ Architecture

The app follows **Clean Architecture** with **MVVM** pattern:

```
lib/
├── core/           → Constants, networking, error handling, theming
├── features/       → Feature modules (products, settings)
│   └── products/
│       ├── data/           → Models, datasources, repository impl
│       ├── domain/         → Abstract repository, use cases
│       └── presentation/  → Providers (ViewModels), screens (Views)
├── router/         → GoRouter navigation configuration
├── services/       → Cache, connectivity, local storage
└── shared/         → Reusable widgets
```

## 🔧 State Management — Why Riverpod?

**Chosen solution**: `flutter_riverpod`

### Why Riverpod was selected:

1. **Compile-time safety** — Riverpod providers are resolved at compile time, eliminating the `ProviderNotFoundException` runtime errors common with Provider.
2. **No BuildContext dependency** — Providers can be accessed anywhere without a widget tree context, making business logic fully independent of the UI layer.
3. **Built-in dependency injection** — Riverpod's `ref.watch` and `ref.read` naturally provide DI, making dependencies explicit and easily mockable for testing.
4. **Granular rebuilds** — `ConsumerWidget` and `ref.watch` ensure only affected widgets rebuild when state changes, optimising performance.
5. **Testability** — `ProviderContainer` with overrides makes unit testing state logic straightforward without any widget testing infrastructure.
6. **Auto-disposal** — `StateNotifierProvider` and `FutureProvider` handle lifecycle management automatically, preventing memory leaks.

### Benefits of this approach:

- Clean separation between UI and business logic via `StateNotifier` providers
- Easily testable — repository, use cases, and state notifiers can all be unit-tested independently
- Scales well for larger applications with complex dependency graphs
- `AsyncValue` pattern provides built-in loading/error/data states

## 📦 Tech Stack

| Category | Package | Purpose |
|---|---|---|
| State Management | `flutter_riverpod` | Reactive state management with DI |
| Networking | `dio` | HTTP client with interceptors |
| Routing | `go_router` | Declarative routing with named routes |
| Local Storage | `shared_preferences` | Persist theme preference + cache |
| Connectivity | `connectivity_plus` | Online/offline detection |
| Image Caching | `cached_network_image` | Network image caching with placeholders |
| JSON Serialization | `json_serializable` + `json_annotation` | Automated model serialization |
| Code Generation | `build_runner` | Generate `.g.dart` files |
| Carousel | `carousel_slider` | Product image carousel |
| Typography | `google_fonts` | Outfit + Inter typefaces |
| Testing | `mocktail` | Mock generation for unit/widget tests |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable channel)
- Dart 3+

### Setup

```bash
# Clone the repository
git clone <repo-url>
cd product_management_app

# Install dependencies
flutter pub get

# Generate JSON serialization code
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Run Tests

```bash
flutter test
```

### Analyze Code

```bash
flutter analyze
```

## 🧪 Testing

| Test Type | File | What it Tests |
|---|---|---|
| **Unit** | `product_repository_impl_test.dart` | Repository fetches from remote and caches locally |
| **Unit** | `product_list_notifier_test.dart` | State notifier updates state correctly on fetch |
| **Widget** | `home_screen_test.dart` | Product list renders `ProductCard` widgets |
| **Widget** | `add_product_screen_test.dart` | Form validation (required fields + numeric price) |

## 🌐 API

Uses [DummyJSON](https://dummyjson.com) API:

- `GET /products` — List products
- `GET /products/{id}` — Single product
- `GET /products/search?q={query}` — Search
- `POST /products/add` — Add product
- `PUT /products/{id}` — Update product
- `DELETE /products/{id}` — Delete product
