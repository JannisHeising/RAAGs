private class Graph {
  public final ArrayList<ArrayList<Edge>> edges;
  public final ArrayList<Vertex> vertices;
  public float avgSpeed = 0; // Information for rendering
  
  public Graph(int cSize, ArrayList<Edge> cEdges) {
    vertices = new ArrayList<Vertex>();
    
    edges = new ArrayList<ArrayList<Edge>>();
    
    for(int i = 0; i < cSize; i++) {
      vertices.add(new Vertex(null, -1));
      
      edges.add(new ArrayList<Edge>());
    }
    
    if(cEdges != null) {
      for(Edge e : cEdges) {
        addEdge(e);
      }
    }
  }
  
  public boolean hasEdge(Edge e) {
    return hasEdge(e.from, e.to);
  }
  
  public boolean hasEdge(int v, int w) {
    return getEdge(v, w) != null;
  }
  
  public Edge getEdge(int v, int w) {
    if(v > w) return getEdge(w, v);
    if(!Edge.isValidEdge(v, w, edges.size())) return null;
    
    ArrayList<Edge> copy = (ArrayList<Edge>)edges.get(v).clone();
    for(Edge e : copy) {
      try {
        if(w == e.to) return e;
      } catch(NullPointerException ex) {
        // Because the Cayley graph is generated in a thread, it sometimes happens that
        // "e.to" throws an exception here. This is nothing to worry about.
      }
    }
    
    return null;
  }
  
  public ArrayList<Vertex> getVertices() {
    return (ArrayList<Vertex>)vertices.clone();
  }
  
  public ArrayList<Edge> getEdges() {
    ArrayList<Edge> out = new ArrayList<Edge>();
    
    for(int i = 0; i < edges.size(); i++) {
      ArrayList<Edge> al = edges.get(i);
      
      for(int k = 0; k < al.size(); k++) {
        out.add(al.get(k));
      }
    }
    
    return out;
  }
  
  public void addVertex(Vertex v) {
    vertices.add(v);
    
    edges.add(new ArrayList<Edge>());
  }
  
  public void addEdge(int v, int w, int label) {
    addEdge(new Edge(v, w, label));
  }
  
  public void addEdge(Edge e) {
    if(this.hasEdge(e)) return;
    
    if(!Edge.isValidEdge(e.from, e.to, edges.size())) {
      println("WARNING: invalid edge given");
      
      return;
    }
    
    edges.get(e.from).add(e);
  }
  
  public void resetPosition() {
    for(Vertex v : vertices) {
      v.pos = new PVector(random(-SPAWN_SIZE, SPAWN_SIZE),
                          random(-SPAWN_SIZE, SPAWN_SIZE),
                          random(-SPAWN_SIZE, SPAWN_SIZE));
    }
  }
  
  public void adjustPos() {
    if(R < EPSILON) return;
    
    int size = vertices.size();
    PVector[] velocity = new PVector[size];
    
    for(int i = 0; i < size; i++) {
      velocity[i] = new PVector(0, 0, 0);
      
      if(vertices.get(i).dist > drawRadius && random(1) < LAG_RELIEF) continue;
      
      for(int k = 0; k < i; k++) {
        if(vertices.get(k).dist > drawRadius && random(1) < LAG_RELIEF) continue;
        
        Vertex v1 = vertices.get(i);
        Vertex v2 = vertices.get(k);
        
        PVector f = PVector.sub(v2.pos, v1.pos);
        float m = f.mag();
        
        float r;
        Edge e = getEdge(k, i);
        if(e != null) {
          r = -pow(m, orderAttract);
          
          if(shadow.hasValue(e.generator)) r *= shadowEffect;
        } else if(m >= repulsionRadius) {
          continue;
        } else {
          r = 0.002 * pow(m, orderRepel);
        }
        
        f.setMag(min(r*R, .6));
        
        velocity[k] = PVector.add(velocity[k], f);
        velocity[i] = PVector.sub(velocity[i], f);
      }
    }
    
    PVector newCamPos = new PVector(0, 0, 0);
    float newAvgSpeed = 0;
    
    for(int i = 0; i < size; i++) {
      vertices.get(i).pos.add(velocity[i]);
      
      newCamPos.add(vertices.get(i).pos);
      newAvgSpeed += velocity[i].mag();
    }
    
    newCamPos.mult(SCALE/size);
    newAvgSpeed *= SCALE/size;
    
    camPos = newCamPos;
    avgSpeed = newAvgSpeed;
  }
  
  public String toString() {
    String out = "";
    
    for(Edge e : this.getEdges()) {
      out += e.from + " " + e.to + (SAVE_WEIGHTS ? " " + PVector.sub(vertices.get(e.from).pos, vertices.get(e.to).pos).mag() : "") + "\n";
    }
    
    out = out.substring(0, out.length() - 1);
    
    return out;
  }
}
