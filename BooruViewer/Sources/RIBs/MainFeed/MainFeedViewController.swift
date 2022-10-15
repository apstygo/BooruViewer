import UIKit
import SwiftUI
import SDWebImageSwiftUI
import ModernRIBs
import SnapKit
import SankakuAPI

protocol MainFeedPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class MainFeedViewController: UIViewController, MainFeedViewControllable {

    // MARK: - Private Types

    private enum Section: Hashable {
        case main
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Post>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Post>

    private enum Constant {
        static let cellReuseIdentifier = "cell"
    }

    // MARK: - Internal Properties

    weak var listener: MainFeedPresentableListener?

    // MARK: - Private Properties

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
    private lazy var dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, post in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.cellReuseIdentifier, for: indexPath)

        cell.contentConfiguration = UIHostingConfiguration {
            GeometryReader { gr in
                WebImage(url: post.previewURL)
                    .resizable()
                    .scaledToFill()
                    .frame(width: gr.size.width, height: gr.size.height)
                    .clipped()
            }
            .padding(.zero)
        }
        .margins([.horizontal, .vertical], 0)

        return cell
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = UIView()
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    // MARK: - Private Methods

    private func configureUI() {
        collectionView.dataSource = dataSource

        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Constant.cellReuseIdentifier)
    }

    private func makeLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout(section: .grid(size: 2))
    }

}

extension MainFeedViewController: MainFeedPresentable {

    func presentPosts(_ posts: [Post]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(posts)

        dataSource.apply(snapshot)
    }

}

extension NSCollectionLayoutSection {

    fileprivate static func grid(size: Int) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1 / CGFloat(size)),
            heightDimension: .fractionalHeight(1)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(1 / CGFloat(size))
        )

        let group: NSCollectionLayoutGroup = .horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: size
        )

        return NSCollectionLayoutSection(group: group)
    }

}
