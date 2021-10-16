private class Vertex {
  public PVector pos;      // position coordinates (for rendering)
  public final Word word;  // the word this vertex represents ("null" if not applicable)
  public final int dist;   // distance to the neutral element ("-1" if not applicable)
  
  public Vertex(Word w, int d) {
    this(0, 0, 0, w, d);
  }
  
  public Vertex(float x, float y, float z, Word w, int d) {
    pos = new PVector(x, y, z);
    word = w;
    dist = d;
  }
}
