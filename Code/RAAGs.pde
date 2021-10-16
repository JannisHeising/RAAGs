private Graph g;

private float zoom = -1000, r, s;
private PVector camPos;

// Non-final variables in all-caps can be modified with the settings file and may thus not be be declared "final", although they are to be treated as such
private boolean autoRotate = false;
private boolean showInterface = true;
private boolean showArrow = false;
private boolean holdingCtrl = false;
private boolean onlyDrawSphere = false;
private boolean stopThreads = false;
private boolean SAVE_WEIGHTS = false;

private final float SPAWN_SIZE = 1;
private final float SCALE = 200;
private int MAX_RADIUS = 5;
private final float PHYSICS_FRAMERATE_CAP = 100;
private float LAG_RELIEF = 0; // Probability that an unrendered vertex doesn't get computed

private int drawRadius; // Radius of the ball around the neutral element
private float physicsFramerate = 0;

// Initial slider values
private float R = .05;
private int orderAttract = 1;
private int orderRepel = -2;
private float repulsionRadius = 1;
private float shadowEffect = .01;

private Slider selectedSlider;
private ArrayList<Slider> sliders;

private IntList shadow;

void setup() {
  size(900, 600, P3D);
  surface.setResizable(true);
  frameRate(40);
  textSize(12);
  textAlign(LEFT, TOP);
  
  camPos = new PVector();
  
  String fileName = "Graph.json";
  try {
    // Load settings from "settings.json"
    JSONObject settings = loadJSONObject("settings.json");
    
    fileName = settings.getString("filename");
    MAX_RADIUS = settings.getInt("max_radius");
    LAG_RELIEF = settings.getFloat("lag_relief");
    SAVE_WEIGHTS = settings.getBoolean("save_weights");
  } catch(Exception ex) {
    // Save standard settings, defined above
    println("WARNING: Could not read \"settings.json\".");
    JSONObject settings = new JSONObject();
    
    settings.setString("filename", fileName);
    settings.setInt("max_radius", MAX_RADIUS);
    settings.setFloat("lag_relief", LAG_RELIEF);
    settings.setBoolean("save_weights", SAVE_WEIGHTS);

    saveJSONObject(settings, "settings.json");
  }
  
  drawRadius = MAX_RADIUS;
  
  int size;
  ArrayList<Edge> edges = new ArrayList<Edge>();
  
  try {
    // Load graph from file, "Graph.json" by default
    JSONObject jsonGraph = loadJSONObject(fileName);
    
    size = jsonGraph.getInt("#generators");
    
    JSONArray jsonEdges = jsonGraph.getJSONArray("edges");
    
    for(int i = 0; i < jsonEdges.size(); i++) {
      edges.add(new Edge(jsonEdges.getJSONObject(i).getInt("from") - 1, jsonEdges.getJSONObject(i).getInt("to") - 1));
    }
  } catch(NullPointerException ex) {
    // Resort to one vertex and no edges
    println("WARNING: Could not read \"" + fileName + "\".");
    size = 1;
  }
  
  // Algorithm for solving the word problem in RAAGs. Most of the work is done in the "Piling" class
  Algorithm raag = new Algorithm<Graph>(size, new Graph(size, edges)) {
    protected boolean isTrivial(Word w) {
      return new Piling(w, triv).isTrivial();
    }
  };
  
  g = raag.getGraph();
  
  // Sample algorithm for another class of groups: (Z/mZ)^n with input (n, m)
  // Remember to set the max. radius large enough (n*m/2) in the settings file.
  //Algorithm z_nm = new Algorithm<Integer>(2, 20) {
  //  protected boolean isTrivial(Word w) {
  //    int[] count = new int[nGens];
      
  //    for(int i : w) {
  //      if(i > 0) {
  //        count[i - 1]++;
  //      } else {
  //        count[-i - 1]--;
  //      }
  //    }
      
  //    for(int i : count) {
  //      if(i%triv != 0) {
  //        return false;
  //      }
  //    }
      
  //    return true;
  //  }
  //};
  
  //g = z_nm.getGraph();
  
  // Slider initialization, nothing interesting
  selectedSlider = null;
  sliders = new ArrayList<Slider>();
  sliders.add(new Slider(0, .5, false, "Step size") {
    protected void init() {
      setValue(R);
    }
    
    public void affect() {
      R = value;
    }
  }
  );
  sliders.add(new Slider(0, 4, true, "Attraction exponent") {
    protected void init() {
      setValue(orderAttract);
    }
    
    public void affect() {
      orderAttract = int(value + .01);
    }
  }
  );
  sliders.add(new Slider(-4, 0, true, "Repulsion exponent") {
    protected void init() {
      setValue(orderRepel);
    }
    
    public void affect() {
      orderRepel = int(value + .01);
    }
  }
  );
  sliders.add(new Slider(-5, 5, false, "log(Repulsion radius)") {
    protected void init() {
      setValue(log(repulsionRadius));
    }
    
    public void affect() {
      repulsionRadius = exp(value);
    }
  }
  );
  sliders.add(new Slider(0, .05, false, "Shadow effect") {
    protected void init() {
      setValue(shadowEffect);
    }
    
    public void affect() {
      shadowEffect = value;
    }
  }
  );
  
  shadow = new IntList();
  
  // Start the physics
  new Thread() {
    public void run() {
      int m = millis();

      while(!stopThreads) {
        while(millis() - m < 1000/PHYSICS_FRAMERATE_CAP) delay(1);
        physicsFramerate = 1000./(millis() - m);
        m = millis();

        g.adjustPos();
      }
    }
  }.start();
}

