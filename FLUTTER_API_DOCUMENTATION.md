# Shamra Electronics Backend API Documentation
## For Flutter Development

**Backend Project:** Shamra Electronics Backend System  
**Framework:** NestJS (Node.js/TypeScript)  
**Database:** MongoDB  
**API Version:** v1  
**Date:** November 29, 2025

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Base Configuration](#base-configuration)
3. [Authentication](#authentication)
4. [API Endpoints](#api-endpoints)
5. [Data Models](#data-models)
6. [Error Handling](#error-handling)
7. [File Uploads](#file-uploads)
8. [Common Patterns](#common-patterns)

---

## 🌐 Overview

This is an electronics e-commerce system with multi-branch support, inventory management, and role-based access control.

### Key Features
- Multi-branch product pricing and inventory
- User authentication with JWT
- OTP-based verification
- Role-based access control (Admin, Manager, Employee, Customer, Merchant)
- Product catalog with categories and subcategories
- Order management
- Notifications system (Firebase)
- Points/Rewards system
- Merchant application system

---

## ⚙️ Base Configuration

### Base URL
```
Production: http://62.171.153.198:3398
Development: http://localhost:3000
```

### API Prefix
All endpoints are prefixed with: `/api/v1`

**Example:** `http://62.171.153.198:3398/api/v1/auth/login`

### Static Files (Images)
Images are served from: `/uploads/`

**Example:** `http://62.171.153.198:3398/uploads/products/image.jpg`

### CORS
CORS is enabled for specified origins.

---

## 🔐 Authentication

### Authentication Flow

#### 1. Register Flow
```
POST /api/v1/auth/send-otp
→ Receive OTP via SMS
POST /api/v1/auth/register/verify-otp
→ Get registration token
POST /api/v1/auth/register (with registrationToken)
→ Get access_token & refresh_token
```

#### 2. Login Flow
```
POST /api/v1/auth/login
→ Get access_token & refresh_token (+ user info)
(If user has branches)
POST /api/v1/auth/select-branch
→ Get updated token with branch context
```

#### 3. Password Reset Flow
```
POST /api/v1/auth/forgot-password
→ Receive OTP
POST /api/v1/auth/reset-password/verify-otp
→ Verify OTP
POST /api/v1/auth/reset-password
→ Password reset complete
```

### Headers

#### For Public Endpoints
```
Content-Type: application/json
```

#### For Protected Endpoints
```
Content-Type: application/json
Authorization: Bearer {access_token}
```

#### For File Upload Endpoints
```
Content-Type: multipart/form-data
Authorization: Bearer {access_token}
```

---

## 📡 API Endpoints

### 🔑 Authentication Endpoints

#### **POST** `/auth/login`
Login with phone number and password.

**Request Body:**
```json
{
  "phoneNumber": "0912345678",
  "password": "password123",
  "fcmToken": "firebase_token_here" // optional
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم تسجيل الدخول بنجاح",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "_id": "507f1f77bcf86cd799439011",
      "firstName": "John",
      "lastName": "Doe",
      "email": "john@example.com",
      "phoneNumber": "0912345678",
      "role": "customer",
      "isActive": true,
      "points": 150,
      "totalPointsEarned": 500,
      "totalPointsUsed": 350,
      "branchId": "507f1f77bcf86cd799439012"
    }
  }
}
```

#### **POST** `/auth/register`
Register a new user.

**Request Body:**
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com", // optional
  "phoneNumber": "0912345678",
  "password": "password123",
  "fcmToken": "firebase_token_here", // optional
  "branchId": "507f1f77bcf86cd799439012", // optional
  "registrationToken": "token_from_verify_otp" // required
}
```

**Response:** Same as login

#### **POST** `/auth/send-otp`
Send OTP to phone number.

**Request Body:**
```json
{
  "phoneNumber": "0912345678"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم إرسال الرمز بنجاح",
  "data": {
    "message": "OTP sent successfully",
    "expiresIn": 300
  }
}
```

#### **POST** `/auth/register/verify-otp`
Verify OTP for registration (returns registration token).

**Request Body:**
```json
{
  "phoneNumber": "0912345678",
  "otp": "1234"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم التحقق من الرمز بنجاح",
  "data": {
    "registrationToken": "temp_token_for_registration"
  }
}
```

#### **POST** `/auth/verify-otp`
Verify OTP after registration (account activation).

**Request Body:**
```json
{
  "phoneNumber": "0912345678",
  "otp": "1234"
}
```

#### **POST** `/auth/forgot-password`
Request password reset OTP.

**Request Body:**
```json
{
  "phoneNumber": "0912345678"
}
```

#### **POST** `/auth/reset-password/verify-otp`
Verify OTP for password reset.

**Request Body:**
```json
{
  "phoneNumber": "0912345678",
  "otp": "1234"
}
```

#### **POST** `/auth/reset-password`
Reset password with OTP.

**Request Body:**
```json
{
  "phoneNumber": "0912345678",
  "otp": "1234",
  "newPassword": "newpassword123"
}
```

#### **POST** `/auth/select-branch`
🔒 Select a branch for the current user session.

**Request Body:**
```json
{
  "branchId": "507f1f77bcf86cd799439012"
}
```

**Response:**
```json
{
  "access_token": "new_token_with_branch_context",
  "refresh_token": "new_refresh_token"
}
```

#### **GET** `/auth/profile`
🔒 Get current user profile.

**Response:**
```json
{
  "success": true,
  "message": "تم جلب الملف الشخصي بنجاح",
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com",
    "phoneNumber": "0912345678",
    "role": "customer",
    "isActive": true,
    "points": 150,
    "selectedBranchObject": {
      "_id": "507f1f77bcf86cd799439012",
      "name": "Main Branch",
      "address": { /* ... */ }
    }
  }
}
```

#### **POST** `/auth/refresh`
Refresh access token.

**Request Body:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم تحديث الرمز المميز بنجاح",
  "data": {
    "access_token": "new_access_token",
    "refresh_token": "new_refresh_token"
  }
}
```

#### **POST** `/auth/logout`
🔒 Logout (client-side token removal).

---

### 👤 User Endpoints

#### **GET** `/users/profile/me`
🔒 Get current user profile (detailed).

**Response:**
```json
{
  "success": true,
  "message": "تم جلب الملف الشخصي بنجاح",
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com",
    "phoneNumber": "0912345678",
    "role": "customer",
    "isActive": true,
    "points": 150,
    "totalPointsEarned": 500,
    "totalPointsUsed": 350,
    "branchId": "507f1f77bcf86cd799439012",
    "selectedBranchId": "507f1f77bcf86cd799439012",
    "selectedBranchObject": { /* ... */ },
    "createdAt": "2025-01-15T10:30:00.000Z",
    "updatedAt": "2025-01-20T15:45:00.000Z"
  }
}
```

#### **PATCH** `/users/profile`
🔒 Update current user profile.

**Request Body:**
```json
{
  "firstName": "Jane",
  "lastName": "Smith",
  "email": "jane@example.com"
}
```

#### **PATCH** `/users/change-password`
🔒 Change password.

**Request Body:**
```json
{
  "currentPassword": "oldpassword123",
  "newPassword": "newpassword123"
}
```

#### **GET** `/users`
🔒 Get all users (Admin/Manager only).

**Query Parameters:**
- `page` (number): Page number
- `limit` (number): Items per page
- `search` (string): Search by name/email/phone
- `role` (string): Filter by role
- `isActive` (boolean): Filter by active status

---

### 🏢 Branch Endpoints

#### **GET** `/branches`
🔒 Get all branches (Admin/Manager only).

**Query Parameters:**
- `page` (number)
- `limit` (number)
- `search` (string)
- `isActive` (boolean)

#### **GET** `/branches/active`
Get active branches (public).

**Response:**
```json
{
  "success": true,
  "message": "تم جلب الفروع النشطة بنجاح",
  "data": [
    {
      "_id": "507f1f77bcf86cd799439012",
      "name": "Main Branch",
      "description": "Our main branch",
      "phone": "0112345678",
      "email": "main@shamra.com",
      "address": {
        "street": "Street Name",
        "city": "Damascus",
        "country": "Syria",
        "coordinates": {
          "lat": 33.5138,
          "lng": 36.2765
        }
      },
      "isActive": true,
      "isMainBranch": true,
      "operatingHours": {
        "monday": { "open": "09:00", "close": "18:00" },
        "tuesday": { "open": "09:00", "close": "18:00" }
      }
    }
  ]
}
```

#### **GET** `/branches/main`
🔒 Get main branch.

#### **GET** `/branches/:id`
🔒 Get branch by ID.

---

### 📦 Product Endpoints

#### **GET** `/products`
Get all products.

**Query Parameters:**
- `page` (number): Default 1
- `limit` (number): Default 20
- `search` (string): Search by name/brand/tags
- `categoryId` (string): Filter by category
- `subCategoryId` (string): Filter by subcategory
- `branchId` (string): Filter by branch
- `brand` (string): Filter by brand
- `minPrice` (number): Minimum price
- `maxPrice` (number): Maximum price
- `isActive` (boolean): Filter active products
- `isFeatured` (boolean): Filter featured products
- `sortBy` (string): Sort field (price, name, createdAt, totalSales)
- `sortOrder` (string): asc or desc

**Response:**
```json
{
  "success": true,
  "message": "تم جلب المنتجات بنجاح",
  "data": [
    {
      "_id": "507f1f77bcf86cd799439013",
      "name": "Samsung TV 55 Inch",
      "description": "4K Smart TV",
      "barcode": "1234567890123",
      "mainImage": "/uploads/products/samsung-tv.jpg",
      "images": [
        "/uploads/products/samsung-tv-1.jpg",
        "/uploads/products/samsung-tv-2.jpg"
      ],
      "brand": "Samsung",
      "categoryId": "507f1f77bcf86cd799439014",
      "subCategoryId": "507f1f77bcf86cd799439015",
      "category": {
        "_id": "507f1f77bcf86cd799439014",
        "name": "Electronics"
      },
      "subCategory": {
        "_id": "507f1f77bcf86cd799439015",
        "name": "Televisions"
      },
      "branchPricing": [
        {
          "branchId": "507f1f77bcf86cd799439012",
          "price": 15000000,
          "costPrice": 12000000,
          "wholeSalePrice": 14000000,
          "salePrice": 13500000,
          "currency": "SYP",
          "stockQuantity": 50,
          "sku": "SAM-TV-55-001",
          "isOnSale": true,
          "isActive": true
        }
      ],
      "specifications": {
        "screen_size": "55 inches",
        "resolution": "4K UHD",
        "smart_tv": "Yes"
      },
      "status": "active",
      "isActive": true,
      "isFeatured": true,
      "tags": ["tv", "smart", "4k"],
      "keywords": ["television", "samsung", "smart tv"],
      "totalSales": 120,
      "viewCount": 450,
      "rating": 4.5,
      "reviewCount": 23,
      "sortOrder": 0,
      "createdAt": "2025-01-10T08:00:00.000Z",
      "updatedAt": "2025-01-20T10:30:00.000Z"
    }
  ],
  "pagination": {
    "total": 150,
    "page": 1,
    "limit": 20,
    "totalPages": 8
  }
}
```

#### **GET** `/products/featured`
Get featured products.

**Query Parameters:**
- `limit` (number): Default 10

#### **GET** `/products/on-sale`
Get products on sale.

**Query Parameters:**
- `limit` (number): Default 20
- `branchId` (string): Optional

#### **GET** `/products/low-stock`
🔒 Get low stock products (Admin/Manager/Employee).

**Query Parameters:**
- `limit` (number): Default 50

#### **GET** `/products/stats`
🔒 Get product statistics (Admin/Manager).

**Response:**
```json
{
  "success": true,
  "message": "تم جلب إحصائيات المنتجات بنجاح",
  "data": {
    "totalProducts": 500,
    "activeProducts": 450,
    "inactiveProducts": 50,
    "featuredProducts": 20,
    "lowStockProducts": 15,
    "outOfStockProducts": 5
  }
}
```

#### **GET** `/products/:id`
Get product by ID.

**Query Parameters:**
- `branchId` (string): Optional, for branch-specific pricing

#### **POST** `/products/with-images`
🔒 Create product with images (Admin/Manager/Employee).

**Content-Type:** `multipart/form-data`

**Form Fields:**
- `name` (string, required)
- `description` (string)
- `barcode` (string)
- `categoryId` (string, required)
- `subCategoryId` (string, required)
- `brand` (string)
- `branchPricing` (JSON string, required): Array of branch pricing objects
- `branches` (JSON string): Array of branch IDs
- `specifications` (JSON string): Object with specifications
- `status` (string): active/inactive/out_of_stock/discontinued
- `isActive` (boolean)
- `isFeatured` (boolean)
- `tags` (JSON string): Array of tags
- `keywords` (JSON string): Array of keywords
- `sortOrder` (number)
- `mainImage` (file): Main product image
- `images` (files): Additional images (max 7)

**Example branchPricing:**
```json
[
  {
    "branchId": "507f1f77bcf86cd799439012",
    "price": 15000000,
    "costPrice": 12000000,
    "wholeSalePrice": 14000000,
    "salePrice": 13500000,
    "currency": "SYP",
    "stockQuantity": 50,
    "sku": "SAM-TV-55-001",
    "isOnSale": true,
    "isActive": true
  }
]
```

#### **PATCH** `/products/:id/with-images`
🔒 Update product with images (Admin/Manager/Employee).

Same fields as create, all optional.

#### **PATCH** `/products/:id/toggle-active`
🔒 Toggle product active status (Admin/Manager).

#### **PATCH** `/products/:id/toggle-featured`
🔒 Toggle product featured status (Admin/Manager).

#### **DELETE** `/products/:id`
🔒 Delete product (Admin only).

---

### 📑 Category Endpoints

#### **GET** `/categories`
Get all categories.

**Query Parameters:**
- `page` (number)
- `limit` (number)
- `search` (string)
- `isActive` (boolean)
- `isFeatured` (boolean)

**Response:**
```json
{
  "success": true,
  "message": "تم جلب التصنيفات بنجاح",
  "data": [
    {
      "_id": "507f1f77bcf86cd799439014",
      "name": "Electronics",
      "image": "/uploads/categories/electronics.jpg",
      "sortOrder": 0,
      "isActive": true,
      "isFeatured": true,
      "productCount": 150
    }
  ],
  "pagination": {
    "total": 20,
    "page": 1,
    "limit": 20,
    "totalPages": 1
  }
}
```

#### **GET** `/categories/stats`
🔒 Get category statistics (Admin/Manager).

#### **GET** `/categories/:id`
Get category by ID.

#### **POST** `/categories`
🔒 Create category with image (Admin/Manager).

**Content-Type:** `multipart/form-data`

**Form Fields:**
- `name` (string, required)
- `sortOrder` (number)
- `isActive` (boolean)
- `isFeatured` (boolean)
- `image` (file): Category image

#### **PATCH** `/categories/:id`
🔒 Update category (Admin/Manager).

#### **PATCH** `/categories/:id/toggle-active`
🔒 Toggle category active status (Admin/Manager).

#### **DELETE** `/categories/:id`
🔒 Delete category (Admin only).

---

### 📂 Sub-Category Endpoints

#### **GET** `/sub-categories`
Get all sub-categories.

**Query Parameters:**
- `page` (number)
- `limit` (number)
- `search` (string)
- `categoryId` (string): Filter by parent category
- `isActive` (boolean)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439015",
      "name": "Televisions",
      "categoryId": "507f1f77bcf86cd799439014",
      "image": "/uploads/sub-categories/televisions.jpg",
      "sortOrder": 0,
      "isActive": true
    }
  ]
}
```

#### **GET** `/sub-categories/category/:categoryId`
Get sub-categories by category ID.

#### **GET** `/sub-categories/:id`
Get sub-category by ID.

#### **POST** `/sub-categories`
🔒 Create sub-category with image (Admin/Manager).

#### **PATCH** `/sub-categories/:id`
🔒 Update sub-category (Admin/Manager).

#### **DELETE** `/sub-categories/:id`
🔒 Delete sub-category (Admin/Manager).

---

### 🛒 Order Endpoints

#### **POST** `/orders`
🔒 Create order (Customer/Merchant).

**Request Body:**
```json
{
  "branchId": "507f1f77bcf86cd799439012",
  "items": [
    {
      "productId": "507f1f77bcf86cd799439013",
      "productName": "Samsung TV 55 Inch",
      "categoryId": "507f1f77bcf86cd799439014",
      "quantity": 2,
      "price": 15000000,
      "total": 30000000
    }
  ],
  "subtotal": 30000000,
  "taxAmount": 0,
  "discountAmount": 1000000,
  "totalAmount": 29000000,
  "currency": "SYP",
  "notes": "Please deliver before 5 PM",
  "location": {
    "lat": 33.5138,
    "lng": 36.2765
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم إنشاء الطلب بنجاح",
  "data": {
    "_id": "507f1f77bcf86cd799439016",
    "orderNumber": "ORD12345678",
    "userId": "507f1f77bcf86cd799439011",
    "branchId": "507f1f77bcf86cd799439012",
    "items": [ /* ... */ ],
    "subtotal": 30000000,
    "taxAmount": 0,
    "discountAmount": 1000000,
    "totalAmount": 29000000,
    "status": "pending",
    "currency": "SYP",
    "isPaid": false,
    "createdAt": "2025-01-20T14:30:00.000Z"
  }
}
```

#### **GET** `/orders`
🔒 Get all orders (Admin/Manager/Employee).

**Query Parameters:**
- `page` (number)
- `limit` (number)
- `search` (string): Search by order number
- `status` (string): Filter by status
- `branchId` (string): Filter by branch
- `customerId` (string): Filter by customer
- `isPaid` (boolean): Filter by payment status
- `startDate` (string): Filter from date
- `endDate` (string): Filter to date

#### **GET** `/orders/my`
🔒 Get my orders (Customer/Merchant).

**Response:**
```json
{
  "success": true,
  "message": "تم جلب طلباتك بنجاح",
  "data": [
    {
      "_id": "507f1f77bcf86cd799439016",
      "orderNumber": "ORD12345678",
      "status": "pending",
      "totalAmount": 29000000,
      "currency": "SYP",
      "isPaid": false,
      "createdAt": "2025-01-20T14:30:00.000Z",
      "branch": {
        "_id": "507f1f77bcf86cd799439012",
        "name": "Main Branch"
      },
      "items": [ /* ... */ ]
    }
  ]
}
```

#### **GET** `/orders/recent`
🔒 Get recent orders (Admin/Manager/Employee/Merchant).

**Query Parameters:**
- `limit` (number): Default 10

#### **GET** `/orders/stats`
🔒 Get order statistics (Admin/Manager).

**Response:**
```json
{
  "success": true,
  "message": "تم جلب إحصائيات الطلبات بنجاح",
  "data": {
    "totalOrders": 1250,
    "pendingOrders": 15,
    "confirmedOrders": 8,
    "processingOrders": 12,
    "shippedOrders": 5,
    "deliveredOrders": 1200,
    "cancelledOrders": 10,
    "totalRevenue": 450000000,
    "averageOrderValue": 360000
  }
}
```

#### **GET** `/orders/number/:orderNumber`
🔒 Get order by order number (Admin/Manager/Employee).

#### **GET** `/orders/by-id/:id`
🔒 Get order by ID.

#### **PATCH** `/orders/:id/status`
🔒 Update order status.

**Request Body:**
```json
{
  "status": "confirmed",
  "notes": "Order confirmed and being processed"
}
```

**Order Status Values:**
- `pending`: Order placed, awaiting confirmation
- `confirmed`: Order confirmed by merchant
- `processing`: Order being prepared
- `shipped`: Order shipped/out for delivery
- `delivered`: Order delivered to customer
- `cancelled`: Order cancelled
- `returned`: Order returned

#### **PATCH** `/orders/:id`
🔒 Update order (Admin/Manager).

#### **DELETE** `/orders/:id`
🔒 Delete order (Admin/Manager).

---

### 🎯 Banner Endpoints

#### **GET** `/banners`
Get all banners.

**Query Parameters:**
- `page` (number)
- `limit` (number)
- `isActive` (boolean)

**Response:**
```json
{
  "success": true,
  "message": "Banners retrieved successfully",
  "data": [
    {
      "_id": "507f1f77bcf86cd799439017",
      "image": "/uploads/banners/banner1.jpg",
      "productId": "507f1f77bcf86cd799439013",
      "categoryId": null,
      "subCategoryId": null,
      "sortOrder": 0,
      "isActive": true
    }
  ],
  "pagination": { /* ... */ }
}
```

#### **GET** `/banners/active`
Get active banners.

**Query Parameters:**
- `limit` (number)

#### **GET** `/banners/stats`
🔒 Get banner statistics (Admin/Manager).

#### **GET** `/banners/:id`
Get banner by ID.

#### **POST** `/banners`
🔒 Create banner (Admin/Manager).

**Content-Type:** `multipart/form-data`

**Form Fields:**
- `image` (file, required)
- `productId` (string): Link to product
- `categoryId` (string): Link to category
- `subCategoryId` (string): Link to sub-category
- `sortOrder` (number)
- `isActive` (boolean)

#### **PATCH** `/banners/:id`
🔒 Update banner (Admin/Manager).

#### **PATCH** `/banners/:id/toggle-active`
🔒 Toggle banner active status (Admin/Manager).

#### **DELETE** `/banners/:id`
🔒 Delete banner (Admin/Manager).

---

### 👥 Customer Endpoints

#### **GET** `/customers`
🔒 Get all customers (Admin/Manager/Employee).

**Query Parameters:**
- `page` (number)
- `limit` (number)
- `search` (string)
- `isActive` (boolean)

#### **GET** `/customers/top-customers`
🔒 Get top customers (Admin/Manager).

**Query Parameters:**
- `limit` (number): Default 10

#### **GET** `/customers/recent`
🔒 Get recent customers (Admin/Manager/Employee).

#### **GET** `/customers/stats`
🔒 Get customer statistics (Admin/Manager).

#### **GET** `/customers/email/:email`
🔒 Get customer by email (Admin/Manager/Employee).

#### **GET** `/customers/:id`
🔒 Get customer by ID (Admin/Manager/Employee).

#### **POST** `/customers`
🔒 Create customer (Admin/Manager/Employee).

#### **PATCH** `/customers/:id`
🔒 Update customer (Admin/Manager/Employee).

#### **PATCH** `/customers/:id/toggle-active`
🔒 Toggle customer active status (Admin/Manager).

#### **DELETE** `/customers/:id`
🔒 Delete customer (Admin/Manager).

---

### 🏪 Merchant Endpoints

#### **POST** `/merchants/request`
🔒 Create merchant application request.

**Request Body:**
```json
{
  "businessName": "Tech Store",
  "businessType": "Electronics Retail",
  "taxId": "123456789",
  "address": {
    "street": "Main Street 123",
    "city": "Damascus",
    "country": "Syria"
  },
  "description": "We sell electronics"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم إرسال طلب التاجر بنجاح",
  "data": {
    "_id": "507f1f77bcf86cd799439018",
    "userId": "507f1f77bcf86cd799439011",
    "businessName": "Tech Store",
    "status": "pending",
    "createdAt": "2025-01-20T15:00:00.000Z"
  }
}
```

#### **GET** `/merchants`
🔒 Get all merchant requests (Admin/Manager).

**Query Parameters:**
- `page` (number)
- `limit` (number)
- `status` (string): pending/approved/rejected

#### **GET** `/merchants/statistics`
🔒 Get merchant statistics (Admin/Manager).

#### **GET** `/merchants/my-request`
🔒 Get my merchant request.

#### **GET** `/merchants/:id`
🔒 Get merchant request by ID (Admin/Manager).

#### **PATCH** `/merchants/my-request`
🔒 Update my merchant request (only if pending).

#### **PATCH** `/merchants/:id/review`
🔒 Review merchant request - approve/reject (Admin only).

**Request Body:**
```json
{
  "status": "approved",
  "reviewNotes": "Application approved"
}
```

**Status Values:**
- `pending`: Under review
- `approved`: Approved, user role changed to merchant
- `rejected`: Rejected

#### **DELETE** `/merchants/:id`
🔒 Delete merchant request (Admin only).

---

### 🔔 Notification Endpoints

#### **GET** `/notifications`
🔒 Get my notifications.

**Query Parameters:**
- `page` (number)
- `limit` (number)
- `isRead` (boolean): Filter by read status
- `type` (string): Filter by notification type

**Response:**
```json
{
  "success": true,
  "message": "تم جلب الإشعارات بنجاح",
  "data": [
    {
      "_id": "507f1f77bcf86cd799439019",
      "recipientId": "507f1f77bcf86cd799439011",
      "title": "Order Confirmed",
      "message": "Your order #ORD12345678 has been confirmed",
      "type": "order_updated",
      "isRead": false,
      "data": {
        "orderId": "507f1f77bcf86cd799439016",
        "orderNumber": "ORD12345678"
      },
      "createdAt": "2025-01-20T15:30:00.000Z"
    }
  ],
  "pagination": { /* ... */ }
}
```

#### **GET** `/notifications/admin`
🔒 Get all notifications (Admin/Manager).

#### **GET** `/notifications/stats`
🔒 Get notification statistics (Admin/Manager).

**Query Parameters:**
- `recipientId` (string): Optional, for specific user

#### **GET** `/notifications/:id`
🔒 Get notification by ID.

#### **POST** `/notifications`
🔒 Create notification (Admin/Manager).

**Request Body:**
```json
{
  "recipientId": "507f1f77bcf86cd799439011",
  "title": "Special Offer",
  "message": "50% off on all electronics",
  "type": "system",
  "data": {
    "categoryId": "507f1f77bcf86cd799439014"
  }
}
```

#### **POST** `/notifications/bulk`
🔒 Create bulk notifications (Admin/Manager).

**Request Body:**
```json
{
  "recipientIds": ["507f...", "508f..."],
  "title": "System Maintenance",
  "message": "System will be down for maintenance",
  "type": "system"
}
```

#### **POST** `/notifications/broadcast`
🔒 Broadcast notification to all users (Admin/Manager).

**Request Body:**
```json
{
  "title": "New Features",
  "message": "Check out our new mobile app features",
  "data": {
    "url": "https://app.shamra.com/features"
  }
}
```

#### **PATCH** `/notifications/:id/read`
🔒 Mark notification as read.

**Request Body:**
```json
{
  "isRead": true
}
```

#### **PATCH** `/notifications/mark-all-read`
🔒 Mark all notifications as read.

#### **PATCH** `/notifications/:id`
🔒 Update notification (Admin/Manager).

#### **DELETE** `/notifications/:id`
🔒 Delete notification (Admin/Manager).

---

### ⚙️ Settings Endpoints

#### **GET** `/settings/public`
Get public settings.

**Response:**
```json
{
  "success": true,
  "message": "تم جلب الإعدادات العامة بنجاح",
  "data": {
    "app_name": "Shamra Electronics",
    "currency": "SYP",
    "tax_rate": 0,
    "delivery_fee": 5000,
    "free_delivery_threshold": 100000,
    "contact_phone": "+963 11 234 5678",
    "contact_email": "info@shamra.com"
  }
}
```

#### **GET** `/settings/value/:key`
Get setting value by key.

**Query Parameters:**
- `default` (string): Default value if not found

**Response:**
```json
{
  "success": true,
  "message": "تم جلب قيمة الإعداد بنجاح",
  "data": {
    "key": "tax_rate",
    "value": "0"
  }
}
```

#### **GET** `/settings/values`
Get multiple setting values.

**Query Parameters:**
- `keys` (string): Comma-separated keys

**Example:** `/settings/values?keys=app_name,currency,tax_rate`

#### **GET** `/settings/category/:category`
🔒 Get settings by category (Admin/Manager).

#### **GET** `/settings`
🔒 Get all settings (Admin/Manager).

**Query Parameters:**
- `page` (number)
- `limit` (number)
- `category` (string)
- `isPublic` (boolean)

#### **GET** `/settings/:key`
🔒 Get setting by key (Admin/Manager).

#### **POST** `/settings`
🔒 Create setting (Admin).

**Request Body:**
```json
{
  "key": "min_order_amount",
  "value": "10000",
  "type": "number",
  "category": "order",
  "description": "Minimum order amount",
  "isPublic": true
}
```

#### **PATCH** `/settings/:key`
🔒 Update setting (Admin/Manager).

**Request Body:**
```json
{
  "value": "15000"
}
```

#### **POST** `/settings/bulk-update`
🔒 Bulk update settings (Admin/Manager).

**Request Body:**
```json
{
  "settings": [
    { "key": "tax_rate", "value": "5" },
    { "key": "delivery_fee", "value": "10000" }
  ]
}
```

#### **PATCH** `/settings/:key/reset`
🔒 Reset setting to default (Admin).

#### **DELETE** `/settings/:key`
🔒 Delete setting (Admin).

#### **POST** `/settings/cache/clear`
🔒 Clear settings cache (Admin).

#### **GET** `/settings/cache/stats`
🔒 Get cache statistics (Admin).

---

## 📊 Data Models

### User Model
```typescript
{
  _id: string,
  firstName: string,
  lastName: string,
  email?: string,
  phoneNumber: string,
  role: "admin" | "manager" | "employee" | "customer" | "merchant",
  isActive: boolean,
  points: number,
  totalPointsEarned: number,
  totalPointsUsed: number,
  profileImage?: string,
  branchId?: string,
  lastLoginAt?: Date,
  fcmToken?: string,
  createdAt: Date,
  updatedAt: Date
}
```

### Product Model
```typescript
{
  _id: string,
  name: string,
  description?: string,
  barcode?: string,
  mainImage?: string,
  images: string[],
  brand?: string,
  categoryId: string,
  subCategoryId: string,
  category?: Category,
  subCategory?: SubCategory,
  branchPricing: [
    {
      branchId: string,
      price: number,
      costPrice: number,
      wholeSalePrice: number,
      salePrice?: number,
      currency: string,
      stockQuantity: number,
      sku: string,
      isOnSale: boolean,
      isActive: boolean
    }
  ],
  branches: string[],
  branchDetails?: Branch[],
  specifications: { [key: string]: any },
  status: "active" | "inactive" | "out_of_stock" | "discontinued",
  isActive: boolean,
  isFeatured: boolean,
  tags: string[],
  keywords: string[],
  totalSales: number,
  viewCount: number,
  rating: number,
  reviewCount: number,
  sortOrder: number,
  createdAt: Date,
  updatedAt: Date
}
```

### Order Model
```typescript
{
  _id: string,
  orderNumber: string,
  userId: string,
  user?: User,
  branchId?: string,
  branch?: Branch,
  items: [
    {
      productId: string,
      productName: string,
      categoryId?: string,
      quantity: number,
      price: number,
      total: number
    }
  ],
  subtotal: number,
  taxAmount: number,
  discountAmount: number,
  totalAmount: number,
  status: "pending" | "confirmed" | "processing" | "shipped" | "delivered" | "cancelled" | "returned",
  currency: string,
  notes?: string,
  isPaid: boolean,
  paidAt?: Date,
  location?: {
    lat: number,
    lng: number
  },
  createdAt: Date,
  updatedAt: Date
}
```

### Category Model
```typescript
{
  _id: string,
  name: string,
  image?: string,
  sortOrder: number,
  isActive: boolean,
  isFeatured: boolean,
  productCount: number,
  createdAt: Date,
  updatedAt: Date
}
```

### SubCategory Model
```typescript
{
  _id: string,
  name: string,
  categoryId: string,
  image?: string,
  sortOrder: number,
  isActive: boolean,
  createdAt: Date,
  updatedAt: Date
}
```

### Branch Model
```typescript
{
  _id: string,
  name: string,
  description?: string,
  phone?: string,
  email?: string,
  address: {
    street: string,
    city: string,
    country: string,
    coordinates?: {
      lat: number,
      lng: number
    }
  },
  managerId?: string,
  isActive: boolean,
  isMainBranch: boolean,
  operatingHours?: {
    [day: string]: {
      open: string,
      close: string
    }
  },
  employeeCount: number,
  totalSales: number,
  totalOrders: number,
  sortOrder: number,
  createdAt: Date,
  updatedAt: Date
}
```

### Banner Model
```typescript
{
  _id: string,
  image: string,
  productId?: string,
  categoryId?: string,
  subCategoryId?: string,
  sortOrder: number,
  isActive: boolean,
  createdAt: Date,
  updatedAt: Date
}
```

### Notification Model
```typescript
{
  _id: string,
  recipientId: string,
  title: string,
  message: string,
  type: "order_created" | "order_updated" | "low_stock" | "out_of_stock" | "promotion_started" | "promotion_ended" | "system",
  isRead: boolean,
  readAt?: Date,
  data?: { [key: string]: any },
  createdAt: Date,
  updatedAt: Date
}
```

### Merchant Request Model
```typescript
{
  _id: string,
  userId: string,
  businessName: string,
  businessType?: string,
  taxId?: string,
  address: {
    street: string,
    city: string,
    country: string
  },
  description?: string,
  status: "pending" | "approved" | "rejected",
  reviewNotes?: string,
  reviewedBy?: string,
  reviewedAt?: Date,
  createdAt: Date,
  updatedAt: Date
}
```

---

## ⚠️ Error Handling

### Response Format

All errors follow this format:

```json
{
  "success": false,
  "message": "Error description in Arabic",
  "error": {
    "statusCode": 400,
    "message": "Detailed error message",
    "error": "Bad Request"
  }
}
```

### HTTP Status Codes

- **200 OK**: Success
- **201 Created**: Resource created
- **400 Bad Request**: Invalid input
- **401 Unauthorized**: Missing or invalid authentication
- **403 Forbidden**: Insufficient permissions
- **404 Not Found**: Resource not found
- **409 Conflict**: Resource already exists
- **422 Unprocessable Entity**: Validation error
- **500 Internal Server Error**: Server error

### Common Error Scenarios

#### 1. Validation Error (400)
```json
{
  "success": false,
  "message": "خطأ في البيانات المدخلة",
  "error": {
    "statusCode": 400,
    "message": [
      "رقم الهاتف غير صحيح",
      "كلمة المرور يجب أن تكون 6 أحرف على الأقل"
    ],
    "error": "Bad Request"
  }
}
```

#### 2. Authentication Error (401)
```json
{
  "success": false,
  "message": "غير مصرح بالدخول",
  "error": {
    "statusCode": 401,
    "message": "Invalid or expired token",
    "error": "Unauthorized"
  }
}
```

#### 3. Permission Error (403)
```json
{
  "success": false,
  "message": "ليس لديك صلاحية للقيام بهذا الإجراء",
  "error": {
    "statusCode": 403,
    "message": "Insufficient permissions",
    "error": "Forbidden"
  }
}
```

#### 4. Not Found Error (404)
```json
{
  "success": false,
  "message": "المورد غير موجود",
  "error": {
    "statusCode": 404,
    "message": "Product not found",
    "error": "Not Found"
  }
}
```

#### 5. Conflict Error (409)
```json
{
  "success": false,
  "message": "رقم الهاتف مستخدم مسبقاً",
  "error": {
    "statusCode": 409,
    "message": "Phone number already exists",
    "error": "Conflict"
  }
}
```

---

## 📤 File Uploads

### Supported Upload Endpoints

1. **Product Images**: `/products/with-images` (POST/PATCH)
2. **Category Images**: `/categories` (POST/PATCH)
3. **Sub-Category Images**: `/sub-categories` (POST/PATCH)
4. **Banner Images**: `/banners` (POST/PATCH)

### Upload Limits

- **Max file size**: 5MB per file
- **Max images per product**: 8 (1 main + 7 additional)
- **Supported formats**: JPG, JPEG, PNG, GIF, WEBP

### Upload Structure

Images are stored in the `/uploads/` directory:
- Products: `/uploads/products/`
- Categories: `/uploads/categories/`
- Sub-categories: `/uploads/sub-categories/`
- Banners: `/uploads/banners/`

### Example: Upload Product with Images (Flutter/Dart)

```dart
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

Future<void> createProductWithImages({
  required String name,
  required String categoryId,
  required String subCategoryId,
  required File mainImage,
  required List<File> additionalImages,
  required List<Map<String, dynamic>> branchPricing,
  String? description,
}) async {
  final dio = Dio();
  
  // Add authorization header
  dio.options.headers['Authorization'] = 'Bearer $accessToken';
  
  // Create form data
  final formData = FormData.fromMap({
    'name': name,
    'categoryId': categoryId,
    'subCategoryId': subCategoryId,
    'description': description ?? '',
    'branchPricing': jsonEncode(branchPricing),
    'isActive': 'true',
    'isFeatured': 'false',
    'mainImage': await MultipartFile.fromFile(
      mainImage.path,
      filename: 'main.jpg',
      contentType: MediaType('image', 'jpeg'),
    ),
  });
  
  // Add additional images
  for (int i = 0; i < additionalImages.length; i++) {
    formData.files.add(MapEntry(
      'images',
      await MultipartFile.fromFile(
        additionalImages[i].path,
        filename: 'image_$i.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
    ));
  }
  
  try {
    final response = await dio.post(
      'http://62.171.153.198:3398/api/v1/products/with-images',
      data: formData,
    );
    
    print('Product created: ${response.data}');
  } catch (e) {
    print('Error: $e');
  }
}
```

---

## 🔄 Common Patterns

### 1. Pagination Pattern

Most list endpoints support pagination:

**Query Parameters:**
```
?page=1&limit=20
```

**Response:**
```json
{
  "success": true,
  "message": "Success message",
  "data": [ /* items */ ],
  "pagination": {
    "total": 150,
    "page": 1,
    "limit": 20,
    "totalPages": 8
  }
}
```

### 2. Search Pattern

**Query Parameters:**
```
?search=samsung&categoryId=123&minPrice=100000&maxPrice=500000
```

### 3. Filtering Pattern

**Query Parameters:**
```
?isActive=true&isFeatured=true&status=active
```

### 4. Sorting Pattern

**Query Parameters:**
```
?sortBy=price&sortOrder=asc
```

Common sortBy values:
- `price`: Sort by price
- `name`: Sort by name
- `createdAt`: Sort by creation date
- `totalSales`: Sort by sales count
- `rating`: Sort by rating

### 5. Branch-Specific Data

Many endpoints accept a `branchId` parameter to get branch-specific data:

**Query Parameters:**
```
?branchId=507f1f77bcf86cd799439012
```

This is especially important for:
- Product pricing and stock
- Order filtering
- Inventory management

### 6. Role-Based Access

User roles determine API access:

| Role | Access Level |
|------|--------------|
| **Admin** | Full access to all endpoints |
| **Manager** | Most endpoints except critical admin functions |
| **Employee** | Read access + basic operations |
| **Customer** | Limited to public endpoints + own data |
| **Merchant** | Similar to customer + order management |

### 7. Response Consistency

All successful responses follow this pattern:

```json
{
  "success": true,
  "message": "Success message in Arabic",
  "data": { /* response data */ }
}
```

For list endpoints with pagination:

```json
{
  "success": true,
  "message": "Success message in Arabic",
  "data": [ /* items */ ],
  "pagination": { /* pagination info */ }
}
```

---

## 🚀 Quick Start Guide for Flutter

### 1. Setup Base Configuration

```dart
class ApiConfig {
  static const String baseUrl = 'http://62.171.153.198:3398/api/v1';
  static const String uploadsUrl = 'http://62.171.153.198:3398/uploads';
  
  static Map<String, String> getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
```

### 2. Authentication Service

```dart
class AuthService {
  final Dio _dio = Dio();
  
  Future<Map<String, dynamic>> login(String phoneNumber, String password) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/auth/login',
        data: {
          'phoneNumber': phoneNumber,
          'password': password,
        },
      );
      
      if (response.data['success']) {
        // Save tokens
        final accessToken = response.data['data']['access_token'];
        final refreshToken = response.data['data']['refresh_token'];
        await _saveTokens(accessToken, refreshToken);
        
        return response.data;
      }
      
      throw Exception(response.data['message']);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }
}
```

### 3. Product Service

```dart
class ProductService {
  final Dio _dio = Dio();
  
  Future<List<Product>> getProducts({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? search,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/products',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (categoryId != null) 'categoryId': categoryId,
          if (search != null) 'search': search,
        },
      );
      
      if (response.data['success']) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Product.fromJson(json)).toList();
      }
      
      throw Exception(response.data['message']);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Product> getProductById(String id) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/products/$id',
      );
      
      if (response.data['success']) {
        return Product.fromJson(response.data['data']);
      }
      
      throw Exception(response.data['message']);
    } catch (e) {
      rethrow;
    }
  }
}
```

### 4. Order Service

```dart
class OrderService {
  final Dio _dio = Dio();
  
