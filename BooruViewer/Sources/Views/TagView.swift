import SwiftUI
import SankakuAPI

struct TagView: View {

    let tag: Tag

    var body: some View {
        Text(tag.name)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(8)
    }

}

struct TagView_Previews: PreviewProvider {

    static let tagJSON = """
        [{
            "id": 34240,
            "name": "female",
            "name_en": "female",
            "name_ja": "女性",
            "type": 0,
            "count": 9170717,
            "post_count": 9170717,
            "pool_count": 97039,
            "series_count": 0,
            "tagName": "female"
          },
    {
        "id": 4537,
        "name": "nintendo",
        "name_en": "nintendo",
        "name_ja": "任天堂",
        "type": 2,
        "count": 381499,
        "post_count": 381499,
        "pool_count": 204,
        "series_count": 0,
        "tagName": "nintendo"
      },
    {
        "id": 936512,
        "name": "nintendo_switch",
        "name_en": "nintendo_switch",
        "name_ja": "ニンテンドースイッチ",
        "type": 3,
        "count": 5267,
        "post_count": 5267,
        "pool_count": 19,
        "series_count": 0,
        "tagName": "nintendo_switch"
      },
    {
        "id": 457099,
        "name": "super_sonico",
        "name_en": "super_sonico",
        "name_ja": "すーぱーそに子",
        "type": 4,
        "count": 26376,
        "post_count": 26376,
        "pool_count": 312,
        "series_count": 0,
        "tagName": "super_sonico"
      },
    {
        "id": 192913,
        "name": "hetero",
        "name_en": "hetero",
        "name_ja": "異性愛",
        "type": 5,
        "count": 805536,
        "post_count": 805536,
        "pool_count": 2362,
        "series_count": 0,
        "tagName": "hetero"
      },
        {
            "id": 253759,
            "name": "cg_art",
            "name_en": "cg_art",
            "name_ja": "ＣＧアート",
            "type": 8,
            "count": 9311422,
            "post_count": 9311422,
            "pool_count": 83918,
            "series_count": 0,
            "tagName": "cg_art"
        },
        {
            "id": 250,
            "name": "tagme",
            "name_en": "tagme",
            "name_ja": "タグ希望",
            "type": 9,
            "count": 14814445,
            "post_count": 14814445,
            "pool_count": 17,
            "series_count": 0,
            "tagName": "tagme"
        }]
    """

    static let tags: [Tag] = {
        let data = Data(tagJSON.utf8)
        return try! JSONDecoder().decode([Tag].self, from: data)
    }()

    static var previews: some View {
        VStack(spacing: 8) {
            ForEach(tags) { tag in
                TagView(tag: tag)
                    .previewLayout(.sizeThatFits)
            }
        }
    }

}
