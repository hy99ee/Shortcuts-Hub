import Foundation

enum LandmarkMutation: Mutation {
  case ToggleFavorite(Int)
  case SetParkDescription(Int, String)
}
