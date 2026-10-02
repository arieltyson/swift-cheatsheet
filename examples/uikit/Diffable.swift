import UIKit

@MainActor
final class TopicsController: UIViewController {
  enum Section { case main }
  private var titles: [Int: String] = [1: "Arrays", 2: "Heaps"]
  private var dataSource: UICollectionViewDiffableDataSource<Section, Int>?
  private(set) var collectionView: UICollectionView?

  override func viewDidLoad() {
    super.viewDidLoad()
    let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
    let layout = UICollectionViewCompositionalLayout.list(using: configuration)
    let collection = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
    collection.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(collection)
    collectionView = collection
    let registration = UICollectionView.CellRegistration<UICollectionViewListCell, Int> {
      [weak self] cell, _, identifier in
      var content = cell.defaultContentConfiguration()
      content.text = self?.titles[identifier]
      cell.contentConfiguration = content
    }
    dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collection) {
      collection, indexPath, identifier in
      collection.dequeueConfiguredReusableCell(
        using: registration, for: indexPath, item: identifier
      )
    }
    var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
    snapshot.appendSections([.main])
    snapshot.appendItems([1, 2])
    dataSource?.apply(snapshot, animatingDifferences: false)
  }

  func renameTopic(id: Int, title: String) {
    guard var snapshot = dataSource?.snapshot(), snapshot.indexOfItem(id) != nil else { return }
    titles[id] = title
    snapshot.reconfigureItems([id])
    dataSource?.apply(snapshot, animatingDifferences: false)
  }
}
