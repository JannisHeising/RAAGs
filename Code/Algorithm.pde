private abstract class Algorithm<T> extends Thread {
  private final Graph g;
  protected final int nGens;
  protected final T triv;
  
  public Algorithm(int n, T cTriv) {
    g = new Graph(0, null);
    nGens = n;
    triv = cTriv;
    
    this.start();
  }
  
  public Graph getGraph() {
    return g;
  }
  
  public void run() {
    g.addVertex(new Vertex(new Word(), 0));
    
    for(int i = 0; i < g.vertices.size(); i++) {
      Vertex v = g.vertices.get(i);
      
      if(v.dist >= MAX_RADIUS) break;
      
      for(int z = -nGens; z <= nGens; z++) {
        if(z == 0) continue;
        
        Word next = v.word.multRight(z);
        
        int connected = -1;
        for(int k = 0; k < g.vertices.size(); k++) {
          if(this.isTrivial(next.multRight(g.vertices.get(k).word.invert()))) {
            connected = k;
            break;
          }
        }
        
        if(connected == -1) {
          // New element
          g.addVertex(new Vertex(random(-SPAWN_SIZE,SPAWN_SIZE),
                                 random(-SPAWN_SIZE,SPAWN_SIZE),
                                 random(-SPAWN_SIZE,SPAWN_SIZE), next, v.dist + 1));
          
          g.addEdge(i, g.vertices.size() - 1, abs(z));
        } else {
          // New edge to old element
          g.addEdge(i, connected, abs(z));
        }
      }
    }
  }
  
  protected abstract boolean isTrivial(Word w);
}
