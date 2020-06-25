class PokeResult {
  String label;
  double confidence;

  PokeResult({
    this.label,
    this.confidence,
  });

  factory PokeResult.fromMap(Map data){
    return PokeResult(
      label: data['label'],
      confidence: data['confidence'],
    );
  }
}