import SwiftUI
import enum SankakuAPI.SortOrder
import enum SankakuAPI.Threshold
import enum SankakuAPI.HidePostsInBooks
import enum SankakuAPI.MediaSize
import enum SankakuAPI.MediaType
import struct SankakuAPI.GetPostsFilters

struct FilterEditorView: View {

    @ObservedObject var viewModel: FilterEditorViewModel

    var body: some View {
        NavigationStack {
            form
                .navigationTitle("Filters")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Apply") {
                            viewModel.onApply()
                        }
                    }
                }
        }
    }

    @ViewBuilder
    var form: some View {
        Form {
            Section("Rating") {
                Toggle("G", isOn: $viewModel.filters.gRatingIncluded)
                Toggle("R15+", isOn: $viewModel.filters.r15RatingIncluded)
                Toggle("R18+", isOn: $viewModel.filters.r18RatingIncluded)
            }

            Picker("Order by", selection: $viewModel.filters.sortOrder) {
                ForEach(Array(SortOrder.allCases), id: \.rawValue) { order in
                    Text(order.rawValue).tag(order)
                }
            }

            Picker("Threshold", selection: $viewModel.filters.threshold) {
                ForEach(Array(Threshold.allCases), id: \.rawValue) { variant in
                    Text("\(variant.rawValue)").tag(variant)
                }
            }

            Picker("Hide posts in books", selection: $viewModel.filters.hidePostsInBooks) {
                ForEach(Array(HidePostsInBooks.allCases), id: \.rawValue) { variant in
                    Text(variant.rawValue).tag(variant)
                }
            }

            Picker("Size", selection: $viewModel.filters.mediaSize) {
                ForEach(Array(MediaSize.allCases), id: \.rawValue) { variant in
                    Text(variant.rawValue).tag(variant)
                }
            }

            Picker("File type", selection: $viewModel.filters.mediaType) {
                ForEach(Array(MediaType.allCases), id: \.rawValue) { variant in
                    Text(variant.rawValue).tag(variant)
                }
            }

//            DatePicker("Date", selection: $viewModel.filters.date, displayedComponents: [.date])
        }
    }

}

struct FilterEditorView_Previews: PreviewProvider {

    static var previews: some View {
        FilterEditorView(viewModel: .init(onApplyHandler: { }))
    }

}
