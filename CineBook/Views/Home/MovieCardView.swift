import CoreData
import SwiftUI

struct MovieCardView: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                if let name = movie.posterImageName, UIImage(named: name) != nil {
                    Image(name)
                        .resizable()
                        .aspectRatio(2/3, contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(2/3, contentMode: .fit)
                        .overlay(
                            Text("POSTER")
                                .foregroundColor(.gray)
                                .font(.caption)
                        )
                }
            }
            .cornerRadius(12)
            .clipped()

            Text(movie.title ?? "")
                .font(.headline)
                .lineLimit(1)

            Text(movie.genre ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
