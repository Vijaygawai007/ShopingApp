
//
//  DatabaseManager.swift
//  ShopingApp
//
//  Created by Vijay on 16/09/26.
//

import Foundation
import SQLite3

class DatabaseManager {

    static let shared = DatabaseManager()

    var db: OpaquePointer?

    // MARK: - Initializer

    private init() {

        db = openDatabase()

        createTable()
    }

    // MARK: - Open Database

    private func openDatabase() -> OpaquePointer? {

        let fileURL = try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ).appendingPathComponent("CartDatabase.sqlite")

        var db: OpaquePointer?

        if sqlite3_open(
            fileURL.path,
            &db
        ) != SQLITE_OK {

            print(
                "❌ Error opening database:",
                String(cString: sqlite3_errmsg(db))
            )

            return nil
        }

        print(
            "✅ Successfully opened database at:",
            fileURL.path
        )

        return db
    }

    // MARK: - Create Table

    private func createTable() {

        let query = """
        CREATE TABLE IF NOT EXISTS CartProducts (
            id INTEGER PRIMARY KEY,
            title TEXT,
            price REAL,
            quantity INTEGER,
            thumbnail TEXT
        );
        """

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(
            db,
            query,
            -1,
            &statement,
            nil
        ) == SQLITE_OK {

            if sqlite3_step(statement) == SQLITE_DONE {

                print("✅ CartProducts table ready")

            } else {

                print("❌ Failed to create CartProducts")
            }

        } else {

            print("❌ Failed to prepare CREATE TABLE")
        }

        sqlite3_finalize(statement)
    }

    // MARK: - Add Thumbnail Column If Needed

    private func addThumbnailColumnIfNeeded() {

        let alterTableString = """
        ALTER TABLE CartProducts
        ADD COLUMN thumbnail TEXT;
        """

        var alterStatement: OpaquePointer?

        if sqlite3_prepare_v2(
            db,
            alterTableString,
            -1,
            &alterStatement,
            nil
        ) == SQLITE_OK {

            if sqlite3_step(alterStatement) == SQLITE_DONE {

                print("✅ Thumbnail column added.")

            } else {

                print(
                    "ℹ️ Thumbnail column may already exist."
                )
            }

        } else {

            print(
                "ℹ️ Thumbnail column already exists or ALTER TABLE failed."
            )
        }

        sqlite3_finalize(alterStatement)
    }

    // MARK: - Insert Product

    func saveCartProduct(_ product: CartProduct) {

        let query = """
        INSERT OR REPLACE INTO CartProducts
        (id, title, price, quantity, thumbnail)
        VALUES (?, ?, ?, ?, ?);
        """

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(
            db,
            query,
            -1,
            &statement,
            nil
        ) == SQLITE_OK {

            // Product ID

            sqlite3_bind_int(
                statement,
                1,
                Int32(product.id)
            )

            // Title

            sqlite3_bind_text(
                statement,
                2,
                (product.title as NSString).utf8String,
                -1,
                nil
            )

            // Price

            sqlite3_bind_double(
                statement,
                3,
                product.price
            )

            // Quantity

            sqlite3_bind_int(
                statement,
                4,
                Int32(product.quantity)
            )

            // Thumbnail

            if let thumbnail = product.thumbnail,
               !thumbnail.isEmpty {

                sqlite3_bind_text(
                    statement,
                    5,
                    (thumbnail as NSString).utf8String,
                    -1,
                    nil
                )

                print(
                    "🖼️ Saving thumbnail:",
                    thumbnail
                )

            } else {

                sqlite3_bind_null(
                    statement,
                    5
                )

                print("❌ Thumbnail is NIL/empty")
            }

            // Execute Insert

            if sqlite3_step(statement) == SQLITE_DONE {

                print(
                    "✅ Saved to SQLite:",
                    product.title
                )

            } else {

                print(
                    "❌ SQLite save failed:",
                    String(cString: sqlite3_errmsg(db))
                )
            }

        } else {

            print("❌ Failed to prepare SQLite INSERT")
        }

        sqlite3_finalize(statement)
    }

    // MARK: - Fetch Products

    func fetchCartProducts() -> [CartProduct] {

        let query = """
        SELECT id, title, price, quantity, thumbnail
        FROM CartProducts;
        """

        var statement: OpaquePointer?

        var products: [CartProduct] = []

        if sqlite3_prepare_v2(
            db,
            query,
            -1,
            &statement,
            nil
        ) == SQLITE_OK {

            while sqlite3_step(statement) == SQLITE_ROW {

                // ID

                let id = Int(
                    sqlite3_column_int(statement, 0)
                )

                // Title

                let titlePointer =
                    sqlite3_column_text(statement, 1)

                let title =
                    titlePointer != nil
                    ? String(cString: titlePointer!)
                    : ""

                // Price

                let price =
                    sqlite3_column_double(statement, 2)

                // Quantity

                let quantity = Int(
                    sqlite3_column_int(statement, 3)
                )

                // Thumbnail

                let thumbnailPointer =
                    sqlite3_column_text(statement, 4)

                let thumbnail: String? =
                    thumbnailPointer != nil
                    ? String(cString: thumbnailPointer!)
                    : nil

                // Create Cart Product

                let product = CartProduct(
                    id: id,
                    title: title,
                    price: price,
                    quantity: quantity,
                    total: price * Double(quantity),
                    discountPercentage: nil,
                    discountedTotal: nil,
                    thumbnail: thumbnail
                )

                products.append(product)
            }

        } else {

            print("❌ Failed to prepare fetch query")
        }

        sqlite3_finalize(statement)

        return products
    }

    // MARK: - Update Cart Product Quantity

    func updateCartQuantity(
        productID: Int,
        quantity: Int
    ) {

        let query = """
        UPDATE CartProducts
        SET quantity = ?
        WHERE id = ?;
        """

        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(
            db,
            query,
            -1,
            &statement,
            nil
        ) == SQLITE_OK else {

            print(
                "❌ Failed to prepare quantity update:",
                String(cString: sqlite3_errmsg(db))
            )

            return
        }

        defer {
            sqlite3_finalize(statement)
        }

        // Bind Quantity

        sqlite3_bind_int(
            statement,
            1,
            Int32(max(1, quantity))
        )

        // Bind Product ID

        sqlite3_bind_int(
            statement,
            2,
            Int32(productID)
        )

        // Execute Update

        if sqlite3_step(statement) == SQLITE_DONE {

            print("✅ Cart quantity updated successfully")

            print("🛒 Product ID:", productID)

            print("📦 New Quantity:", quantity)

        } else {

            print(
                "❌ Quantity update failed:",
                String(cString: sqlite3_errmsg(db))
            )
        }
    }

    // MARK: - Delete Cart Product

    func deleteCartProduct(productID: Int) {

        let query = """
        DELETE FROM CartProducts
        WHERE id = ?;
        """

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(
            db,
            query,
            -1,
            &statement,
            nil
        ) == SQLITE_OK {

            sqlite3_bind_int(
                statement,
                1,
                Int32(productID)
            )

            if sqlite3_step(statement) == SQLITE_DONE {

                print(
                    "🗑️ Product deleted from SQLite:",
                    productID
                )

            } else {

                print(
                    "❌ Failed to delete product:",
                    String(cString: sqlite3_errmsg(db))
                )
            }

        } else {

            print("❌ Failed to prepare delete query")
        }

        sqlite3_finalize(statement)
    }

    // MARK: - Check If Product Is In Cart

    func isProductInCart(productID: Int) -> Bool {

        let query = """
        SELECT id
        FROM CartProducts
        WHERE id = ?
        LIMIT 1;
        """

        var statement: OpaquePointer?

        var exists = false

        if sqlite3_prepare_v2(
            db,
            query,
            -1,
            &statement,
            nil
        ) == SQLITE_OK {

            sqlite3_bind_int(
                statement,
                1,
                Int32(productID)
            )

            if sqlite3_step(statement) == SQLITE_ROW {

                exists = true
            }
        }

        sqlite3_finalize(statement)

        return exists
    }
}
