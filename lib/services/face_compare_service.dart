import 'dart:math';

class FaceCompareService {
  /// Cosine Similarity
  double cosineSimilarity(List<double> embedding1, List<double> embedding2) {
    if (embedding1.length != embedding2.length) {
      throw Exception("Embedding size mismatch.");
    }

    double dotProduct = 0;
    double normA = 0;
    double normB = 0;

    for (int i = 0; i < embedding1.length; i++) {
      dotProduct += embedding1[i] * embedding2[i];

      normA += embedding1[i] * embedding1[i];

      normB += embedding2[i] * embedding2[i];
    }

    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  bool isSamePerson(
    List<double> registeredEmbedding,
    List<double> currentEmbedding,
  ) {
    final similarity = cosineSimilarity(registeredEmbedding, currentEmbedding);

    print("Similarity : $similarity");

    return similarity >= 0.75;
  }
}
