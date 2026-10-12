<img width="1179" height="2556" alt="Carts_Screen" src="https://github.com/user-attachments/assets/7322a2d9-7b2d-4752-8aeb-069e3c171826" /># 🛍️ ShopingApp — Native iOS E-Commerce Application

**A modern shopping experience built with Swift and UIKit.**

ShopingApp is a native iOS e-commerce application designed to provide a smooth and convenient online shopping experience. It brings together product discovery, category browsing, search, product details, wishlist management, shopping cart, user authentication, order tracking, and payment integration in one application.

Built as an iOS development portfolio project, ShopingApp demonstrates practical experience with native iOS development, API integration, reusable UI components, local data persistence, and application navigation.

<p align="center">
  <strong>Swift · UIKit · REST APIs · SQLite · Razorpay</strong>
</p>

------------------------------------------------------------------------------------------------------------------------

## ✨ Features

### 🛒 Product Discovery & Shopping

- Browse products in a clean, organized interface.
- Explore products through categories.
- Search products by name and relevant details.
- View product images, prices, and descriptions.
- Open detailed product screens before purchasing.
- Enjoy a collection-based layout for product browsing.

### ❤️ Wishlist & Cart Management

- Add and remove products from your wishlist.
- View cart items in a dedicated cart screen.
- Manage product quantities.
- Calculate item totals and purchase amounts.
- Store cart information locally using SQLite.

### 🔐 Authentication & User Profile

- Login interface with email and password fields.
- Remember-me functionality using local preferences.
- Supabase authentication and profile integration.
- Profile information and profile image management.

### 💳 Checkout & Payments

- Razorpay checkout integration.
- Payment amount conversion from rupees to paise.
- Payment success and failure callbacks.
- Payment-related product and order information handling.
- SQLite-based order storage for order history.

> **Note:** Payment success callbacks should be verified on a secure backend before treating an order as a confirmed, paid transaction in production.

### 📦 Order Management

- Store order details locally.
- Maintain product information associated with orders.
- Display order history in a dedicated screen.
- Keep order data available between app sessions.

### 🎨 User Interface

- Custom onboarding screens.
- Horizontal onboarding carousel with page control.
- Reusable collection view and table view cells.
- UIKit Storyboards and view controllers.
- Product image loading and caching with Kingfisher.
- Navigation between shopping, cart, profile, and order screens.

------------------------------------------------------------------------------------------------------------------------
## 🧰 Tech Stack

| Technology | Purpose |
|---|---|
| **Swift 5** | Primary programming language |
| **UIKit** | Native iOS user interface |
| **UICollectionView** | Product grids and category layouts |
| **UITableView** | List-based screens |
| **Compositional Layout** | Flexible collection view layouts |
| **Alamofire** | HTTP networking and API requests |
| **Kingfisher** | Remote image loading and caching |
| **SQLite** | Local cart and order data persistence |
| **Supabase** | Authentication, profile data, and storage integration |
| **Razorpay** | Payment checkout integration |
| **UserDefaults** | Lightweight local preference storage |
| **Xcode** | Development, debugging, and building |

------------------------------------------------------------------------------------------------------------------------

## 🔄 How the App Works

1. **Onboarding:** Introduces users to the shopping experience.
2. **Authentication:** Provides the login and account access flow.
3. **Home:** Loads and displays products from an API.
4. **Product Details:** Shows information about a selected product.
5. **Wishlist & Cart:** Supports product selection and cart management.
6. **Checkout:** Starts the Razorpay payment flow.
7. **Orders:** Stores and displays purchase-related information.
8. **Profile:** Provides access to user profile information.

------------------------------------------------------------------------------------------------------------------------

## 🚀 Getting Started

### Prerequisites

