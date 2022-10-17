import UIKit
import SwiftUI
import ModernRIBs
import SDWebImageSwiftUI

protocol DetailPagePresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class DetailPageViewController: UIViewController, DetailPagePresentable, DetailPageViewControllable {

    // MARK: - Private Types

    private typealias DataSource = UICollectionViewDiffableDataSource<DetailPageSection, DetailPageItem>

    // MARK: - Internal Properties

    weak var listener: DetailPagePresentableListener?

    var viewModel: DetailPageViewModel? {
        didSet {
            guard viewModel != oldValue else {
                return
            }

            presentViewModel()
        }
    }

    // MARK: - Private Properties

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
    private lazy var dataSource: DataSource = makeDataSource()

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
        presentViewModel()
    }

    // MARK: - Private Methods

    private func configureUI() {
        collectionView.dataSource = dataSource

        view.backgroundColor = .systemBackground
    }

    private func presentViewModel() {
        guard let viewModel, isViewLoaded else {
            return
        }

        dataSource.apply(viewModel.snapshot)
    }

    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(300)
            )

            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group: NSCollectionLayoutGroup = .horizontal(layoutSize: itemSize, subitems: [item])
            return NSCollectionLayoutSection(group: group)
        }
    }

    private func makeDataSource() -> DataSource {
        typealias ImageRegistration = UICollectionView.CellRegistration<UICollectionViewCell, DetailPageItem.Image>
        let imageRegistration = ImageRegistration { cell, indexPath, viewModel in
            cell.contentConfiguration = UIHostingConfiguration {
                WebImage(url: viewModel.sampleURL, options: .highPriority)
                    .placeholder {
                        WebImage(url: viewModel.previewURL, options: .highPriority)
                            .resizable()
                            .scaledToFit()
                    }
                    .resizable()
                    .scaledToFit()
            }
            .margins([.horizontal, .vertical], 0)
        }

        return DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case let .image(viewModel):
                return collectionView.dequeueConfiguredReusableCell(
                    using: imageRegistration,
                    for: indexPath,
                    item: viewModel
                )
            }
        }
    }

}

// MARK: - Helpers

extension UIColor {

    fileprivate static var random: UIColor {
        let range: Range<CGFloat> = 0..<1

        return UIColor(
            red: .random(in: range),
            green: .random(in: range),
            blue: .random(in: range),
            alpha: 1
        )
    }

}
