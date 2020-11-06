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
  
  public Loc abs(){
    Loc result = copy();
    if( result.x < 0 ) result.x = 0 - result.x;
    if( result.y < 0 ) result.y = 0 - result.y;
    return result;
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
  
  public float r(){
    return sqrt( x*x+y*y );  
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
  public abstract String save();
  
  public Touch how_am_I_touching( Thing other ){
    if( this == other ) return not_touching;
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
  boolean maker_mode = false;
  boolean dead = false;
  public Person(){
     loc.x = 640/2;
  }
  public void draw(){
    if( !maker_mode ){
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
    }else{
        fill( 224, 90, 211 );
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
    if( abs(person.speed.y) < .4 ){
      person.speed.y = -jump_speed;
    }
  }
  public void take_hit( int hurt_amount ){
      dead=true;
  }
  public String save(){
    return "   person_init( " + (loc.x/block_size.x) + ", " + (loc.y/block_size.y) + " );";
  }
}
void keyPressed() {
  //println( keyCode );
  if( !person.maker_mode ){
    if( keyCode == LEFT ){
      person.speed.x = -walk_speed;
    }else if( keyCode == RIGHT ){
      person.speed.x = +walk_speed;
    }else if( keyCode == UP || keyCode == 32 ){
      person.jump();
    //}else if( keyCode == 32 ){
    //  println( "" + round( person.loc.x/block_size.x) + "," + round( person.loc.y/block_size.y) );
    }else if( key == 'm' ){
      person.maker_mode = !person.maker_mode;
    }
  }else{
    if( keyCode == LEFT ){
      person.loc.x = (round(person.loc.x/block_size.x)-1)*block_size.x;
    }else if( keyCode == RIGHT ){
      person.loc.x = (round(person.loc.x/block_size.x)+1)*block_size.x;
    }else if( keyCode == UP ){
      person.loc.y = (round(person.loc.y/block_size.y)-1)*block_size.y;
    }else if( keyCode == DOWN ){
      person.loc.y = (round(person.loc.y/block_size.y)+1)*block_size.y;
    }else if( key == 'm' ){
      person.maker_mode = !person.maker_mode;
    }else if( key == 'c' ){
      coin( person.loc.x/block_size.x, person.loc.y/block_size.y );
    }else if( key == 'w' ){
       walky( person.loc.x/block_size.x, person.loc.y/block_size.y, 10 );
    }else if( key == 'b' ){
      solid_brick(  person.loc.x/block_size.x, person.loc.y/block_size.y, 1, 1 );
    }else if( key == 'i' ){
      invisible_brick(  person.loc.x/block_size.x, person.loc.y/block_size.y, 1, 1 );
    }else if( key == 'q' ){
      //make a thick brick
      if( last_last_brick != null && last_brick != null ){
        things_to_remove.add(last_last_brick);
        things_to_remove.add(last_brick);
        Loc center = (last_last_brick.loc.plus(last_brick.loc)).times(.5);
        Loc size   = (last_last_brick.loc.minus(last_brick.loc));
        size.x = abs(size.x);
        size.y = abs(size.y);
        size = size.plus(block_size);
        solid_brick( center.x/block_size.x, center.y/block_size.y, size.x/block_size.x, size.y/block_size.y );
      }
    }else if( key == 's' ){
      String level = "";
      int added_length = 0;
      for( Thing thing : all_things ){
        String thing_save = thing.save().trim();
        added_length += thing_save.length();
        level += thing_save;
        if( added_length > 7000 ){
          added_length = 0;
          level += "\n";
        }
      }
      println( level );
      
      
      
      PrintWriter fout = createWriter( "" + year() + "_" + month() + "_" + day() + "_" + hour() + " " + minute() + "_" + second() + ".txt" );
      fout.println( level );
      fout.flush();
      fout.close();
    }else if( key == 'd' ){
      for( Thing thing : all_things ){
        Touch t = person.how_am_I_touching( thing ); 
        if( t.touching && t.overlap.r() > .5 ){
          things_to_remove.add( thing ); 
        }
      }
    }else if( key == 'r' ){
      if( last_last_brick != null && last_brick != null ){
        things_to_remove.add( last_last_brick );
        things_to_remove.add( last_brick );
        door( last_last_brick.loc.x/block_size.x, last_last_brick.loc.y/block_size.y, last_brick.loc.x/block_size.x, last_brick.loc.y/block_size.y );
      }
    }else if( key == 'n' ){
      button( person.loc.x/block_size.x, person.loc.y/block_size.y );
    }else if( key == 't' ){
      teleporter( person.loc.x/block_size.x, person.loc.y/block_size.y );
    }else if( key == ',' ){
      if( last_growable != null ){
        last_growable.size = last_growable.size.times(1.3);
      }
    }else if( key == '.' ){
      if( last_growable != null ){
        last_growable.size = last_growable.size.times(.8);
      }
    }else{
      println( "key == '" + key + "'" );
    }
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
  
  public String save(){
    return "   solid_brick( " + (loc.x/block_size.x) + ", " + (loc.y/block_size.y) + ", " + (size.x/block_size.x) + ", " + (size.y/block_size.y) + " );";
  }
}
SolidBrick last_last_brick = null;
SolidBrick last_brick = null;
void solid_brick( float x, float y, float brick_width, float brick_height ){
   SolidBrick new_brick = new SolidBrick();
   new_brick.loc.x = x*block_size.x;
   new_brick.loc.y = y*block_size.y;
   new_brick.size.x = brick_width*block_size.x;
   new_brick.size.y = brick_height*block_size.y;
   all_things.add( new_brick );
   last_last_brick = last_brick;
   last_brick = new_brick;
}

class InvisibleBrick extends SolidBrick{
  public void draw(){
    if( person.maker_mode ){
      fill( 237, 237, 237 );
      rect(loc.x-.5*size.x, loc.y-.5*size.y, size.x, size.y, 7);
    }
  }
  public String save(){
    return "   invisible_brick( " + (loc.x/block_size.x) + ", " + (loc.y/block_size.y) + ", " + (size.x/block_size.x) + ", " + (size.y/block_size.y) + " );";
  }
}
void invisible_brick( float x, float y, float brick_width, float brick_height ){
   InvisibleBrick new_brick = new InvisibleBrick();
   new_brick.loc.x = x*block_size.x;
   new_brick.loc.y = y*block_size.y;
   new_brick.size.x = brick_width*block_size.x;
   new_brick.size.y = brick_height*block_size.y;
   all_things.add( new_brick );
}

class Door extends SolidBrick{
  boolean is_open = false;
  Loc closed_top;
  Loc bottom;
  Loc current_top;
  public Door( Loc top, Loc bottom ){
    this.closed_top = top;
    this.bottom = bottom;
    this.current_top = this.closed_top;
    
    this.loc = current_top.plus(bottom).times(.5);
    this.size = current_top.minus(bottom).abs().plus(block_size);
  }
  void draw(){
    Loc top_target = null;
    if( is_open ){
      top_target = bottom;
    }else{
      top_target = closed_top;
    }
    current_top = top_target.minus(current_top).times(.1).plus(current_top);
    
    this.loc = current_top.plus(bottom).times(.5);
    this.size = current_top.minus(bottom).abs().plus(block_size);
   
    super.draw();
  }
  String save(){
    return "   door(" + (closed_top.x/block_size.x) + ", " + (closed_top.y/block_size.y) + ", " + (bottom.x/block_size.x) + ", " + (bottom.y/block_size.y) + ");";
  }
}
Door last_door = null;
void door( float x1, float y1, float x2, float y2 ){
  Door new_door = new Door( new Loc(x1*block_size.x,y1*block_size.y), new Loc(x2*block_size.x,y2*block_size.y) );
  all_things.add(new_door);
  last_door = new_door;
}

class Button extends Thing{
  Door door = null;
  float timeout = 0;
  public void interact( Thing other_thing, boolean is_person ){
    if( door != null && is_person ){
      Touch touch = other_thing.how_am_I_touching( this );
      if( timeout > 0 ){
        timeout -= 1;
        if( touch.touching )other_thing.solid_push(touch.overlap);
      }else{
        if( touch.touching && touch.overlap.r() > .5 ){
          other_thing.solid_push(touch.overlap);
          timeout = 100;
          
          door.is_open = !door.is_open;
        }
      }
    }
  }
  public String save(){
    return "   button( " + (loc.x/block_size.x) + ", " + (loc.y/block_size.y) + " );";
  }
  public void take_hit(int amount){}
  public void solid_push( Loc loc ){}
  public void draw(){
    if( timeout > 0 ){
      fill( 0, 255, 0 );
    }else{
      fill( 255, 153, 153 );
    }
     rect(loc.x-.5*size.x, loc.y-.5*size.y, size.x, size.y, 7);
  }
}
void button( float x, float y ){
   Button new_button = new Button();
   new_button.loc.x = x*block_size.x;
   new_button.loc.y = y*block_size.y;
   new_button.door = last_door;
   all_things.add(new_button);
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
  public String save(){
    return "   coin( " + (loc.x/block_size.x) + ", " + (loc.y/block_size.y) + " );";
  }
}
void coin( float x, float y ){
  //println( "made coin" );
  Coin new_coin = new Coin();
  new_coin.loc.x = x*block_size.x;
  new_coin.loc.y = y*block_size.y;
  all_things.add( new_coin );
}

class Teleporter extends Thing{
  Teleporter other_end = null;
  float color_angle = 0;
  float timeout = 0;
  public void interact( Thing other_thing, boolean is_person ){
    if( other_end != null ){
      if( timeout > 0 ){
        timeout -= 1;
      }else{
        Touch touch = other_thing.how_am_I_touching( this );
        if( touch.touching && touch.overlap.r() > .5 ){
          other_thing.loc = other_thing.loc.minus( this.loc ).plus( other_end.loc );
          other_thing.solid_push(touch.overlap);
          //println( "ported from " + this.loc + " to " + other_end.loc );
          other_end.timeout = 1000;
        }
      }
    }
  }
  public String save(){
    return "   teleporter( " + (loc.x/block_size.x) + ", " + (loc.y/block_size.y) + " );";
  }
  public void take_hit(int amount){}
  public void solid_push( Loc loc ){}
  public void draw(){
    if( timeout <= 0 ) color_angle += .1;
    if( color_angle > 2*PI ) color_angle -= 2*PI;
    fill( 255*cos( color_angle ), 255*sin(color_angle ), 100 );
     rect(loc.x-.5*size.x, loc.y-.5*size.y, size.x, size.y, 7);
  }
}
Teleporter last_teleporter = null;
void teleporter( float x, float y ){
  //println( "maken a telelportermaifactor at " + x + ", " + y );
  Teleporter new_porter = new Teleporter();
  new_porter.loc.x = x*(block_size.x);
  new_porter.loc.y = y*(block_size.y);
  //println( "The new porter is at " + new_porter.loc + " and it saves as " + new_porter.save() );
  if( last_teleporter != null ){
    new_porter.other_end = last_teleporter;
    last_teleporter.other_end = new_porter;
    last_teleporter = null;
  }else{
    last_teleporter = new_porter;
  }
  all_things.add( new_porter );
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
  
  public String save(){
    return "   walky2( " + (loc.x/block_size.x) + ", " + (loc.y/block_size.y) + ", " + (size.x/block_size.x) + ", " + this.speed.x + " );";
  }
}
Thing last_growable = null;
void walky( float x, float y, float x_speed ){
   WalkyBadguy bob = new WalkyBadguy();
   bob.loc.x = x*block_size.x;
   bob.loc.y = y*block_size.y;
   bob.speed.x = x_speed;
   //println( "bob is at " + bob.loc );
   all_things.add(bob);
   last_growable = bob;
}
void walky2( float x, float y, float size, float x_speed ){
   WalkyBadguy bob = new WalkyBadguy();
   bob.loc.x = x*block_size.x;
   bob.loc.y = y*block_size.y;
   bob.size.x = size*block_size.x;
   bob.size.y = size*block_size.y;
   bob.speed.x = x_speed;
   //println( "bob is at " + bob.loc );
   all_things.add(bob);
   last_growable = bob;
}
   
Person person = null;
void person_init( float x, float y ){
  person.loc.x = x*(block_size.x);
  person.loc.y = y*(block_size.y);
}
 
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
  fill(73, 148, 27);
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
  person.maker_mode = true;
person_init( 55.0, 10.0 );solid_brick( 6.0, 4.0, 10.0, 1.0 );coin( 8.0, 3.0 );solid_brick( -3.0, 10.0, 1.0, 1.0 );solid_brick( 14.0, 10.0, 1.0, 1.0 );coin( 3.0, 1.0 );coin( 6.0, 1.0 );coin( 7.0, 1.0 );coin( 8.0, 1.0 );coin( 9.0, 1.0 );solid_brick( 1.0, 3.0, 1.0, 1.0 );solid_brick( 11.0, 3.0, 1.0, 1.0 );coin( 5.0, 1.0 );coin( 4.0, 1.0 );coin( 3.0, 0.0 );coin( 4.0, 0.0 );coin( 5.0, 0.0 );coin( 6.0, 0.0 );coin( 7.0, 0.0 );coin( 8.0, 0.0 );coin( 9.0, 0.0 );coin( 3.0, 2.0 );coin( 4.0, 2.0 );coin( 5.0, 2.0 );coin( 7.0, 2.0 );coin( 8.0, 2.0 );coin( 9.0, 2.0 );coin( 10.0, 2.0 );coin( 11.0, 2.0 );coin( 11.0, 1.0 );coin( 11.0, 0.0 );coin( 10.0, -1.0 );coin( 9.0, -1.0 );coin( 8.0, -1.0 );coin( 7.0, -1.0 );coin( 6.0, -1.0 );coin( 5.0, -1.0 );coin( 4.0, -1.0 );coin( 3.0, -1.0 );coin( 2.0, 2.0 );coin( 2.0, 4.0 );coin( 2.0, 5.0 );coin( 11.0, 5.0 );coin( 11.0, 4.0 );coin( 11.0, 3.0 );coin( 2.0, 6.0 );solid_brick( -8.0, 10.0, 1.0, 1.0 );solid_brick( -8.0, 9.0, 1.0, 1.0 );solid_brick( -9.0, 10.0, 1.0, 1.0 );solid_brick( -16.0, 10.0, 1.0, 1.0 );solid_brick( -17.0, 10.0, 1.0, 1.0 );solid_brick( -18.0, 10.0, 1.0, 1.0 );solid_brick( -19.0, 10.0, 1.0, 1.0 );solid_brick( -19.0, 9.0, 1.0, 1.0 );solid_brick( -19.0, 8.0, 1.0, 1.0 );solid_brick( -19.0, 7.0, 1.0, 1.0 );solid_brick( -19.0, 6.0, 1.0, 1.0 );solid_brick( -19.0, 5.0, 1.0, 1.0 );solid_brick( -19.0, 4.0, 1.0, 1.0 );solid_brick( -19.0, 3.0, 1.0, 1.0 );solid_brick( -19.0, 2.0, 1.0, 1.0 );solid_brick( -19.0, 1.0, 1.0, 1.0 );solid_brick( -19.0, 0.0, 1.0, 1.0 );solid_brick( -19.0, -1.0, 1.0, 1.0 );solid_brick( -19.0, -2.0, 1.0, 1.0 );solid_brick( -19.0, -3.0, 1.0, 1.0 );solid_brick( -19.0, -4.0, 1.0, 1.0 );solid_brick( -19.0, -5.0, 1.0, 1.0 );solid_brick( -19.0, -6.0, 1.0, 1.0 );solid_brick( -19.0, -7.0, 1.0, 1.0 );solid_brick( -19.0, -8.0, 1.0, 1.0 );solid_brick( -19.0, -9.0, 1.0, 1.0 );solid_brick( -19.0, -10.0, 1.0, 1.0 );solid_brick( -19.0, -12.0, 1.0, 1.0 );solid_brick( -19.0, -11.0, 1.0, 1.0 );solid_brick( -18.0, -12.0, 1.0, 1.0 );solid_brick( -17.0, -12.0, 1.0, 1.0 );solid_brick( -16.0, -12.0, 1.0, 1.0 );solid_brick( -15.0, -12.0, 1.0, 1.0 );solid_brick( -14.0, -12.0, 1.0, 1.0 );solid_brick( -13.0, -12.0, 1.0, 1.0 );solid_brick( -9.0, -12.0, 1.0, 1.0 );coin( -16.0, 9.0 );coin( -17.0, 9.0 );coin( -17.0, 8.0 );coin( -18.0, 8.0 );coin( -17.0, 8.0 );coin( -16.0, 8.0 );coin( -15.0, 7.0 );coin( -16.0, 7.0 );coin( -17.0, 7.0 );coin( -18.0, 7.0 );coin( -18.0, 6.0 );coin( -17.0, 6.0 );coin( -16.0, 6.0 );coin( -15.0, 6.0 );solid_brick( -14.0, 10.0, 1.0, 1.0 );solid_brick( -15.0, 10.0, 1.0, 1.0 );solid_brick( -14.0, 9.0, 1.0, 1.0 );solid_brick( -18.0, 5.0, 1.0, 1.0 );solid_brick( -17.0, 5.0, 1.0, 1.0 );solid_brick( -16.0, 5.0, 1.0, 1.0 );solid_brick( -14.0, 5.0, 1.0, 1.0 );solid_brick( -14.0, 4.0, 1.0, 1.0 );coin( -15.0, 4.0 );coin( -16.0, 4.0 );coin( -17.0, 4.0 );solid_brick( -17.0, 1.0, 1.0, 1.0 );solid_brick( -16.0, 1.0, 1.0, 1.0 );solid_brick( -15.0, 1.0, 1.0, 1.0 );solid_brick( -14.0, 1.0, 1.0, 1.0 );solid_brick( -14.0, 0.0, 1.0, 1.0 );coin( -17.0, 0.0 );coin( -16.0, 0.0 );coin( -15.0, 0.0 );solid_brick( -18.0, -3.0, 1.0, 1.0 );solid_brick( -17.0, -3.0, 1.0, 1.0 );solid_brick( -16.0, -3.0, 1.0, 1.0 );solid_brick( -14.0, -3.0, 1.0, 1.0 );solid_brick( -14.0, -4.0, 1.0, 1.0 );coin( -18.0, -4.0 );coin( -16.0, -4.0 );coin( -15.0, -4.0 );solid_brick( -17.0, -7.0, 1.0, 1.0 );solid_brick( -16.0, -7.0, 1.0, 1.0 );solid_brick( -15.0, -7.0, 1.0, 1.0 );solid_brick( -14.0, -7.0, 1.0, 1.0 );coin( -17.0, -8.0 );coin( -16.0, -8.0 );coin( -15.0, -8.0 );coin( -15.0, -9.0 );coin( -16.0, -9.0 );coin( -17.0, -9.0 );coin( -18.0, -9.0 );coin( -18.0, -10.0 );coin( -17.0, -10.0 );coin( -16.0, -10.0 );coin( -15.0, -10.0 );coin( -15.0, -11.0 );coin( -16.0, -11.0 );coin( -17.0, -11.0 );coin( -18.0, -11.0 );coin( -14.0, -11.0 );solid_brick( -13.0, 10.0, 1.0, 1.0 );solid_brick( -1.0, -5.0, 1.0, 1.0 );solid_brick( -4.0, -10.0, 1.0, 1.0 );coin( -15.0, 8.0 );solid_brick( -11.0, 10.0, 1.0, 1.0 );solid_brick( -10.0, 10.0, 1.0, 1.0 );solid_brick( -12.0, 10.0, 1.0, 1.0 );coin( -13.0, 1.0 );coin( -12.0, 1.0 );coin( -11.0, 1.0 );coin( -12.0, -3.0 );coin( -11.0, -3.0 );coin( -13.0, -7.0 );coin( -12.0, -7.0 );coin( -11.0, -7.0 );walky2( 305.4, 10.0, 1.0, 10.0 );solid_brick( 308.0, 10.0, 1.0, 1.0 );solid_brick( 308.0, 6.0, 1.0, 1.0 );solid_brick( 307.0, 6.0, 1.0, 1.0 );solid_brick( 306.0, 6.0, 1.0, 1.0 );solid_brick( 305.0, 6.0, 1.0, 1.0 );solid_brick( 304.0, 6.0, 1.0, 1.0 );solid_brick( 303.0, 6.0, 1.0, 1.0 );solid_brick( 302.0, 6.0, 1.0, 1.0 );solid_brick( 301.0, 6.0, 1.0, 1.0 );solid_brick( 301.0, 7.0, 1.0, 1.0 );solid_brick( 301.0, 8.0, 1.0, 1.0 );solid_brick( 301.0, 9.0, 1.0, 1.0 );solid_brick( 301.0, 10.0, 1.0, 1.0 );solid_brick( 302.0, 9.0, 1.0, 1.0 );solid_brick( 303.0, 9.0, 1.0, 1.0 );solid_brick( 304.0, 9.0, 1.0, 1.0 );solid_brick( 305.0, 9.0, 1.0, 1.0 );solid_brick( 308.0, 9.0, 1.0, 1.0 );solid_brick( 308.0, 8.0, 1.0, 1.0 );solid_brick( 308.0, 7.0, 1.0, 1.0 );solid_brick( 305.0, 8.0, 1.0, 1.0 );walky2( 301.8, 8.0, 1.0, -10.0 );coin( 12.0, 1.0 );coin( 12.0, 2.0 );coin( 12.0, 3.0 );coin( 12.0, 4.0 );solid_brick( 17.0, -3.0, 1.0, 1.0 );solid_brick( 16.0, -2.0, 1.0, 1.0 );solid_brick( 15.0, -2.0, 1.0, 1.0 );solid_brick( 14.0, -2.0, 1.0, 1.0 );solid_brick( 13.0, -3.0, 1.0, 1.0 );coin( 17.0, -2.0 );coin( 18.0, -3.0 );coin( 18.0, -4.0 );coin( 17.0, -4.0 );coin( 17.0, -5.0 );coin( 15.0, -6.0 );coin( 13.0, -6.0 );coin( 13.0, -5.0 );coin( 18.0, -5.0 );coin( 12.0, -5.0 );coin( 12.0, -4.0 );coin( 12.0, -3.0 );coin( 13.0, -2.0 );coin( 14.0, -1.0 );coin( 15.0, -1.0 );coin( 16.0, -1.0 );coin( 15.0, -3.0 );coin( 16.0, -3.0 );coin( 16.0, -4.0 );coin( 15.0, -4.0 );coin( 15.0, -5.0 );coin( 14.0, -4.0 );coin( 13.0, -4.0 );coin( 14.0, -3.0 );solid_brick( 1.0, 12.0, 1.0, 1.0 );solid_brick( 2.0, 12.0, 1.0, 1.0 );solid_brick( 3.0, 13.0, 1.0, 1.0 );solid_brick( 3.0, 14.0, 1.0, 1.0 );solid_brick( 2.0, 15.0, 1.0, 1.0 );solid_brick( 1.0, 15.0, 1.0, 1.0 );solid_brick( 0.0, 15.0, 1.0, 1.0 );solid_brick( 0.0, 13.0, 1.0, 1.0 );solid_brick( 0.0, 12.0, 1.0, 1.0 );solid_brick( 0.0, 14.0, 1.0, 1.0 );solid_brick( 0.0, 16.0, 1.0, 1.0 );solid_brick( 0.0, 17.0, 1.0, 1.0 );solid_brick( 0.0, 18.0, 1.0, 1.0 );solid_brick( 7.0, 18.0, 1.0, 1.0 );solid_brick( 7.0, 17.0, 1.0, 1.0 );solid_brick( 7.0, 16.0, 1.0, 1.0 );solid_brick( 0.0, 19.0, 1.0, 1.0 );solid_brick( 7.0, 19.0, 1.0, 1.0 );solid_brick( 7.0, 15.0, 1.0, 1.0 );solid_brick( 6.0, 16.0, 1.0, 1.0 );solid_brick( 5.0, 15.0, 1.0, 1.0 );solid_brick( 4.0, 16.0, 1.0, 1.0 );solid_brick( 4.0, 18.0, 1.0, 1.0 );solid_brick( 5.0, 19.0, 1.0, 1.0 );solid_brick( 6.0, 18.0, 1.0, 1.0 );solid_brick( 4.0, 17.0, 1.0, 1.0 );solid_brick( 9.0, 15.0, 1.0, 1.0 );solid_brick( 9.0, 16.0, 1.0, 1.0 );solid_brick( 9.0, 17.0, 1.0, 1.0 );solid_brick( 9.0, 18.0, 1.0, 1.0 );solid_brick( 9.0, 19.0, 1.0, 1.0 );solid_brick( 9.0, 20.0, 1.0, 1.0 );solid_brick( 9.0, 21.0, 1.0, 1.0 );solid_brick( 9.0, 22.0, 1.0, 1.0 );solid_brick( 9.0, 23.0, 1.0, 1.0 );coin( 3.0, 5.0 );coin( 4.0, 5.0 );coin( 5.0, 5.0 );
coin( 6.0, 5.0 );coin( 7.0, 5.0 );coin( 8.0, 5.0 );coin( 9.0, 5.0 );coin( 10.0, 5.0 );coin( 10.0, 6.0 );coin( 9.0, 6.0 );coin( 8.0, 6.0 );coin( 7.0, 6.0 );coin( 6.0, 6.0 );coin( 5.0, 6.0 );coin( 4.0, 6.0 );coin( 3.0, 6.0 );solid_brick( 10.0, 15.0, 1.0, 1.0 );solid_brick( 11.0, 15.0, 1.0, 1.0 );solid_brick( 12.0, 16.0, 1.0, 1.0 );solid_brick( 12.0, 17.0, 1.0, 1.0 );solid_brick( 11.0, 18.0, 1.0, 1.0 );solid_brick( 10.0, 18.0, 1.0, 1.0 );solid_brick( 14.0, 16.0, 1.0, 1.0 );solid_brick( 14.0, 17.0, 1.0, 1.0 );solid_brick( 14.0, 18.0, 1.0, 1.0 );solid_brick( 15.0, 15.0, 1.0, 1.0 );solid_brick( 15.0, 19.0, 1.0, 1.0 );solid_brick( 16.0, 18.0, 1.0, 1.0 );solid_brick( 17.0, 18.0, 1.0, 1.0 );solid_brick( 17.0, 19.0, 1.0, 1.0 );solid_brick( 17.0, 17.0, 1.0, 1.0 );solid_brick( 17.0, 16.0, 1.0, 1.0 );solid_brick( 17.0, 15.0, 1.0, 1.0 );solid_brick( 16.0, 16.0, 1.0, 1.0 );solid_brick( 22.0, 15.0, 1.0, 1.0 );solid_brick( 21.0, 14.0, 1.0, 1.0 );solid_brick( 21.0, 13.0, 1.0, 1.0 );solid_brick( 22.0, 12.0, 1.0, 1.0 );solid_brick( 23.0, 13.0, 1.0, 1.0 );solid_brick( 23.0, 14.0, 1.0, 1.0 );solid_brick( 21.0, 16.0, 1.0, 1.0 );solid_brick( 20.0, 17.0, 1.0, 1.0 );solid_brick( 20.0, 18.0, 1.0, 1.0 );solid_brick( 21.0, 19.0, 1.0, 1.0 );solid_brick( 22.0, 19.0, 1.0, 1.0 );solid_brick( 23.0, 19.0, 1.0, 1.0 );solid_brick( 24.0, 18.0, 1.0, 1.0 );solid_brick( 25.0, 17.0, 1.0, 1.0 );solid_brick( 25.0, 19.0, 1.0, 1.0 );solid_brick( 23.0, 17.0, 1.0, 1.0 );solid_brick( 22.0, 16.0, 1.0, 1.0 );solid_brick( 34.0, 13.0, 1.0, 1.0 );solid_brick( 33.0, 12.0, 1.0, 1.0 );solid_brick( 32.0, 12.0, 1.0, 1.0 );solid_brick( 30.0, 14.0, 1.0, 1.0 );solid_brick( 34.0, 17.0, 1.0, 1.0 );solid_brick( 34.0, 18.0, 1.0, 1.0 );solid_brick( 33.0, 19.0, 1.0, 1.0 );solid_brick( 31.0, 19.0, 1.0, 1.0 );solid_brick( 32.0, 19.0, 1.0, 1.0 );solid_brick( 30.0, 18.0, 1.0, 1.0 );solid_brick( 30.0, 13.0, 1.0, 1.0 );solid_brick( 31.0, 12.0, 1.0, 1.0 );solid_brick( 31.0, 15.0, 1.0, 1.0 );solid_brick( 32.0, 15.0, 1.0, 1.0 );solid_brick( 33.0, 15.0, 1.0, 1.0 );solid_brick( 34.0, 16.0, 1.0, 1.0 );solid_brick( 37.0, 15.0, 1.0, 1.0 );solid_brick( 39.0, 15.0, 1.0, 1.0 );solid_brick( 39.0, 16.0, 1.0, 1.0 );solid_brick( 39.0, 17.0, 1.0, 1.0 );solid_brick( 39.0, 19.0, 1.0, 1.0 );solid_brick( 39.0, 18.0, 1.0, 1.0 );solid_brick( 38.0, 16.0, 1.0, 1.0 );solid_brick( 36.0, 16.0, 1.0, 1.0 );solid_brick( 36.0, 17.0, 1.0, 1.0 );solid_brick( 36.0, 18.0, 1.0, 1.0 );solid_brick( 38.0, 18.0, 1.0, 1.0 );solid_brick( 37.0, 19.0, 1.0, 1.0 );solid_brick( 41.0, 15.0, 1.0, 1.0 );solid_brick( 41.0, 16.0, 1.0, 1.0 );solid_brick( 41.0, 17.0, 1.0, 1.0 );solid_brick( 41.0, 18.0, 1.0, 1.0 );solid_brick( 41.0, 19.0, 1.0, 1.0 );solid_brick( 42.0, 16.0, 1.0, 1.0 );solid_brick( 43.0, 15.0, 1.0, 1.0 );solid_brick( 44.0, 15.0, 1.0, 1.0 );solid_brick( 47.0, 16.0, 1.0, 1.0 );solid_brick( 47.0, 17.0, 1.0, 1.0 );solid_brick( 47.0, 18.0, 1.0, 1.0 );solid_brick( 48.0, 19.0, 1.0, 1.0 );solid_brick( 50.0, 18.0, 1.0, 1.0 );solid_brick( 49.0, 18.0, 1.0, 1.0 );solid_brick( 50.0, 19.0, 1.0, 1.0 );solid_brick( 50.0, 17.0, 1.0, 1.0 );solid_brick( 50.0, 16.0, 1.0, 1.0 );solid_brick( 50.0, 15.0, 1.0, 1.0 );solid_brick( 49.0, 16.0, 1.0, 1.0 );solid_brick( 48.0, 15.0, 1.0, 1.0 );solid_brick( 52.0, 12.0, 1.0, 1.0 );solid_brick( 52.0, 13.0, 1.0, 1.0 );solid_brick( 52.0, 14.0, 1.0, 1.0 );solid_brick( 52.0, 15.0, 1.0, 1.0 );solid_brick( 52.0, 16.0, 1.0, 1.0 );solid_brick( 52.0, 17.0, 1.0, 1.0 );solid_brick( 52.0, 18.0, 1.0, 1.0 );solid_brick( 52.0, 19.0, 1.0, 1.0 );solid_brick( 53.0, 16.0, 1.0, 1.0 );solid_brick( 54.0, 15.0, 1.0, 1.0 );solid_brick( 55.0, 16.0, 1.0, 1.0 );solid_brick( 55.0, 17.0, 1.0, 1.0 );solid_brick( 55.0, 18.0, 1.0, 1.0 );solid_brick( 55.0, 19.0, 1.0, 1.0 );solid_brick( 45.0, 16.0, 1.0, 1.0 );solid_brick( 63.0, 13.0, 1.0, 1.0 );solid_brick( 64.0, 12.0, 1.0, 1.0 );solid_brick( 65.0, 12.0, 1.0, 1.0 );solid_brick( 66.0, 13.0, 1.0, 1.0 );solid_brick( 66.0, 14.0, 1.0, 1.0 );solid_brick( 66.0, 15.0, 1.0, 1.0 );solid_brick( 65.0, 16.0, 1.0, 1.0 );solid_brick( 64.0, 17.0, 1.0, 1.0 );solid_brick( 63.0, 18.0, 1.0, 1.0 );solid_brick( 62.0, 19.0, 1.0, 1.0 );solid_brick( 61.0, 18.0, 1.0, 1.0 );solid_brick( 60.0, 17.0, 1.0, 1.0 );solid_brick( 59.0, 16.0, 1.0, 1.0 );solid_brick( 58.0, 15.0, 1.0, 1.0 );solid_brick( 58.0, 14.0, 1.0, 1.0 );solid_brick( 58.0, 13.0, 1.0, 1.0 );solid_brick( 59.0, 12.0, 1.0, 1.0 );solid_brick( 60.0, 12.0, 1.0, 1.0 );solid_brick( 61.0, 13.0, 1.0, 1.0 );solid_brick( 62.0, 14.0, 1.0, 1.0 );coin( 1.0, 5.0 );coin( 1.0, 4.0 );coin( 0.0, 4.0 );coin( 0.0, 3.0 );coin( 0.0, 2.0 );coin( 0.0, 1.0 );coin( 1.0, 1.0 );coin( 1.0, 0.0 );coin( 1.0, 2.0 );coin( 2.0, -1.0 );solid_brick( 15.0, 0.0, 1.0, 1.0 );solid_brick( 14.0, 1.0, 1.0, 1.0 );solid_brick( 15.0, 2.0, 1.0, 1.0 );solid_brick( 16.0, 3.0, 1.0, 1.0 );solid_brick( 15.0, 4.0, 1.0, 1.0 );solid_brick( 14.0, 5.0, 1.0, 1.0 );solid_brick( 6.0, 7.0, 1.0, 1.0 );solid_brick( 7.0, 8.0, 1.0, 1.0 );solid_brick( 6.0, 9.0, 1.0, 1.0 );solid_brick( 5.0, 10.0, 1.0, 1.0 );solid_brick( 6.0, 10.0, 1.0, 1.0 );solid_brick( 7.0, 10.0, 1.0, 1.0 );solid_brick( 14.0, 6.0, 1.0, 1.0 );solid_brick( 15.0, 7.0, 1.0, 1.0 );solid_brick( 16.0, 8.0, 1.0, 1.0 );solid_brick( 15.0, 9.0, 1.0, 1.0 );solid_brick( 15.0, 10.0, 1.0, 1.0 );solid_brick( 16.0, 10.0, 1.0, 1.0 );teleporter( 13.0, 10.0 );teleporter( 15.0, -4.0 );solid_brick( 0.0, 2.0, 1.0, 1.0 );coin( 6.0, 2.0 );coin( 5.0, 3.0 );coin( 6.0, 3.0 );coin( 7.0, 3.0 );coin( 9.0, 3.0 );coin( 10.0, 3.0 );coin( 4.0, 3.0 );coin( 2.0, 3.0 );coin( 3.0, 3.0 );coin( 2.0, 1.0 );solid_brick( 2.0, 0.0, 1.0, 1.0 );coin( 10.0, 1.0 );solid_brick( 10.0, 0.0, 1.0, 1.0 );teleporter( 6.0, 1.0 );teleporter( 17.0, 10.0 );coin( -17.0, -4.0 );coin( -18.0, 0.0 );coin( -18.0, 4.0 );coin( -18.0, 9.0 );coin( -18.0, -8.0 );solid_brick( -7.0, 9.0, 1.0, 1.0 );coin( -13.0, 9.006 );coin( -14.0, 8.0 );coin( -14.0, 7.0 );coin( -13.0, 8.0 );coin( -13.0, 7.0 );coin( -13.0, 6.0 );coin( -13.0, 5.0 );coin( -13.0, 4.0 );coin( -13.0, 3.0 );coin( -14.0, 3.0 );coin( -15.0, 3.0 );coin( -16.0, 3.0 );coin( -17.0, 3.0 );coin( -18.0, 3.0 );coin( -18.0, 2.0 );coin( -17.0, 2.0 );coin( -16.0, 2.0 );coin( -15.0, 2.0 );coin( -14.0, 2.0 );coin( -13.0, 2.0 );coin( -13.0, 0.0 );coin( -13.0, -1.0 );coin( -14.0, -1.0 );coin( -15.0, -1.0 );coin( -16.0, -1.0 );coin( -17.0, -1.0 );coin( -18.0, -1.0 );coin( -18.0, -2.0 );coin( -17.0, -2.0 );coin( -16.0, -2.0 );coin( -15.0, -2.0 );coin( -14.0, -2.0 );coin( -13.0, -2.0 );coin( -13.0, -4.0 );coin( -13.0, -4.0 );coin( -13.0, -5.0 );coin( -14.0, -5.0 );coin( -15.0, -5.0 );coin( -15.0, -5.0 );coin( -16.0, -5.0 );coin( -17.0, -5.0 );coin( -17.0, -5.0 );coin( -18.0, -5.0 );coin( -18.0, -5.0 );coin( -18.0, -5.0 );coin( -18.0, -6.0 );coin( -18.0, -6.0 );coin( -17.0, -6.0 );coin( -16.0, -6.0 );coin( -16.0, -6.0 );coin( -16.0, -6.0 );coin( -16.0, -6.0 );coin( -15.0, -6.0 );coin( -14.0, -6.0 );coin( -13.0, -6.0 );coin( -12.0, -6.0 );coin( -12.0, -5.0 );coin( -12.0, -4.0 );coin( -11.0, -4.0 );coin( -11.0, -5.0 );coin( -11.0, -6.0 );coin( -10.0, -6.0 );
coin( -10.0, -5.0 );coin( -10.0, -4.0 );coin( -10.0, -3.0 );coin( -9.0, -3.0 );coin( -9.0, -4.0 );coin( -9.0, -5.0 );coin( -9.0, -6.0 );coin( -9.0, -8.0 );coin( -9.0, -9.0 );coin( -9.0, -10.0 );coin( -10.0, -8.0 );coin( -10.0, -7.0 );coin( -10.0, -9.0 );coin( -10.0, -10.0 );coin( -10.0, -11.0 );coin( -11.0, -11.0 );coin( -11.0, -10.0 );coin( -11.0, -9.0 );coin( -11.0, -8.0 );coin( -12.0, -8.0 );coin( -12.0, -9.0 );coin( -12.0, -10.0 );coin( -12.0, -11.0 );coin( -13.0, -8.0 );coin( -13.0, -9.0 );coin( -13.0, -10.0 );coin( -13.0, -11.0 );coin( -12.0, -2.0 );coin( -12.0, -1.0 );coin( -12.0, 0.0 );coin( -11.0, -1.0 );coin( -11.0, -2.0 );coin( -11.0, 0.0 );coin( -10.0, -2.0 );coin( -9.0, -2.0 );coin( -11.0, 2.0 );coin( -11.0, 3.0 );coin( -11.0, 4.0 );coin( -11.0, 5.0 );coin( -11.0, 6.0 );coin( -11.0, 6.0 );coin( -11.0, 7.0 );coin( -11.0, 7.0 );coin( -11.0, 7.0 );coin( -12.0, 7.0 );coin( -12.0, 6.0 );coin( -12.0, 5.0 );coin( -12.0, 3.0 );coin( -12.0, 2.0 );coin( -13.0, 3.0 );coin( -13.0, 3.0 );coin( -16.0, 3.0 );coin( -15.0, 3.0 );coin( -15.0, 3.0 );coin( -14.0, 3.0 );coin( -12.0, 3.0 );coin( -11.0, 3.0 );coin( -13.0, 9.006 );coin( -12.0, 9.006 );coin( -12.0, 8.0 );coin( -11.0, 8.0 );coin( -11.0, 9.0 );coin( -10.0, 9.0 );coin( -10.0, 8.0 );coin( -10.0, 7.0 );coin( -10.0, 6.0 );coin( -10.0, 5.0 );coin( -10.0, 4.0 );coin( -10.0, 3.0 );coin( -10.0, 2.0 );coin( -10.0, 1.0 );coin( -10.0, 0.0 );coin( -10.0, -1.0 );coin( -9.0, -1.0 );coin( -9.0, 0.0 );coin( -9.0, 1.0 );coin( -9.0, 2.0 );coin( -9.0, 3.0 );coin( -9.0, 4.0 );coin( -9.0, 5.0 );coin( -9.0, 6.0 );coin( -9.0, 7.0 );coin( -9.0, 8.0 );solid_brick( -8.0, -4.5, 1.0, 16.0 );door(-8.0, 4.0, -8.0, 8.0);button( -9.0, 9.0 );teleporter( -7.0, 10.0 );solid_brick( -14.0, -11.0, 1.0, 1.0 );solid_brick( -14.0, -10.0, 1.0, 1.0 );solid_brick( -14.0, -9.0, 1.0, 1.0 );solid_brick( -14.0, 3.0, 1.0, 1.0 );solid_brick( -14.0, 1.0, 1.0, 1.0 );solid_brick( -14.0, 2.0, 1.0, 1.0 );solid_brick( -14.0, -1.0, 1.0, 1.0 );solid_brick( -14.0, -2.0, 1.0, 1.0 );solid_brick( -14.0, -5.0, 1.0, 1.0 );solid_brick( -14.0, -6.0, 1.0, 1.0 );coin( -18.0, -7.0 );coin( -15.0, -3.0 );coin( -18.0, 0.0 );coin( -18.0, 1.0 );invisible_brick( -13.0, -7.0, 1.0, 1.0 );invisible_brick( -12.0, -7.0, 1.0, 1.0 );invisible_brick( -11.0, -7.0, 1.0, 1.0 );invisible_brick( -10.0, -7.0, 1.0, 1.0 );invisible_brick( -12.0, -3.0, 1.0, 1.0 );invisible_brick( -11.0, -3.0, 1.0, 1.0 );invisible_brick( -10.0, -3.0, 1.0, 1.0 );invisible_brick( -9.0, -3.0, 1.0, 1.0 );teleporter( -17.0, -11.0 );coin( -13.0, -3.0 );invisible_brick( -13.0, 1.0, 1.0, 1.0 );invisible_brick( -12.0, 1.0, 1.0, 1.0 );invisible_brick( -11.0, 1.0, 1.0, 1.0 );invisible_brick( -10.0, 1.0, 1.0, 1.0 );invisible_brick( -9.0, 5.0, 1.0, 1.0 );invisible_brick( -10.0, 5.0, 1.0, 1.0 );invisible_brick( -11.0, 5.0, 1.0, 1.0 );invisible_brick( -12.0, 5.0, 1.0, 1.0 );invisible_brick( -14.0, 8.0, 1.0, 1.0 );invisible_brick( -14.0, 7.0, 1.0, 1.0 );invisible_brick( -14.0, -8.0, 1.0, 1.0 );solid_brick( -12.0, -7.0, 1.0, 1.0 );solid_brick( -10.0, -7.0, 1.0, 1.0 );solid_brick( -12.0, -3.0, 1.0, 1.0 );solid_brick( -10.0, -3.0, 1.0, 1.0 );solid_brick( -12.0, 1.0, 1.0, 1.0 );solid_brick( -10.0, 1.0, 1.0, 1.0 );solid_brick( -12.0, 5.0, 1.0, 1.0 );solid_brick( -10.0, 5.0, 1.0, 1.0 );coin( -11.0, 5.0 );coin( -9.0, 5.0 );coin( -11.0, 1.0 );coin( -13.0, 1.0 );coin( -11.0, -3.0 );coin( -9.0, -3.0 );coin( -11.0, -6.0 );coin( -11.0, -7.0 );coin( -13.0, -7.0 );coin( -14.0, -8.0 );coin( -14.0, 8.0 );coin( -14.0, 7.0 );coin( 14.0, -5.0 );coin( 16.0, -5.0 );solid_brick( 16.0, -6.0, 1.0, 1.0 );solid_brick( 14.0, -6.0, 1.0, 1.0 );coin( 12.0, -6.0 );coin( 13.0, -7.0 );coin( 14.0, -7.0 );coin( 15.0, -7.0 );coin( 16.0, -7.0 );coin( 17.0, -6.0 );coin( 17.0, -7.0 );coin( 18.0, -6.0 );coin( -14.0, 6.0 );solid_brick( 39.0, 10.0, 1.0, 1.0 );solid_brick( 40.0, 9.0, 1.0, 1.0 );solid_brick( 41.0, 8.0, 1.0, 1.0 );solid_brick( 41.0, 9.0, 1.0, 1.0 );solid_brick( 40.0, 10.0, 1.0, 1.0 );solid_brick( 41.0, 10.0, 1.0, 1.0 );solid_brick( 44.5, 6.5, 8.0, 2.0 );solid_brick( 48.5, 4.0, 10.0, 3.0 );solid_brick( 55.0, 10.0, 1.0, 1.0 );walky2( 53.8, 10.0, 1.0, 10.0 );walky2( 154.8952, 10.2952, 0.40960002, -10.0 );solid_brick( 203.0, 10.0, 1.0, 1.0 );walky2( 106.293434, 7.106561, 6.7868776, 10.0 );
}


//ideas
//teleporter which makes it so you skip a problem.
//Numbers in a jail so that they can't escape.
//math problems.  
