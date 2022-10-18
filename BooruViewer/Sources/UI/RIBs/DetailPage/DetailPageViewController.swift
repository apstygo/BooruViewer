import UIKit
import SwiftUI
import ModernRIBs
import SDWebImageSwiftUI
import SankakuAPI

protocol DetailPagePresentableListener: AnyObject {
    func didScrollToRelatedPost(at index: Int)
    func willAppear()
    func didTapOnPost(_ post: Post)
    func didTapOnTag(_ tag: Tag)
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
    private var previewedPosts: [ObjectIdentifier: Post] = [:]
    private let customTransitioningDelegate = StackTransitioningDelegate()

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        listener?.willAppear()
    }

    // MARK: - ViewControllable

    func navigate(to viewController: ViewControllable) {
        guard let navigationController else {
            assertionFailure("Can't push without a stack")
            return
        }

        navigationController.pushViewController(viewController.uiviewController, animated: true)
    }

    func pop(_ viewController: ViewControllable) {
        guard let navigationController else {
            assertionFailure("Can't pop without a stack")
            return
        }

        guard !viewController.uiviewController.isMovingFromParent else {
            return
        }

        guard navigationController.viewControllers.last == viewController.uiviewController else {
            assertionFailure("The provided view controller is not at the top of the stack")
            return
        }

        navigationController.popViewController(animated: true)
    }

    // MARK: - Private Methods

    private func configureUI() {
        collectionView.dataSource = dataSource
        collectionView.delegate = self

        view.backgroundColor = .systemBackground
    }

    private func presentViewModel() {
        guard let viewModel, isViewLoaded else {
            return
        }

        dataSource.apply(viewModel.snapshot)
    }

    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            switch self?.section(atIndex: sectionIndex) {
            case .images:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(300)
                )

                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group: NSCollectionLayoutGroup = .horizontal(layoutSize: itemSize, subitems: [item])
                return NSCollectionLayoutSection(group: group)

            case .tags:
                let section: NSCollectionLayoutSection = .flow()
                section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 16, trailing: 16)
                return section

            case .relatedPosts:
                return .grid(size: 2)

            case nil:
                return nil
            }
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

        typealias TagRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Tag>
        let tagRegistration = TagRegistration { [weak listener] cell, indexPath, tag in
            cell.contentConfiguration = UIHostingConfiguration {
                TagView(tag: tag)
                    .onTapGesture {
                        listener?.didTapOnTag(tag)
                    }
            }
            .margins([.horizontal, .vertical], 0)
        }

        typealias RelatedPostRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Post>
        let relatedPostRegistration = RelatedPostRegistration { [weak listener] cell, indexPath, post in
            cell.contentConfiguration = UIHostingConfiguration {
                PostPreview(post: post)
                    .onAppear {
                        listener?.didScrollToRelatedPost(at: indexPath.item)
                    }
                    .onTapGesture {
                        listener?.didTapOnPost(post)
                    }
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

            case let .tag(tag):
                return collectionView.dequeueConfiguredReusableCell(
                    using: tagRegistration,
                    for: indexPath,
                    item: tag
                )

            case let .relatedPost(post):
                return collectionView.dequeueConfiguredReusableCell(
                    using: relatedPostRegistration,
                    for: indexPath,
                    item: post
                )
            }
        }
    }

    private func section(atIndex index: Int) -> DetailPageSection? {
        guard
            let sections = viewModel?.snapshot.sectionIdentifiers,
            sections.indices.contains(index)
        else {
            return nil
        }

        return sections[index]
    }

}

// MARK: - UICollectionViewDelegate

extension DetailPageViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
                        point: CGPoint) -> UIContextMenuConfiguration? {
        guard
            indexPaths.count == 1,
            let item = dataSource.itemIdentifier(for: indexPaths[0]),
            case let .relatedPost(post) = item
        else {
            return nil
        }

        let configuration = UIContextMenuConfiguration {
            let preview = ContextMenuPostPreview(post: post)
            let hostingController = UIHostingController(rootView: preview)
            hostingController.sizingOptions = .preferredContentSize
            return hostingController
        }

        previewedPosts[ObjectIdentifier(configuration)] = post

        return configuration
    }

    func collectionView(_ collectionView: UICollectionView,
                        willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                        animator: UIContextMenuInteractionCommitAnimating) {
        guard let post = previewedPosts[ObjectIdentifier(configuration)] else {
            return
        }

        animator.addCompletion { [weak listener] in
            listener?.didTapOnPost(post)
        }
    }

}
