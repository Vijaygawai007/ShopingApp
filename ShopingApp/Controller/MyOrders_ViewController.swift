import UIKit

class MyOrders_ViewController: UIViewController {
    
    @IBOutlet weak var my_Orders: UITableView!
    
    var orders: [Order] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        my_Orders.delegate = self
        my_Orders.dataSource = self
        my_Orders.rowHeight = 100
        my_Orders.showsVerticalScrollIndicator = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadOrders()
    }
    
    // MARK: - Fetch From SQLite
    
    private func loadOrders() {
        
        orders = OrderSQLiteManager.shared.fetchOrders()
        
        print("================================")
        print("📦 MY ORDERS")
        print("Orders: \(orders.count)")
        print("================================")
        
        my_Orders.reloadData()
    }
}

extension MyOrders_ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyOrderTableViewCell",  for: indexPath
        ) as? MyOrderTableViewCell else {
            return UITableViewCell()
        }
        let order = orders[indexPath.row]
        cell.configure(with: order)
        cell.selectionStyle = .none
        return cell
    }
}

extension MyOrders_ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {tableView.deselectRow(at: indexPath,animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        240
    }
}
