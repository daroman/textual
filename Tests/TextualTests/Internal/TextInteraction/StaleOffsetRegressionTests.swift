#if TEXTUAL_ENABLE_TEXT_SELECTION && !targetEnvironment(macCatalyst)
  import SwiftUI
  import Testing

  @testable import Textual

  // A shipping iOS app (Textual 0.5.0) crashed while the user dragged a selection handle:
  //
  //   TextLayoutCollection.localCharacterRange(at:)   <- Index out of range
  //   TextLayoutCollection.characterIndex(at:)
  //   TextSelectionModel.offset(from:to:)
  //   @objc UITextInteractionView.offset(from:to:)
  //
  // UIKit asked for the distance to a position it had kept from an earlier layout. The layout
  // was still there but had fewer lines, runs or slices, so only the nested index was stale.
  struct StaleOffsetRegressionTests {
    @Test(arguments: [
      IndexPath(layout: 99), IndexPath(line: 99, layout: 0), IndexPath(run: 99, line: 0, layout: 0),
      IndexPath(runSlice: 99, run: 0, line: 0, layout: 0),
    ])
    func offsetInvolvingAStalePositionIsZero(indexPath: IndexPath) throws {
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let valid = model.endPosition
      let stale = TextPosition(indexPath: indexPath, affinity: .upstream)

      #expect(model.offset(from: valid, to: stale) == 0)
      #expect(model.offset(from: stale, to: valid) == 0)
      #expect(model.position(from: stale, offset: 1) == nil)
    }

    @Test
    func offsetAcrossAnEmptyDocumentIsZero() {
      // `startPosition` names layout 0 even when there is none.
      let model = TextSelectionModel(layoutCollection: EmptyTextLayoutCollection())

      #expect(model.offset(from: model.startPosition, to: model.endPosition) == 0)
    }

    @Test
    func offsetBetweenValidPositionsIsUnchanged() throws {
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")

      #expect(model.offset(from: model.startPosition, to: model.endPosition) > 0)
    }
  }
#endif
