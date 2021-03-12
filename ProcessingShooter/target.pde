class Objetivo{
  final static float velMax = 4;
  //final static float tamMax = 50;
  //final static float tamMin = 20;
  final static float puntMax = 200;
  PVector posicion, velocidad;
  float size=10;
  float speed=1;
  float tam=1;
  int r, g, b;
  
  
  Objetivo(){
    velocidad = new PVector(random(-velMax, velMax), random(-velMax, velMax));
    float x, y;
    if (key>='0' && key<='4') {
    speed=key-'0';
    }
    velocidad.x*=speed;
    velocidad.y*=speed;
    if(abs(velocidad.x) > abs(velocidad.y)){
      if(velocidad.x > 0){
        x = 0;
      }
      else{
        x = width;
      }
      y = height * abs(velocidad.y) / velMax;
    }
    else{
      if(velocidad.y > 0){
        y = 0;
      }
      else{
        y = height;
      }
      x = width * abs(velocidad.y) / velMax;
    }
    posicion = new PVector(x, y);
    if (key>='6' && key<='9') {
    tam=key-'0';
    }
    size *= tam;
    r = (int)random(0, 255);
    g = (int)random(0, 255);
    b = (int)random(0, 255);
  }
  
  void draw(){
    fill(r, g, b);
    ellipseMode(CENTER);
    ellipse(posicion.x, posicion.y, size, size);
    posicion.add(velocidad);  
  }
  
  int puntos(){
    return (int)(puntMax / size * velocidad.mag());
  }
  
}  