void draw() {
  if(mousePressed) {
    if(selectedSlider == null) {
      // Rotate the graph by dragging it around
      r += .005 * (mouseX - pmouseX);
      s -= .005 * (mouseY - pmouseY);
      s = max(-PI/2, min(PI/2, s));
    } else {
      // Adjust a slider
      float xAdj = min(max(mouseX - selectedSlider.pos.x, 0), selectedSlider.w);
      float v = map(xAdj, 0, selectedSlider.w, selectedSlider.min, selectedSlider.max);
      
      selectedSlider.setValue(v);
    }
  }
  
  if (autoRotate) {
    r += .003;
  }
  
  background(#000000);
  
  pushMatrix();
  translate(width/2, height/2, zoom);
  rotateX(s);
  rotateY(r);
  
  translate(-camPos.x, -camPos.y, -camPos.z);
  
  if(showArrow) {
    fill(#BBBBBB);
    drawArrow(0, 750, 0, 60, 20, 120);
  }
  
  ArrayList<Edge> edges = g.getEdges();
  for(Edge e : edges) {
    Vertex from = g.vertices.get(e.from);
    Vertex to = g.vertices.get(e.to);
    
    if (onlyDrawSphere) {
      if(to.dist != drawRadius) continue;
    } else {
      if(to.dist > drawRadius) continue;
    }
    
    if(onlyDrawSphere) {
      stroke(#ffffff, 70);
    } else if(shadow.hasValue(e.generator)) {
      stroke(#ffffff, 80);
    } else {
      stroke(#ffffff, 200);
    }
    
    line(from.pos.x * SCALE, from.pos.y * SCALE, from.pos.z * SCALE, to.pos.x * SCALE, to.pos.y * SCALE, to.pos.z * SCALE);
  }

  if(onlyDrawSphere) {
    ArrayList<Vertex> vertices = g.getVertices();

    noStroke();
    fill(#ffffff, 200);
    for(Vertex v : vertices) {
      if(v.dist != drawRadius) continue;
      pushMatrix();
      translate(v.pos.x * SCALE, v.pos.y * SCALE, v.pos.z * SCALE);
      sphere(4);
      popMatrix();
    }
  }
  popMatrix();

  if(showInterface) {
    textAlign(LEFT, TOP);
    fill(#ffffff);
    text("Framerate render/physics: " + int(frameRate) + ", " + int(physicsFramerate), 0, 0);
    text("#vertices: " + g.vertices.size() + ", #edges: " + edges.size(), 0, 15);
    text("Radius: " + drawRadius, 0, 30);
    text("Avg Speed: " + (int(g.avgSpeed * 100) / 100.), 0, 45);

    if(shadow.size() > 0) {
      String str = shadow.get(0) + "";

      for(int i = 1; i < shadow.size(); i++) {
        str += ", " + shadow.get(i);
      }

      text("Shadowed: " + str, 0, 60);
    }


    for(int i = 0; i < sliders.size(); i++) {
      sliders.get(i).draw(width - sliders.get(i).w - 20, 10 + 30*i);
    }
  }
}

void mousePressed() {
  if(mouseButton == LEFT) {
    for(Slider s : sliders) {
      if((s.pos.x <= mouseX && mouseX <= s.pos.x + s.w) && (s.pos.y <= mouseY && mouseY <= s.pos.y + s.h)) {
        selectedSlider = s;
        break;
      }
    }
  }
}

void mouseReleased() {
  selectedSlider = null;
}

void mouseWheel(MouseEvent evt) {
  if(holdingCtrl) {
    drawRadius = max(0, min(drawRadius - evt.getCount(), MAX_RADIUS));
  } else {
    zoom -= 50 * evt.getCount();
  }
}

void keyPressed() {
  if(key == 'r' || key == 'R') {
    g.resetPosition();
  } else if(key == 'a' || key == 'A') {
    autoRotate = !autoRotate;
  } else if(key == 's' || key == 's') {
    showArrow = !showArrow;
  } else if(key == 'd' || key == 'D') {
    onlyDrawSphere = !onlyDrawSphere;
  } else if(key == 'p' || key == 'P') {
    PrintWriter out = createWriter("edges.txt");
    out.print(g.toString());
    out.flush();
    out.close();
  } else if(key >= 49 && key <= 57) {
    // Number keys 1 - 9
    int n = key - 48;

    if (shadow.hasValue(n)) {
      shadow.removeValue(n);
    } else {
      shadow.appendUnique(n);
      shadow.sort();
    }
  } else if(keyCode == 17) {
    // Control key
    holdingCtrl = true;
  } else if(keyCode == 97) {
    // F1 key
    showInterface = !showInterface;
  }
}

void keyReleased() {
  if(keyCode == 17) {
    holdingCtrl = false;
  }
}

void drawArrow(float x, float y, float z, float w, float h, float l) {
  beginShape();
  vertex(x - w/2, y, z);
  vertex(x + w/2, y, z);
  vertex(x, y, z + l);
  endShape(CLOSE);
  beginShape();
  vertex(x - w/2, y + h, z);
  vertex(x + w/2, y + h, z);
  vertex(x, y + h, z + l);
  endShape(CLOSE);
  beginShape();
  vertex(x - w/2, y, z);
  vertex(x + w/2, y, z);
  vertex(x + w/2, y + h, z);
  vertex(x - w/2, y + h, z);
  endShape(CLOSE);
  beginShape();
  vertex(x - w/2, y, z);
  vertex(x, y, z + l);
  vertex(x, y + h, z + l);
  vertex(x - w/2, y + h, z);
  endShape(CLOSE);
  beginShape();
  vertex(x + w/2, y, z);
  vertex(x, y, z + l);
  vertex(x, y + h, z + l);
  vertex(x + w/2, y + h, z);
  endShape(CLOSE);
}

void exit() {
  stopThreads = true;

  super.exit();
}

private int sgn(int n) {
  if(n > 0) return 1;
  else if(n < 0) return -1;
  
  return 0;
}
