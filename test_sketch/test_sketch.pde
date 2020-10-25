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
  
  public Loc minus( Loc other ){
     return new Loc(this.x-other.x,this.y-other.y); 
  }
  
  public Loc times( float a ){
     return new Loc(this.x*a,this.y*a); 
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
  public abstract void interact( Thing thing, boolean is_person );
  public abstract void solid_push( Loc loc );
  public abstract void take_hit( int hurt_amount );
  
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
float floor = block_size.y*10.5;

LinkedList< Thing > things_to_remove = new LinkedList< Thing >();
LinkedList< Thing > all_things = new LinkedList< Thing >();

class Person extends Thing{
  boolean dead = false;
  public Person(){
     loc.x = 640/2;
  }
  public void draw(){
    
    if( !dead ){
      float bottom = loc.y+.5*size.y;
      
      
      if( bottom < floor ){
        speed = speed.plus( gravity );
      }else{
        loc.y = floor - .5*size.y;
        if( speed.y > 0 ) speed.y = 0;
      }
      
      for( Thing other_thing : all_things ){
         other_thing.interact(this, true); 
      }
      
      
      fill( blue );
      rect(loc.x-.5*size.x, loc.y-.5*size.y, size.x, size.y, 7);
        
      loc = loc.plus( speed );
    }else{
      fill( 103, 130, 122 );
      rect(loc.x-.5*size.x, loc.y-.5*size.y, size.x, size.y, 7);
    }
  }
  public void interact( Thing thing, boolean is_person ){
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
  public void take_hit( int hurt_amount ){
      dead=true;
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
  }else if( keyCode == 32 ){
    print( "" + round( person.loc.x/block_size.x) + "," + round( person.loc.y/block_size.y) );
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
  public void interact( Thing other_thing, boolean is_person ){
    if( other_thing == this ) return;
    Touch touch = other_thing.how_am_I_touching( this );
    if( touch.touching ){
      other_thing.solid_push( touch.overlap );
    }
  }
  public void solid_push( Loc loc ){
    //ignore pushes we are a brick
  }
  
  public void take_hit( int hurt_amount ){
    //nothing for now
  }
}


void solid_brick( float x, float y, float brick_width, float brick_height ){
   SolidBrick new_brick = new SolidBrick();
   new_brick.loc.x = x*block_size.x;
   new_brick.loc.y = y*block_size.y;
   new_brick.size.x = brick_width*block_size.x;
   new_brick.size.y = brick_height*block_size.y;
   all_things.add( new_brick );
}

float coin_spin_rate = 3;
class Coin extends Thing{
  float angle = 0;
  public void draw(){
    if( angle > 2*PI ) angle -= 2*PI;
    fill( 244, 255, 43 );
    color( 138, 145, 0 );
    ellipse(loc.x, loc.y, size.x*cos(angle), size.y);
    angle += coin_spin_rate;
  }
  public void interact( Thing other_thing, boolean is_person ){
    if( other_thing == this ) return;
    Touch touch = other_thing.how_am_I_touching( this );
    if( touch.touching && is_person ){
      things_to_remove.add(this);
    }
  }
  public void solid_push( Loc loc ){
    //ignore pushes we are a brick
  }
  public void take_hit( int hurt_amount ){
    //nothing for now
  }
}

void coin( float x, float y ){
  Coin new_coin = new Coin();
  new_coin.loc.x = x*block_size.x;
  new_coin.loc.y = y*block_size.y;
  all_things.add( new_coin );
}

abstract class Badguy extends Thing{
  public void interact( Thing other_thing, boolean is_person ){
    if( other_thing == this ) return;
    Touch touch = other_thing.how_am_I_touching( this );
    if( touch.touching ){
      if( is_person ){
        //head hit is ok.
        if( touch.overlap.y < 0 ){
          if( other_thing.speed.y > 0 ) other_thing.speed.y *= -1;
          this.take_hit(1);
        }else{
          other_thing.take_hit(1);
        }
      }else{
        //another badguy touch like a brick
        other_thing.solid_push( touch.overlap.times(.5) );
        this.solid_push( touch.overlap.times(-.5) );
      }
    }
  }
  public void solid_push( Loc push ){
    //This is a brick telling us how much we are intersecting.
    if( push.y != 0 )if( (push.y > 0) != (speed.y > 0) ) speed.y = 0;
    if( push.x != 0 )if( (push.x > 0) != (speed.x > 0) ) speed.x *= -1;
    loc = loc.plus(push);
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
       other_thing.interact(this,false); 
    }
    
    loc = loc.plus( speed ); 
    
  }
}

float walking_speed = 5;
class WalkyBadguy extends Badguy{
  public WalkyBadguy(){
    this.speed.x = walking_speed;
  }
  public void take_hit( int hurt_amount ){
    things_to_remove.add(this);
  }
  public void draw(){
    super.draw();
    fill( 230, 179, 14 );
    //println( "badguy loc " + loc.times(1/block_size.x) );
    ellipse(loc.x, loc.y, size.x, size.y);
  }
}

void walky( float x, float y, float x_speed ){
   WalkyBadguy bob = new WalkyBadguy();
   bob.loc.x = x*block_size.x;
   bob.loc.y = y*block_size.y;
   bob.speed.x = x_speed;
   //println( "bob is at " + bob.loc );
   all_things.add(bob);
}
        

Person person = null;
 
// The statements in the setup() function 
// run once when the program begins
void setup() {
  fullScreen();
  //size(809, 500);  // Size should be the first statement
  stroke(255);     // Set stroke color to white
  
  surface.setResizable(true);
  
  person = new Person();
  all_things.add(person);
  level1();
}

// The statements in draw() are run until the 
// program is stopped. Each statement is run in 
// sequence and after the last line is read, the first 
// line is run again.
Loc screen_loc = new Loc();
void draw() { 
  Loc screen_center = new Loc( width*.5, height*.5 );
  
  background(191, 252, 255);   // Set the background to black
  //horizon
  fill(55, 196, 130);
  rect(0,screen_center.y,width,height);
  
  //ground
  fill(201, 44, 0);
  rect(0,floor-screen_loc.y,width,height);
  
  pushMatrix();
  translate( -screen_loc.x, -screen_loc.y );
  screen_loc = (person.loc.minus(screen_center).minus(screen_loc)).times(.1).plus(screen_loc);
  

 //person.draw();
  for( Thing thing : all_things ){
    thing.draw();
  }
  for( Thing thing : things_to_remove ){
    all_things.remove(thing);
  }
  
  popMatrix();
} 



//Define level
void level1(){
  solid_brick( 5, 6, 1,1 );
  solid_brick( 8, 4, 2,1 );
  coin( 8,3 ); 
  coin( 8,4 );
  
  
  solid_brick( -3, 10, 1, 1 );
  solid_brick( 14, 10, 1, 1 );
  
  walky( 12, 10, walking_speed );
  //walky( 9, 3, -walking_speed );
  walky( 5, 5, -walking_speed*.25 );
  
  //for( int i = 0; i < 1000; ++i ){
  //  walky( 5*random(10), 10*random(100), walking_speed*2*random(1)-1 );
  //}
}
