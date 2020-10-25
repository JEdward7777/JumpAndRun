import java.util.LinkedList;


color blue = color( 0,0,255 );
color red = color( 255, 0, 0 );



class Loc{
  float x;
  float y;
  public Loc(){}
  public Loc( float x, float y ){
    this.x = x; this.y = y;
  }
  public Loc copy(){
    return new Loc(this.x,this.y);
  }
  
  public Loc plus( Loc other ){
     return new Loc(this.x+other.x,this.y+other.y); 
  }
  
  public String toString(){
    return "(" + x + "," + y + ")";
  }
}

Loc block_size = new Loc(50,50);

Loc gravity = new Loc(0,.3);


class Touch{
  Loc overlap = new Loc(0,0);
  boolean touching = false;
}
Touch not_touching = new Touch();

abstract class Thing{
  public Thing(){
     size = block_size.copy();
  }
  Loc loc = new Loc();
  Loc size = new Loc();
  Loc speed = new Loc();
  public abstract void draw();
  public abstract void interact( Thing thing );
  public abstract void solid_push( Loc loc );
  
  public Touch how_am_I_touching( Thing other ){
    if( other.loc.x + .5*other.size.x < this.loc.x -.5*this.size.x  ) return not_touching;
    if( other.loc.y + .5*other.size.y < this.loc.y -.5*this.size.y  ) return not_touching;
    if( this.loc.x  + .5*this.size.x  < other.loc.x-.5*other.size.x ) return not_touching;
    if( this.loc.y  + .5*this.size.y  < other.loc.y-.5*other.size.y ) return not_touching;
    
    float shift_to_left  = this.loc.x - other.loc.x + .5*(other.size.x+this.size.x);
    float shift_to_right = other.loc.x - this.loc.x + .5*(this.size.x+other.size.x);
    float shift_to_top   = this.loc.y - other.loc.y + .5*(other.size.y+this.size.y);
    float shift_to_bottom= other.loc.y - this.loc.y + .5*(this.size.y+other.size.y);
    
    Touch result = new Touch();
    result.touching = true;
    
    result.overlap = new Loc(-shift_to_left,0);
    float min_movement = shift_to_left;
    
    if( shift_to_right < min_movement ){
       result.overlap = new Loc( shift_to_right, 0 );
       min_movement = shift_to_right;
    }
    
    if( shift_to_top < min_movement ){
      result.overlap = new Loc( 0, -shift_to_top );
      min_movement = shift_to_top;
    }
    
    if( shift_to_bottom < min_movement ){
      result.overlap = new Loc( 0, shift_to_bottom );
      min_movement = shift_to_bottom;
    }
    
   return result;
  }
}

float walk_speed = 10;
float jump_speed = 14;
float floor = 360;

LinkedList< Thing > all_things = new LinkedList< Thing >();

class Person extends Thing{
  public Person(){
     loc.x = 640/2;
  }
  public void draw(){
    
    float bottom = loc.y+.5*size.y;
    
    
    if( bottom < floor ){
      speed = speed.plus( gravity );
    }else{
      loc.y = floor - .5*size.y;
      if( speed.y > 0 ) speed.y = 0;
    }
    
    for( Thing other_thing : all_things ){
       other_thing.interact(this); 
    }
    
    
    fill( blue );
    rect(loc.x-.5*size.x, loc.y-.5*size.y, size.x, size.y, 7);
      
    loc = loc.plus( speed );
  }
  public void interact( Thing thing ){
    //Until multiplayered happens this is self interaction
  }
  public void solid_push( Loc push ){
    //This is a brick telling us how much we are intersecting.
    if( push.y != 0 )if( (push.y > 0) != (speed.y > 0) ) speed.y = 0;
    if( push.x != 0 )if( (push.x > 0) != (speed.x > 0) ) speed.x = 0;
    loc = loc.plus(push);
  }
  public void jump(){
    println( "Jump!!" );
    if( abs(person.speed.y) < .1 ){
      person.speed.y = -jump_speed;
    }
  }
}
void keyPressed() {
  println( keyCode );
  if( keyCode == LEFT ){
    person.speed.x = -walk_speed;
  }else if( keyCode == RIGHT ){
    person.speed.x = +walk_speed;
  }else if( keyCode == UP ){
    person.jump();
  }
}

void keyReleased(){
  if( keyCode == RIGHT && person.speed.x > 0 ){
    person.speed.x = 0;
  }else if( keyCode == LEFT && person.speed.x < 0 ){
    person.speed.x = 0;
  }
}


class SolidBrick extends Thing{
  
  public void draw(){
    fill( red );
    rect(loc.x-.5*size.x, loc.y-.5*size.y, size.x, size.y, 7);
  }
  public void interact( Thing other_thing ){
    Touch touch = other_thing.how_am_I_touching( this );
    if( touch.touching ){
      other_thing.solid_push( touch.overlap );
    }
  }
  public void solid_push( Loc loc ){
    //ignore pushes we are a brick
  }
}


void solid_brick( float x, float y, float width, float height ){
   SolidBrick new_brick = new SolidBrick();
   new_brick.loc.x = x*block_size.x;
   new_brick.loc.y = y*block_size.y;
   new_brick.size.x = width*block_size.x;
   new_brick.size.y = height*block_size.y;
   all_things.add( new_brick );
}

Person person = null;
 
// The statements in the setup() function 
// run once when the program begins
void setup() {
  size(640, 360);  // Size should be the first statement
  stroke(255);     // Set stroke color to white
  //noLoop();
  
  
  person = new Person();
  all_things.add(person);
  level1();
}

// The statements in draw() are run until the 
// program is stopped. Each statement is run in 
// sequence and after the last line is read, the first 
// line is run again.
void draw() { 
  background(0);   // Set the background to black
 //person.draw();
  for( Thing thing : all_things ){
    thing.draw();
  }
} 

void mousePressed() {
  
}



//Define level
void level1(){
  solid_brick( 5, 6, 1,1 );
  solid_brick( 8, 4, 2,1 );
}