  Future<Order> createOrder({
    required String branchId,
    required List<OrderItem> items,
    required double totalAmount,
    String? notes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/orders',
        options: Options(headers: ApiConfig.getHeaders(token: token)),
        data: {
          'branchId': branchId,
          'items': items.map((item) => item.toJson()).toList(),
          'subtotal': totalAmount,
          'taxAmount': 0,
          'discountAmount': 0,
          'totalAmount': totalAmount,
          'currency': 'SYP',
          if (notes != null) 'notes': notes,
        },
      );
      
      if (response.data['success']) {
        return Order.fromJson(response.data['data']);
      }
      
      throw Exception(response.data['message']);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<List<Order>> getMyOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/orders/my',
        options: Options(headers: ApiConfig.getHeaders(token: token)),
      );
      
      if (response.data['success']) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Order.fromJson(json)).toList();
      }
      
      throw Exception(response.data['message']);
    } catch (e) {
      rethrow;
    }
  }
}
```

### 5. Image Helper

```dart
class ImageHelper {
  static String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return ''; // Return placeholder
    }
    
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    
    return '${ApiConfig.uploadsUrl}${imagePath}';
  }
}

// Usage in Widget
CachedNetworkImage(
  imageUrl: ImageHelper.getFullImageUrl(product.mainImage),
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

---

## 📝 Notes

### Phone Number Format
Phone numbers should be in one of these formats:
- `0912345678` (local format)
- `+963912345678` (international format)

The backend accepts both and validates accordingly.

### Currency
The system supports multiple currencies:
- `SYP` (Syrian Pound) - Default
- `USD` (US Dollar)
- `EUR` (Euro)
- `TRK` (Turkish Lira)

### Date Format
All dates are in ISO 8601 format:
```
2025-01-20T14:30:00.000Z
```

### Points System
Customers earn points on purchases:
- Points are currency-agnostic
- Can be used for discounts
- Tracked via `points`, `totalPointsEarned`, `totalPointsUsed` fields

### Order Status Flow
Typical order flow:
```
pending → confirmed → processing → shipped → delivered
```

Can also be:
```
pending → cancelled
delivered → returned
```

### Branch Pricing
Products have different prices/stock per branch:
- Each product has `branchPricing` array
- Contains price, stock, SKU per branch
- Use `branchId` query parameter to get branch-specific data

---

## 🔗 Additional Resources

### Firebase Configuration
The app uses Firebase for:
- Push notifications (FCM)
- User device token management

Make sure to:
1. Configure Firebase in your Flutter app
2. Send `fcmToken` during login/register
3. Handle notification payloads from the backend

### Testing
- Use Postman collection for API testing
- Base URL: `http://62.171.153.198:3398/api/v1`
- Test user credentials (if available from backend team)

### Support
For backend issues or questions, contact the backend development team.

---

**Document Version:** 1.0  
**Last Updated:** November 29, 2025  
**Generated For:** Flutter Development Team
