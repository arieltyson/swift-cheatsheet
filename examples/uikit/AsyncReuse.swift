import UIKit

final class ThumbnailCell: UITableViewCell {
  private var representedID: Int?
  private var loadTask: Task<Void, Never>?
  private var generation = UUID()

  func configure(
    id: Int,
    loadImage: @escaping @MainActor () async throws -> UIImage
  ) {
    cancelLoad()
    representedID = id
    let requestGeneration = generation
    var content = defaultContentConfiguration()
    content.text = "Item \(id)"
    content.image = UIImage(systemName: "photo")
    contentConfiguration = content
    loadTask = Task { [weak self] in
      do {
        let image = try await loadImage()
        try Task.checkCancellation()
        guard let self,
          self.representedID == id,
          self.generation == requestGeneration
        else { return }
        var updated = self.defaultContentConfiguration()
        updated.text = "Item \(id)"
        updated.image = image
        self.contentConfiguration = updated
      } catch {
        return
      }
    }
  }

  func cancelLoad() {
    loadTask?.cancel()
    loadTask = nil
    generation = UUID()
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    cancelLoad()
    representedID = nil
    contentConfiguration = nil
  }

  deinit { loadTask?.cancel() }
}
