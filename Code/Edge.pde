private static class Edge {
  public final int from, to, generator;
  
  public Edge(int cFrom, int cTo) {
    this(cFrom, cTo, 0);
  }
  
  public Edge(int cFrom, int cTo, int cGenerator) {
    // Mathematically, the order of "from" and "to" does not matter, so from a code standpoint, it is better to always store them so that "to" is larger than or equal to "from". For instance, the method below is a bit shorter because of this.
    if(cFrom <= cTo) {
      from = cFrom;
      to = cTo;
    } else {
      from = cTo;
      to = cFrom;
    }
    
    generator = cGenerator;
  }
  
  // This method helps keep some code in the "Graph" class a bit cleaner.
  public static boolean isValidEdge(int mFrom, int mTo, int upperLimit) {
    return 0 <= mFrom && mFrom <= mTo && mTo < upperLimit;
  }
}
