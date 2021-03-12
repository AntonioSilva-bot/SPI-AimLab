import processing.sound.*;
import processing.serial.*; 
Serial port;  // Create object from Serial class
SoundFile misonido;
SoundFile metal;
final int objetivoContador = 20;
Objetivo[] objetivos;
int puntos = 0;
int tiempo;
PFont font;
PFont date;
PFont team;
PFont tecla;
int a=0;
int score=0;

void setup(){
  misonido = new SoundFile(this, "sonido.mp3");
  metal = new SoundFile(this, "metal.mp3");
  size(1366, 768);
  noCursor();
  objetivos = new Objetivo[objetivoContador];
  for(int i = 0; i < objetivoContador; i++){
    objetivos[i] = new Objetivo();
  }
  tiempo = 30 * 60;
   port = new Serial(this, "COM4", 9600); 
}

void draw(){
  background(200);
  font = loadFont("Stencil-48.vlw");
      textFont(font, 120);
      text("SPI-AimLab", width/4, 210);
      
      date = loadFont("MingLiU-ExtB-48.vlw");
      textFont(date, 50);
      text("V 1.0.0", 650,260);
      
      team = loadFont("MingLiU-ExtB-48.vlw");
      textFont(team, 50);
      text("Antonio Silva, Alan Mondragón", 450,320);
      
      tecla = loadFont("MingLiU-ExtB-48.vlw");
      textFont(team, 50);
      text("Presiona f para continuar", 480, 370); 
      
  if(a == 1){
    background(200);
    for(int i = 0; i < objetivoContador; i++){
      objetivos[i].draw();
      if(objetivos[i].posicion.x - objetivos[i].size/2 > width ||
         objetivos[i].posicion.x + objetivos[i].size/2 < 0 ||
         objetivos[i].posicion.y - objetivos[i].size/2 > height ||
         objetivos[i].posicion.y + objetivos[i].size/2 < 0){
         objetivos[i] = new Objetivo();
       }
    }
   }
  else if(key == 'f'||key == 'F'){
    a=+1;
  }
  
  crosshair();
  puntos();
  
  tiempo--;
  if(tiempo <= 0){
    noLoop();
    background(200);
    textSize(50);
    fill(100, 0, 0);
    textAlign(CENTER, CENTER);
    text("SPI-AimLab\n\nGame Over!\nPoints: " + puntos + "\nRecord"+score+
    "\nPress e to restart", width/2, height/2);
    delay(1000);
  }
}

void crosshair(){
  crosshair(4, 3, 5);
}

void crosshair(int size, int thickness, int offset){
  strokeWeight(thickness);
  line(mouseX - offset, mouseY, mouseX - offset - size, mouseY);
  line(mouseX + offset, mouseY, mouseX + offset + size, mouseY);
  line(mouseX, mouseY - offset, mouseX, mouseY - offset - size);
  line(mouseX, mouseY + offset, mouseX, mouseY + offset + size);
  
}

void puntos(){
  textSize(32);
  if(tiempo / 60 <= 10){
    fill(255, 0, 0);
  }
  else{
    fill(25);
  }
  text("Time: " + (tiempo / 60), 10, 30);
  fill(25);
  text("Points: " + puntos, 10, 70);
  if (puntos>score){
    score=puntos;
  }
  text("Record: " + score, 10, 100);
}

void setGameTime(){
   tiempo = (int)(30 * frameRate);
}

void keyPressed(){
  if(tiempo<='0'){
    setGameTime();
    for(int i = 0; i < objetivoContador; i++){
      objetivos[i] = new Objetivo();
    } 
    puntos = 0;
    textAlign(LEFT);
    loop();
  }
  else if (key == 'e'||key == 'E'){
    misonido.play();
    PVector mousePos = new PVector(mouseX, mouseY);
    for(int i = 0; i < objetivoContador; i++){
      if(objetivos[i].posicion.dist(mousePos) <= objetivos[i].size/2){
         metal.play();
        puntos += objetivos[i].puntos();
        tiempo += objetivos[i].velocidad.mag() * 5;
        objetivos[i] = new Objetivo(); 
      }
    }
  }
}
