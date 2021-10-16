private class Word extends ArrayList<Integer> {
  public Word multLeft(int i) {
    if(i == 0) throw new ArithmeticException("generator count starts at 1, instead 0 given");
    
    Word out = this.copy();
    
    if(out.size() > 0 && out.get(0) == -i) {
      out.remove(0);
    } else {
      out.add(0, i);
    }
    
    return out;
  }
  
  public Word multLeft(Word w) {
    Word out = this.copy();
    for(int i = w.size() - 1; i >= 0; i--) {
      out = out.multLeft(w.get(i));
    }
    
    return out;
  }
  
  public Word multRight(int i) {
    if(i == 0) throw new ArithmeticException("generator count starts at 1, instead 0 given");
    
    Word out = this.copy();
    
    int s = out.size();
    if(s > 0 && out.getLastLetter() == -i) {
      out.remove(s - 1);
    } else {
      out.add(s, i);
    }
    
    return out;
  }
  
  public Word multRight(Word w) {
    Word out = this.copy();
    for(int v : w) {
      out = out.multRight(v);
    }
    
    return out;
  }
  
  public Word copy() {
    return (Word)super.clone();
  }
  
  public int getLastLetter() {
    if(this.size() == 0) return 0;
    return this.get(this.size() - 1);
  }
  
  public Word invert() {
    Word out = new Word();
    
    for(int v : this) {
      out = out.multLeft(-v);
    }
    
    return out;
  }
  
  public String toString() {
    if(this.size() == 0) return "e";
    
    String out = "";
    
    for(int i : this) {
      if(i > 0) {
        out += (char)(i + 96);
      } else {
        out += "(" + (char)(-i + 96) + "^-1)";
      }
    }
    
    return out;
  }
}
