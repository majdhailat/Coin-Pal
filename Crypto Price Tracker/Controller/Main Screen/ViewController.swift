import UIKit
import Charts
/*
 View controller for the main screen
    - Manges the pie chart
        - Handles the look of the pie chart
        - Gets pie chart data from the coin handler
    - Manges the total balance label
        - Handles the look of the balance labael
        - Gets the balabce from the coin handler
    - Contains the refresh methods for the view
 */
class ViewController: UIViewController, CoinHandlerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pieChart: PieChartView!
    
    let coinHandler: CoinHandler = CoinHandler()
    private let myRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector (backgroundNofification), name: UIApplication.willEnterForegroundNotification, object: nil);
        //put all code of your viewDidLoad to refresh
        initPieChart()//initializing the pie chart view
        coinHandler.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        myRefreshControl.addTarget(self, action: #selector (ViewController.handleRefresh), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        super.viewDidLoad()
    }
    
    @objc func backgroundNofification(noftification:NSNotification){
        coinHandler.canUpdateCoinDataTimerComplete()
        handleRefresh()
    }
    /*
     Refreshes the view when the user switches between light/dark mode on their device
     */
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        handleRefreshNow()
    }
    
    /*
     Gets the total balance and the total balance in BTC from the coin handler
     Formats the balance properly (with commas and proper decimal places)
     Sets the pie chart centre text to the balance
     */
    func refreshTotalBalanceText(){
        let balanceLabel: NSMutableAttributedString = NSMutableAttributedString()
        let totalBalance: Double = coinHandler.getTotalBalanceValue(rateAgainstUSD: coinHandler.selectedExchangeRateAgainstUSD)//getting total balance
        let totalBalanceInBTC: Double = coinHandler.getTotalBalanceValueInBTC()//getting balance in BTC
        if (totalBalance != 0){
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            var balanceString = "\(String(format: "%.2f", totalBalance))"//formatting balance
            balanceString = "$\(numberFormatter.string(from: NSNumber(value: Double(balanceString)!)) ?? "0.00")"//formatting balance
            let totalBalanceInBTCString = "\(String(format: "%.5f", totalBalanceInBTC)) BTC"//formatting btc balance
            let totalBalanceAttributedString = NSAttributedString(string: balanceString, attributes: balanceAttributes)
            let totalBalanceInBTCAttributedString = NSAttributedString(string: totalBalanceInBTCString, attributes: balanceInBTCAttributes)
            balanceLabel.append(totalBalanceAttributedString)
            balanceLabel.append(NSAttributedString(string: "\n"))
            balanceLabel.append(totalBalanceInBTCAttributedString)
        }else{
            let noBalanceAttributedString = NSAttributedString(string: "No Balance", attributes: balanceAttributes)
            balanceLabel.append(noBalanceAttributedString)
        }
        pieChart.centerAttributedText = balanceLabel//setting balance
    }
    
    /*
     Takes and sets the pie chart data
     */
    func setPieChartData(data: PieChartData) {
        pieChart.data = data
    }
    
    var balanceAttributes: [NSAttributedString.Key: Any]!
    var balanceInBTCAttributes: [NSAttributedString.Key: Any]!
    /*
     Initializes the attributes for the pie chart
     Initializes the attributes of the centre pie chart text (balance text)
     */
    func initPieChart(){
        pieChart.rotationEnabled = false
        pieChart.legend.enabled = false
        pieChart.chartDescription?.text = ""
        pieChart.noDataText = "Connecting to the interwebs"
        pieChart.holeRadiusPercent = 0.9
        pieChart.holeColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)

        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        balanceAttributes = [
            .font: UIFont.systemFont(ofSize: 28),
            .foregroundColor: UIColor(named: "labelColor") ?? UIColor.label,
            .paragraphStyle : paragraphStyle
        ]
        balanceInBTCAttributes = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor(named: "labelColor") ?? UIColor.label,
            .paragraphStyle : paragraphStyle
        ]
    }
    
    /*
     Called whenever a new view controller is about to come up
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToPortfolio"){
            if let sender: LoadedCoinTableViewCell = sender as? LoadedCoinTableViewCell{
                let destinationVC = segue.destination as! PortfolioViewController
                destinationVC.coinHandler = coinHandler
                let coindID: String = coinHandler.loadedCoins[sender.tag].id
                destinationVC.coinID = coindID//initializing the id of the coin for the portoflio page
            }
        }
        else if (segue.identifier == "goToEditCoins"){
            let destinationVC = segue.destination as! EditCoinsViewController
            destinationVC.coinHandler = coinHandler
        }
        else if (segue.identifier == "goToSettings"){
            let destinationVC = segue.destination as! SettingsViewController
            destinationVC.coinHandler = coinHandler
        }
   }
    
    /*
     Called when the user pulls down on the view
     Refeshes the coin data of each table view cell and balance label
     */
    @objc func handleRefresh(){
        coinHandler.updateCoinData()//updating data
        if (!coinHandler.didUpdateAddressBalance){
            coinHandler.updateAddressBalances()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {//waiting for 3 seconds
            self.refreshTotalBalanceText()
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
        }
    }
    
    /*
     Refreshes the view without the 3 second delay
     */
    func handleRefreshNow(){
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.refreshTotalBalanceText()
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
        }
    }
}
