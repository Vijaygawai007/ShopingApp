import UIKit
import Alamofire
import Kingfisher

class CartViewController: UIViewController {

    @IBOutlet weak var cartTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        cartTable.delegate = self
        cartTable.dataSource = self

        cartTable.showsVerticalScrollIndicator = false
        cartTable.showsHorizontalScrollIndicator = false

    }

}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension CartViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        return 10
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CartTableViewCell",
            for: indexPath
        ) as! CartTableViewCell

        cell.selectionStyle = .none

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        return 230
    }
}
