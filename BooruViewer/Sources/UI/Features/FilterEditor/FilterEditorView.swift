import SwiftUI
import ComposableArchitecture
import enum SankakuAPI.SortOrder
import enum SankakuAPI.Threshold
import enum SankakuAPI.HidePostsInBooks
import enum SankakuAPI.MediaSize
import enum SankakuAPI.MediaType
import struct SankakuAPI.GetPostsFilters

struct FilterEditorView: View {

    let store: StoreOf<FilterEditorFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            FilterEditorContent(viewStore: viewStore)
        }
    }

}

private struct FilterEditorContent: View {

    // MARK: - Internal Properties

    @ObservedObject var viewStore: ViewStoreOf<FilterEditorFeature>

    var applyButtonPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .navigationBarTrailing
        #else
        .automatic
        #endif
    }

    // MARK: - Layout

    var body: some View {
        NavigationStack {
            form
                .navigationTitle("Filters")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: applyButtonPlacement) {
                        Button("Apply") {
                            viewStore.send(.apply)
                        }
                        .disabled(!viewStore.isApplyButtonActive)
                    }
                }
        }
    }

    @ViewBuilder
    var form: some View {
        Form {
            Section("Rating") {
                Toggle("G", isOn: filtersBinding.gRatingIncluded)
                Toggle("R15+", isOn: filtersBinding.r15RatingIncluded)
                Toggle("R18+", isOn: filtersBinding.r18RatingIncluded)
            }

            Picker("Order by", selection: filtersBinding.sortOrder) {
                ForEach(Array(SortOrder.allCases), id: \.rawValue) { order in
                    Text(order.rawValue).tag(order)
                }
            }

            Picker("Threshold", selection: filtersBinding.threshold) {
                ForEach(Array(Threshold.allCases), id: \.rawValue) { variant in
                    Text("\(variant.rawValue)").tag(variant)
                }
            }

            Picker("Hide posts in books", selection: filtersBinding.hidePostsInBooks) {
                ForEach(Array(HidePostsInBooks.allCases), id: \.rawValue) { variant in
                    Text(variant.rawValue).tag(variant)
                }
            }

            Picker("Size", selection: filtersBinding.mediaSize) {
                ForEach(Array(MediaSize.allCases), id: \.rawValue) { variant in
                    Text(variant.rawValue).tag(variant)
                }
            }

            Picker("File type", selection: filtersBinding.mediaType) {
                ForEach(Array(MediaType.allCases), id: \.rawValue) { variant in
                    Text(variant.rawValue).tag(variant)
                }
            }

//            DatePicker("Date", selection: filtersBinding.date, displayedComponents: [.date])
        }
    }

    // MARK: - Bindings

    var filtersBinding: Binding<GetPostsFilters> {
        viewStore.binding { state in
            state.filters
        } send: { newValue in
            .setFilters(newValue)
        }
    }

}

// MARK: - Previews

struct FilterEditorView_Previews: PreviewProvider {

    static var previews: some View {
        FilterEditorView(
            store: Store(
                initialState: FilterEditorFeature.State(filters: .init()),
                reducer: FilterEditorFeature()
            )
        )
    }

}