- macOS
- Xcode
- An Apple development environment
- CocoaPods, if required by your project configuration
- API credentials for the services you have configured

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/Vijaygawai007/ShopingApp.git
```

**2. Navigate to the project directory**

```bash
cd ShopingApp
```

**3. Install dependencies**

If the repository includes a `Podfile`, run:

```bash
pod install
```

If CocoaPods dependencies are configured, open the `.xcworkspace` file rather than the `.xcodeproj` file.

**4. Configure API credentials**

Set up the required API endpoint, authentication credentials, and payment configuration in your local development environment.

**5. Open the project**

Open the workspace or Xcode project, select an available iOS simulator, and build and run the application.

------------------------------------------------------------------------------------------------------------------------

## 🔑 Configuration & Security

Before running the application, configure the services required by your implementation.

- **Product API:** Set the appropriate base URL and endpoints in your networking layer.
- **Supabase:** Configure the project URL and public client key if Supabase features are enabled.
- **Razorpay:** Use a test Key ID for development and testing.
- **Secrets:** Never commit API secrets, private keys, payment secrets, or production credentials to GitHub.
- **Payments:** Verify Razorpay payment signatures on your backend before confirming paid orders.
- **Database:** Ensure the local SQLite schema and database initialization match the current project implementation.

------------------------------------------------------------------------------------------------------------------------

## 📸 Screenshots

| Screen | What to showcase |
|---|---|
| Onboarding | Welcome screens and page indicators |
| Home | Product grid and categories |
| Product Details | Product information and purchase controls |
| Wishlist | Liked products |
| Shopping Cart | Selected products and quantity controls |
| Checkout | Razorpay test checkout |
| My Orders | Order history |
| Profile | Account details and profile image |

Example Markdown for displaying your screenshots:

![OnBoarding_1](https://github.com/Vijaygawai007/ShopingApp/blob/a9312861bcb49347856a9a78a061a60ba1511321/screen_shots/Onboarding-1.png)
![OnBoarding_2](https://github.com/Vijaygawai007/ShopingApp/blob/a9312861bcb49347856a9a78a061a60ba1511321/screen_shots/Onboarding_2.png)
![OnBoarding_3](https://github.com/Vijaygawai007/ShopingApp/blob/a9312861bcb49347856a9a78a061a60ba1511321/screen_shots/Onbarding_3.png)
![Login_Screen](https://github.com/Vijaygawai007/ShopingApp/blob/a9312861bcb49347856a9a78a061a60ba1511321/screen_shots/Login_screen.png)
![Sign_Up](https://github.com/Vijaygawai007/ShopingApp/blob/a9312861bcb49347856a9a78a061a60ba1511321/screen_shots/Signup_screen.png)
![Pass_Reset](https://github.com/Vijaygawai007/ShopingApp/blob/a9312861bcb49347856a9a78a061a60ba1511321/screen_shots/Passward_screen.png)
![ShopingApp Home]([Screenshots/home.png](https://github.com/Vijaygawai007/ShopingApp/blob/a9312861bcb49347856a9a78a061a60ba1511321/screen_shots/Home_Screen.png))
![Product Details](Screenshots/product-details.png)
![Shopping Cart](https://github.com/Vijaygawai007/ShopingApp/blob/a9312861bcb49347856a9a78a061a60ba1511321/screen_shots/Carts_Screen.png)
![My Orders](https://github.com/Vijaygawai007/ShopingApp/blob/a9312861bcb49347856a9a78a061a60ba1511321/screen_shots/Ordered_Screen.png)
![User_Profile](https://github.com/Vijaygawai007/ShopingApp/blob/a9312861bcb49347856a9a78a061a60ba1511321/screen_shots/Profile_Screen.png)
![Product_Payment](https://github.com/Vijaygawai007/ShopingApp/blob/a9312861bcb49347856a9a78a061a60ba1511321/screen_shots/payment_Screen.png)

------------------------------------------------------------------------------------------------------------------------

## 🧠 Key Learning Outcomes

This project demonstrates practical learning and implementation in:

- Native iOS application development using Swift.
- UIKit view controllers, Storyboards, and reusable cells.
- UICollectionView and compositional layouts.
- REST API integration and JSON data handling.
- Networking and remote image caching.
- Separation of UI, model, and networking responsibilities.
- Local persistence using SQLite and UserDefaults.
- Authentication and profile integration.
- Payment checkout flows and callback handling.
- Debugging, dependency management, and application navigation.

------------------------------------------------------------------------------------------------------------------------

## 👨‍💻 Developer

**Vijay V. Gawai**  
iOS Developer | Swift | UIKit | SwiftUI

I enjoy building native iOS applications with a focus on clean interfaces, maintainable code, and practical functionality. ShopingApp represents my hands-on work with e-commerce application development and the iOS technologies used to build real-world mobile experiences.

- **GitHub:** [Vijaygawai007](https://github.com/Vijaygawai007)
- **Project Repository:** [ShopingApp](https://github.com/Vijaygawai007/ShopingApp)
- **LinkedIn:** [Vijay Gawai](https://www.linkedin.com/in/vijay-gawai-75658b203/)

------------------------------------------------------------------------------------------------------------------------

## ⭐ Support

If you find this project useful or interesting, consider giving the repository a ⭐ on GitHub.

**Built with Swift and UIKit.**
