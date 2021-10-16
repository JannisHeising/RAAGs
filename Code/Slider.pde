private abstract class Slider {
  public PVector pos;
  public final float w, h;
  public final float min, max;
  public final boolean discrete;
  public final String name;
  public float value;
  
  public Slider(float cMin, float cMax, boolean cDiscrete, String cName) {
    w = 200;
    h = 10;
    
    min = cMin;
    max = cMax;
    discrete = cDiscrete;
    name = cName;
    
    value = 0;
    init();
  }
  
  public void draw(float x, float y) {
    pos = new PVector(x, y);
    
    fill(#A5A5A5);
    stroke(#ffffff);
    rect(x, y, w, h);
    fill(#E0E0E0);
    ellipse(x + map(value, min, max, 0, w), y + h/2, 1.5 * h, 1.5 * h);
    
    textAlign(RIGHT, TOP);
    text(name + ": " + int(value * 100) * 1./100, x - 8, y - 3);
  }
  
  public void setValue(float v) {
    if(discrete) {
      value = floor(v + .5);
    } else {
      value = v;
    }
    affect();
  }
  
  protected abstract void init();
  
  public abstract void affect();
}
