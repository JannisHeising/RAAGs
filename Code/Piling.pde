private class Piling {
  public final Word[] p;
  
  public Piling(Word w, Graph g) {
    int size = g.vertices.size();
    p = new Word[size];
    
    for(int i = 0; i < size; i++) {
      p[i] = new Word();
    }
    
    try {
      for(int i = 0; i < w.size(); i++) {
        int z = w.get(i);
        int a = abs(z);
        
        if(a <= 0 || a > size) {
          throw new ArithmeticException();
        }
        
        boolean cancel = (p[a - 1].size() > 0 && p[a - 1].getLastLetter() == -sgn(z));
        
        for(int k = 0; k < size; k++) {
          if(k == a - 1) {
            
            p[k] = p[k].multRight(sgn(z));
            
          } else if(!g.hasEdge(k, a - 1)) {
            
            p[k] = p[k].multRight(2 * (cancel ? -1 : 1));
            
          }
        }
      }
    } catch(ArithmeticException ex) {
      println("WARNING: invalid word given");
    }
  }
  
  public boolean isTrivial() {
    for(int i = 0; i < p.length; i++) {
      if(p[i].size() > 0) {
        return false;
      }
    }
    
    return true;
  }
}
