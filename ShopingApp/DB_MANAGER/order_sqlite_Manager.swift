import Foundation
import SQLite3

class OrderSQLiteManager {
    
    static let shared = OrderSQLiteManager()
    
    private var db: OpaquePointer?
    
    private init() {
        openDatabase()
        createOrdersTable()
    }
    
    // MARK: - Database Path
    
    private func databasePath() -> String {
        
        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        
        return documentsDirectory
            .appendingPathComponent("ShopingApp.sqlite")
            .path
    }
    
    // MARK: - Open Database
    
    private func openDatabase() {
        
        let path = databasePath()
        
        if sqlite3_open(path, &db) == SQLITE_OK {
            
            print("✅ SQLite database opened")
            print("📍 Database Path: \(path)")
            
        } else {
            
            print("❌ Failed to open SQLite database")
        }
    }
    
    // MARK: - Create Orders Table
    
    private func createOrdersTable() {
        
        let query = """
        CREATE TABLE IF NOT EXISTS Orders (
            orderID INTEGER PRIMARY KEY,
            productID INTEGER NOT NULL,
            productName TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            price REAL NOT NULL,
            total REAL NOT NULL,
            paymentID TEXT NOT NULL,
            status TEXT NOT NULL,
            orderDate TEXT NOT NULL,
            thumbnail TEXT NOT NULL
        );
        """
        
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(
            db,
            query,
            -1,
            &statement,
            nil
        ) == SQLITE_OK else {
            
            print("❌ Failed to prepare Orders table")
            return
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("✅ Orders table ready")
        } else {
            print("❌ Failed to create Orders table")
        }
        
        sqlite3_finalize(statement)
    }
    
    // MARK: - Save Order
    
    func saveOrder(
        productID: Int,
        productName: String,
        quantity: Int,
        price: Double,
        paymentID: String,
        thumbnail: String
    ) {
        
        let orderID = Int(Date().timeIntervalSince1970 * 1000)
        
        let total = price * Double(quantity)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let orderDate = formatter.string(from: Date())
        
        let query = """
        INSERT INTO Orders
        (
            orderID,
            productID,
            productName,
            quantity,
            price,
            total,
            paymentID,
            status,
            orderDate,
            thumbnail
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(
            db,
            query,
            -1,
            &statement,
            nil
        ) == SQLITE_OK else {
            
            print("❌ Failed to prepare INSERT order query")
            return
        }
        
        sqlite3_bind_int64(
            statement,
            1,
            sqlite3_int64(orderID)
        )
        
        sqlite3_bind_int(
            statement,
            2,
            Int32(productID)
        )
        
        sqlite3_bind_text(
            statement,
            3,
            (productName as NSString).utf8String,
            -1,
            nil
        )
        
        sqlite3_bind_int(
            statement,
            4,
            Int32(quantity)
        )
        
        sqlite3_bind_double(
            statement,
            5,
            price
        )
        
        sqlite3_bind_double(
            statement,
            6,
            total
        )
        
        sqlite3_bind_text(
            statement,
            7,
            (paymentID as NSString).utf8String,
            -1,
            nil
        )
        
        sqlite3_bind_text(
            statement,
            8,
            ("Order Placed" as NSString).utf8String,
            -1,
            nil
        )
        
        sqlite3_bind_text(
            statement,
            9,
            (orderDate as NSString).utf8String,
            -1,
            nil
        )
        
        sqlite3_bind_text(
            statement,
            10,
            (thumbnail as NSString).utf8String,
            -1,
            nil
        )
        
        if sqlite3_step(statement) == SQLITE_DONE {
            
            print("================================")
            print("✅ ORDER SAVED IN SQLITE")
            print("Order ID: \(orderID)")
            print("Product ID: \(productID)")
            print("Product: \(productName)")
            print("Quantity: \(quantity)")
            print("Price: \(price)")
            print("Total: \(total)")
            print("Payment ID: \(paymentID)")
            print("Status: Order Placed")
            print("================================")
            
        } else {
            
            print("❌ Failed to save order")
            print(
                "SQLite Error: \(String(cString: sqlite3_errmsg(db)))"
            )
        }
        
        sqlite3_finalize(statement)
    }
    
    // MARK: - Fetch Orders
    
    func fetchOrders() -> [Order] {
        
        var orders: [Order] = []
        
        let query = """
        SELECT
            orderID,
            productID,
            productName,
            quantity,
            price,
            total,
            paymentID,
            status,
            orderDate,
            thumbnail
        FROM Orders
        ORDER BY orderID DESC;
        """
        
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(
            db,
            query,
            -1,
            &statement,
            nil
        ) == SQLITE_OK else {
            
            print("❌ Failed to prepare fetch orders query")
            return orders
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            
            let orderID = Int(
                sqlite3_column_int64(statement, 0)
            )
            
            let productID = Int(
                sqlite3_column_int(statement, 1)
            )
            
            let productName = String(
                cString: sqlite3_column_text(statement, 2)
            )
            
            let quantity = Int(
                sqlite3_column_int(statement, 3)
            )
            
            let price = sqlite3_column_double(
                statement,
                4
            )
            
            let total = sqlite3_column_double(
                statement,
                5
            )
            
            let paymentID = String(
                cString: sqlite3_column_text(statement, 6)
            )
            
            let status = String(
                cString: sqlite3_column_text(statement, 7)
            )
            
            let orderDate = String(
                cString: sqlite3_column_text(statement, 8)
            )
            
            let thumbnail = String(
                cString: sqlite3_column_text(statement, 9)
            )
            
            let order = Order(
                orderID: orderID,
                productID: productID,
                productName: productName,
                quantity: quantity,
                price: price,
                total: total,
                paymentID: paymentID,
                status: status,
                orderDate: orderDate,
                thumbnail: thumbnail
            )
            
            orders.append(order)
        }
        
        sqlite3_finalize(statement)
        
        print("📦 SQLite Orders Found: \(orders.count)")
        
        return orders
    }
}
