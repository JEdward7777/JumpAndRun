import java.util.LinkedList;

import java.io.File;
import javax.sound.sampled.*;
import java.io.FileReader;

color blue = color( 0,0,255 );
color red = color( 255, 0, 0 );
color purple = color( 230,230,250 );

String[] level_codes = { "", "22222", "33333", "44444", "55555", "66666", "77777", "88888","99999", "45324", "11111", "12121" };

class EscMenu extends Menu{
  public void draw(){
    pushStyle();
    strokeWeight(10);
    stroke(255, 220, 43);
    fill(255, 249, 217, 230);
    
    float menu_width = 500;
    float menu_height = 400;
    
    
    rect( .5*(width-menu_width), .5*(height-menu_height), menu_width, menu_height, 20);
    
    textAlign(CENTER, BOTTOM);
    
    fill(0);
    textSize(30);
    text( "What do you want?\nPress Esc to continue\nPress q to quit\nPress r to restart\nPress n for the level choser.", width*.5, .5*(height-menu_height)+300 );
    
   
    popStyle();
  }
  public void keyPressed(){
    if( keyCode == ESC ){
      key = 0;
      menu = null;
    }else if( key== 'q' ){
      exit();
    }else if( key== 'r' ){
      menu = null;
      reset();
    }else if( key=='n' ){
       show_start_menu();
    }
  }
}

class StartMenu extends Menu{
  String code = "";
  boolean wrong_code = false;
  
  public void draw(){
    pushStyle();
    strokeWeight(10);
    stroke(255, 220, 43);
    fill(255, 249, 217, 230);
    
    float menu_width = 500;
    float menu_height = 400;
    
    
    rect( .5*(width-menu_width), .5*(height-menu_height), menu_width, menu_height, 20);
    
    textAlign(CENTER, BOTTOM);
    
    fill(0);
    textSize(30);
    text( "Type level code or press enter", width*.5, .5*(height-menu_height)+50 );
    
    //Draw box
    fill(255);
    Loc box_size = new Loc();
    Loc box_pos = new Loc();
    box_size.x = menu_width * .8;
    box_size.y = 100;
    box_pos.x = .5*width;
    box_pos.y = .5*(height-menu_height)+200;
    strokeWeight(5);
    rect( box_pos.x-.5*box_size.x, box_pos.y-.5*box_size.y, box_size.x, box_size.y, 10 );
    
    //now draw the code which is being typed
    fill(0);
    textSize(100);
    textAlign(LEFT, CENTER);
    text( code, box_pos.x-.5*box_size.x + 5, box_pos.y );
    
    //now draw wrong code text
    if( wrong_code ){
      textSize(30);
      fill( 255, 0, 0 );
      textAlign(CENTER, BOTTOM);
      text( "Wrong code", width*.5, .5*(height-menu_height)+300 );
    }
    
    popStyle();
  }
  public void keyPressed(){
    wrong_code = false;
    if( keyCode == BACKSPACE ){
      if( code.length() > 0 ){
        code = code.substring( 0, code.length()-1 );
      }
    }else if( keyCode == ESC ){
      key = 0;
      code = "";
    }else if( key==ENTER||key==RETURN ){
      testCode();
    }else{
      if( code.length() < 6 ){
        code = code + key;
        code = code.trim();
      }
    }
  }
  void testCode(){
    if( code.equals( "load" ) ){
      show_load_menu();
    }else{
    
    if( code.startsWith( "m" ) ){
        person.maker_mode = true;
        code = code.substring(1);
      }
      
      if( code.equals( "n" ) ) show_message_menu( "Starting new level", new DoSomething(){ public void do_it(){ start_level(-1); } } );
      
      boolean wrong_code = true;
      
      for( int i = 0; i < level_codes.length && wrong_code; ++i ){
        if( code.equals( level_codes[i] ) ){
          wrong_code = false;
          final int final_i = i;
          show_message_menu( "Starting level " + (i+1), new DoSomething(){ public void do_it(){ start_level(final_i); } } );
        }
      }
    }
  }
}
void show_start_menu(){
  menu = new StartMenu(); 
}


class LoadMenu extends Menu{
  String what = "";
  boolean bad_file = false;
  
  public void draw(){
    pushStyle();
    strokeWeight(10);
    stroke(255, 220, 43);
    fill(255, 249, 217, 230);
    
    float menu_width = 500;
    float menu_height = 400;
    
    
    rect( .5*(width-menu_width), .5*(height-menu_height), menu_width, menu_height, 20);
    
    textAlign(CENTER, BOTTOM);
    
    fill(0);
    textSize(30);
    text( "Type saved name and press enter", width*.5, .5*(height-menu_height)+50 );
    
    //Draw box
    fill(255);
    Loc box_size = new Loc();
    Loc box_pos = new Loc();
    box_size.x = menu_width * .8;
    box_size.y = 100;
    box_pos.x = .5*width;
    box_pos.y = .5*(height-menu_height)+200;
    strokeWeight(5);
    rect( box_pos.x-.5*box_size.x, box_pos.y-.5*box_size.y, box_size.x, box_size.y, 10 );
    
    //now draw the code which is being typed
    fill(0);
    textSize(100);
    textAlign(LEFT, CENTER);
    text( what, box_pos.x-.5*box_size.x + 5, box_pos.y );
    
    //now draw wrong code text
    if( bad_file ){
      textSize(30);
      fill( 255, 0, 0 );
      textAlign(CENTER, BOTTOM);
      text( "Bad filename", width*.5, .5*(height-menu_height)+300 );
    }
    
    popStyle();
  }
  public void keyPressed(){
    bad_file = false;
    if( keyCode == BACKSPACE ){
      if( what.length() > 0 ){
        what = what.substring( 0, what.length()-1 );
      }
    }else if( keyCode == ESC ){
      key = 0;
      what = "";
    }else if( key==ENTER||key==RETURN ){
      tryLoad();
    }else{
      what = what + key;
    }
  }
  void tryLoad(){
    File newFile = new File(sketchPath(),what+ ".lvl");
    
    println( "Checking if found " + newFile.getAbsoluteFile() );
  
    
    if( !newFile.exists() ){
      bad_file = true;
    }else{
      show_message_menu( "Loading " + what, new DoSomething(){ public void do_it(){ load_level( what ); } } );
    }
  }
}
void show_load_menu(){
  menu = new LoadMenu(); 
}

class SaveMenu extends Menu{
  String what = level_name;
  
  public void draw(){
    pushStyle();
    strokeWeight(10);
    stroke(255, 220, 43);
    fill(255, 249, 217, 230);
    
    float menu_width = 500;
    float menu_height = 400;
    
    
    rect( .5*(width-menu_width), .5*(height-menu_height), menu_width, menu_height, 20);
    
    textAlign(CENTER, BOTTOM);
    
    fill(0);
    textSize(30);
    text( "Type name to save as", width*.5, .5*(height-menu_height)+50 );
    
    //Draw box
    fill(255);
    Loc box_size = new Loc();
    Loc box_pos = new Loc();
    box_size.x = menu_width * .8;
    box_size.y = 100;
    box_pos.x = .5*width;
    box_pos.y = .5*(height-menu_height)+200;
    strokeWeight(5);
    rect( box_pos.x-.5*box_size.x, box_pos.y-.5*box_size.y, box_size.x, box_size.y, 10 );
    
    //now draw the code which is being typed
    fill(0);
    textSize(100);
    textAlign(LEFT, CENTER);
    text( what, box_pos.x-.5*box_size.x + 5, box_pos.y );
    
    
    popStyle();
  }
  public void keyPressed(){
    if( keyCode == BACKSPACE ){
      if( what.length() > 0 ){
        what = what.substring( 0, what.length()-1 );
      }
    }else if( keyCode == ESC ){
      key = 0;
      menu = null;
    }else if( key==ENTER||key==RETURN ){
      trySave();
    }else{
      what = what + key;
    }
  }
  void trySave(){
    
    String filename = what;
    if( !filename.endsWith( ".lvl" ) ){
      filename += ".lvl";
    }
    
    File newFile = new File(sketchPath(),filename);
   
    
    println( "Checking if found " + newFile.getAbsoluteFile() );
  
    
    if( newFile.exists() ){
      show_confirm_menu( "Do you want to overwrite " + what + "?", 
        new DoSomething(){ public void do_it(){ show_message_menu( "Overwriting " + what, new DoSomething(){ public void do_it(){ save_level( what ); } } ); } },
        new DoSomething(){ public void do_it(){  show_save_menu();   } } );
    }else{
      show_message_menu( "Saving " + what, new DoSomething(){ public void do_it(){ save_level( what ); } } );
    }
  }
}
void show_save_menu(){
  menu = new SaveMenu(); 
}

class ConfirmMenu extends Menu{
  String message = null;
  DoSomething yesDo = null;
  DoSomething noDo = null;
  
  public ConfirmMenu( String message, DoSomething yesDo, DoSomething noDo ){
    this.message = message;
     this.yesDo = yesDo;
     this.noDo = noDo;
  }
  
  
  public void draw(){
    pushStyle();
    strokeWeight(10);
    stroke(255, 220, 43);
    fill(255, 249, 217, 230);
    
    float menu_width = 500;
    float menu_height = 100;
    
    
    rect( .5*(width-menu_width), .5*(height-menu_height), menu_width, menu_height, 20);
    
    textAlign(CENTER, BOTTOM);
    
    fill(0);
    textSize(30);
    text( this.message + "\nPress Y or N", width*.5, .5*(height-menu_height)+90 );
  
   
    popStyle();
  }
  public void keyPressed(){
    if( keyCode == ESC ){
      key = 0;
      menu = null;
    }else if( key == 'y' || key == 'Y' ){
      menu = null;
      yesDo.do_it();
    }else if( key == 'n' || key == 'N' ){
      menu = null;
      noDo.do_it();
    }
  }
}
void show_confirm_menu( String message, DoSomething yesDo, DoSomething noDo ){
  menu = new ConfirmMenu( message, yesDo, noDo ); 
}


abstract class DoSomething{
  abstract void do_it();
}

class MessageMenu extends Menu{
  String message = null;
  DoSomething what_next = null;
  public MessageMenu( String message, DoSomething what_next ){
    this.message = message;
    this.what_next = what_next;
  }
  
  public void draw(){
    pushStyle();
    strokeWeight(10);
    stroke(255, 220, 43);
    fill(255, 249, 217, 230);
    
    float menu_width = 600;
    float menu_height = 100;
    rect( .5*(width-menu_width), .5*(height-menu_height), menu_width, menu_height, 20);
    
    textAlign(CENTER, BOTTOM);
    
    fill(0);
    textSize(30);
    text( message, width*.5, .5*(height-menu_height)+50 );
    
    popStyle();
  }
  public void keyPressed(){
    
    
    
    println( "keyPressed on menu with message " + message );
    menu = null;
    if( this.what_next != null ) this.what_next.do_it();
    
    if( keyCode == ESC ) key = 0;
  }
}

void show_message_menu( String message, DoSomething ds ){
  menu = new MessageMenu( message, ds );
  println( "menu changed to one with message " + message );
}

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
  
  public float angle(){
     return atan2(y,x); 
  }
  
  public String toString(){
    return "(" + x + "," + y + ")";
  }
}

Loc polar_loc( float r, float angle ){
  return new Loc( r*cos(angle), r*sin(angle) ); 
}

Loc block_size = new Loc(50,50);

Loc gravity = new Loc(0,.3);


class Touch{
  Loc overlap = new Loc(0,0);
  boolean touching = false;
}
Touch not_touching = new Touch();

abstract class Thing{
  boolean in_water = false;
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
  public void do_shift_action(Person person){};
  
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

class GravitySwitch extends Thing{
  float timeout = 0;
  boolean unlocked = true;
  Loc target_gravity = new Loc(0,.3);
  public void interact( Thing other_thing, boolean is_person ){
    Touch touch = other_thing.how_am_I_touching( this );
    if( is_person ){
      if( timeout > 0 ){
        timeout -= 1;
        if( touch.touching )other_thing.solid_push(touch.overlap);
      }else{
        if( touch.touching && touch.overlap.r() > .5 ){
          other_thing.solid_push(touch.overlap);
          if( unlocked ){
            timeout = 100;
            gravity = target_gravity.copy();
          }
        }
      }
    }else{
        if( touch.touching )other_thing.solid_push(touch.overlap);
    } 
  }
  public String save(){
    return "   gravity_switch(" + (loc.x/block_size.x) + "," + (loc.y/block_size.y) + "," + target_gravity.x + "," + target_gravity.y + ");";
  }
  public void take_hit(int amount){}
  public void solid_push( Loc loc ){}
  public void draw(){
    fill(4, 13, 184);
    rect(loc.x-.5*size.x, loc.y-.5*size.y, size.x, size.y, 7);
    line(loc.x,loc.y,loc.x+target_gravity.x*40,loc.y+target_gravity.y*40);
  }
}
void gravity_switch( float x, float y, float gravity_x, float gravity_y ){
   GravitySwitch thing = new GravitySwitch();
   thing.loc.x = x*block_size.x;
   thing.loc.y = y*block_size.y;
   thing.target_gravity.x = gravity_x;
   thing.target_gravity.y = gravity_y;
   all_things.add(thing);
}
GravitySwitch last_gravity_switch = null;
void gravity_switch2( float x, float y, float gravity_x, float gravity_y ){
   GravitySwitch thing = new GravitySwitch();
   thing.loc.x = x*block_size.x;
   thing.loc.y = y*block_size.y;
   thing.target_gravity.x = gravity_x;
   thing.target_gravity.y = gravity_y;
   all_things.add(thing);
   last_gravity_switch = thing;
}

abstract class PickupAble extends Thing{
  Thing carried_by = null;
  
  public void draw(){
    if( carried_by == null ){
        loc = loc.plus( speed );
        
        float bottom = loc.y+.5*size.y;
        
        
        
        speed = speed.plus( gravity );
        if( bottom > floor ){
          this.solid_push( new Loc(0,floor-bottom) );
        }
        
        for( Thing other_thing : all_things ){
           other_thing.interact(this, false); 
        }  
    }else{
        loc = carried_by.loc.copy();
        loc.y -= (carried_by.size.y+this.size.y)*.5*.75;
    }
  }
  public void interact( Thing thing, boolean is_person ){
  }
  public void solid_push( Loc push ){
    //This is a brick telling us how much we are intersecting.
    if( push.y != 0 )if( (push.y > 0) != (speed.y > 0) ) speed.y = 0;
    if( push.x != 0 )if( (push.x > 0) != (speed.x > 0) ) speed.x = 0;
    loc = loc.plus(push);
  }
  public void do_shift_action( Person person ){
    if( carried_by == null ){
      carried_by = person;
    }else{
      carried_by = null;
    }
  }
}

//from https://processing.org/examples/star.html
void star(float x, float y, float radius1, float radius2, int npoints) {
  float angle = TWO_PI / npoints;
  float halfAngle = angle/2.0;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius2;
    float sy = y + sin(a) * radius2;
    vertex(sx, sy);
    sx = x + cos(a+halfAngle) * radius1;
    sy = y + sin(a+halfAngle) * radius1;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}
class Key extends PickupAble{
  int r,g,b;
  public Key( int r, int g, int b, float x, float y ){
    this.r = r; this.g = g; this.b = b;
    this.loc.x = x;
    this.loc.y = y;
    all_keys.add(this);
  }
  public String save(){
    return "   key(" + r + "," + g + "," + b + "," + (loc.x/block_size.x) + "," + (loc.y/block_size.y) + ");";
  }
  public void take_hit( int hurt_amount ){}
  public void draw(){
    super.draw();
    fill(r,g,b);
    star( loc.x, loc.y, size.x*.25, size.x*.5, 5 );
  }
}
void key( int r, int g, int b, float x, float y ){
   Key thing = new Key(r,g,b,x*block_size.x,y*block_size.y);
   all_things.add(thing);
}

class Water extends Thing{
  public void draw(){
    pushStyle();
    noStroke();
    fill( 0, 136, 255, 50 );
    rect(loc.x-.5*size.x, loc.y-.5*size.y, size.x, size.y, 0);
    popStyle();
  }
  public void interact( Thing other_thing, boolean is_person ){
    if( other_thing == this ) return;
    Touch touch = other_thing.how_am_I_touching( this );
    if( touch.touching ){
      other_thing.speed = other_thing.speed.times(.9);
      other_thing.in_water = true;
    }
  }
  public void solid_push( Loc loc ){
    //ignore pushes we are a brick
  }
  
  public void take_hit( int hurt_amount ){
    //nothing for now
  }
  
  public String save(){
    return "   water( " + (loc.x/block_size.x) + ", " + (loc.y/block_size.y) + ", " + (size.x/block_size.x) + ", " + (size.y/block_size.y) + " );";
  }
}

void water( float x, float y, float brick_width, float brick_height ){
   Water thing = new Water();
   thing.loc.x = x*block_size.x;
   thing.loc.y = y*block_size.y;
   thing.size.x = brick_width*block_size.x;
   thing.size.y = brick_height*block_size.y;
   all_things.add( thing );
   last_last_thing = last_thing;
   last_thing = thing;
}

float walk_speed = 10;
float jump_speed = 14;
float floor = block_size.y*10.5;

LinkedList< Thing > things_to_add = new LinkedList< Thing >();
LinkedList< Thing > things_to_remove = new LinkedList< Thing >();
LinkedList< Thing > all_things = new LinkedList< Thing >();
LinkedList< Key >   all_keys   = new LinkedList< Key >();
void remove_things(){
  things_to_add.clear();
  things_to_remove.clear();
  all_things.clear();
  all_keys.clear();
  all_things.add(person);
  person.dead = false;
  gravity = new Loc(0,.3);
  last_teleporter = null;
}

class Person extends Thing{
  boolean maker_mode = false;
  boolean dead = false;
  Loc desired_direction = new Loc();
  
  int points = 0;
  
  public Person(){
     loc.x = 640/2;
  }
  public void draw(){
    if( !maker_mode ){
      if( !dead ){
        float bottom = loc.y+.5*size.y;
        
        float go_speed = walk_speed;
        if( in_water ) go_speed *= .5;
        
        if( abs(gravity.y) > abs(gravity.x) ){
          speed.x = desired_direction.x*go_speed;
          if( person.in_water )speed.y = desired_direction.y*go_speed;
          if( gravity.y > 0 ){
             if( desired_direction.y >= 0 && speed.y < 0 ) speed.y = 5;
          }else{
             if( desired_direction.y <= 0 && speed.y > 0 ) speed.y = -5;
          }
        }else{
          speed.y = desired_direction.y*go_speed;
          if( person.in_water )speed.x = desired_direction.x*go_speed;
          
          if( gravity.x > 0 ){
             if( desired_direction.x >= 0 && speed.x < 0 ) speed.x = 5;
          }else{
             if( desired_direction.x <= 0 && speed.x > 0 ) speed.x = -5;
          }
        }
        
        
          
        
        speed = speed.plus( gravity );
        
        if( bottom > floor ){
          this.solid_push( new Loc(0,floor-bottom) );
        }
        
        in_water = false;
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
    if( abs(gravity.y) > abs(gravity.x) ){
      if( gravity.y > 0 ){
        if( desired_direction.y < 0 && push.y < 0 ) jump();
      }else{
        if( desired_direction.y > 0 && push.y > 0 ) jump();
      }
    }else{
      if( gravity.x > 0 ){
        if( desired_direction.x < 0 && push.x < 0 ) jump();
      }else{
        if( desired_direction.x > 0 && push.x > 0 ) jump();
      }
    }
      
    loc = loc.plus(push);
  }
  public void jump(){
    if( abs(gravity.y) > abs(gravity.x) ){
      if( abs(person.speed.y) < .4 ){
        if( gravity.y > 0 ){
          person.speed.y = -jump_speed;
        }else{
          person.speed.y = jump_speed;
        }
      }
    }else{
      if( abs(person.speed.x) < .4 ){
        if( gravity.x > 0 ){
          person.speed.x = -jump_speed;
        }else{
          person.speed.x = jump_speed;
        }
      }
    }
  }
  public void set_in_water(){
    in_water = true;
  }
  public void take_hit( int hurt_amount ){
      dead=true;
      points -= 10;
      
      sad_sound.setFramePosition(0);
      sad_sound.start();
  }
  public String save(){ return ""; }
  
  public void figure_shift_action(){
    for( Thing thing : all_things ){
      Touch t = person.how_am_I_touching( thing ); 
      if( t.touching && t.overlap.r() > .5 ){
        thing.do_shift_action(this);
      }
    }
    println( "In figure_shift_action" );
  }
}

void keyReleased(){
  if( keyCode == RIGHT && person.desired_direction.x > 0 ){
    person.desired_direction.x = 0;
  }else if( keyCode == LEFT && person.desired_direction.x < 0 ){  
    person.desired_direction.x = 0;
  }else if( keyCode == DOWN && person.desired_direction.y > 0 ){  
    person.desired_direction.y = 0;
  }else if( (keyCode == UP || key == ' ') && person.desired_direction.y < 0 ){  
    person.desired_direction.y = 0;
  }
}

void reset(){
    if( the_start_block != null ){
      person.loc = the_start_block.loc.copy();
      person.speed = new Loc(0,0);
    }else{
      person.loc = new Loc(0,0);
    }
    person.dead = false;
}

void keyPressed() {
  //println( keyCode );
  if( menu != null ){
    menu.keyPressed();
  }else if( keyCode == ESC ){
    key = 0;
    menu = new EscMenu();
  }else if( !person.maker_mode ){
    if( key == 'm' ){
      person.maker_mode = !person.maker_mode;
    }else if( keyCode == SHIFT ){
      person.figure_shift_action(); 
    }else if( key == 'r' ){
      reset();
    }else if( keyCode == UP || key == ' ' ){
      person.desired_direction.y = -1;
    }else if( keyCode == DOWN ){
      person.desired_direction.y = 1;
    }else if( keyCode == LEFT ){
      person.desired_direction.x = -1;
    }else if( keyCode == RIGHT ){
      person.desired_direction.x = 1;
    }
  }else{
    if( keyCode == LEFT ){
      person.loc.x = (round(person.loc.x/block_size.x)-1)*block_size.x;
      if( last_gravity_switch != null ){
        last_gravity_switch.target_gravity = new Loc(-.3,0);
        last_gravity_switch = null;
      }
    }else if( keyCode == RIGHT ){
      person.loc.x = (round(person.loc.x/block_size.x)+1)*block_size.x;
      if( last_gravity_switch != null ){
        last_gravity_switch.target_gravity = new Loc(.3,0);
        last_gravity_switch = null;
      }
    }else if( keyCode == UP ){
      person.loc.y = (round(person.loc.y/block_size.y)-1)*block_size.y;
      if( last_gravity_switch != null ){
        last_gravity_switch.target_gravity = new Loc(0,-.3);
        last_gravity_switch = null;
      }
    }else if( keyCode == DOWN ){
      person.loc.y = (round(person.loc.y/block_size.y)+1)*block_size.y;
      if( last_gravity_switch != null ){
        last_gravity_switch.target_gravity = new Loc(0,.3);
        last_gravity_switch = null;
      }
    }else if( key == 'm' ){
      person.maker_mode = !person.maker_mode;
    }else if( key == 'g' ){
      gravity_switch2(  person.loc.x/block_size.x, person.loc.y/block_size.y, 0, .3 );
    }else if( key == 'c' ){
      coin( person.loc.x/block_size.x, person.loc.y/block_size.y );
    }else if( key == 'w' ){
       walky( person.loc.x/block_size.x, person.loc.y/block_size.y, -5 );
    }else if( key == 'k' ){
       laser_spike( person.loc.x/block_size.x, person.loc.y/block_size.y, 1, -.8 );
    }else if( key == 'y' ){
      walking_brick( person.loc.x/block_size.x, person.loc.y/block_size.y, 1, 1, 1 );
      print( "placed at " + person.loc.x/block_size.x + "," + person.loc.y/block_size.y );
    }else if( key == 'o' ){
      bouncy( person.loc.x/block_size.x, person.loc.y/block_size.y, 1, -5 );
    }else if( key == 'l' ){
      loopy( person.loc.x/block_size.x, person.loc.y/block_size.y, 1, -.2, .7 );
    }else if( key == 'p' ){
      spike( person.loc.x/block_size.x, person.loc.y/block_size.y, .7, 1 );
    }else if( key == 'f' ){
       fish( person.loc.x/block_size.x, person.loc.y/block_size.y, 1, 2 );
    }else if( key == 'b' ){
      solid_brick(  person.loc.x/block_size.x, person.loc.y/block_size.y, 1, 1 );
    }else if( key == 'a' ){
      water(  person.loc.x/block_size.x, person.loc.y/block_size.y, 1, 1 );
    }else if( key == 'i' ){
      invisible_brick(  person.loc.x/block_size.x, person.loc.y/block_size.y, 1, 1 );
    }else if( key == 'q' ){
      //make a thick brick
      if( last_last_thing != null && last_thing != null ){
        things_to_remove.add(last_last_thing);
        Loc center = (last_last_thing.loc.plus(last_thing.loc)).times(.5);
        Loc size   = (last_last_thing.loc.minus(last_thing.loc));
        size.x = abs(size.x);
        size.y = abs(size.y);
        size = size.plus(block_size);
        last_thing.size = size;
        last_thing.loc = center;
      }
    }else if( key == '2' ){
      key(  255, 0, 0, person.loc.x/block_size.x, person.loc.y/block_size.y );
    }else if( key == '3' ){
      keyed_button(  255, 0, 0, person.loc.x/block_size.x, person.loc.y/block_size.y );
    }else if( key == '4' ){
      key(  0, 255, 0, person.loc.x/block_size.x, person.loc.y/block_size.y );
    }else if( key == '5' ){
      keyed_button(  0, 255, 0, person.loc.x/block_size.x, person.loc.y/block_size.y );
    }else if( key == '6' ){
      key(  0, 0, 255, person.loc.x/block_size.x, person.loc.y/block_size.y );
    }else if( key == '7' ){
      keyed_button(  0, 0, 255, person.loc.x/block_size.x, person.loc.y/block_size.y );
    }else if( keyCode == CONTROL ){
      maker_maker( person.loc.x/block_size.x, person.loc.y/block_size.y, 1, -2 );
    }else if( key == 's' ){
      show_save_menu();
      //String level = "";
      //int added_length = 0;
      //for( Thing thing : all_things ){
      //  String thing_save = thing.save().trim();
      //  added_length += thing_save.length();
      //  level += thing_save;
      //  if( added_length > 7000 ){
      //    added_length = 0;
      //    level += "\n";
      //  }
      //}
      //println( level );
      
      
      
      //PrintWriter fout = createWriter( "" + year() + "_" + month() + "_" + day() + "_" + hour() + " " + minute() + "_" + second() + ".txt" );
      //fout.println( level );
      //fout.flush();
      //fout.close();
    }else if( key == 'd' ){
      for( Thing thing : all_things ){
        Touch t = person.how_am_I_touching( thing ); 
        if( t.touching && t.overlap.r() > .5 ){
          things_to_remove.add( thing ); 
        }
      }
    }else if( key == 'r' ){
      if( last_last_thing != null && last_thing != null ){
        things_to_remove.add( last_last_thing );
        things_to_remove.add( last_thing );
        door( last_last_thing.loc.x/block_size.x, last_last_thing.loc.y/block_size.y, last_thing.loc.x/block_size.x, last_thing.loc.y/block_size.y );
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
    }else if( key == '1' ){
      start_block(  person.loc.x/block_size.x, person.loc.y/block_size.y );
    }else if( key == 'e' ){
      end_block(  person.loc.x/block_size.x, person.loc.y/block_size.y );
    }else if( key == '=' ){
      show_load_menu();
    }else{
      println( "key == '" + key + "'" );
    }
  }
}



class StartBlock extends Thing{
  
  public void draw(){
    if( person.maker_mode ){
      fill( 53, 232, 68 );
      rect(loc.x-.5*size.x, loc.y-.5*size.y, size.x, size.y, 7);
    }
  }
  public void interact( Thing other_thing, boolean is_person ){}
  public void solid_push( Loc loc ){}
  
  public void take_hit( int hurt_amount ){}
  
  public String save(){
    return "   start_block(" + (loc.x/block_size.x) + "," + (loc.y/block_size.y) + ");";
  }
  
}
StartBlock the_start_block = null;
void start_block( float x, float y ){
   StartBlock thing = new StartBlock();
   thing.loc.x = x*block_size.x;
   thing.loc.y = y*block_size.y;
   all_things.add(thing);
   person_init( x, y );
   the_start_block = thing;
}


class EndBlock extends Thing{
  boolean activated = false;
  public void draw(){
    fill( 201, 0, 185 );
    rect(loc.x-.5*size.x, loc.y-.5*size.y, size.x, size.y, 7);
  }
  public void interact( Thing other_thing, boolean is_person ){
    if( is_person ){
      Touch touch = other_thing.how_am_I_touching( this );
      if( touch.touching ){
        if( !activated ){
          win_sound.setFramePosition(0);
          win_sound.start();
          this.activated = true;
          show_message_menu( "You finished level " + level_name + " with " + person.points + " points.", new DoSomething(){ public void do_it(){
            //loaded levels are -1 and they don't have a next level.
            if( current_level_number == -1 ){
              //after showing that they are done, don't do something just in case they still want to save.
            }else if( current_level_number + 1 == level_codes.length ){
              println( "option 1" );
              show_message_menu( "You finished all the levels!!  Your score is " + person.points, new DoSomething(){ public void do_it(){ show_start_menu(); } });
            }else{
              println( "option 2 current_level_number is " + current_level_number );
              show_message_menu( "The code for level " + (current_level_number+2) + " is " + level_codes[current_level_number+1], new DoSomething(){ public void do_it(){
                show_message_menu( "Starting level " + (current_level_number+2) + "!", new DoSomething(){ public void do_it(){
                  start_level( current_level_number+1 );
                }});
              }});
            }
          }});
        }
      }
    }
  }
  public void solid_push( Loc loc ){}
  
  public void take_hit( int hurt_amount ){}
  
  public String save(){
    return "   end_block(" + (loc.x/block_size.x) + "," + (loc.y/block_size.y) + ");";
  }
}
void end_block( float x, float y ){
   EndBlock thing = new EndBlock();
   thing.loc.x = x*block_size.x;
   thing.loc.y = y*block_size.y;
   all_things.add(thing);
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
Thing last_last_thing = null;
Thing last_thing = null;
void solid_brick( float x, float y, float brick_width, float brick_height ){
   SolidBrick new_brick = new SolidBrick();
   new_brick.loc.x = x*block_size.x;
   new_brick.loc.y = y*block_size.y;
   new_brick.size.x = brick_width*block_size.x;
   new_brick.size.y = brick_height*block_size.y;
   all_things.add( new_brick );
   last_last_thing = last_thing;
   last_thing = new_brick;
}




class WalkingBrick extends SolidBrick{
  static final int RESTING = 0;
  static final int MOVING_UP = 1;
  static final int MOVING_FORWARD = 2;
  static final int MOVING_DOWN = 3;
  
  int block_state = RESTING;
  int foot_state = RESTING;
  
  float timer = 500;
  
  Loc moving_foot = new Loc();
  Loc other_foot = new Loc();
  
  float speed_x = 1;
  int dir = -1;
  
  public void draw(){
    float extra_standing_y = size.y*.25;
    float saved_size_y = size.x;
    float foot_span = .8*size.x;
    float foot_lift = .2*size.x;
    float foot_lift_speed = 2;
    float foot_forward_multiple = 4;
    
    if( !person.maker_mode ){
       
      if( block_state == RESTING ){
        if( timer > 0 ){
          timer--;
        }else{
          block_state = MOVING_UP;
          timer = 0;
          
          moving_foot.y = other_foot.y = loc.y + .5*size.y;
          //if( dir > 0 ){
          //  moving_foot.x = loc.x + .5*foot_span;
          //  other_foot.x = loc.x - .5*foot_span;
          //}else{
          //  moving_foot.x = loc.x - .5*foot_span;
          //  other_foot.x = loc.x + .5*foot_span;
          //}
        }
      }else if( block_state == MOVING_UP ){
        if( timer < extra_standing_y ){
          timer++;
          size.y = saved_size_y + timer;
        }else{
          block_state = MOVING_FORWARD;
          speed.x = speed_x*dir;
          timer = random(300);
        }
        
      }else if( block_state == MOVING_FORWARD ){
        if( timer > 0 ){
          timer--;
          
          if( foot_state == RESTING ){
            foot_state = MOVING_UP;
          }else if( foot_state == MOVING_UP ){
            if( moving_foot.y > loc.y+.5*size.y-foot_lift ){
              moving_foot.y-=foot_lift_speed;
            }else{
              foot_state = MOVING_FORWARD;
            }
          }else if( foot_state == MOVING_FORWARD ){
            if( dir > 0 ){
              moving_foot.x += speed_x*foot_forward_multiple;
              if( moving_foot.x > loc.x+.5*foot_span ) foot_state = MOVING_DOWN;
            }else{
              moving_foot.x -= speed_x*foot_forward_multiple;
              if( moving_foot.x < loc.x-.5*foot_span ) foot_state = MOVING_DOWN;
            }
          }else if( foot_state == MOVING_DOWN ){
            if( moving_foot.y < loc.y+.5*size.y ){
              moving_foot.y+=foot_lift_speed;
            }else{
              Loc temp = moving_foot;
              moving_foot = other_foot;
              other_foot = temp;
              foot_state = MOVING_UP;
            }
          }
              
        }else{
          block_state = MOVING_DOWN;
          timer = extra_standing_y;
          speed.x = 0;
          
          moving_foot.y = other_foot.y = loc.y + .5*size.y;
        }
        
      }else if( block_state == MOVING_DOWN ){
        if( timer > 0 ){
          timer--;
          size.y = saved_size_y + timer;
        }else{
          size.y = saved_size_y;
          block_state = RESTING;
          timer = random(500);
          //timer = random(100);
        }
      }
      
      
        
      float bottom = loc.y+.5*size.y;
      
      speed = speed.plus( gravity );
      loc = loc.plus( speed ); 
      
      if( bottom > floor ){
        this.solid_push( new Loc(0,floor-bottom) ); 
      }
      
      for( Thing other_thing : all_things ){
         other_thing.interact(this,false); 
      }
      
      //pull feet to us if we are too far away.
      if( loc.minus(moving_foot).r() > size.x*2 ) moving_foot = loc.plus(polar_loc( size.x*2, moving_foot.minus(loc).angle() ));
      if( loc.minus(other_foot ).r() > size.x*2 ) other_foot  = loc.plus(polar_loc( size.x*2, other_foot.minus(loc ).angle() ));
      
      
    }
    
    //draw legs
    pushStyle();
    strokeWeight(2);
    stroke(0);
    line( moving_foot.x, moving_foot.y-1, max(loc.x-.5*size.x,min(loc.x+.5*size.x,moving_foot.x)), loc.y );
    line( other_foot.x, other_foot.y-1, max(loc.x-.5*size.x,min(loc.x+.5*size.x,other_foot.x)), loc.y );
    float toe_length = .13*size.x*dir;
    line( moving_foot.x, moving_foot.y-1, moving_foot.x+toe_length, moving_foot.y-1 );
    line( other_foot.x, other_foot.y-1, other_foot.x+toe_length, other_foot.y-1 );
    popStyle();
    
    //draw body
    fill( red );
    float body_y = loc.y-.5*size.y+.5*saved_size_y;
    rect(loc.x-.5*size.x, body_y-.5*saved_size_y, size.x, saved_size_y, 7);
  }
  
  public void interact( Thing other_thing, boolean is_person ){
    if( other_thing == this ) return;
    Touch touch = other_thing.how_am_I_touching( this );
    if( touch.touching ){
      //another badguy touch like a brick
      other_thing.solid_push( touch.overlap.times(.5) );
      this.solid_push( touch.overlap.times(-.5) );
      if( is_person && block_state == MOVING_FORWARD && person.desired_direction.x == 0 ){
        other_thing.speed.x = this.speed.x;
      }
    }
  }
  public void solid_push( Loc push ){
    //This is a brick telling us how much we are intersecting.
    if( push.y != 0 )if( (push.y > 0) != (speed.y > 0) ) speed.y = 0;
    if( push.x != 0 )if( (push.x > 0) != (speed.x > 0) ){
      speed.x *= -1;
      if( dir > 0 ){
        dir = -1;
      }else{
        dir = 1;
      }
    }
    loc = loc.plus(push);
  }
  
  
  public String save(){
    return "   walking_brick(" + (loc.x/block_size.x) + "," + (loc.y/block_size.y) + "," + (size.x/block_size.x) + "," + (size.x/block_size.y) + "," + this.speed_x*this.dir + ");";
  }
}

void walking_brick( float x, float y, float brick_width, float brick_height, float speed ){
   WalkingBrick new_brick = new WalkingBrick();
   new_brick.loc.x = x*block_size.x;
   new_brick.loc.y = y*block_size.y;
   new_brick.size.x = brick_width*block_size.x;
   new_brick.size.y = brick_height*block_size.y;
   if( speed < 0 ){
     new_brick.speed_x = -speed;
     new_brick.dir = -1;
   }else{
     new_brick.speed_x = speed;
     new_brick.dir = 1;
   }
   //if( new_brick.dir > 0 ){
   //   new_brick.moving_foot.x = new_brick.loc.x + .5*new_brick.size.x;
   //   new_brick.other_foot.x = new_brick.loc.x - .5*new_brick.size.x;
   //}else{
   //   new_brick.moving_foot.x = new_brick.loc.x - .5*new_brick.size.x;
   //   new_brick.other_foot.x = new_brick.loc.x + .5*new_brick.size.x;
   //}
   new_brick.moving_foot.x = new_brick.other_foot.x = new_brick.loc.x;
   new_brick.moving_foot.y = new_brick.other_foot.y = new_brick.loc.y+new_brick.size.y*.5;
   
   all_things.add( new_brick );
   
   last_growable = new_brick;
   last_last_thing = last_thing;
   last_thing = new_brick;
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
   last_last_thing = last_thing;
   last_thing = new_brick;
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
  boolean unlocked = true;
  public void interact( Thing other_thing, boolean is_person ){
    Touch touch = other_thing.how_am_I_touching( this );
    if( is_person || other_thing instanceof LaserLight ){
      if( timeout > 0 ){
        timeout -= 1;
        if( touch.touching )other_thing.solid_push(touch.overlap);
      }else{
        if( touch.touching && touch.overlap.r() > .5 ){
          other_thing.solid_push(touch.overlap);
          if( unlocked ){
            timeout = 100;
            if( door != null )door.is_open = !door.is_open;
            
            if(door.is_open){
              open_door_sound.setFramePosition(0);
              open_door_sound.start();
            }else{
              close_door_sound.setFramePosition(0);
              close_door_sound.start();
            }
          }
        }
      }
    }else{
        if( touch.touching )other_thing.solid_push(touch.overlap);
    } 
  }
  public String save(){
    return "   button( " + (loc.x/block_size.x) + ", " + (loc.y/block_size.y) + " );";
  }
  public void take_hit(int amount){}
  public void solid_push( Loc loc ){}
  public void draw(){
    if( !unlocked ){
      fill( 189, 40, 122 );
    }else if( timeout > 0 ){
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
class KeyedButton extends Button{
  int r,g,b;
  public KeyedButton( int r, int g, int b, float x, float y ){
    this.r = r; this.g = g; this.b = b;
    this.loc.x = x; this.loc.y = y;
    this.unlocked = false;
  }
  void draw(){
    super.draw();
    fill(r,g,b);
    star( loc.x, loc.y, size.x*.25*.75, size.x*.5*.75, 5 );
    
    this.unlocked = false;
    for( Key key : all_keys ){
      if( key.r == this.r && key.g == this.g && key.b == this.b ){
        Touch t = this.how_am_I_touching( key ); 
        if( t.touching ){
          this.unlocked = true;
        }
      }
    }
  }
  public String save(){
    return "   keyed_button("+r+","+g+","+b+"," + (loc.x/block_size.x) + "," + (loc.y/block_size.y) + ");";
  }
}
void keyed_button( int r, int g, int b, float x, float y ){
   KeyedButton thing = new KeyedButton(r,g,b,x*block_size.x,y*block_size.y);
   thing.door = last_door;
   all_things.add(thing);
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
      person.points += 5;
      coin_sound.setFramePosition(0);
      coin_sound.start();
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
          other_end.timeout = 10000;
          other_thing.solid_push(touch.overlap);
          //println( "ported from " + this.loc + " to " + other_end.loc );
          
          if( is_person ){
            teleporter_sound.setFramePosition(0);
            teleporter_sound.start();
          }
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
  public void take_hit( int hurt_amount ){
    things_to_remove.add(this);
    person.points += 1;
    badguy_die_sound.setFramePosition(0);
    badguy_die_sound.start();
  }
  public void solid_push( Loc push ){
    //This is a brick telling us how much we are intersecting.
    if( push.y != 0 )if( (push.y > 0) != (speed.y > 0) ) speed.y = 0;
    if( push.x != 0 )if( (push.x > 0) != (speed.x > 0) ) speed.x *= -1;
    loc = loc.plus(push);
  }
  
  
  double MAX_SPEED = 20;
  public void draw(){
    if( !person.maker_mode ){
    
      float bottom = loc.y+.5*size.y;
      
      
      speed = speed.plus( gravity );
      
      if( speed.r() > MAX_SPEED ){
        speed = speed.times( .7 );
      }
      
      loc = loc.plus( speed );
        
      if( bottom > floor ){
        this.solid_push( new Loc(0,floor-bottom) );
      }
      
      for( Thing other_thing : all_things ){
         other_thing.interact(this,false); 
      }
       
    }
    
  }
}

float bubble_float_speed = 3;
class Bubble extends Thing{
  public Bubble( float x, float y ){
    loc.x = x;
    loc.y = y;
    size.x = size.y = .1 * block_size.x;
  }
  
  public void take_hit( int hurt_amount ){
    things_to_remove.add(this);
  }
  
  public void interact( Thing other_thing, boolean is_person ){
  }
  
  public void draw(){
    if( !person.maker_mode ){
    
      float bottom = loc.y+.5*size.y;
      
      if( bottom > floor ) this.solid_push( new Loc(0,floor-bottom) );
     
      //in_water = true;
      in_water = false;
      for( Thing other_thing : all_things ){
         other_thing.interact(this,false); 
      }
      
      if( !in_water || random(100) < 1 ){
        things_to_remove.add(this);
      }else{
        if( abs(gravity.y) > abs(gravity.x) ){
          if( gravity.y > 0 ){
            if( speed.y > -bubble_float_speed ) speed.y -= 1;
          }else{
            if( speed.y <  bubble_float_speed ) speed.y += 1;
          }
        }else{
          if( gravity.x > 0 ){
            if( speed.x > -bubble_float_speed ) speed.x -= 1;
          }else{
            if( speed.x <  bubble_float_speed ) speed.x += 1;
          }
        }
      }

      fill( 255 );
      ellipse(loc.x, loc.y, size.x, size.y);
      
      loc = loc.plus( speed ); 
    }else{
      fill( 255 );
      ellipse(loc.x, loc.y, size.x, size.y);
    }
  }
  public String save(){ return ""; }
  public void solid_push( Loc push ){
    if( push.y != 0 )if( (push.y > 0) != (speed.y > 0) ) speed.y *= -1;
    if( push.x != 0 )if( (push.x > 0) != (speed.x > 0) ) speed.x *= -1;
    loc = loc.plus(push);
  }
}

class Fish extends Badguy{
  float desired_speed = 5;
  public Fish( float x, float y, float size, float desired_speed ){
    loc.x = x;
    loc.y = y;
    this.size.x = this.size.y = size;
    this.desired_speed = desired_speed;
    this.speed.x = desired_speed;
    this.speed.y = -desired_speed*.25;
  }
  
  int eye_timer = 0;
  public void draw(){
    
    if( !person.maker_mode ){
    
      float bottom = loc.y+.5*size.y;
      
      if( bottom > floor ) this.solid_push( new Loc(0,floor-bottom) );
     
      in_water = false;
      for( Thing other_thing : all_things ){
         other_thing.interact(this,false); 
      }
      
      if( !in_water ){
        this.speed = this.speed.plus(gravity);
      }else{
        //swim
        if( this.speed.r() < desired_speed ){
          if( this.speed.x == 0 ) this.speed.x = desired_speed;
          this.speed = this.speed.times( desired_speed ).times( 1/this.speed.r() );
        }
      }
      
      float dir = -1;
      if( speed.x < 0 ) dir = 1;
      fill( 199, 119, 0 );
      ellipse(loc.x, loc.y, size.x, size.y*.8);
      triangle(loc.x+dir*size.x*.5*.5,loc.y,loc.x+dir*.5*size.x,loc.y-.5*size.y,loc.x+dir*.5*size.x,loc.y+.5*size.y);
      boolean eye_closed = false;
      if( random(100) < 1 ){
        eye_timer = 20;
      }else if( eye_timer > 0 ){
        eye_timer--;
        eye_closed = true;
      }
      
      
      if( eye_closed ){
        fill( 199, 119, 0 );
      }else{
        fill(255);
      }
      float eye_size = size.x*.2;
      ellipse(loc.x-dir*.5*.75*size.x,loc.y-.5*.5*size.y,eye_size,eye_size);
      fill(0);
      if( !eye_closed ){
        float pupil_size = eye_size * .75;
        ellipse(loc.x-dir*.5*.8*size.x,loc.y-.5*.5*size.y,pupil_size,pupil_size);
      }
      
      loc = loc.plus( speed ); 
      if( random(10) < 1 ){
        things_to_add.add(new Bubble(loc.x-dir*.5*.8*size.x,loc.y-.6*size.y));
      }
    }else{
      fill( 199, 119, 0 );
      ellipse(loc.x, loc.y, size.x, size.y);
    }
  }
  public void solid_push( Loc push ){
    //This is a brick telling us how much we are intersecting.
    if( push.y != 0 )if( (push.y > 0) != (speed.y > 0) ){
      if( in_water ){
        //bounce in water.
        speed.y *= -1;
      }else{
        //splat on ground
        speed.y = 0;
        speed.x = 0;
      }
    }
    if( push.x != 0 )if( (push.x > 0) != (speed.x > 0) ) speed.x *= -1;
    loc = loc.plus(push);
  }
  public String save(){
    return "   fish(" + (loc.x/block_size.x) + "," + (loc.y/block_size.y) + "," + (size.x/block_size.x) + "," + this.speed.x + ");";
  }  
}
void fish( float x, float y, float size, float speed ){
   Fish bob = new Fish(x*block_size.x,y*block_size.y,size*block_size.x,speed);
   //println( "bob is at " + bob.loc );
   all_things.add(bob);
   last_growable = bob;
}
  

float walking_speed = 5;
class WalkyBadguy extends Badguy{
  public WalkyBadguy(){
    this.speed.x = walking_speed;
  }
  public void draw(){
    super.draw();
    fill( 230, 179, 14 );
    //println( "badguy loc " + loc.times(1/block_size.x) );
    ellipse(loc.x, loc.y, size.x, size.y);
    pushStyle();
    strokeWeight(2);
    stroke(0);
    if( this.speed.x < 0 ){
      line( loc.x-.3*size.x, loc.y-.3*size.y, loc.x-.3*size.x, loc.y-.35*size.y );
      line( loc.x-.2*size.x, loc.y-.3*size.y, loc.x-.2*size.x, loc.y-.35*size.y );
      line( loc.x-.28*size.x, loc.y-.2*size.y, loc.x-.25*size.x, loc.y-.1*size.y );
      line( loc.x-.22*size.x, loc.y-.2*size.y, loc.x-.23*size.x, loc.y-.1*size.y );
      line( loc.x-.25*size.x, loc.y-.1*size.y, loc.x-.23*size.x, loc.y-.1*size.y );
    }else{
      line( loc.x+.3*size.x, loc.y-.3*size.y, loc.x+.3*size.x, loc.y-.35*size.y );
      line( loc.x+.2*size.x, loc.y-.3*size.y, loc.x+.2*size.x, loc.y-.35*size.y );
      line( loc.x+.28*size.x, loc.y-.2*size.y, loc.x+.25*size.x, loc.y-.1*size.y );
      line( loc.x+.22*size.x, loc.y-.2*size.y, loc.x+.23*size.x, loc.y-.1*size.y );
      line( loc.x+.25*size.x, loc.y-.1*size.y, loc.x+.23*size.x, loc.y-.1*size.y );
    }
    popStyle();
  }
  
  //flag for something to set for this not to save.
  public boolean dont_save = false;
  public String save(){
    if( !dont_save ){
      return "   walky2(" + (loc.x/block_size.x) + "," + (loc.y/block_size.y) + "," + (size.x/block_size.x) + "," + this.speed.x + ");";
    }else{
      return "";
    }
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
WalkyBadguy walky2( float x, float y, float size, float x_speed ){
   WalkyBadguy bob = new WalkyBadguy();
   bob.loc.x = x*block_size.x;
   bob.loc.y = y*block_size.y;
   bob.size.x = size*block_size.x;
   bob.size.y = size*block_size.y;
   bob.speed.x = x_speed;
   //println( "bob is at " + bob.loc );
   all_things.add(bob);
   last_growable = bob;
   return bob;
}

class LaserLight extends Thing{
  int timer = 0;
  int direction = 1;
  int count_out = 0;
  Thing parent = null;
  public void interact( Thing other_thing, boolean is_person ){
    if( other_thing == this ) return;
    //anything which touches laser light gets hit.
     Touch touch = other_thing.how_am_I_touching( this );
    if( touch.touching ){
      if( other_thing != parent ){
        other_thing.take_hit(1);
      }
    }
  }
  public String save(){
    //laser light doesn't save.
    return "";
  }
  public void take_hit(int amount){}
  public void solid_push( Loc push ){
    //stop propogating.
    //count_out = 0;
    push.y = 0;
    loc = loc.plus(push);
  }
  
  public void draw(){
    if( !person.maker_mode ) timer--;
    //Probably should just draw as a stick.
    pushStyle();
    strokeWeight(0);
    fill( red );
    rect(loc.x-.5*size.x, loc.y-.5*size.y, size.x, size.y );
    popStyle();
    
    if( !person.maker_mode ){  
      
      boolean hit_brick = false;
      
      for( Thing other_thing : all_things ){
        if( other_thing != parent ){
           other_thing.interact(this,false);
           if( other_thing instanceof SolidBrick || other_thing instanceof Door ){
              if( how_am_I_touching( other_thing ).touching ){
                hit_brick = true;
              }
           }
        }
      }
    
      if( count_out > 0 && !hit_brick ){
         shoot_laser( loc.plus( new Loc( direction*.5*size.x, 0 )), direction, count_out-1, null ); 
         count_out = 0;
      }
      
      if( timer <= 0 ){
        things_to_remove.add(this);
      }
    }
  }
}
Loc LASER_SIZE = new Loc( block_size.x, 2 );
void shoot_laser( Loc start, int direction, int count_out, Thing parent ){
  
  LaserLight new_laser = new LaserLight();
  new_laser.timer = LaserSpikeBadguy.SHOOT_TIME;
  new_laser.direction = direction;
  new_laser.size = LASER_SIZE;
  new_laser.loc = start.plus( new Loc(direction*.5*new_laser.size.x, 0) );
  new_laser.count_out = count_out;
  new_laser.parent = parent;
   things_to_add.add(new_laser);
  
}

class LaserSpikeBadguy extends Badguy{
  static final int SITTING = 0;
  static final int CHARGING = 1;
  static final int SHOOTING = 2;
  static final int MOVING = 3;
  
  static final int MIN_SIT_TIME = 100;
  static final int MAX_SIT_TIME = 200;
  
  static final int MIN_MOVE_TIME = 50;
  static final int MAX_MOVE_TIME = 150;
  
  static final int CHARGE_TIME = 200;
  static final int SHOOT_TIME = 100;
  
  int mode = SITTING;
  int count_down = 0;
  
  float walking_speed = .8;
  float saved_speed = 0;
  
  public LaserSpikeBadguy(){
    mode = SITTING;
    count_down = (int)random( MAX_SIT_TIME-MIN_SIT_TIME ) + MIN_SIT_TIME;
  }
  public void draw(){
    if( !person.maker_mode ) count_down--;

    if( mode == SITTING ){
      fill( 181, 181, 181 );
      
      if( count_down <= 0 ){
        mode = CHARGING;
        count_down = CHARGE_TIME;
      }
    }else if( mode == CHARGING ){
      int charged_color = 255;
      fill( int( (count_down-CHARGE_TIME)/(float)(charged_color-CHARGE_TIME)*(charged_color-181)+181 ) );
      
      if( count_down <= 0 ){
        mode = SHOOTING;
        count_down = SHOOT_TIME;
        
        int direction = (saved_speed > 0)?1:-1;
        
        shoot_laser( loc.plus(new Loc(direction*(.25*size.x+1),0)), direction, 100, this );
      }
    }else if( mode == SHOOTING ){
      fill( 255, 0, 0 );
      
      if( count_down <= 0 ){
        mode = MOVING;
        count_down = (int)random( MAX_MOVE_TIME-MIN_MOVE_TIME ) + MIN_MOVE_TIME;
        
        if( saved_speed != 0 ){
          speed.x = saved_speed;
        }else{
          speed.x = walking_speed;
        }
      }
    }else if( mode == MOVING ){
      fill( 181, 181, 181 );
      
      if( count_down <= 0 ){
        mode = SITTING;
        count_down = (int)random( MAX_SIT_TIME-MIN_SIT_TIME ) + MIN_SIT_TIME;
        
        saved_speed = speed.x;
        speed.x = 0;
      }
    }
    
    super.draw();
    pushStyle();
    triangle( (float)(loc.x - .5*size.x), (float)(loc.y + .5*size.y), (float)loc.x, (float)(loc.y-.5*size.y), (float)(loc.x + .5*size.x), (float)(loc.y + .5*size.y)  );
    popStyle();
  }
  
  public String save(){
    return "   laser_spike(" + (loc.x/block_size.x) + "," + (loc.y/block_size.y) + "," + (size.x/block_size.x) + "," + this.speed.x + ");";
  }
}
void laser_spike( float x, float y, float size, float x_speed ){
   LaserSpikeBadguy bob = new LaserSpikeBadguy();
   bob.loc.x = x*block_size.x;
   bob.loc.y = y*block_size.y;
   bob.size.x = size*block_size.x;
   bob.size.y = size*block_size.y;
   bob.walking_speed = x_speed;
   //println( "bob is at " + bob.loc );
   all_things.add(bob);
   last_growable = bob;
}
       

class BouncyBadguy extends Badguy{
  public void draw(){
    super.draw();
    fill( 245, 0, 237 );
    ellipse(loc.x, loc.y, size.x, size.y);
    pushStyle();
    strokeWeight(2);
    stroke(0);
    if( this.speed.x < 0 ){
      line( loc.x-.3*size.x, loc.y-.3*size.y, loc.x-.3*size.x, loc.y-.35*size.y );
      line( loc.x-.2*size.x, loc.y-.3*size.y, loc.x-.2*size.x, loc.y-.35*size.y );
      line( loc.x-.28*size.x, loc.y-.2*size.y, loc.x-.25*size.x, loc.y-.1*size.y );
      line( loc.x-.22*size.x, loc.y-.2*size.y, loc.x-.23*size.x, loc.y-.1*size.y );
      line( loc.x-.25*size.x, loc.y-.1*size.y, loc.x-.23*size.x, loc.y-.1*size.y );
    }else{
      line( loc.x+.3*size.x, loc.y-.3*size.y, loc.x+.3*size.x, loc.y-.35*size.y );
      line( loc.x+.2*size.x, loc.y-.3*size.y, loc.x+.2*size.x, loc.y-.35*size.y );
      line( loc.x+.28*size.x, loc.y-.2*size.y, loc.x+.25*size.x, loc.y-.1*size.y );
      line( loc.x+.22*size.x, loc.y-.2*size.y, loc.x+.23*size.x, loc.y-.1*size.y );
      line( loc.x+.25*size.x, loc.y-.1*size.y, loc.x+.23*size.x, loc.y-.1*size.y );
    }
    popStyle();
  }
  public void take_hit( int hurt_amount ){
    things_to_remove.add(this);
    person.points += 2;
    badguy_die_sound.setFramePosition(0);
    badguy_die_sound.start();
  }
  
  public void solid_push( Loc push ){
    //This is a brick telling us how much we are intersecting.
    if( push.y != 0 )if( (push.y > 0) != (speed.y > 0) ) speed.y *= -1;
    if( push.x != 0 )if( (push.x > 0) != (speed.x > 0) ) speed.x *= -1;
    loc = loc.plus(push);
  }
  public String save(){
    return "   bouncy(" + (loc.x/block_size.x) + "," + (loc.y/block_size.y) + "," + (size.x/block_size.x) + "," + this.speed.x + ");";
  }
}
void bouncy( float x, float y, float size, float x_speed ){
   BouncyBadguy bob = new BouncyBadguy();
   bob.loc.x = x*block_size.x;
   bob.loc.y = y*block_size.y;
   bob.size.x = size*block_size.x;
   bob.size.y = size*block_size.y;
   bob.speed.x = x_speed;
   //println( "bob is at " + bob.loc );
   all_things.add(bob);
   last_growable = bob;
}

class LoopyBadguy extends Badguy{
  float angle_speed = .2;
  float forward_speed = 1;
  
  Loc behind_point = new Loc();
  
  public void draw(){
    if( !person.maker_mode ){
    
      
      //Pull the behind_point to one size away
      Loc self_to_point = behind_point.minus(loc);
      behind_point = self_to_point.times( size.x/self_to_point.r() ).plus(loc);
      
      //now rotate the behind point around ourselves the opposite direction
      self_to_point = behind_point.minus(loc);
      behind_point = polar_loc(self_to_point.r(),self_to_point.angle()-angle_speed*.5).plus(loc);
      
      //push the loopy away from the point by one speed and rotate around the point by some angle
      Loc point_to_self = loc.minus(behind_point);
      loc = polar_loc(point_to_self.r()+forward_speed,point_to_self.angle()+angle_speed).plus(behind_point);
      
      line( loc.x, loc.y, behind_point.x, behind_point.y );
     
        
      float bottom = loc.y+.5*size.y;
      if( bottom > floor ){
        this.solid_push( new Loc(0,floor-bottom) );
      }
      
      for( Thing other_thing : all_things ){
         other_thing.interact(this,false); 
      }
      
      //loc = loc.plus( speed ); 
    }
      
    
    fill( 29, 21, 102 );
    ellipse(loc.x, loc.y, size.x, size.y);
    pushStyle();
    strokeWeight(2);
    stroke(0);
    if( loc.x > behind_point.x ){
      line( loc.x-.3*size.x, loc.y-.3*size.y, loc.x-.3*size.x, loc.y-.35*size.y );
      line( loc.x-.2*size.x, loc.y-.3*size.y, loc.x-.2*size.x, loc.y-.35*size.y );
      line( loc.x-.28*size.x, loc.y-.2*size.y, loc.x-.25*size.x, loc.y-.1*size.y );
      line( loc.x-.22*size.x, loc.y-.2*size.y, loc.x-.23*size.x, loc.y-.1*size.y );
      line( loc.x-.25*size.x, loc.y-.1*size.y, loc.x-.23*size.x, loc.y-.1*size.y );
    }else{
      line( loc.x+.3*size.x, loc.y-.3*size.y, loc.x+.3*size.x, loc.y-.35*size.y );
      line( loc.x+.2*size.x, loc.y-.3*size.y, loc.x+.2*size.x, loc.y-.35*size.y );
      line( loc.x+.28*size.x, loc.y-.2*size.y, loc.x+.25*size.x, loc.y-.1*size.y );
      line( loc.x+.22*size.x, loc.y-.2*size.y, loc.x+.23*size.x, loc.y-.1*size.y );
      line( loc.x+.25*size.x, loc.y-.1*size.y, loc.x+.23*size.x, loc.y-.1*size.y );
    }
    popStyle();
  }
  public void take_hit( int hurt_amount ){
    things_to_remove.add(this);
    person.points += 2;
  }
  
  public void solid_push( Loc push ){
    //This is a brick telling us how much we are intersecting.
    if( push.y != 0 )if( (push.y > 0) != (speed.y > 0) ) speed.y *= -1;
    if( push.x != 0 )if( (push.x > 0) != (speed.x > 0) ) speed.x *= -1;
    loc = loc.plus(push);
  }
  public String save(){
    return "   loopy(" + (loc.x/block_size.x) + "," + (loc.y/block_size.y) + "," + (size.x/block_size.x) + "," + this.angle_speed+ "," + this.forward_speed + ");";
  }
}
void loopy( float x, float y, float size, float angle_speed, float forward_speed ){
   LoopyBadguy bob = new LoopyBadguy();
   bob.loc.x = x*block_size.x;
   bob.loc.y = y*block_size.y;
   bob.size.x = size*block_size.x;
   bob.size.y = size*block_size.y;
   bob.angle_speed = angle_speed;
   bob.forward_speed = forward_speed;
   bob.behind_point = bob.loc.plus( new Loc(size,0) );
   //println( "bob is at " + bob.loc );
   all_things.add(bob);
   last_growable = bob;
}

class Spike extends SolidBrick{
  public void interact( Thing other_thing, boolean is_person ){
    if( other_thing == this ) return;
    Touch touch = other_thing.how_am_I_touching( this );
    if( touch.touching ){
      if( is_person ){
          other_thing.take_hit(1);
      }else{
        //another badguy touch like a brick
        other_thing.solid_push( touch.overlap.times(.5) );
        this.solid_push( touch.overlap.times(-.5) );
      }
    }
  }
  public void draw(){
    fill( 181, 181, 181 );
    triangle( (float)(loc.x - .5*size.x), (float)(loc.y + .5*size.y), (float)loc.x, (float)(loc.y-.5*size.y), (float)(loc.x + .5*size.x), (float)(loc.y + .5*size.y)  );
  }
  
  public String save(){
    return "   spike(" + (loc.x/block_size.x) + "," + (loc.y/block_size.y) + "," + (size.x/block_size.x) + "," + (size.y/block_size.y) + ");";
  }
}
void spike( float x, float y, float width, float height ){
   Spike bob = new Spike();
   bob.loc.x = x*block_size.x;
   bob.loc.y = y*block_size.y;
   bob.size.x = width*block_size.x;
   bob.size.y = height*block_size.y;
   all_things.add(bob);
   last_growable = bob;
   last_last_thing = last_thing;
   last_thing = bob;
}

WalkyBadguy birth_walky( float x, float y, float size, float x_speed ){
   WalkyBadguy bob = new WalkyBadguy();
   bob.loc.x = x*block_size.x;
   bob.loc.y = y*block_size.y;
   bob.size.x = size*block_size.x;
   bob.size.y = size*block_size.y;
   bob.speed.x = x_speed;
   bob.dont_save = true;
   things_to_add.add(bob);
   return bob;
}

class MakerMakerBadguy extends Badguy{
  static final int SITTING = 0;
  static final int MAKING = 1;
  static final int MOVING = 2;
  
  static final int MIN_SIT_TIME = 50;
  static final int MAX_SIT_TIME = 100;
  
  static final int MIN_MOVE_TIME = 300;
  static final int MAX_MOVE_TIME = 400;
  
  static final int MAKE_TIME = 60;

  static final int AIR_SOUND_RANGE = 900;
  
  int mode = SITTING;
  int count_down = 0;
  
  float walking_speed = .8;
  float saved_speed = 0;
  
  Badguy baby = null;
  
  public MakerMakerBadguy(){
    mode = SITTING;
    count_down = (int)random( MAX_SIT_TIME-MIN_SIT_TIME ) + MIN_SIT_TIME;
  }
  public void draw(){
    if( !person.maker_mode ) count_down--;
    
    
    pushStyle();
    fill( purple );
    rect(loc.x-.5*size.x, loc.y-.5*size.y, size.x, size.y, 7);
    popStyle();
    
    int d = (speed.x > 0)?1:(speed.x < 0)?-1:(saved_speed > 0)?1:-1;
    if( mode == SITTING ){
      pushStyle();
      strokeWeight(2);
      stroke(0);
    
      //happy face for sitting
      line( loc.x+d*4.5*size.x/(float)16, loc.y-2.0*size.y/(float)8, loc.x+d*4.5*size.x/(float)16, loc.y-3.0*size.y/(float)8 );
      line( loc.x+d*2.5*size.x/(float)16, loc.y-2.0*size.y/(float)8, loc.x+d*2.5*size.x/(float)16, loc.y-3.0*size.y/(float)8 );
      line( loc.x+d*0*size.x/(float)16, loc.y+0.5*size.y/(float)8, loc.x+d*0*size.x/(float)16, loc.y-1.5*size.y/(float)8 );
      line( loc.x+d*0*size.x/(float)16, loc.y-0.5*size.y/(float)8, loc.x+d*6*size.x/(float)16, loc.y-0.5*size.y/(float)8 );
      line( loc.x+d*6*size.x/(float)16, loc.y-1.5*size.y/(float)8, loc.x+d*6*size.x/(float)16, loc.y+0.5*size.y/(float)8 );
      line( loc.x+d*6*size.x/(float)16, loc.y+0.5*size.y/(float)8, loc.x+d*0*size.x/(float)16, loc.y+0.5*size.y/(float)8 );
      
      popStyle();
      
      if( count_down <= 0 ){
        mode = MAKING;
        count_down = MAKE_TIME;
      }
    }else if( mode == MAKING ){
      //Sqeeze face.  For making.      
      pushStyle();
      strokeWeight(2);
      stroke(0);
      line( loc.x+d*6*size.x/(float)16, loc.y-3.0*size.y/(float)8, loc.x+d*4*size.x/(float)16, loc.y-2.5*size.y/(float)8 );
      line( loc.x+d*4*size.x/(float)16, loc.y-2.5*size.y/(float)8, loc.x+d*6*size.x/(float)16, loc.y-2.0*size.y/(float)8 );
      line( loc.x+d*0*size.x/(float)16, loc.y-3.0*size.y/(float)8, loc.x+d*2*size.x/(float)16, loc.y-2.5*size.y/(float)8 );
      line( loc.x+d*2*size.x/(float)16, loc.y-2.5*size.y/(float)8, loc.x+d*0*size.x/(float)16, loc.y-2.0*size.y/(float)8 );
      line( loc.x+d*2*size.x/(float)16, loc.y-0.5*size.y/(float)8, loc.x+d*3*size.x/(float)16, loc.y-1.0*size.y/(float)8 );
      line( loc.x+d*3*size.x/(float)16, loc.y-1.0*size.y/(float)8, loc.x+d*4*size.x/(float)16, loc.y-0.5*size.y/(float)8 );
      line( loc.x+d*4*size.x/(float)16, loc.y-0.5*size.y/(float)8, loc.x+d*3*size.x/(float)16, loc.y-0.0*size.y/(float)8 );
      line( loc.x+d*3*size.x/(float)16, loc.y-0.0*size.y/(float)8, loc.x+d*2*size.x/(float)16, loc.y-0.5*size.y/(float)8 );
      popStyle();
      
      //fill( 255, 0, 0 );
      
      if( baby == null ){
        baby = birth_walky( this.loc.x/(float)block_size.x, (this.loc.y+this.size.y)/(float)block_size.x, (this.size.x/(float)MAKE_TIME)/(float)block_size.x, this.walking_speed );

        //only make sound if within AIR_SOUND_RANGE of person

        if( person.loc.minus(this.loc).r() < AIR_SOUND_RANGE ){
          air_up_sound.setFramePosition(0);
          air_up_sound.start();
          println( "Yes R was " + person.loc.minus(this.loc).r() );
        }else{
          println( "No R was " + person.loc.minus(this.loc).r() );
        }
      }
      baby.size.x = (MAKE_TIME-count_down)*this.size.x/(float)MAKE_TIME;
      baby.size.y = (MAKE_TIME-count_down)*this.size.y/(float)MAKE_TIME;
      baby.speed.x = 0;
      
      if( count_down <= 0 ){
        mode = MOVING;
        count_down = (int)random( MAX_MOVE_TIME-MIN_MOVE_TIME ) + MIN_MOVE_TIME;
        
        if( saved_speed != 0 ){
          speed.x = saved_speed;
        }else{
          speed.x = walking_speed;
        }
      }
    }else if( mode == MOVING ){
      //image closed eyes probably for walking.     
      pushStyle();
      strokeWeight(2);
      stroke(0);
      line( loc.x+d*7*size.x/(float)16, loc.y-2*size.y/(float)8, loc.x+d*6*size.x/(float)16, loc.y-3*size.y/(float)8 );
      line( loc.x+d*6*size.x/(float)16, loc.y-3*size.y/(float)8, loc.x+d*5*size.x/(float)16, loc.y-2*size.y/(float)8 );
      line( loc.x+d*3*size.x/(float)16, loc.y-2*size.y/(float)8, loc.x+d*2*size.x/(float)16, loc.y-3*size.y/(float)8 );
      line( loc.x+d*2*size.x/(float)16, loc.y-3*size.y/(float)8, loc.x+d*1*size.x/(float)16, loc.y-2*size.y/(float)8 );
      line( loc.x+d*4*size.x/(float)16, loc.y+0*size.y/(float)8, loc.x+d*3*size.x/(float)16, loc.y+1*size.y/(float)8 );
      line( loc.x+d*3*size.x/(float)16, loc.y+1*size.y/(float)8, loc.x+d*2*size.x/(float)16, loc.y+0*size.y/(float)8 );
      popStyle();
      
      
      if( baby != null ){
        baby.speed.x = -1*this.walking_speed;
        baby = null;
      }
      
      //fill( 181, 181, 181 );
   
      if( count_down <= 0 ){
        mode = SITTING;
        count_down = (int)random( MAX_SIT_TIME-MIN_SIT_TIME ) + MIN_SIT_TIME;
        
        saved_speed = speed.x;
        speed.x = 0;
      }
    }
    
    super.draw();
  }
  
  public String save(){
    return "   maker_maker(" + (loc.x/block_size.x) + "," + (loc.y/block_size.y) + "," + (size.x/block_size.x) + "," + this.speed.x + ");";
  }
}
void maker_maker( float x, float y, float size, float x_speed ){
   MakerMakerBadguy bob = new MakerMakerBadguy();
   bob.loc.x = x*block_size.x;
   bob.loc.y = y*block_size.y;
   bob.size.x = size*block_size.x;
   bob.size.y = size*block_size.y;
   bob.walking_speed = x_speed;
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
//MediaPlayer coin_sound;
Clip coin_sound;
Clip teleporter_sound;
Clip badguy_die_sound;
Clip win_sound;
Clip open_door_sound;
Clip close_door_sound;
Clip air_up_sound;
Clip sad_sound;
void setup() {
  fullScreen();
  //size(809, 500);  // Size should be the first statement
  stroke(255);     // Set stroke color to white
  
  surface.setResizable(true);
  
  person = new Person();
  all_things.add(person);
  //level1();
  show_start_menu();
  
  //println( new File( sketchPath(), "/data/coin.mp3").toURI().toString() );
  
  //Media hit = new Media( new File( sketchPath(), "/data/coin.mp3").toURI().toString() );
  //coin_sound = new MediaPlayer(hit);
  try{
    coin_sound = AudioSystem.getClip();
    coin_sound.open(AudioSystem.getAudioInputStream(new File(sketchPath(), "/data/coin.wav")));
    
    teleporter_sound = AudioSystem.getClip();
    teleporter_sound.open(AudioSystem.getAudioInputStream(new File(sketchPath(), "/data/teleport.wav")));
    
    badguy_die_sound = AudioSystem.getClip();
    badguy_die_sound.open(AudioSystem.getAudioInputStream(new File(sketchPath(), "/data/badguy_die.wav")));
    
    win_sound = AudioSystem.getClip();
    win_sound.open(AudioSystem.getAudioInputStream(new File(sketchPath(), "/data/win.wav")));
    
    open_door_sound = AudioSystem.getClip();
    open_door_sound.open(AudioSystem.getAudioInputStream(new File(sketchPath(), "/data/door_open.wav")));

    air_up_sound = AudioSystem.getClip();
    air_up_sound.open(AudioSystem.getAudioInputStream(new File(sketchPath(), "/data/air_up.wav")));
    
    close_door_sound = AudioSystem.getClip();
    close_door_sound.open(AudioSystem.getAudioInputStream(new File(sketchPath(), "/data/door_close.wav")));
    
    sad_sound = AudioSystem.getClip();
    sad_sound.open(AudioSystem.getAudioInputStream(new File(sketchPath(), "/data/sad.wav")));
  }catch( Exception exc ){ 
    
    exc.printStackTrace(System.out);
  }
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
  all_things.addAll( things_to_add );
  things_to_add.clear();
  
  popMatrix();
  
  //Draw points.
  
  pushStyle();
  
  textSize(250);
  fill( 255, 255, 3 );
  text( person.points, 100, 200 );
  
  popStyle();

  if( person.dead ){
    pushStyle();
    strokeWeight(10);
    stroke(255, 220, 43);
    fill(255, 249, 217, 230);
    
    float menu_width = 600;
    float menu_height = 100;
    rect( .5*(width-menu_width), .5*(height-menu_height), menu_width, menu_height, 20);
    
    textAlign(CENTER, BOTTOM);
    
    fill(0);
    textSize(30);
    text( "You had a sad.  Press r.", width*.5, .5*(height-menu_height)+50 );
    popStyle();
  }
  
  if( menu != null ) menu.draw();
 
} 

abstract class Menu{
  abstract void draw();
  abstract void keyPressed();
}


void load_level( String filename ){
  current_level_number = -1; //this marks it as a custom.
  level_name = filename;
  remove_things();
  
  BufferedReader br_in = null;
  try{
    br_in = new BufferedReader( new FileReader( new File(sketchPath(), filename + ".lvl" ) ) );
    
    String line = br_in.readLine();
    
    while( line != null ){
      println( "processing line \"" + line + "\"" );
      
      int index = 0;
      
      while( index < line.length() ){
        String method_name = "";
        
        //first get to it.
        while( index < line.length() && line.charAt(index) == ' ' ) index++;
        
        //now get method_name
        while( line.charAt(index) != '(' && line.charAt(index) != ' ' ){
          method_name = method_name + line.charAt(index); 
          index++;
        }
        
        //Make sure we are at the (
        while( line.charAt(index) != '(' ) index++;
        index++;
        
        //now get all the args.
        LinkedList< String > args = new LinkedList< String >();
        boolean done_with_args = false;
        while( !done_with_args ){
          String arg = "";
          while( line.charAt(index) == ' ' ) index++;
          while( line.charAt(index) != ',' && line.charAt(index) != ')' && line.charAt(index ) != ' ' ){
            arg = arg + line.charAt(index);
            index++;
          }
          while( line.charAt(index) == ' ' ) index++;
          if( line.charAt(index) == ')' )done_with_args = true;
          index++;
          while( line.charAt(index) == ' ' ) index++;
          args.add( arg );
        }
        if( line.charAt(index) == ';' ) index++;
        
        if( args.size() > 4 ){
          println( "More then four" );
        }
        for( String arg: args ){
          if( arg.length() > 20 ){
            println( "Log arg " + arg );
          }
        }
        
        println( "args is " + args );
        if( method_name.equals( "invisible_brick" ) ){ //4
          invisible_brick( Float.parseFloat( args.get(0) ), Float.parseFloat( args.get(1) ), Float.parseFloat( args.get(2) ), Float.parseFloat( args.get(3) ) );
        }else if( method_name.equals( "coin" ) ){ //2f
          coin( Float.parseFloat( args.get(0) ), Float.parseFloat( args.get(1) ) );
        }else if( method_name.equals( "walky2" ) ){ //4f
          walky2( Float.parseFloat( args.get(0) ), Float.parseFloat( args.get(1) ), Float.parseFloat( args.get(2) ), Float.parseFloat( args.get(3) ) );
        }else if( method_name.equals( "laser_spike" ) ){ //4f
          laser_spike( Float.parseFloat( args.get(0) ), Float.parseFloat( args.get(1) ), Float.parseFloat( args.get(2) ), Float.parseFloat( args.get(3) ) );
        }else if( method_name.equals( "walking_brick" ) ){
          walking_brick( Float.parseFloat( args.get(0) ), Float.parseFloat( args.get(1) ), Float.parseFloat( args.get(2) ), Float.parseFloat( args.get(3) ), Float.parseFloat( args.get(4) ) );
        }else if( method_name.equals( "solid_brick" ) ){ //4f
          solid_brick( Float.parseFloat( args.get(0) ), Float.parseFloat( args.get(1) ), Float.parseFloat( args.get(2) ), Float.parseFloat( args.get(3) ) );
        }else if( method_name.equals( "start_block" ) ){ //2f
          start_block( Float.parseFloat( args.get(0) ), Float.parseFloat( args.get(1) ) );
        }else if( method_name.equals( "water" ) ){ //4f
          water( Float.parseFloat( args.get(0) ), Float.parseFloat( args.get(1) ), Float.parseFloat( args.get(2) ), Float.parseFloat( args.get(3) ) );
        }else if( method_name.equals( "teleporter" ) ){ //2f
          teleporter( Float.parseFloat( args.get(0) ), Float.parseFloat( args.get(1) ) );
        }else if( method_name.equals( "key" ) ){ //3i 2f
          key( Integer.parseInt( args.get(0) ), Integer.parseInt( args.get(1) ), Integer.parseInt( args.get(2) ), Float.parseFloat( args.get(3) ), Float.parseFloat( args.get(4) ) );
        }else if( method_name.equals( "door" ) ){ //4f
          door( Float.parseFloat( args.get(0) ), Float.parseFloat( args.get(1) ), Float.parseFloat( args.get(2) ), Float.parseFloat( args.get(3) ) );
        }else if( method_name.equals( "button" ) ){ //2f
          button( Float.parseFloat( args.get(0) ), Float.parseFloat( args.get(1) ) );
        }else if( method_name.equals( "keyed_button" ) ){ //3i 2f
          keyed_button( Integer.parseInt( args.get(0) ), Integer.parseInt( args.get(1) ), Integer.parseInt( args.get(2) ), Float.parseFloat( args.get(3) ), Float.parseFloat( args.get(4) ) );
        }else if( method_name.equals( "end_block" ) ){ //2f
          end_block( Float.parseFloat( args.get(0) ), Float.parseFloat( args.get(1) ) );
        }else if( method_name.equals( "fish" ) ){ //4f
          fish( Float.parseFloat( args.get(0) ), Float.parseFloat( args.get(1) ), Float.parseFloat( args.get(2) ), Float.parseFloat( args.get(3) ) );
        }else if( method_name.equals( "gravity_switch" ) ){ //4f
          gravity_switch( Float.parseFloat( args.get(0) ), Float.parseFloat( args.get(1) ), Float.parseFloat( args.get(2) ), Float.parseFloat( args.get(3) ) );
        }else if( method_name.equals( "spike" ) ){ //4f
          spike( Float.parseFloat( args.get(0) ), Float.parseFloat( args.get(1) ), Float.parseFloat( args.get(2) ), Float.parseFloat( args.get(3) ) );
        }else if( method_name.equals( "bouncy" ) ){ //4f
          bouncy( Float.parseFloat( args.get(0) ), Float.parseFloat( args.get(1) ), Float.parseFloat( args.get(2) ), Float.parseFloat( args.get(3) ) );
        }else if( method_name.equals( "loopy" ) ){ //5f
          loopy( Float.parseFloat( args.get(0) ), Float.parseFloat( args.get(1) ), Float.parseFloat( args.get(2) ), Float.parseFloat( args.get(3) ), Float.parseFloat( args.get(4) ) );
        }else if( method_name.equals( "maker_maker" ) ){ //4f
          maker_maker( Float.parseFloat( args.get(0) ), Float.parseFloat( args.get(1) ), Float.parseFloat( args.get(2) ), Float.parseFloat( args.get(3) ) );
        }else{
          throw new IOException( "Unknown thingy \"" + method_name + "\" with args \"" + args + "\"" );
        }
        while( index < line.length() && line.charAt(index) == ' ' ) index++;
      }
      
      line = br_in.readLine();
    }
    println( "Done processing lines" );
    
    
  }catch( java.io.FileNotFoundException ex ){
    show_message_menu( "Couldn't find the file " + filename , new DoSomething(){ public void do_it(){ start_level(-1); } } );
  }catch( java.io.IOException ex ){
    show_message_menu( "IOException " + ex , new DoSomething(){ public void do_it(){ start_level(-1); } } );
    
  }finally{
    try{
      if( br_in != null )br_in.close();
    }catch( java.io.IOException ex ){
    }
  }
  
    
}

void save_level( String filename ){
    current_level_number = -1;
    level_name = filename;
    
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
    
    
    if( filename.length() == 0 ){
      filename = "" + year() + "_" + month() + "_" + day() + "_" + hour() + " " + minute() + "_" + second() + ".lvl";
    }
    
    if( !filename.endsWith( ".lvl" ) ){
      filename = filename + ".lvl";
    }
    
    PrintWriter fout = createWriter( filename );
    fout.println( level );
    fout.flush();
    fout.close();
}

Menu menu = null;

String level_name = "";
int current_level_number = 0;
//Define level
void start_level( int level_num ){
  current_level_number = level_num;
  level_name = "level " + (level_num+1);
  remove_things();
  
  if( -1 == level_num ){
    //this is a blank level for making new levels
  }else if( level_num+1 == 1 ){
    walking_brick( 0, 10, 1,1, -1 );
    laser_spike( 1, 10, 1, -.7 );
    walky2( 2, 10, 1, -.7 );
    
    
solid_brick( 6.0, 4.0, 10.0, 1.0 );coin( 8.0, 3.0 );solid_brick( -3.0, 10.0, 1.0, 1.0 );solid_brick( 14.0, 10.0, 1.0, 1.0 );coin( 3.0, 1.0 );coin( 6.0, 1.0 );coin( 7.0, 1.0 );coin( 8.0, 1.0 );coin( 9.0, 1.0 );solid_brick( 1.0, 3.0, 1.0, 1.0 );solid_brick( 11.0, 3.0, 1.0, 1.0 );coin( 5.0, 1.0 );coin( 4.0, 1.0 );coin( 3.0, 0.0 );coin( 4.0, 0.0 );coin( 5.0, 0.0 );coin( 6.0, 0.0 );coin( 7.0, 0.0 );coin( 8.0, 0.0 );coin( 9.0, 0.0 );coin( 3.0, 2.0 );coin( 4.0, 2.0 );coin( 5.0, 2.0 );coin( 7.0, 2.0 );coin( 8.0, 2.0 );coin( 9.0, 2.0 );coin( 10.0, 2.0 );coin( 11.0, 2.0 );coin( 11.0, 1.0 );coin( 11.0, 0.0 );coin( 10.0, -1.0 );coin( 9.0, -1.0 );coin( 8.0, -1.0 );coin( 7.0, -1.0 );coin( 6.0, -1.0 );coin( 5.0, -1.0 );coin( 4.0, -1.0 );coin( 3.0, -1.0 );coin( 2.0, 2.0 );coin( 2.0, 4.0 );coin( 2.0, 5.0 );coin( 11.0, 5.0 );coin( 11.0, 4.0 );coin( 11.0, 3.0 );coin( 2.0, 6.0 );solid_brick( -8.0, 10.0, 1.0, 1.0 );solid_brick( -8.0, 9.0, 1.0, 1.0 );solid_brick( -9.0, 10.0, 1.0, 1.0 );solid_brick( -16.0, 10.0, 1.0, 1.0 );solid_brick( -17.0, 10.0, 1.0, 1.0 );solid_brick( -18.0, 10.0, 1.0, 1.0 );solid_brick( -19.0, 10.0, 1.0, 1.0 );solid_brick( -19.0, 9.0, 1.0, 1.0 );solid_brick( -19.0, 8.0, 1.0, 1.0 );solid_brick( -19.0, 7.0, 1.0, 1.0 );solid_brick( -19.0, 6.0, 1.0, 1.0 );solid_brick( -19.0, 5.0, 1.0, 1.0 );solid_brick( -19.0, 4.0, 1.0, 1.0 );solid_brick( -19.0, 3.0, 1.0, 1.0 );solid_brick( -19.0, 2.0, 1.0, 1.0 );solid_brick( -19.0, 1.0, 1.0, 1.0 );solid_brick( -19.0, 0.0, 1.0, 1.0 );solid_brick( -19.0, -1.0, 1.0, 1.0 );solid_brick( -19.0, -2.0, 1.0, 1.0 );solid_brick( -19.0, -3.0, 1.0, 1.0 );solid_brick( -19.0, -4.0, 1.0, 1.0 );solid_brick( -19.0, -5.0, 1.0, 1.0 );solid_brick( -19.0, -6.0, 1.0, 1.0 );solid_brick( -19.0, -7.0, 1.0, 1.0 );solid_brick( -19.0, -8.0, 1.0, 1.0 );solid_brick( -19.0, -9.0, 1.0, 1.0 );solid_brick( -19.0, -10.0, 1.0, 1.0 );solid_brick( -19.0, -12.0, 1.0, 1.0 );solid_brick( -19.0, -11.0, 1.0, 1.0 );solid_brick( -18.0, -12.0, 1.0, 1.0 );solid_brick( -17.0, -12.0, 1.0, 1.0 );solid_brick( -16.0, -12.0, 1.0, 1.0 );solid_brick( -15.0, -12.0, 1.0, 1.0 );solid_brick( -14.0, -12.0, 1.0, 1.0 );solid_brick( -13.0, -12.0, 1.0, 1.0 );solid_brick( -9.0, -12.0, 1.0, 1.0 );coin( -16.0, 9.0 );coin( -17.0, 9.0 );coin( -17.0, 8.0 );coin( -18.0, 8.0 );coin( -17.0, 8.0 );coin( -16.0, 8.0 );coin( -15.0, 7.0 );coin( -16.0, 7.0 );coin( -17.0, 7.0 );coin( -18.0, 7.0 );coin( -18.0, 6.0 );coin( -17.0, 6.0 );coin( -16.0, 6.0 );coin( -15.0, 6.0 );solid_brick( -14.0, 10.0, 1.0, 1.0 );solid_brick( -15.0, 10.0, 1.0, 1.0 );solid_brick( -14.0, 9.0, 1.0, 1.0 );solid_brick( -18.0, 5.0, 1.0, 1.0 );solid_brick( -17.0, 5.0, 1.0, 1.0 );solid_brick( -16.0, 5.0, 1.0, 1.0 );solid_brick( -14.0, 5.0, 1.0, 1.0 );solid_brick( -14.0, 4.0, 1.0, 1.0 );coin( -15.0, 4.0 );coin( -16.0, 4.0 );coin( -17.0, 4.0 );solid_brick( -17.0, 1.0, 1.0, 1.0 );solid_brick( -16.0, 1.0, 1.0, 1.0 );solid_brick( -15.0, 1.0, 1.0, 1.0 );solid_brick( -14.0, 1.0, 1.0, 1.0 );solid_brick( -14.0, 0.0, 1.0, 1.0 );coin( -17.0, 0.0 );coin( -16.0, 0.0 );coin( -15.0, 0.0 );solid_brick( -18.0, -3.0, 1.0, 1.0 );solid_brick( -17.0, -3.0, 1.0, 1.0 );solid_brick( -16.0, -3.0, 1.0, 1.0 );solid_brick( -14.0, -3.0, 1.0, 1.0 );solid_brick( -14.0, -4.0, 1.0, 1.0 );coin( -18.0, -4.0 );coin( -16.0, -4.0 );coin( -15.0, -4.0 );solid_brick( -17.0, -7.0, 1.0, 1.0 );solid_brick( -16.0, -7.0, 1.0, 1.0 );solid_brick( -15.0, -7.0, 1.0, 1.0 );solid_brick( -14.0, -7.0, 1.0, 1.0 );coin( -17.0, -8.0 );coin( -16.0, -8.0 );coin( -15.0, -8.0 );coin( -15.0, -9.0 );coin( -16.0, -9.0 );coin( -17.0, -9.0 );coin( -18.0, -9.0 );coin( -18.0, -10.0 );coin( -17.0, -10.0 );coin( -16.0, -10.0 );coin( -15.0, -10.0 );coin( -15.0, -11.0 );coin( -16.0, -11.0 );coin( -17.0, -11.0 );coin( -18.0, -11.0 );coin( -14.0, -11.0 );solid_brick( -13.0, 10.0, 1.0, 1.0 );solid_brick( -1.0, -5.0, 1.0, 1.0 );solid_brick( -4.0, -10.0, 1.0, 1.0 );coin( -15.0, 8.0 );solid_brick( -11.0, 10.0, 1.0, 1.0 );solid_brick( -10.0, 10.0, 1.0, 1.0 );solid_brick( -12.0, 10.0, 1.0, 1.0 );coin( -13.0, 1.0 );coin( -12.0, 1.0 );coin( -11.0, 1.0 );coin( -12.0, -3.0 );coin( -11.0, -3.0 );coin( -13.0, -7.0 );coin( -12.0, -7.0 );coin( -11.0, -7.0 );walky2(304.8,10.0,1.0,10.0);solid_brick( 308.0, 10.0, 1.0, 1.0 );solid_brick( 308.0, 6.0, 1.0, 1.0 );solid_brick( 307.0, 6.0, 1.0, 1.0 );solid_brick( 306.0, 6.0, 1.0, 1.0 );solid_brick( 305.0, 6.0, 1.0, 1.0 );solid_brick( 304.0, 6.0, 1.0, 1.0 );solid_brick( 303.0, 6.0, 1.0, 1.0 );solid_brick( 302.0, 6.0, 1.0, 1.0 );solid_brick( 301.0, 6.0, 1.0, 1.0 );solid_brick( 301.0, 7.0, 1.0, 1.0 );solid_brick( 301.0, 8.0, 1.0, 1.0 );solid_brick( 301.0, 9.0, 1.0, 1.0 );solid_brick( 301.0, 10.0, 1.0, 1.0 );solid_brick( 302.0, 9.0, 1.0, 1.0 );solid_brick( 303.0, 9.0, 1.0, 1.0 );solid_brick( 304.0, 9.0, 1.0, 1.0 );solid_brick( 305.0, 9.0, 1.0, 1.0 );solid_brick( 308.0, 9.0, 1.0, 1.0 );solid_brick( 308.0, 8.0, 1.0, 1.0 );solid_brick( 308.0, 7.0, 1.0, 1.0 );solid_brick( 305.0, 8.0, 1.0, 1.0 );walky2(302.8,8.006,1.0,-10.0);coin( 12.0, 1.0 );coin( 12.0, 2.0 );coin( 12.0, 3.0 );coin( 12.0, 4.0 );solid_brick( 17.0, -3.0, 1.0, 1.0 );solid_brick( 16.0, -2.0, 1.0, 1.0 );solid_brick( 15.0, -2.0, 1.0, 1.0 );solid_brick( 14.0, -2.0, 1.0, 1.0 );solid_brick( 13.0, -3.0, 1.0, 1.0 );coin( 17.0, -2.0 );coin( 18.0, -3.0 );coin( 18.0, -4.0 );coin( 17.0, -4.0 );coin( 17.0, -5.0 );coin( 15.0, -6.0 );coin( 13.0, -6.0 );coin( 13.0, -5.0 );coin( 18.0, -5.0 );coin( 12.0, -5.0 );coin( 12.0, -4.0 );coin( 12.0, -3.0 );coin( 13.0, -2.0 );coin( 14.0, -1.0 );coin( 15.0, -1.0 );coin( 16.0, -1.0 );coin( 15.0, -3.0 );coin( 16.0, -3.0 );coin( 16.0, -4.0 );coin( 15.0, -4.0 );coin( 15.0, -5.0 );coin( 14.0, -4.0 );coin( 13.0, -4.0 );coin( 14.0, -3.0 );solid_brick( 1.0, 12.0, 1.0, 1.0 );solid_brick( 2.0, 12.0, 1.0, 1.0 );solid_brick( 3.0, 13.0, 1.0, 1.0 );solid_brick( 3.0, 14.0, 1.0, 1.0 );solid_brick( 2.0, 15.0, 1.0, 1.0 );solid_brick( 1.0, 15.0, 1.0, 1.0 );solid_brick( 0.0, 15.0, 1.0, 1.0 );solid_brick( 0.0, 13.0, 1.0, 1.0 );solid_brick( 0.0, 12.0, 1.0, 1.0 );solid_brick( 0.0, 14.0, 1.0, 1.0 );solid_brick( 0.0, 16.0, 1.0, 1.0 );solid_brick( 0.0, 17.0, 1.0, 1.0 );solid_brick( 0.0, 18.0, 1.0, 1.0 );solid_brick( 7.0, 18.0, 1.0, 1.0 );solid_brick( 7.0, 17.0, 1.0, 1.0 );solid_brick( 7.0, 16.0, 1.0, 1.0 );solid_brick( 0.0, 19.0, 1.0, 1.0 );solid_brick( 7.0, 19.0, 1.0, 1.0 );solid_brick( 7.0, 15.0, 1.0, 1.0 );solid_brick( 6.0, 16.0, 1.0, 1.0 );solid_brick( 5.0, 15.0, 1.0, 1.0 );solid_brick( 4.0, 16.0, 1.0, 1.0 );solid_brick( 4.0, 18.0, 1.0, 1.0 );solid_brick( 5.0, 19.0, 1.0, 1.0 );solid_brick( 6.0, 18.0, 1.0, 1.0 );solid_brick( 4.0, 17.0, 1.0, 1.0 );solid_brick( 9.0, 15.0, 1.0, 1.0 );solid_brick( 9.0, 16.0, 1.0, 1.0 );solid_brick( 9.0, 17.0, 1.0, 1.0 );solid_brick( 9.0, 18.0, 1.0, 1.0 );solid_brick( 9.0, 19.0, 1.0, 1.0 );solid_brick( 9.0, 20.0, 1.0, 1.0 );solid_brick( 9.0, 21.0, 1.0, 1.0 );solid_brick( 9.0, 22.0, 1.0, 1.0 );solid_brick( 9.0, 23.0, 1.0, 1.0 );coin( 3.0, 5.0 );coin( 4.0, 5.0 );coin( 5.0, 5.0 );coin( 6.0, 5.0 );coin( 7.0, 5.0 );
coin( 8.0, 5.0 );coin( 9.0, 5.0 );coin( 10.0, 5.0 );coin( 10.0, 6.0 );coin( 9.0, 6.0 );coin( 8.0, 6.0 );coin( 7.0, 6.0 );coin( 6.0, 6.0 );coin( 5.0, 6.0 );coin( 4.0, 6.0 );coin( 3.0, 6.0 );solid_brick( 10.0, 15.0, 1.0, 1.0 );solid_brick( 11.0, 15.0, 1.0, 1.0 );solid_brick( 12.0, 16.0, 1.0, 1.0 );solid_brick( 12.0, 17.0, 1.0, 1.0 );solid_brick( 11.0, 18.0, 1.0, 1.0 );solid_brick( 10.0, 18.0, 1.0, 1.0 );solid_brick( 14.0, 16.0, 1.0, 1.0 );solid_brick( 14.0, 17.0, 1.0, 1.0 );solid_brick( 14.0, 18.0, 1.0, 1.0 );solid_brick( 15.0, 15.0, 1.0, 1.0 );solid_brick( 15.0, 19.0, 1.0, 1.0 );solid_brick( 16.0, 18.0, 1.0, 1.0 );solid_brick( 17.0, 18.0, 1.0, 1.0 );solid_brick( 17.0, 19.0, 1.0, 1.0 );solid_brick( 17.0, 17.0, 1.0, 1.0 );solid_brick( 17.0, 16.0, 1.0, 1.0 );solid_brick( 17.0, 15.0, 1.0, 1.0 );solid_brick( 16.0, 16.0, 1.0, 1.0 );solid_brick( 22.0, 15.0, 1.0, 1.0 );solid_brick( 21.0, 14.0, 1.0, 1.0 );solid_brick( 21.0, 13.0, 1.0, 1.0 );solid_brick( 22.0, 12.0, 1.0, 1.0 );solid_brick( 23.0, 13.0, 1.0, 1.0 );solid_brick( 23.0, 14.0, 1.0, 1.0 );solid_brick( 21.0, 16.0, 1.0, 1.0 );solid_brick( 20.0, 17.0, 1.0, 1.0 );solid_brick( 20.0, 18.0, 1.0, 1.0 );solid_brick( 21.0, 19.0, 1.0, 1.0 );solid_brick( 22.0, 19.0, 1.0, 1.0 );solid_brick( 23.0, 19.0, 1.0, 1.0 );solid_brick( 24.0, 18.0, 1.0, 1.0 );solid_brick( 25.0, 17.0, 1.0, 1.0 );solid_brick( 25.0, 19.0, 1.0, 1.0 );solid_brick( 23.0, 17.0, 1.0, 1.0 );solid_brick( 22.0, 16.0, 1.0, 1.0 );solid_brick( 34.0, 13.0, 1.0, 1.0 );solid_brick( 33.0, 12.0, 1.0, 1.0 );solid_brick( 32.0, 12.0, 1.0, 1.0 );solid_brick( 30.0, 14.0, 1.0, 1.0 );solid_brick( 34.0, 17.0, 1.0, 1.0 );solid_brick( 34.0, 18.0, 1.0, 1.0 );solid_brick( 33.0, 19.0, 1.0, 1.0 );solid_brick( 31.0, 19.0, 1.0, 1.0 );solid_brick( 32.0, 19.0, 1.0, 1.0 );solid_brick( 30.0, 18.0, 1.0, 1.0 );solid_brick( 30.0, 13.0, 1.0, 1.0 );solid_brick( 31.0, 12.0, 1.0, 1.0 );solid_brick( 31.0, 15.0, 1.0, 1.0 );solid_brick( 32.0, 15.0, 1.0, 1.0 );solid_brick( 33.0, 15.0, 1.0, 1.0 );solid_brick( 34.0, 16.0, 1.0, 1.0 );solid_brick( 37.0, 15.0, 1.0, 1.0 );solid_brick( 39.0, 15.0, 1.0, 1.0 );solid_brick( 39.0, 16.0, 1.0, 1.0 );solid_brick( 39.0, 17.0, 1.0, 1.0 );solid_brick( 39.0, 19.0, 1.0, 1.0 );solid_brick( 39.0, 18.0, 1.0, 1.0 );solid_brick( 38.0, 16.0, 1.0, 1.0 );solid_brick( 36.0, 16.0, 1.0, 1.0 );solid_brick( 36.0, 17.0, 1.0, 1.0 );solid_brick( 36.0, 18.0, 1.0, 1.0 );solid_brick( 38.0, 18.0, 1.0, 1.0 );solid_brick( 37.0, 19.0, 1.0, 1.0 );solid_brick( 41.0, 15.0, 1.0, 1.0 );solid_brick( 41.0, 16.0, 1.0, 1.0 );solid_brick( 41.0, 17.0, 1.0, 1.0 );solid_brick( 41.0, 18.0, 1.0, 1.0 );solid_brick( 41.0, 19.0, 1.0, 1.0 );solid_brick( 42.0, 16.0, 1.0, 1.0 );solid_brick( 43.0, 15.0, 1.0, 1.0 );solid_brick( 44.0, 15.0, 1.0, 1.0 );solid_brick( 47.0, 16.0, 1.0, 1.0 );solid_brick( 47.0, 17.0, 1.0, 1.0 );solid_brick( 47.0, 18.0, 1.0, 1.0 );solid_brick( 48.0, 19.0, 1.0, 1.0 );solid_brick( 50.0, 18.0, 1.0, 1.0 );solid_brick( 49.0, 18.0, 1.0, 1.0 );solid_brick( 50.0, 19.0, 1.0, 1.0 );solid_brick( 50.0, 17.0, 1.0, 1.0 );solid_brick( 50.0, 16.0, 1.0, 1.0 );solid_brick( 50.0, 15.0, 1.0, 1.0 );solid_brick( 49.0, 16.0, 1.0, 1.0 );solid_brick( 48.0, 15.0, 1.0, 1.0 );solid_brick( 52.0, 12.0, 1.0, 1.0 );solid_brick( 52.0, 13.0, 1.0, 1.0 );solid_brick( 52.0, 14.0, 1.0, 1.0 );solid_brick( 52.0, 15.0, 1.0, 1.0 );solid_brick( 52.0, 16.0, 1.0, 1.0 );solid_brick( 52.0, 17.0, 1.0, 1.0 );solid_brick( 52.0, 18.0, 1.0, 1.0 );solid_brick( 52.0, 19.0, 1.0, 1.0 );solid_brick( 53.0, 16.0, 1.0, 1.0 );solid_brick( 54.0, 15.0, 1.0, 1.0 );solid_brick( 55.0, 16.0, 1.0, 1.0 );solid_brick( 55.0, 17.0, 1.0, 1.0 );solid_brick( 55.0, 18.0, 1.0, 1.0 );solid_brick( 55.0, 19.0, 1.0, 1.0 );solid_brick( 45.0, 16.0, 1.0, 1.0 );solid_brick( 63.0, 13.0, 1.0, 1.0 );solid_brick( 64.0, 12.0, 1.0, 1.0 );solid_brick( 65.0, 12.0, 1.0, 1.0 );solid_brick( 66.0, 13.0, 1.0, 1.0 );solid_brick( 66.0, 14.0, 1.0, 1.0 );solid_brick( 66.0, 15.0, 1.0, 1.0 );solid_brick( 65.0, 16.0, 1.0, 1.0 );solid_brick( 64.0, 17.0, 1.0, 1.0 );solid_brick( 63.0, 18.0, 1.0, 1.0 );solid_brick( 62.0, 19.0, 1.0, 1.0 );solid_brick( 61.0, 18.0, 1.0, 1.0 );solid_brick( 60.0, 17.0, 1.0, 1.0 );solid_brick( 59.0, 16.0, 1.0, 1.0 );solid_brick( 58.0, 15.0, 1.0, 1.0 );solid_brick( 58.0, 14.0, 1.0, 1.0 );solid_brick( 58.0, 13.0, 1.0, 1.0 );solid_brick( 59.0, 12.0, 1.0, 1.0 );solid_brick( 60.0, 12.0, 1.0, 1.0 );solid_brick( 61.0, 13.0, 1.0, 1.0 );solid_brick( 62.0, 14.0, 1.0, 1.0 );coin( 1.0, 5.0 );coin( 1.0, 4.0 );coin( 0.0, 4.0 );coin( 0.0, 3.0 );coin( 0.0, 2.0 );coin( 0.0, 1.0 );coin( 1.0, 1.0 );coin( 1.0, 0.0 );coin( 1.0, 2.0 );coin( 2.0, -1.0 );solid_brick( 15.0, 0.0, 1.0, 1.0 );solid_brick( 14.0, 1.0, 1.0, 1.0 );solid_brick( 15.0, 2.0, 1.0, 1.0 );solid_brick( 16.0, 3.0, 1.0, 1.0 );solid_brick( 15.0, 4.0, 1.0, 1.0 );solid_brick( 14.0, 5.0, 1.0, 1.0 );solid_brick( 6.0, 7.0, 1.0, 1.0 );solid_brick( 7.0, 8.0, 1.0, 1.0 );solid_brick( 6.0, 9.0, 1.0, 1.0 );solid_brick( 5.0, 10.0, 1.0, 1.0 );solid_brick( 6.0, 10.0, 1.0, 1.0 );solid_brick( 7.0, 10.0, 1.0, 1.0 );solid_brick( 14.0, 6.0, 1.0, 1.0 );solid_brick( 15.0, 7.0, 1.0, 1.0 );solid_brick( 16.0, 8.0, 1.0, 1.0 );solid_brick( 15.0, 9.0, 1.0, 1.0 );solid_brick( 15.0, 10.0, 1.0, 1.0 );solid_brick( 16.0, 10.0, 1.0, 1.0 );teleporter( 13.0, 10.0 );teleporter( 15.0, -4.0 );solid_brick( 0.0, 2.0, 1.0, 1.0 );coin( 6.0, 2.0 );coin( 5.0, 3.0 );coin( 6.0, 3.0 );coin( 7.0, 3.0 );coin( 9.0, 3.0 );coin( 10.0, 3.0 );coin( 4.0, 3.0 );coin( 2.0, 3.0 );coin( 3.0, 3.0 );coin( 2.0, 1.0 );solid_brick( 2.0, 0.0, 1.0, 1.0 );coin( 10.0, 1.0 );solid_brick( 10.0, 0.0, 1.0, 1.0 );teleporter( 6.0, 1.0 );teleporter( 17.0, 10.0 );coin( -17.0, -4.0 );coin( -18.0, 0.0 );coin( -18.0, 4.0 );coin( -18.0, 9.0 );coin( -18.0, -8.0 );solid_brick( -7.0, 9.0, 1.0, 1.0 );coin( -13.0, 9.006 );coin( -14.0, 8.0 );coin( -14.0, 7.0 );coin( -13.0, 8.0 );coin( -13.0, 7.0 );coin( -13.0, 6.0 );coin( -13.0, 5.0 );coin( -13.0, 4.0 );coin( -13.0, 3.0 );coin( -14.0, 3.0 );coin( -15.0, 3.0 );coin( -16.0, 3.0 );coin( -17.0, 3.0 );coin( -18.0, 3.0 );coin( -18.0, 2.0 );coin( -17.0, 2.0 );coin( -16.0, 2.0 );coin( -15.0, 2.0 );coin( -14.0, 2.0 );coin( -13.0, 2.0 );coin( -13.0, 0.0 );coin( -13.0, -1.0 );coin( -14.0, -1.0 );coin( -15.0, -1.0 );coin( -16.0, -1.0 );coin( -17.0, -1.0 );coin( -18.0, -1.0 );coin( -18.0, -2.0 );coin( -17.0, -2.0 );coin( -16.0, -2.0 );coin( -15.0, -2.0 );coin( -14.0, -2.0 );coin( -13.0, -2.0 );coin( -13.0, -4.0 );coin( -13.0, -4.0 );coin( -13.0, -5.0 );coin( -14.0, -5.0 );coin( -15.0, -5.0 );coin( -15.0, -5.0 );coin( -16.0, -5.0 );coin( -17.0, -5.0 );coin( -17.0, -5.0 );coin( -18.0, -5.0 );coin( -18.0, -5.0 );coin( -18.0, -5.0 );coin( -18.0, -6.0 );coin( -18.0, -6.0 );coin( -17.0, -6.0 );coin( -16.0, -6.0 );coin( -16.0, -6.0 );coin( -16.0, -6.0 );coin( -16.0, -6.0 );coin( -15.0, -6.0 );coin( -14.0, -6.0 );coin( -13.0, -6.0 );coin( -12.0, -6.0 );coin( -12.0, -5.0 );coin( -12.0, -4.0 );coin( -11.0, -4.0 );coin( -11.0, -5.0 );coin( -11.0, -6.0 );coin( -10.0, -6.0 );coin( -10.0, -5.0 );coin( -10.0, -4.0 );
coin( -10.0, -3.0 );coin( -9.0, -3.0 );coin( -9.0, -4.0 );coin( -9.0, -5.0 );coin( -9.0, -6.0 );coin( -9.0, -8.0 );coin( -9.0, -9.0 );coin( -9.0, -10.0 );coin( -10.0, -8.0 );coin( -10.0, -7.0 );coin( -10.0, -9.0 );coin( -10.0, -10.0 );coin( -10.0, -11.0 );coin( -11.0, -11.0 );coin( -11.0, -10.0 );coin( -11.0, -9.0 );coin( -11.0, -8.0 );coin( -12.0, -8.0 );coin( -12.0, -9.0 );coin( -12.0, -10.0 );coin( -12.0, -11.0 );coin( -13.0, -8.0 );coin( -13.0, -9.0 );coin( -13.0, -10.0 );coin( -13.0, -11.0 );coin( -12.0, -2.0 );coin( -12.0, -1.0 );coin( -12.0, 0.0 );coin( -11.0, -1.0 );coin( -11.0, -2.0 );coin( -11.0, 0.0 );coin( -10.0, -2.0 );coin( -9.0, -2.0 );coin( -11.0, 2.0 );coin( -11.0, 3.0 );coin( -11.0, 4.0 );coin( -11.0, 5.0 );coin( -11.0, 6.0 );coin( -11.0, 6.0 );coin( -11.0, 7.0 );coin( -11.0, 7.0 );coin( -11.0, 7.0 );coin( -12.0, 7.0 );coin( -12.0, 6.0 );coin( -12.0, 5.0 );coin( -12.0, 3.0 );coin( -12.0, 2.0 );coin( -13.0, 3.0 );coin( -13.0, 3.0 );coin( -16.0, 3.0 );coin( -15.0, 3.0 );coin( -15.0, 3.0 );coin( -14.0, 3.0 );coin( -12.0, 3.0 );coin( -11.0, 3.0 );coin( -13.0, 9.006 );coin( -12.0, 9.006 );coin( -12.0, 8.0 );coin( -11.0, 8.0 );coin( -11.0, 9.0 );coin( -10.0, 9.0 );coin( -10.0, 8.0 );coin( -10.0, 7.0 );coin( -10.0, 6.0 );coin( -10.0, 5.0 );coin( -10.0, 4.0 );coin( -10.0, 3.0 );coin( -10.0, 2.0 );coin( -10.0, 1.0 );coin( -10.0, 0.0 );coin( -10.0, -1.0 );coin( -9.0, -1.0 );coin( -9.0, 0.0 );coin( -9.0, 1.0 );coin( -9.0, 2.0 );coin( -9.0, 3.0 );coin( -9.0, 4.0 );coin( -9.0, 5.0 );coin( -9.0, 6.0 );coin( -9.0, 7.0 );coin( -9.0, 8.0 );solid_brick( -8.0, -4.5, 1.0, 16.0 );door(-8.0, 4.0, -8.0, 8.0);button( -9.0, 9.0 );teleporter( -7.0, 10.0 );solid_brick( -14.0, -11.0, 1.0, 1.0 );solid_brick( -14.0, -10.0, 1.0, 1.0 );solid_brick( -14.0, -9.0, 1.0, 1.0 );solid_brick( -14.0, 3.0, 1.0, 1.0 );solid_brick( -14.0, 1.0, 1.0, 1.0 );solid_brick( -14.0, 2.0, 1.0, 1.0 );solid_brick( -14.0, -1.0, 1.0, 1.0 );solid_brick( -14.0, -2.0, 1.0, 1.0 );solid_brick( -14.0, -5.0, 1.0, 1.0 );solid_brick( -14.0, -6.0, 1.0, 1.0 );coin( -18.0, -7.0 );coin( -15.0, -3.0 );coin( -18.0, 0.0 );coin( -18.0, 1.0 );invisible_brick( -13.0, -7.0, 1.0, 1.0 );invisible_brick( -12.0, -7.0, 1.0, 1.0 );invisible_brick( -11.0, -7.0, 1.0, 1.0 );invisible_brick( -10.0, -7.0, 1.0, 1.0 );invisible_brick( -12.0, -3.0, 1.0, 1.0 );invisible_brick( -11.0, -3.0, 1.0, 1.0 );invisible_brick( -10.0, -3.0, 1.0, 1.0 );invisible_brick( -9.0, -3.0, 1.0, 1.0 );teleporter( -17.0, -11.0 );coin( -13.0, -3.0 );invisible_brick( -13.0, 1.0, 1.0, 1.0 );invisible_brick( -12.0, 1.0, 1.0, 1.0 );invisible_brick( -11.0, 1.0, 1.0, 1.0 );invisible_brick( -10.0, 1.0, 1.0, 1.0 );invisible_brick( -9.0, 5.0, 1.0, 1.0 );invisible_brick( -10.0, 5.0, 1.0, 1.0 );invisible_brick( -11.0, 5.0, 1.0, 1.0 );invisible_brick( -12.0, 5.0, 1.0, 1.0 );invisible_brick( -14.0, 8.0, 1.0, 1.0 );invisible_brick( -14.0, 7.0, 1.0, 1.0 );invisible_brick( -14.0, -8.0, 1.0, 1.0 );solid_brick( -12.0, -7.0, 1.0, 1.0 );solid_brick( -10.0, -7.0, 1.0, 1.0 );solid_brick( -12.0, -3.0, 1.0, 1.0 );solid_brick( -10.0, -3.0, 1.0, 1.0 );solid_brick( -12.0, 1.0, 1.0, 1.0 );solid_brick( -10.0, 1.0, 1.0, 1.0 );solid_brick( -12.0, 5.0, 1.0, 1.0 );solid_brick( -10.0, 5.0, 1.0, 1.0 );coin( -11.0, 5.0 );coin( -9.0, 5.0 );coin( -11.0, 1.0 );coin( -13.0, 1.0 );coin( -11.0, -3.0 );coin( -9.0, -3.0 );coin( -11.0, -6.0 );coin( -11.0, -7.0 );coin( -13.0, -7.0 );coin( -14.0, -8.0 );coin( -14.0, 8.0 );coin( -14.0, 7.0 );coin( 14.0, -5.0 );coin( 16.0, -5.0 );solid_brick( 16.0, -6.0, 1.0, 1.0 );solid_brick( 14.0, -6.0, 1.0, 1.0 );coin( 12.0, -6.0 );coin( 13.0, -7.0 );coin( 14.0, -7.0 );coin( 15.0, -7.0 );coin( 16.0, -7.0 );coin( 17.0, -6.0 );coin( 17.0, -7.0 );coin( 18.0, -6.0 );coin( -14.0, 6.0 );solid_brick( 39.0, 10.0, 1.0, 1.0 );solid_brick( 40.0, 9.0, 1.0, 1.0 );solid_brick( 41.0, 8.0, 1.0, 1.0 );solid_brick( 41.0, 9.0, 1.0, 1.0 );solid_brick( 40.0, 10.0, 1.0, 1.0 );solid_brick( 41.0, 10.0, 1.0, 1.0 );solid_brick( 44.5, 6.5, 8.0, 2.0 );solid_brick( 48.5, 4.0, 10.0, 3.0 );solid_brick( 55.0, 10.0, 1.0, 1.0 );walky2(43.0,10.0,1.0,-10.0);walky2(163.8952,10.2952,0.40960002,-10.0);solid_brick( 203.0, 10.0, 1.0, 1.0 );walky2(136.42795,7.106561,6.7868776,10.0);walky2(119.134514,10.0,1.0,-10.0);solid_brick( 62.0, 2.0, 1.0, 1.0 );solid_brick( 62.0, 1.0, 1.0, 1.0 );solid_brick( 62.0, 0.0, 1.0, 1.0 );solid_brick( 62.0, -1.0, 1.0, 1.0 );solid_brick( 63.0, -2.0, 1.0, 1.0 );solid_brick( 64.0, -2.0, 1.0, 1.0 );solid_brick( 65.0, -1.0, 1.0, 1.0 );solid_brick( 65.0, 0.0, 1.0, 1.0 );solid_brick( 65.0, 1.0, 1.0, 1.0 );solid_brick( 65.0, 2.0, 1.0, 1.0 );solid_brick( 65.0, 3.0, 1.0, 1.0 );solid_brick( 64.0, 4.0, 1.0, 1.0 );solid_brick( 63.0, 4.0, 1.0, 1.0 );solid_brick( 62.0, 3.0, 1.0, 1.0 );solid_brick( 63.0, 1.0, 1.0, 1.0 );solid_brick( 64.0, 1.0, 1.0, 1.0 );solid_brick( 64.0, 2.0, 1.0, 1.0 );solid_brick( 63.0, 2.0, 1.0, 1.0 );solid_brick( 61.0, 0.0, 1.0, 1.0 );solid_brick( 60.0, -1.0, 1.0, 1.0 );solid_brick( 61.0, -2.0, 1.0, 1.0 );solid_brick( 60.0, -3.0, 1.0, 1.0 );solid_brick( 66.0, 7.0, 1.0, 1.0 );solid_brick( 67.0, 7.0, 1.0, 1.0 );solid_brick( 68.0, 7.0, 1.0, 1.0 );solid_brick( 69.0, 6.0, 1.0, 1.0 );solid_brick( 70.0, 1.0, 1.0, 1.0 );solid_brick( 71.0, 0.0, 1.0, 1.0 );solid_brick( 72.0, 0.0, 1.0, 1.0 );solid_brick( 73.0, 0.0, 1.0, 1.0 );solid_brick( 74.0, 1.0, 1.0, 1.0 );solid_brick( 75.0, 0.0, 1.0, 1.0 );solid_brick( 76.0, -1.0, 1.0, 1.0 );start_block(-7.0,8.0);end_block(70.0,5.0);solid_brick( -27.0, 7.5, 1.0, 6.0 );water( -26.0, 5.0, 1.0, 1.0 );water( -25.0, 5.0, 1.0, 1.0 );water( -24.0, 5.0, 1.0, 1.0 );water( -23.0, 5.0, 1.0, 1.0 );water( -22.0, 5.0, 1.0, 1.0 );water( -21.0, 5.0, 1.0, 1.0 );water( -20.0, 5.0, 1.0, 1.0 );water( -20.0, 6.0, 1.0, 1.0 );water( -21.0, 6.0, 1.0, 1.0 );water( -22.0, 6.0, 1.0, 1.0 );water( -23.0, 6.0, 1.0, 1.0 );water( -24.0, 6.0, 1.0, 1.0 );water( -25.0, 6.0, 1.0, 1.0 );water( -26.0, 6.0, 1.0, 1.0 );water( -26.0, 7.0, 1.0, 1.0 );water( -25.0, 7.0, 1.0, 1.0 );water( -24.0, 7.0, 1.0, 1.0 );water( -23.0, 7.0, 1.0, 1.0 );water( -22.0, 7.0, 1.0, 1.0 );water( -21.0, 7.0, 1.0, 1.0 );water( -20.0, 7.0, 1.0, 1.0 );water( -20.0, 8.0, 1.0, 1.0 );water( -21.0, 8.0, 1.0, 1.0 );water( -22.0, 8.0, 1.0, 1.0 );water( -23.0, 8.0, 1.0, 1.0 );water( -24.0, 8.0, 1.0, 1.0 );water( -25.0, 8.0, 1.0, 1.0 );water( -26.0, 8.0, 1.0, 1.0 );water( -26.0, 9.0, 1.0, 1.0 );water( -25.0, 9.0, 1.0, 1.0 );water( -24.0, 9.0, 1.0, 1.0 );water( -23.0, 9.0, 1.0, 1.0 );water( -22.0, 9.0, 1.0, 1.0 );water( -21.0, 9.0, 1.0, 1.0 );water( -20.0, 9.0, 1.0, 1.0 );water( -20.0, 10.0, 1.0, 1.0 );water( -21.0, 10.0, 1.0, 1.0 );water( -22.0, 10.0, 1.0, 1.0 );water( -23.0, 10.0, 1.0, 1.0 );water( -24.0, 10.0, 1.0, 1.0 );water( -25.0, 10.0, 1.0, 1.0 );water( -26.0, 10.0, 1.0, 1.0 );fish(-25.0,6.0,1.0,2);
  }else if( level_num+1 == 2 ){
    start_block(-3.0,7.0);solid_brick( -16.5, -2.5, 20.0, 26.0 );solid_brick( 12.0, 6.0, 11.0, 1.0 );solid_brick( 17.0, 5.0, 1.0, 1.0 );walky2( 16.0, 5.0, 1.0, -5.0 );coin( 9.0, 3.0 );coin( 12.0, 3.0 );coin( 15.0, 3.0 );coin( 1.0, 3.0 );solid_brick( 21.5, 1.0, 10.0, 1.0 );walky2( 26.0, 0.0, 1.0, -5.0 );solid_brick( 30.5, 6.0, 4.0, 9.0 );walky2( 21.0, 7.8896623, 5.220675, -5.6E-45 );coin( -25.0, -18.0 );coin( -23.0, -18.0 );coin( -20.0, -18.0 );coin( -22.0, -18.0 );coin( -18.0, -18.0 );coin( -15.0, -18.0 );coin( -13.0, -18.0 );coin( -10.0, -18.0 );coin( -8.0, -18.0 );coin( -9.0, -20.0 );coin( -12.0, -20.0 );coin( -15.0, -20.0 );coin( -18.0, -20.0 );coin( -21.0, -20.0 );coin( -23.0, -20.0 );solid_brick( -26.0, -16.0, 1.0, 1.0 );solid_brick( -7.0, -16.0, 1.0, 1.0 );walky2( -22.0, -16.15, 0.42598403, -5.0 );teleporter( -16.0, -19.0 );teleporter( 65.0, 10.0 );coin( 18.0, -2.0 );coin( 21.0, -2.0 );coin( 25.0, -2.0 );coin( 35.0, 7.0 );coin( 39.0, 7.0 );coin( 44.0, 7.0 );solid_brick( 56.0, 3.0, 1.0, 15.0 );solid_brick( 76.0, 3.0, 1.0, 15.0 );solid_brick( 60.0, 5.0, 1.0, 1.0 );solid_brick( 67.5, 6.0, 16.0, 1.0 );solid_brick( 73.0, 1.0, 1.0, 1.0 );solid_brick( 65.0, 2.0, 17.0, 1.0 );teleporter( 55.0, 10.0 );teleporter( 56.0, -5.0 );walky2( 57.0, 1.0, 1.0, -5.0 );walky2( 62.0, 5.0, 1.0, -5.0 );walky2( 66.0, 5.0, 1.0, -5.0 );coin( 60.0, 8.0 );coin( 63.0, 8.0 );coin( 66.0, 8.0 );coin( 69.0, 8.0 );coin( 72.0, 8.0 );coin( 74.0, 8.0 );walky2( 67.0, -1.0, 3.089157, -5.0 );solid_brick( 67.0, -4.0, 17.0, 1.0 );key(255,0,0,75.0,10.0);teleporter( 82.0, 7.0 );teleporter( 90.0, 7.0 );teleporter( 86.0, 7.0 );teleporter( 98.0, 7.0 );teleporter( 94.0, 7.0 );teleporter( 75.0, -5.0 );walky2( 84.0, 10.0, 1.0, -5.0 );door(105.0, 10.0, 105.0, 3.0);button( 66.0, -5.0 );solid_brick( 105.0, -1.0, 1.0, 7.0 );solid_brick( 116.0, -4.0, 21.0, 1.0 );solid_brick( 126.0, 2.0, 1.0, 11.0 );solid_brick( 115.5, 6.0, 12.0, 1.0 );solid_brick( 115.5, 2.0, 6.0, 1.0 );coin( 110.0, 3.0 );coin( 113.0, -1.0 );coin( 115.0, -1.0 );coin( 118.0, -1.0 );coin( 121.0, 4.0 );solid_brick( 122.0, 0.0, 1.0, 1.0 );solid_brick( 123.5, 1.0, 4.0, 1.0 );walky2( 124.0, 0.0, 1.0, -5.0 );walky2( 114.0, -0.43072328, 3.8614466, -5.0 );door(125.0, 2.0, 125.0, 10.0);button( 115.0, 5.0 );teleporter( 115.0, 10.0 );teleporter( 115.0, -5.0 );coin( 107.0, -7.0 );coin( 110.0, -7.0 );coin( 113.0, -7.0 );coin( 117.0, -7.0 );coin( 120.0, -7.0 );coin( 123.0, -7.0 );coin( 126.0, -7.0 );coin( 104.0, -4.0 );coin( 104.0, -3.0 );coin( 104.0, -2.0 );coin( 104.0, -1.0 );coin( 104.0, 0.0 );coin( 104.0, 1.0 );coin( 104.0, 2.0 );coin( 104.0, 3.0 );coin( 104.0, 4.0 );coin( 104.0, 5.0 );coin( 103.0, 5.0 );coin( 103.0, 4.0 );coin( 103.0, 3.0 );coin( 103.0, 2.0 );coin( 103.0, 1.0 );coin( 103.0, 0.0 );coin( 103.0, -1.0 );coin( 103.0, -2.0 );coin( 103.0, -3.0 );coin( 103.0, -4.0 );coin( 127.0, -4.0 );coin( 127.0, -3.0 );coin( 127.0, -2.0 );coin( 127.0, -1.0 );coin( 127.0, 0.0 );coin( 127.0, 1.0 );coin( 127.0, 2.0 );coin( 127.0, 3.0 );coin( 127.0, 4.0 );coin( 128.0, 4.0 );coin( 128.0, 3.0 );coin( 128.0, 2.0 );coin( 128.0, 1.0 );coin( 128.0, 0.0 );coin( 128.0, -1.0 );coin( 128.0, -2.0 );coin( 128.0, -3.0 );coin( 128.0, -4.0 );door(140.0, 10.0, 140.0, 3.0);keyed_button(255,0,0,138.0,10.0);solid_brick( 140.0, -1.5, 1.0, 8.0 );solid_brick( 149.0, -5.0, 17.0, 1.0 );solid_brick( 157.0, 3.0, 1.0, 15.0 );solid_brick( 149.0, 3.5, 9.0, 6.0 );solid_brick( 144.0, 7.0, 1.0, 1.0 );solid_brick( 142.0, 3.0, 1.0, 1.0 );coin( 146.0, -2.0 );coin( 148.0, -2.0 );coin( 151.0, -2.0 );coin( 153.0, -2.0 );solid_brick( 149.0, -10.0, 1.0, 1.0 );teleporter( 153.0, 0.0 );teleporter( 153.0, -6.0 );teleporter( 140.0, -6.0 );teleporter( 13.0, -17.0 );solid_brick( 169.0, 7.0, 1.0, 1.0 );solid_brick( 170.0, 8.0, 1.0, 1.0 );solid_brick( 171.0, 7.0, 1.0, 1.0 );solid_brick( 169.0, 6.0, 1.0, 1.0 );solid_brick( 171.0, 6.0, 1.0, 1.0 );solid_brick( 172.0, 8.0, 1.0, 1.0 );solid_brick( 173.0, 7.0, 1.0, 1.0 );solid_brick( 173.0, 6.0, 1.0, 1.0 );solid_brick( 175.0, 6.0, 1.0, 1.0 );solid_brick( 175.0, 7.0, 1.0, 1.0 );solid_brick( 175.0, 8.0, 1.0, 1.0 );solid_brick( 177.0, 8.0, 1.0, 1.0 );solid_brick( 177.0, 7.0, 1.0, 1.0 );solid_brick( 177.0, 6.0, 1.0, 1.0 );solid_brick( 178.0, 6.0, 1.0, 1.0 );solid_brick( 179.0, 7.0, 1.0, 1.0 );solid_brick( 179.0, 8.0, 1.0, 1.0 );solid_brick( 260.5, -2.0, 28.0, 25.0 );door(157.0, -6.0, 155.0, -20.0);keyed_button(0,255,0,151.0,-6.0);solid_brick( 134.0, 0.0, 1.0, 1.0 );key(0,255,0,134.0,-1.0);water( 4.0, 5.0, 1.0, 1.0 );water( 4.0, 6.0, 1.0, 1.0 );water( 4.0, 7.0, 1.0, 1.0 );water( 4.0, 8.0, 1.0, 1.0 );water( 4.0, 9.0, 1.0, 1.0 );water( 4.0, 10.0, 1.0, 1.0 );water( 3.0, 10.0, 1.0, 1.0 );water( 3.0, 9.0, 1.0, 1.0 );water( 3.0, 8.0, 1.0, 1.0 );water( 3.0, 7.0, 1.0, 1.0 );water( 3.0, 6.0, 1.0, 1.0 );water( 3.0, 5.0, 1.0, 1.0 );water( 2.0, 5.0, 1.0, 1.0 );water( 2.0, 6.0, 1.0, 1.0 );water( 2.0, 7.0, 1.0, 1.0 );water( 2.0, 8.0, 1.0, 1.0 );water( 2.0, 9.0, 1.0, 1.0 );water( 2.0, 10.0, 1.0, 1.0 );water( 1.0, 10.0, 1.0, 1.0 );water( 1.0, 9.0, 1.0, 1.0 );water( 1.0, 8.0, 1.0, 1.0 );water( 1.0, 7.0, 1.0, 1.0 );water( 1.0, 6.0, 1.0, 1.0 );water( 1.0, 5.0, 1.0, 1.0 );water( 28.0, 10.0, 1.0, 1.0 );water( 27.0, 10.0, 1.0, 1.0 );water( 26.0, 10.0, 1.0, 1.0 );water( 25.0, 10.0, 1.0, 1.0 );water( 24.0, 10.0, 1.0, 1.0 );water( 23.0, 10.0, 1.0, 1.0 );water( 22.0, 10.0, 1.0, 1.0 );water( 21.0, 10.0, 1.0, 1.0 );water( 20.0, 10.0, 1.0, 1.0 );water( 19.0, 10.0, 1.0, 1.0 );water( 19.0, 9.0, 1.0, 1.0 );water( 19.0, 8.0, 1.0, 1.0 );water( 19.0, 7.0, 1.0, 1.0 );water( 19.0, 6.0, 1.0, 1.0 );water( 18.0, 5.0, 1.0, 1.0 );water( 18.0, 6.0, 1.0, 1.0 );water( 18.0, 7.0, 1.0, 1.0 );water( 18.0, 8.0, 1.0, 1.0 );water( 18.0, 9.0, 1.0, 1.0 );water( 18.0, 10.0, 1.0, 1.0 );water( 19.0, 5.0, 1.0, 1.0 );water( 20.0, 5.0, 1.0, 1.0 );water( 21.0, 5.0, 1.0, 1.0 );water( 22.0, 5.0, 1.0, 1.0 );water( 23.0, 5.0, 1.0, 1.0 );water( 24.0, 5.0, 1.0, 1.0 );water( 25.0, 5.0, 1.0, 1.0 );water( 26.0, 5.0, 1.0, 1.0 );water( 27.0, 5.0, 1.0, 1.0 );water( 28.0, 5.0, 1.0, 1.0 );water( 28.0, 6.0, 1.0, 1.0 );water( 28.0, 7.0, 1.0, 1.0 );water( 28.0, 8.0, 1.0, 1.0 );water( 28.0, 9.0, 1.0, 1.0 );water( 27.0, 9.0, 1.0, 1.0 );water( 27.0, 8.0, 1.0, 1.0 );water( 27.0, 7.0, 1.0, 1.0 );water( 27.0, 6.0, 1.0, 1.0 );water( 26.0, 6.0, 1.0, 1.0 );water( 26.0, 7.0, 1.0, 1.0 );water( 26.0, 8.0, 1.0, 1.0 );water( 26.0, 9.0, 1.0, 1.0 );water( 25.0, 9.0, 1.0, 1.0 );water( 25.0, 8.0, 1.0, 1.0 );water( 25.0, 7.0, 1.0, 1.0 );water( 25.0, 6.0, 1.0, 1.0 );water( 24.0, 6.0, 1.0, 1.0 );water( 24.0, 7.0, 1.0, 1.0 );water( 24.0, 8.0, 1.0, 1.0 );water( 24.0, 9.0, 1.0, 1.0 );water( 23.0, 9.0, 1.0, 1.0 );water( 23.0, 8.0, 1.0, 1.0 );water( 23.0, 7.0, 1.0, 1.0 );water( 23.0, 6.0, 1.0, 1.0 );water( 22.0, 6.0, 1.0, 1.0 );water( 22.0, 7.0, 1.0, 1.0 );water( 22.0, 8.0, 1.0, 1.0 );water( 22.0, 9.0, 1.0, 1.0 );water( 21.0, 9.0, 1.0, 1.0 );water( 21.0, 8.0, 1.0, 1.0 );water( 21.0, 7.0, 1.0, 1.0 );water( 21.0, 6.0, 1.0, 1.0 );water( 20.0, 6.0, 1.0, 1.0 );water( 20.0, 7.0, 1.0, 1.0 );
water( 20.0, 8.0, 1.0, 1.0 );water( 20.0, 9.0, 1.0, 1.0 );solid_brick( 17.0, 10.0, 1.0, 1.0 );solid_brick( 17.0, 9.0, 1.0, 1.0 );solid_brick( 17.0, 8.0, 1.0, 1.0 );solid_brick( 17.0, 7.0, 1.0, 1.0 );solid_brick( 5.0, 10.0, 1.0, 1.0 );solid_brick( 5.0, 9.0, 1.0, 1.0 );solid_brick( 5.0, 8.0, 1.0, 1.0 );solid_brick( 5.0, 7.0, 1.0, 1.0 );solid_brick( 5.0, 6.0, 1.0, 1.0 );solid_brick( 5.0, 5.0, 1.0, 1.0 );solid_brick( 0.0, 5.0, 1.0, 1.0 );solid_brick( 0.0, 6.0, 1.0, 1.0 );solid_brick( 0.0, 7.0, 1.0, 1.0 );solid_brick( 0.0, 8.0, 1.0, 1.0 );solid_brick( 0.0, 9.0, 1.0, 1.0 );solid_brick( 0.0, 10.0, 1.0, 1.0 );end_block(175.0,4.0);
  }else if( level_num+1 == 3 ){
solid_brick( 23.0, 10.006, 41.0, 1.0 );solid_brick( 13.0, 7.0, 1.0, 5.0 );solid_brick( 33.0, 7.0, 1.0, 5.0 );solid_brick( 30.0, 5.0, 5.0, 1.0 );solid_brick( 13.0, 0.0, 21.0, 1.0 );solid_brick( 23.0, 0.0, 1.0, 11.0 );solid_brick( 25.0, 2.0, 3.0, 1.0 );solid_brick( 36.0, 0.0, 15.0, 1.0 );solid_brick( 33.0, 1.5, 1.0, 2.0 );solid_brick( 43.0, -10.5, 1.0, 40.0 );solid_brick( 38.0, -7.5, 1.0, 6.0 );solid_brick( 33.0, -10.0, 21.0, 1.0 );solid_brick( 3.0, -15.0, 1.0, 31.0 );solid_brick( 33.0, -7.0, 1.0, 5.0 );solid_brick( 13.0, -8.0, 1.0, 15.0 );solid_brick( 8.0, -10.0, 9.0, 1.0 );water( 4.0, -7.0, 1.0, 1.0 );water( 5.0, -7.0, 1.0, 1.0 );water( 6.0, -7.0, 1.0, 1.0 );water( 7.0, -7.0, 1.0, 1.0 );water( 8.0, -7.0, 1.0, 1.0 );water( 9.0, -7.0, 1.0, 1.0 );water( 10.0, -7.0, 1.0, 1.0 );water( 11.0, -7.0, 1.0, 1.0 );water( 12.0, -7.0, 1.0, 1.0 );water( 12.0, -6.0, 1.0, 1.0 );water( 11.0, -6.0, 1.0, 1.0 );water( 10.0, -6.0, 1.0, 1.0 );water( 9.0, -6.0, 1.0, 1.0 );water( 8.0, -6.0, 1.0, 1.0 );water( 7.0, -6.0, 1.0, 1.0 );water( 6.0, -6.0, 1.0, 1.0 );water( 5.0, -6.0, 1.0, 1.0 );water( 4.0, -6.0, 1.0, 1.0 );water( 4.0, -5.0, 1.0, 1.0 );water( 5.0, -5.0, 1.0, 1.0 );water( 6.0, -5.0, 1.0, 1.0 );water( 7.0, -5.0, 1.0, 1.0 );water( 8.0, -5.0, 1.0, 1.0 );water( 9.0, -5.0, 1.0, 1.0 );water( 10.0, -5.0, 1.0, 1.0 );water( 11.0, -5.0, 1.0, 1.0 );water( 12.0, -5.0, 1.0, 1.0 );water( 12.0, -4.0, 1.0, 1.0 );water( 11.0, -4.0, 1.0, 1.0 );water( 10.0, -4.0, 1.0, 1.0 );water( 9.0, -4.0, 1.0, 1.0 );water( 8.0, -4.0, 1.0, 1.0 );water( 7.0, -4.0, 1.0, 1.0 );water( 6.0, -4.0, 1.0, 1.0 );water( 5.0, -4.0, 1.0, 1.0 );water( 4.0, -4.0, 1.0, 1.0 );water( 4.0, -3.0, 1.0, 1.0 );water( 5.0, -3.0, 1.0, 1.0 );water( 6.0, -3.0, 1.0, 1.0 );water( 7.0, -3.0, 1.0, 1.0 );water( 8.0, -3.0, 1.0, 1.0 );water( 9.0, -3.0, 1.0, 1.0 );water( 10.0, -3.0, 1.0, 1.0 );water( 11.0, -3.0, 1.0, 1.0 );water( 12.0, -3.0, 1.0, 1.0 );water( 12.0, -2.0, 1.0, 1.0 );water( 11.0, -2.0, 1.0, 1.0 );water( 10.0, -2.0, 1.0, 1.0 );water( 9.0, -2.0, 1.0, 1.0 );water( 8.0, -2.0, 1.0, 1.0 );water( 7.0, -2.0, 1.0, 1.0 );water( 6.0, -2.0, 1.0, 1.0 );water( 5.0, -2.0, 1.0, 1.0 );water( 4.0, -2.0, 1.0, 1.0 );water( 5.0, -1.0, 1.0, 1.0 );water( 4.0, -1.0, 1.0, 1.0 );water( 6.0, -1.0, 1.0, 1.0 );water( 7.0, -1.0, 1.0, 1.0 );water( 8.0, -1.0, 1.0, 1.0 );water( 9.0, -1.0, 1.0, 1.0 );water( 10.0, -1.0, 1.0, 1.0 );water( 11.0, -1.0, 1.0, 1.0 );water( 12.0, -1.0, 1.0, 1.0 );fish(7.070426,-7.4294024,1.0,1.8953298);walky2(14.7,-0.994,1.0,5.0);walky2(18.8,-3.00394,5.0198803,5.0);solid_brick( 6.0, -15.0, 5.0, 1.0 );solid_brick( 25.0, -20.0, 35.0, 1.0 );solid_brick( 23.0, -13.0, 1.0, 5.0 );solid_brick( 33.0, -13.0, 1.0, 5.0 );water( 24.0, -14.0, 1.0, 1.0 );water( 24.0, -13.0, 1.0, 1.0 );water( 24.0, -12.0, 1.0, 1.0 );water( 24.0, -11.0, 1.0, 1.0 );water( 25.0, -11.0, 1.0, 1.0 );water( 25.0, -12.0, 1.0, 1.0 );water( 25.0, -13.0, 1.0, 1.0 );water( 25.0, -14.0, 1.0, 1.0 );water( 26.0, -14.0, 1.0, 1.0 );water( 26.0, -13.0, 1.0, 1.0 );water( 26.0, -12.0, 1.0, 1.0 );water( 26.0, -11.0, 1.0, 1.0 );water( 27.0, -11.0, 1.0, 1.0 );water( 27.0, -12.0, 1.0, 1.0 );water( 27.0, -13.0, 1.0, 1.0 );water( 27.0, -14.0, 1.0, 1.0 );water( 28.0, -14.0, 1.0, 1.0 );water( 28.0, -13.0, 1.0, 1.0 );water( 28.0, -12.0, 1.0, 1.0 );water( 29.0, -11.0, 1.0, 1.0 );water( 29.0, -12.0, 1.0, 1.0 );water( 29.0, -13.0, 1.0, 1.0 );water( 29.0, -14.0, 1.0, 1.0 );water( 30.0, -14.0, 1.0, 1.0 );water( 30.0, -13.0, 1.0, 1.0 );water( 30.0, -12.0, 1.0, 1.0 );water( 30.0, -11.0, 1.0, 1.0 );water( 31.0, -11.0, 1.0, 1.0 );water( 31.0, -12.0, 1.0, 1.0 );water( 31.0, -13.0, 1.0, 1.0 );water( 31.0, -14.0, 1.0, 1.0 );water( 32.0, -14.0, 1.0, 1.0 );water( 32.0, -13.0, 1.0, 1.0 );water( 32.0, -12.0, 1.0, 1.0 );water( 28.0, -11.0, 1.0, 1.0 );water( 32.0, -11.0, 1.0, 1.0 );fish(27.76,-11.0,1.0,-2.0);fish(24.673756,-11.0,1.0,0.0);solid_brick( 23.0, -23.0, 1.0, 5.0 );solid_brick( 20.0, -25.0, 5.0, 1.0 );solid_brick( 40.0, -25.0, 5.0, 1.0 );solid_brick( 38.0, -28.0, 1.0, 5.0 );solid_brick( 23.0, -30.0, 41.0, 1.0 );water( 39.0, -27.0, 1.0, 1.0 );water( 40.0, -27.0, 1.0, 1.0 );water( 41.0, -27.0, 1.0, 1.0 );water( 42.0, -27.0, 1.0, 1.0 );water( 41.0, -26.0, 1.0, 1.0 );water( 40.0, -26.0, 1.0, 1.0 );water( 39.0, -26.0, 1.0, 1.0 );door(3.0, 1.0, 3.0, 9.0);button( 0.0, 10.0 );door(4.0, 9.0, 4.0, 1.0);button( -3.0, 10.0 );walky2(18.0,9.011999,1.0,-5.0);teleporter( 34.0, -25.0 );teleporter( 43.0, -31.0 );water( 42.0, -26.0, 1.0, 1.0 );teleporter( 42.0, -29.0 );teleporter( 34.0, -21.0 );teleporter( 34.0, -29.0 );teleporter( 12.0, -9.0 );teleporter( 45.0, 10.0 );teleporter( -9.0, -8.0 );door(13.0, -10.0, 23.0, -10.0);button( 42.0, -1.0 );door(13.0, -21.0, 13.0, -29.0);button( 39.0, -5.0 );key(0,255,0,18.0,-11.0);invisible_brick( 3.0, -31.0, 1.0, 1.0 );end_block(37.0,-31.0);walky2(24.536255,-38.563744,16.127487,5.0);start_block(-6.0,2.0);invisible_brick( 33.0, -31.0, 1.0, 1.0 );coin( 4.0, -1.0 );coin( 4.0, -2.0 );coin( 5.0, -2.0 );coin( 5.0, -1.0 );coin( 4.0, -7.0 );coin( 7.0, -5.0 );coin( 10.0, -7.0 );coin( 11.0, -4.0 );coin( 8.0, -2.0 );coin( 5.0, -4.0 );coin( -9.0, -7.0 );coin( -9.0, -6.0 );coin( -9.0, -5.0 );coin( -9.0, -4.0 );coin( -9.0, -3.0 );coin( -9.0, -2.0 );coin( -9.0, -1.0 );coin( -9.0, 0.0 );coin( -9.0, 1.0 );coin( -9.0, 2.0 );coin( -9.0, 3.0 );coin( -9.0, 4.0 );coin( -9.0, 4.0 );coin( -9.0, 5.0 );coin( -9.0, 6.0 );coin( -9.0, 7.0 );coin( -9.0, 8.0 );coin( -9.0, 9.0 );coin( -9.0, 10.0 );coin( 12.0, 6.0 );coin( 7.0, 5.0 );coin( 16.0, 3.0 );coin( 17.0, 3.0 );coin( 18.0, 3.0 );coin( 19.0, 3.0 );coin( 28.0, 6.0 );coin( 28.0, 7.0 );coin( 29.0, 7.0 );coin( 29.0, 6.0 );coin( 39.0, 8.0 );coin( 39.0, 3.0 );coin( 35.0, 3.0 );coin( 35.0, 8.0 );coin( 37.0, 6.0 );coin( 37.0, -9.0 );coin( 36.0, -9.0 );coin( 35.0, -9.0 );coin( 34.0, -9.0 );coin( 34.0, -8.0 );coin( 35.0, -8.0 );coin( 36.0, -8.0 );coin( 37.0, -8.0 );coin( 37.0, -7.0 );coin( 36.0, -7.0 );coin( 35.0, -7.0 );coin( 34.0, -7.0 );coin( 34.0, -6.0 );coin( 35.0, -6.0 );coin( 36.0, -6.0 );coin( 37.0, -6.0 );coin( 37.0, -5.0 );coin( 36.0, -5.0 );coin( 35.0, -5.0 );coin( 34.0, -5.0 );invisible_brick( 36.0, -5.0, 1.0, 1.0 );invisible_brick( 37.0, -5.0, 1.0, 1.0 );coin( 24.0, -3.0 );coin( 24.0, -5.0 );coin( 22.0, -1.0 );coin( 21.0, -1.0 );coin( 20.0, -1.0 );coin( 19.0, -1.0 );coin( 18.0, -1.0 );coin( 17.0, -1.0 );coin( 16.0, -1.0 );coin( 15.0, -1.0 );coin( 14.0, -1.0 );coin( 8.0, -14.0 );coin( 8.0, -13.0 );coin( 8.0, -12.0 );coin( 8.0, -11.0 );coin( 7.0, -11.0 );coin( 7.0, -12.0 );coin( 7.0, -13.0 );coin( 7.0, -14.0 );coin( 4.0, -14.0 );coin( 25.0, -14.0 );coin( 32.0, -11.0 );coin( 30.0, -13.0 );coin( 40.0, -13.0 );coin( 41.0, -14.0 );coin( 42.0, -17.0 );coin( 38.0, -17.0 );coin( 37.0, -14.0 );door(33.0, -30.0, 33.0, -20.0);keyed_button(0,255,0,42.0,-11.0);solid_brick( 84.0, 5.0, 11.0, 11.0 );solid_brick( 47.0, 8.0, 1.0, 5.0 );walky2(66.41714,0.01713501,20.96573,-5.0);fish(8.456921,-3.9530745,0.719913,1.6161432);fish(8.573414,-0.613414,0.24533713,2.0);coin( 28.0, -26.0 );coin( 25.0, -26.0 );
coin( 24.0, -24.0 );coin( 25.0, -23.0 );coin( 26.0, -22.0 );coin( 27.0, -22.0 );coin( 28.0, -23.0 );coin( 29.0, -24.0 );coin( 27.0, -25.0 );coin( 8.0, -26.0 );coin( 9.0, -27.0 );coin( 10.0, -27.0 );coin( 11.0, -26.0 );coin( 11.0, -25.0 );coin( 10.0, -24.0 );coin( 9.0, -23.0 );coin( 8.0, -22.0 );coin( 7.0, -23.0 );coin( 6.0, -24.0 );coin( 5.0, -25.0 );coin( 5.0, -26.0 );coin( 6.0, -27.0 );coin( 7.0, -27.0 );coin( 8.0, -31.0 );coin( 8.0, -32.0 );coin( 8.0, -33.0 );coin( 8.0, -34.0 );coin( 8.0, -35.0 );coin( 8.0, -36.0 );coin( 8.0, -37.0 );coin( 8.0, -38.0 );coin( 8.0, -39.0 );coin( 7.0, -39.0 );coin( 7.0, -38.0 );coin( 7.0, -36.0 );coin( 7.0, -37.0 );coin( 7.0, -34.0 );coin( 7.0, -35.0 );coin( 7.0, -33.0 );coin( 7.0, -32.0 );coin( 7.0, -31.0 );coin( 6.0, -31.0 );coin( 6.0, -32.0 );coin( 6.0, -33.0 );coin( 6.0, -34.0 );coin( 6.0, -35.0 );coin( 6.0, -36.0 );coin( 6.0, -37.0 );coin( 6.0, -38.0 );coin( 6.0, -39.0 );coin( 5.0, -39.0 );coin( 5.0, -38.0 );coin( 5.0, -37.0 );coin( 5.0, -36.0 );coin( 5.0, -35.0 );coin( 5.0, -34.0 );coin( 5.0, -33.0 );coin( 5.0, -32.0 );coin( 5.0, -31.0 );coin( 4.0, -31.0 );coin( 4.0, -32.0 );coin( 4.0, -33.0 );coin( 4.0, -34.0 );coin( 4.0, -35.0 );coin( 4.0, -36.0 );coin( 4.0, -37.0 );coin( 4.0, -38.0 );coin( 4.0, -39.0 );coin( 3.0, -39.0 );coin( 3.0, -38.0 );coin( 3.0, -37.0 );coin( 3.0, -36.0 );coin( 3.0, -35.0 );coin( 3.0, -34.0 );coin( 3.0, -33.0 );coin( 3.0, -32.0 );coin( 3.0, -31.0 );teleporter( 44.0, -20.0 );teleporter( 23.0, -51.0 );teleporter( 15.0, -22.0 );teleporter( 41.0, 8.0 );key(255,0,0,20.0,-11.0);door(14.0, -15.0, 14.0, -20.0);keyed_button(255,0,0,12.0,-14.0);walky2(10.0,9.0,0.4430234,-5.0);walky2(9.0,9.0,0.36859542,-5.0);
  }else if( level_num+1 == 4 ){
invisible_brick( 100.0, -25.0, 1.0, 1.0 );invisible_brick( 101.0, -25.0, 1.0, 1.0 );invisible_brick( 101.0, -25.0, 1.0, 1.0 );invisible_brick( 101.0, -25.0, 1.0, 1.0 );invisible_brick( 102.0, -25.0, 1.0, 1.0 );invisible_brick( 103.0, -25.0, 1.0, 1.0 );invisible_brick( 104.0, -25.0, 1.0, 1.0 );invisible_brick( 105.0, -25.0, 1.0, 1.0 );invisible_brick( 106.0, -25.0, 1.0, 1.0 );invisible_brick( 106.0, -25.0, 1.0, 1.0 );invisible_brick( 107.0, -25.0, 1.0, 1.0 );invisible_brick( 108.0, -25.0, 1.0, 1.0 );invisible_brick( 109.0, -25.0, 1.0, 1.0 );invisible_brick( 110.0, -25.0, 1.0, 1.0 );invisible_brick( 110.0, -25.0, 1.0, 1.0 );invisible_brick( 111.0, -25.0, 1.0, 1.0 );invisible_brick( 112.0, -25.0, 1.0, 1.0 );invisible_brick( 113.0, -25.0, 1.0, 1.0 );invisible_brick( 113.0, -25.0, 1.0, 1.0 );invisible_brick( 115.0, -25.0, 1.0, 1.0 );invisible_brick( 115.0, -25.0, 1.0, 1.0 );invisible_brick( 114.0, -25.0, 1.0, 1.0 );invisible_brick( 116.0, -25.0, 1.0, 1.0 );invisible_brick( 117.0, -25.0, 1.0, 1.0 );invisible_brick( 117.0, -25.0, 1.0, 1.0 );invisible_brick( 118.0, -25.0, 1.0, 1.0 );invisible_brick( 119.0, -25.0, 1.0, 1.0 );invisible_brick( 120.0, -25.0, 1.0, 1.0 );invisible_brick( 121.0, -25.0, 1.0, 1.0 );invisible_brick( 122.0, -25.0, 1.0, 1.0 );invisible_brick( 123.0, -25.0, 1.0, 1.0 );invisible_brick( 124.0, -25.0, 1.0, 1.0 );invisible_brick( 125.0, -25.0, 1.0, 1.0 );invisible_brick( 126.0, -25.0, 1.0, 1.0 );invisible_brick( 127.0, -25.0, 1.0, 1.0 );solid_brick( 235.0, 11.0, 19.0, 3.0 );solid_brick( 244.0, 4.5, 1.0, 12.0 );solid_brick( 240.0, 8.0, 1.0, 5.0 );solid_brick( 235.0, 7.0, 1.0, 7.0 );solid_brick( 231.0, 8.0, 1.0, 5.0 );solid_brick( 228.0, 6.5, 1.0, 8.0 );solid_brick( 225.0, 8.5, 1.0, 4.0 );solid_brick( 223.0, 9.5, 1.0, 2.0 );solid_brick( 221.0, 10.0, 1.0, 1.0 );coin( 221.0, 9.0 );coin( 223.0, 8.0 );coin( 225.0, 6.0 );coin( 228.0, 2.0 );coin( 231.0, 6.0 );coin( 231.0, 5.0 );coin( 235.0, 3.0 );coin( 240.0, 5.0 );solid_brick( 242.0, 6.0, 1.0, 9.0 );coin( 242.0, 1.0 );coin( 244.0, -2.0 );solid_brick( 247.0, 2.0, 1.0, 17.0 );coin( 247.0, -7.0 );solid_brick( 252.0, -2.0, 1.0, 25.0 );coin( 252.0, -14.0 );coin( 252.0, -15.0 );solid_brick( 256.0, -5.5, 1.0, 34.0 );solid_brick( 277.5, -25.0, 28.0, 1.0 );start_block(163.0,7.0);solid_brick( 130.0, -9.0, 49.0, 41.0 );coin( 256.0, -23.0 );coin( 257.0, -25.0 );coin( 259.0, -22.0 );coin( 259.0, -27.0 );coin( 261.0, -29.0 );coin( 263.0, -29.0 );coin( 264.0, -28.0 );coin( 265.0, -27.0 );coin( 265.0, -26.0 );coin( 266.0, -26.0 );coin( 288.0, -29.0 );coin( 281.0, -29.0 );coin( 281.0, -39.0 );coin( 282.0, -30.0 );coin( 282.0, -39.0 );coin( 282.0, -30.0 );coin( 282.0, -29.0 );coin( 282.0, -29.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 282.0, -30.0 );coin( 272.0, -32.0 );coin( 275.0, -29.0 );coin( 279.0, -35.0 );coin( 267.0, -35.0 );coin( 273.0, -38.0 );end_block(289.0,-26.0);solid_brick( 250.0, -11.0, 1.0, 1.0 );coin( 250.0, -12.0 );solid_brick( 254.0, -19.0, 1.0, 1.0 );coin( 254.0, -20.0 );invisible_brick( 260.5, -20.0, 8.0, 1.0 );invisible_brick( 264.0, -22.5, 1.0, 6.0 );
  }else if( level_num+1 == 5 ){
    solid_brick( 6.4, 7.5, 1.0, 6.0 );solid_brick( 0.0, -28.5, 1.0, 78.0 );solid_brick( 16.5, -67.0, 34.0, 1.0 );solid_brick( -15.0, 6.5, 1.0, 8.0 );end_block(3.0,10.0);door(1.0, 4.0, 6.0, 4.0);keyed_button(0,255,0,8.0,10.0);start_block(3.0,0.0);solid_brick( 28.5, 1.0, 12.0, 1.0 );solid_brick( 34.0, -3.5, 1.0, 8.0 );solid_brick( 23.0, -27.0, 1.0, 55.0 );key(255,0,0,29.99657,-3.218651E-8);solid_brick( 50.0, -4.5, 1.0, 30.0 );solid_brick( 48.5, 7.0, 2.0, 1.0 );solid_brick( 43.5, 3.0, 4.0, 1.0 );solid_brick( 48.5, -1.0, 2.0, 1.0 );solid_brick( 44.5, -5.0, 2.0, 1.0 );solid_brick( 49.0, -9.0, 1.0, 1.0 );solid_brick( 46.0, -12.0, 1.0, 1.0 );solid_brick( 49.0, -16.0, 1.0, 1.0 );teleporter( 52.0, 10.0 );teleporter( 20.0, -56.0 );teleporter( 73.0, 10.0 );teleporter( -9.0, 10.0 );solid_brick( 79.5, -5.0, 4.0, 31.0 );solid_brick( 131.0, -8.0, 3.0, 37.0 );gravity_switch(9.0,5.0,0.0,0.3);gravity_switch(64.0,10.0,-0.3,0.0);coin( 5.0, 1.0 );coin( 5.0, -4.0 );coin( 2.0, -7.0 );coin( 5.0, -9.0 );coin( 2.0, -12.0 );coin( 5.0, -14.0 );coin( 2.0, -17.0 );coin( 6.0, -19.0 );coin( 2.0, -22.0 );coin( 5.0, -24.0 );solid_brick( 11.0, -13.5, 1.0, 14.0 );coin( 12.0, -7.0 );coin( 12.0, -8.0 );coin( 12.0, -9.0 );coin( 12.0, -10.0 );coin( 12.0, -11.0 );coin( 12.0, -12.0 );coin( 12.0, -13.0 );coin( 12.0, -14.0 );coin( 12.0, -15.0 );coin( 12.0, -16.0 );coin( 12.0, -17.0 );coin( 12.0, -18.0 );coin( 12.0, -19.0 );coin( 12.0, -20.0 );coin( 13.0, -20.0 );coin( 13.0, -19.0 );coin( 13.0, -18.0 );coin( 13.0, -17.0 );coin( 13.0, -16.0 );coin( 13.0, -15.0 );coin( 13.0, -14.0 );coin( 13.0, -13.0 );coin( 13.0, -12.0 );coin( 13.0, -11.0 );coin( 13.0, -10.0 );coin( 13.0, -9.0 );coin( 13.0, -8.0 );coin( 13.0, -7.0 );coin( 14.0, -7.0 );coin( 14.0, -8.0 );coin( 14.0, -9.0 );coin( 14.0, -10.0 );coin( 14.0, -11.0 );coin( 14.0, -12.0 );coin( 14.0, -13.0 );coin( 14.0, -14.0 );coin( 14.0, -15.0 );coin( 14.0, -16.0 );coin( 14.0, -18.0 );coin( 14.0, -19.0 );coin( 14.0, -20.0 );coin( 14.0, -17.0 );solid_brick( 12.0, -21.0, 1.0, 1.0 );solid_brick( 13.5, -6.0, 4.0, 1.0 );solid_brick( 15.0, -7.0, 1.0, 1.0 );walky2(12.9,-6.9940004,1.0,-5.0);coin( 2.0, -27.0 );coin( 5.0, -31.0 );coin( 2.0, -33.0 );coin( 2.0, -38.0 );coin( 5.0, -36.0 );coin( 5.0, -42.0 );coin( 2.0, -44.0 );coin( 2.0, -49.0 );coin( 5.0, -47.0 );coin( 5.0, -52.0 );coin( 2.0, -52.0 );coin( 2.0, -57.0 );coin( 5.0, -55.0 );coin( 5.0, -60.0 );coin( 2.0, -63.0 );coin( 5.0, -66.0 );coin( 5.0, -64.0 );solid_brick( 0.0, -69.5, 1.0, 4.0 );solid_brick( 1.0, -71.0, 1.0, 1.0 );walky2(8.74244,-68.636444,2.28488,5.0);solid_brick( 32.0, -71.0, 1.0, 1.0 );solid_brick( 33.0, -69.5, 1.0, 4.0 );solid_brick( 17.0, 7.0, 1.0, 1.0 );solid_brick( 23.0, 7.0, 1.0, 1.0 );solid_brick( 19.0, 4.0, 1.0, 1.0 );solid_brick( 21.0, 4.0, 1.0, 1.0 );coin( 36.0, 5.0 );coin( 36.0, 6.0 );coin( 36.0, 7.0 );coin( 37.0, 7.0 );coin( 38.0, 7.0 );coin( 38.0, 6.0 );coin( 38.0, 5.0 );coin( 40.0, 5.0 );coin( 40.0, 6.0 );coin( 40.0, 7.0 );coin( 40.0, 8.0 );coin( 40.0, 9.0 );coin( 40.0, 10.0 );coin( 41.0, 7.0 );coin( 42.0, 6.0 );coin( 41.0, 5.0 );coin( 26.0, -2.0 );coin( 26.0, -3.0 );coin( 26.0, -4.0 );coin( 26.0, -5.0 );coin( 26.0, -6.0 );coin( 28.0, -6.0 );coin( 28.0, -5.0 );coin( 28.0, -4.0 );coin( 28.0, -3.0 );coin( 28.0, -2.0 );coin( 30.0, -2.0 );coin( 30.0, -3.0 );coin( 30.0, -4.0 );coin( 30.0, -5.0 );coin( 30.0, -6.0 );coin( 49.0, -2.0 );coin( 45.0, -6.0 );coin( 44.0, -6.0 );coin( 46.0, -13.0 );coin( 49.0, -10.0 );coin( 49.0, -17.0 );coin( 50.0, -20.0 );coin( 50.0, -21.0 );coin( 50.0, -22.0 );coin( 50.0, -23.0 );coin( 50.0, -24.0 );coin( 50.0, -25.0 );coin( 50.0, -26.0 );coin( 48.0, 6.0 );coin( 49.0, 6.0 );coin( 49.0, 5.0 );coin( 45.0, 1.0 );coin( 45.0, 2.0 );coin( 44.0, 2.0 );coin( 43.0, 2.0 );coin( 42.0, 2.0 );coin( 42.0, 1.0 );walky2(13.369258,10.006,1.0,5.0);walky2(9.769258,10.006,1.0,-5.0);walky2(26.08463,10.159888,0.692224,5.0);walky2(2.9117298,8.411729,4.1765404,-5.0);solid_brick( -119.0, -18.5, 1.0, 58.0 );solid_brick( -107.0, -47.0, 23.0, 1.0 );walky2(-66.66914,-12.5248575,46.061714,5.0);door(21.0, 9.0, 21.0, 8.0);button( 20.0, 6.0 );solid_brick( 20.0, 8.0, 5.0, 1.0 );solid_brick( 6.0, -22.5, 1.0, 6.0 );door(70.0, 10.0, 70.0, -20.0);keyed_button(255,0,0,67.0,10.0);key(0,255,0,-14.0,9.999999);water( -7.5, 6.5, 14.0, 8.0 );spike(34.0,-8.0,0.7,0.7);spike(19.0,3.0,0.7,1.0);spike(21.0,3.0,0.7,1.0);spike(31.5,9.5,2.0245104,2.0245104);spike(-125.0,-18.5,1.0,58.0);spike(16.0,15.5,21.0,4.0);spike(37.0,16.5,5.0,8.0);bouncy(40.0,0.0,1.0,-5.0);bouncy(32.0,-4.0,1.0,-5.0);bouncy(38.0,7.0,1.0,-5.0);bouncy(42.0,6.0,1.0,-5.0);bouncy(47.0,9.0,1.0,-5.0);
  }else if( level_num+1 == 6 ){
solid_brick( -70.0, 5.5, 1.0, 12.0 );solid_brick( -40.0, 5.5, 1.0, 12.0 );solid_brick( -42.0, 0.0, 5.0, 1.0 );solid_brick( -53.5, 0.0, 12.0, 1.0 );solid_brick( -64.5, 0.0, 12.0, 1.0 );solid_brick( -64.5, 6.0, 12.0, 1.0 );solid_brick( -59.0, 7.0, 1.0, 1.0 );walky2(-61.0,10.0,1.0,-5.0);walky2(-60.0,10.0,1.0,-5.0);walky2(-59.0,10.0,1.0,-5.0);walky2(-58.0,10.0,1.0,-5.0);walky2(-57.0,10.0,1.0,-5.0);walky2(-56.0,10.0,1.0,-5.0);walky2(-55.0,10.0,1.0,-5.0);walky2(-54.0,10.0,1.0,-5.0);solid_brick( -48.0, 1.0, 1.0, 1.0 );solid_brick( -53.0, 10.0, 1.0, 1.0 );solid_brick( -59.0, 5.0, 1.0, 1.0 );walky2(-69.0,5.0,1.0,-5.0);walky2(-68.0,5.0,1.0,-5.0);walky2(-67.0,5.0,1.0,-5.0);walky2(-66.0,5.0,1.0,-5.0);walky2(-65.0,5.0,1.0,-5.0);walky2(-64.0,5.0,1.0,-5.0);solid_brick( -48.0, 2.5, 1.0, 4.0 );solid_brick( -53.0, 2.5, 1.0, 4.0 );fish(-51.0,10.0,1.0,2.0);fish(-51.0,9.0,1.0,2.0);fish(-50.0,9.0,1.0,2.0);fish(-50.0,10.0,1.0,2.0);fish(-49.0,10.0,1.0,2.0);fish(-49.0,9.0,1.0,2.0);fish(-52.0,9.0,1.0,2.0);fish(-52.0,10.0,1.0,2.0);start_block(-44.0,1.0);gravity_switch(-46.0,6.0,0.0,-0.3);gravity_switch(-44.0,6.0,0.0,0.3);solid_brick( -47.0, 8.0, 1.0, 1.0 );solid_brick( -47.0, 9.0, 1.0, 1.0 );solid_brick( -46.0, 9.0, 1.0, 1.0 );solid_brick( -45.0, 9.0, 1.0, 1.0 );solid_brick( -45.0, 9.0, 1.0, 1.0 );solid_brick( -44.0, 9.0, 1.0, 1.0 );solid_brick( -43.0, 9.0, 1.0, 1.0 );solid_brick( -43.0, 8.0, 1.0, 1.0 );solid_brick( -40.0, -18.0, 1.0, 35.0 );solid_brick( -48.0, -35.0, 17.0, 1.0 );solid_brick( -83.5, -12.0, 8.0, 47.0 );solid_brick( -69.0, -35.0, 21.0, 1.0 );solid_brick( -55.0, -36.0, 1.0, 1.0 );solid_brick( -55.0, -37.0, 1.0, 1.0 );solid_brick( -55.0, -38.0, 1.0, 1.0 );solid_brick( -56.0, -38.0, 1.0, 1.0 );solid_brick( -57.0, -38.0, 1.0, 1.0 );solid_brick( -57.0, -38.0, 1.0, 1.0 );solid_brick( -58.0, -38.0, 1.0, 1.0 );solid_brick( -59.0, -38.0, 1.0, 1.0 );solid_brick( -60.0, -38.0, 1.0, 1.0 );solid_brick( -60.0, -37.0, 1.0, 1.0 );solid_brick( -60.0, -36.0, 1.0, 1.0 );end_block(-56.0,-37.0);gravity_switch(-73.0,-34.0,0.3,0.0);gravity_switch(-70.0,-34.0,-0.3,0.0);solid_brick( -69.0, -31.0, 1.0, 1.0 );solid_brick( -69.0, -30.0, 1.0, 1.0 );solid_brick( -70.0, -30.0, 1.0, 1.0 );solid_brick( -71.0, -30.0, 1.0, 1.0 );solid_brick( -72.0, -30.0, 1.0, 1.0 );solid_brick( -73.0, -30.0, 1.0, 1.0 );solid_brick( -74.0, -30.0, 1.0, 1.0 );solid_brick( -74.0, -31.0, 1.0, 1.0 );solid_brick( -54.0, -5.0, 29.0, 1.0 );bouncy(-78.0,10.0,1.0,-5.0);bouncy(-76.0,10.0,1.0,-5.0);key(0,255,0,-74.75,10.0);bouncy(-72.0,10.0,1.0,-5.0);bouncy(-76.0,10.0,1.0,-5.0);bouncy(-78.0,10.0,1.0,-5.0);spike(-61.0,-11.0,7.720073,11.028677);spike(-55.0,-6.0,0.7,1.0);spike(-52.0,-6.0,0.7,1.0);spike(-48.0,-6.0,0.7,1.0);spike(-44.0,-6.0,0.7,1.0);door(-56.0, -35.0, -59.0, -35.0);keyed_button(0,255,0,-41.0,-6.0);solid_brick( -76.0, 4.0, 9.0, 1.0 );solid_brick( -73.5, 0.0, 8.0, 1.0 );solid_brick( -60.0, -23.0, 41.0, 1.0 );water( -50.5, 2.5, 4.0, 4.0 );teleporter( -69.0, 1.0 );teleporter( -72.0, -32.0 );solid_brick( -75.0, -5.0, 11.0, 1.0 );gravity_switch(-79.0,-22.0,0.0,0.3);solid_brick( -66.0, -11.0, 3.0, 1.0 );solid_brick( -65.5, -13.0, 2.0, 1.0 );solid_brick( -65.0, -16.0, 1.0, 3.0 );solid_brick( -69.5, -16.0, 4.0, 1.0 );solid_brick( -63.5, -20.0, 10.0, 1.0 );solid_brick( -63.0, -32.0, 1.0, 5.0 );solid_brick( -58.5, -30.0, 10.0, 1.0 );door(-54.0, -35.0, -54.0, -30.0);button( -65.0, -18.0 );solid_brick( -65.0, -19.0, 1.0, 1.0 );walky2(-47.0,-28.0,3.7129297,-5.0);bouncy(-52.0,-28.0,0.32768002,-5.0);bouncy(-51.0,-28.0,0.40960002,-5.0);bouncy(-51.0,-27.0,0.32768002,-5.0);bouncy(-54.0,-27.0,0.32768002,-5.0);bouncy(-53.0,-27.0,0.40960002,-5.0);bouncy(-52.0,-27.0,0.262144,-5.0);bouncy(-53.0,-28.0,0.32768002,-5.0);bouncy(-54.0,-28.0,0.40960002,-5.0);bouncy(-55.0,-28.0,0.32768002,-5.0);bouncy(-55.0,-27.0,0.40960002,-5.0);bouncy(-56.0,-28.0,0.40960002,-5.0);bouncy(-56.0,-27.0,0.32768002,-5.0);bouncy(-56.0,-26.0,0.40960002,-5.0);bouncy(-55.0,-26.0,0.512,-5.0);bouncy(-54.0,-26.0,0.512,-5.0);bouncy(-53.0,-26.0,0.512,-5.0);bouncy(-53.0,-26.0,0.40960002,-5.0);bouncy(-52.0,-26.0,0.512,-5.0);bouncy(-51.0,-26.0,0.40960002,-5.0);bouncy(-57.0,-27.0,1.0,-5.0);
  }else if( level_num+1 == 7 ){
solid_brick( -7.0, -232.0, 1.0, 1.0 );solid_brick( -6.0, -232.0, 1.0, 1.0 );solid_brick( -5.0, -232.0, 1.0, 1.0 );solid_brick( -4.0, -232.0, 1.0, 1.0 );solid_brick( -4.0, -231.0, 1.0, 1.0 );solid_brick( -4.0, -230.0, 1.0, 1.0 );solid_brick( -4.0, -229.0, 1.0, 1.0 );solid_brick( -4.0, -228.0, 1.0, 1.0 );solid_brick( -4.0, -227.0, 1.0, 1.0 );solid_brick( -3.0, -227.0, 1.0, 1.0 );solid_brick( -2.0, -227.0, 1.0, 1.0 );solid_brick( -1.0, -227.0, 1.0, 1.0 );solid_brick( 0.0, -227.0, 1.0, 1.0 );solid_brick( 1.0, -227.0, 1.0, 1.0 );solid_brick( 2.0, -227.0, 1.0, 1.0 );solid_brick( 3.0, -227.0, 1.0, 1.0 );solid_brick( 3.0, -228.0, 1.0, 1.0 );solid_brick( 3.0, -229.0, 1.0, 1.0 );solid_brick( 3.0, -230.0, 1.0, 1.0 );solid_brick( 3.0, -231.0, 1.0, 1.0 );solid_brick( 3.0, -232.0, 1.0, 1.0 );solid_brick( 4.0, -232.0, 1.0, 1.0 );solid_brick( 5.0, -232.0, 1.0, 1.0 );solid_brick( 6.0, -232.0, 1.0, 1.0 );solid_brick( 7.0, -232.0, 1.0, 1.0 );solid_brick( 8.0, -232.0, 1.0, 1.0 );solid_brick( 17.5, -232.0, 18.0, 1.0 );fish(-3.0013535,-230.5917,1.0,-1.8766589);fish(0.02226292,-231.02876,1.0,1.9402851);solid_brick( 46.0, -232.0, 13.0, 1.0 );solid_brick( 53.0, -230.0, 3.0, 5.0 );start_block(-7.0,-239.0);invisible_brick( 33.0, -232.0, 13.0, 1.0 );solid_brick( 59.5, -228.0, 10.0, 1.0 );solid_brick( 64.0, -229.0, 1.0, 1.0 );gravity_switch(66.0,-229.0,0.0,-0.3);solid_brick( 74.5, -258.0, 32.0, 1.0 );solid_brick( -16.0, -258.0, 15.0, 1.0 );solid_brick( -23.0, -254.0, 1.0, 7.0 );invisible_brick( 97.0, -258.0, 13.0, 1.0 );invisible_brick( 103.0, -251.0, 1.0, 15.0 );invisible_brick( 103.0, -235.5, 1.0, 16.0 );solid_brick( 66.5, -228.0, 4.0, 1.0 );solid_brick( 79.0, -229.5, 23.0, 2.0 );solid_brick( 103.0, -229.0, 1.0, 1.0 );solid_brick( 103.0, -230.0, 1.0, 1.0 );solid_brick( 103.0, -231.0, 1.0, 1.0 );solid_brick( 103.0, -232.0, 1.0, 1.0 );solid_brick( 103.0, -233.0, 1.0, 1.0 );solid_brick( 103.0, -228.0, 1.0, 1.0 );solid_brick( 96.5, -229.0, 12.0, 1.0 );water( -0.5, -229.5, 6.0, 4.0 );walky2(60.0,-232.0,3.7129297,-5.0);walky2(98.0,-231.0,2.8560998,-5.0);walky2(-21.0,-251.9928,2.28488,-5.0);solid_brick( -13.0, -251.5, 1.0, 2.0 );solid_brick( 25.0, -258.0, 67.0, 1.0 );solid_brick( 58.0, -255.5, 1.0, 4.0 );solid_brick( 24.5, -254.0, 66.0, 1.0 );solid_brick( 28.5, -256.0, 60.0, 5.0 );door(-8.0, -258.0, -8.0, -254.0);keyed_button(0,255,0,-22.0,-257.0);key(0,255,0,-1.0,-228.0);solid_brick( 10.5, 10.0, 26.0, 1.0 );solid_brick( 23.0, 5.5, 1.0, 10.0 );solid_brick( -2.0, 5.5, 1.0, 10.0 );fish(10.0,4.0,2.197,2.0);fish(4.0,6.0,3.7129297,2.0);fish(9.0,8.0,0.64,2.0);water( 10.5, 5.5, 24.0, 8.0 );fish(16.0,6.0,6.274851,2.0);invisible_brick( 17.0, 1.0, 11.0, 1.0 );invisible_brick( 4.0, 1.0, 11.0, 1.0 );teleporter( -2.0, -255.0 );teleporter( -2.0, -5.0 );solid_brick( 1.0, -4.0, 15.0, 1.0 );solid_brick( -6.5, -7.0, 2.0, 7.0 );solid_brick( -4.0, -5.0, 1.0, 1.0 );solid_brick( -5.0, -5.0, 1.0, 1.0 );solid_brick( -5.0, -6.0, 1.0, 1.0 );solid_brick( -5.0, -7.0, 1.0, 1.0 );solid_brick( 0.0, -5.0, 1.0, 1.0 );solid_brick( 1.0, -5.0, 1.0, 1.0 );solid_brick( 1.0, -6.0, 1.0, 1.0 );solid_brick( 1.0, -7.0, 1.0, 1.0 );solid_brick( -38.0, -99.0, 31.0, 265.0 );solid_brick( -53.0, -232.0, 1.0, 1.0 );solid_brick( -53.0, -233.0, 1.0, 1.0 );solid_brick( -53.0, -234.0, 1.0, 1.0 );solid_brick( -53.0, -235.0, 1.0, 1.0 );solid_brick( -53.0, -236.0, 1.0, 1.0 );solid_brick( -53.0, -237.0, 1.0, 1.0 );solid_brick( -53.0, -238.0, 1.0, 1.0 );solid_brick( -29.0, -232.0, 1.0, 1.0 );solid_brick( -28.0, -232.0, 1.0, 1.0 );solid_brick( -28.0, -233.0, 1.0, 1.0 );solid_brick( -28.0, -234.0, 1.0, 1.0 );solid_brick( -25.0, -232.0, 1.0, 1.0 );solid_brick( -24.0, -232.0, 1.0, 1.0 );solid_brick( -24.0, -233.0, 1.0, 1.0 );solid_brick( -24.0, -234.0, 1.0, 1.0 );solid_brick( -33.0, -232.0, 1.0, 1.0 );solid_brick( -32.0, -232.0, 1.0, 1.0 );solid_brick( -32.0, -233.0, 1.0, 1.0 );solid_brick( -31.0, -233.0, 1.0, 1.0 );solid_brick( -32.0, -234.0, 1.0, 1.0 );solid_brick( -35.0, -233.0, 1.0, 1.0 );solid_brick( -36.0, -232.0, 1.0, 1.0 );solid_brick( -36.0, -233.0, 1.0, 1.0 );solid_brick( -36.0, -234.0, 1.0, 1.0 );solid_brick( -37.0, -232.0, 1.0, 1.0 );solid_brick( -40.0, -232.0, 1.0, 1.0 );solid_brick( -40.0, -233.0, 1.0, 1.0 );solid_brick( -40.0, -234.0, 1.0, 1.0 );solid_brick( -39.0, -233.0, 1.0, 1.0 );solid_brick( -41.0, -232.0, 1.0, 1.0 );solid_brick( -43.0, -233.0, 1.0, 1.0 );solid_brick( -52.0, -234.0, 1.0, 5.0 );solid_brick( -51.0, -233.0, 1.0, 1.0 );solid_brick( -44.0, -232.0, 1.0, 1.0 );solid_brick( -44.0, -233.0, 1.0, 1.0 );solid_brick( -44.0, -234.0, 1.0, 1.0 );solid_brick( -45.0, -232.0, 1.0, 1.0 );solid_brick( -48.0, -232.0, 1.0, 1.0 );solid_brick( -48.0, -233.0, 1.0, 1.0 );solid_brick( -47.0, -233.0, 1.0, 1.0 );teleporter( -52.0, -237.0 );teleporter( -1.0, 9.0 );solid_brick( -1.0, 6.0, 1.0, 1.0 );solid_brick( 2.0, 9.0, 1.0, 1.0 );solid_brick( 2.0, 8.0, 1.0, 1.0 );solid_brick( 2.0, 7.0, 1.0, 1.0 );solid_brick( 2.0, 6.0, 1.0, 1.0 );solid_brick( -11.5, -241.0, 8.0, 19.0 );solid_brick( -19.0, -234.0, 9.0, 5.0 );solid_brick( -19.0, -245.0, 9.0, 11.0 );end_block(-16.0,-237.0);gravity_switch(-2.0,-257.0,0.0,0.3);door(-23.0, -240.0, -23.0, -236.0);keyed_button(0,0,255,-27.0,-233.0);key(0,0,255,-7.0,-11.0);solid_brick( -7.5, -15.5, 4.0, 6.0 );
  }else if( level_num+1 == 8 ){
water( -22.0, 9.0, 9.0, 3.0 );water( -22.0, 7.0, 5.0, 1.0 );start_block(-20.0,7.0);water( -22.0, 9.5, 3.0, 2.0 );water( -11.0, 2.5, 9.0, 4.0 );water( -5.5, 2.5, 2.0, 2.0 );water( -9.5, -1.0, 4.0, 3.0 );water( -12.5, -0.5, 2.0, 2.0 );water( -14.0, 0.0, 1.0, 1.0 );water( -12.0, 5.0, 5.0, 1.0 );water( -16.0, 3.0, 1.0, 1.0 );water( -16.0, 2.0, 1.0, 1.0 );water( -17.0, 3.0, 1.0, 1.0 );water( -22.0, -2.0, 9.0, 3.0 );water( -22.0, -4.0, 5.0, 1.0 );water( -17.0, -2.0, 1.0, 1.0 );water( -27.0, -2.0, 1.0, 1.0 );water( -22.0, 0.0, 7.0, 1.0 );water( -12.0, -10.0, 11.0, 5.0 );water( -12.0, -7.0, 7.0, 1.0 );water( -18.5, -10.0, 2.0, 3.0 );water( -5.0, -10.0, 3.0, 3.0 );water( -6.0, -12.0, 1.0, 1.0 );water( -11.5, -13.0, 10.0, 1.0 );water( -10.5, -14.0, 4.0, 1.0 );water( -16.0, -40.0, 1.0, 37.0 );end_block(-16.0,-59.0);water( -16.0, -7.0, 1.0, 1.0 );water( -18.0, -8.0, 1.0, 1.0 );water( -20.0, -9.0, 1.0, 1.0 );water( -20.0, -11.0, 1.0, 1.0 );water( -20.0, -10.0, 1.0, 1.0 );water( -18.0, -12.0, 1.0, 1.0 );water( -17.0, -13.0, 1.0, 1.0 );water( -16.0, -21.0, 1.0, 1.0 );water( -16.0, -15.5, 1.0, 2.0 );water( -17.0, -18.0, 1.0, 1.0 );water( -16.0, -18.5, 1.0, 4.0 );water( -12.0, -6.0, 7.0, 1.0 );water( -8.0, -7.0, 1.0, 1.0 );water( -6.0, -8.0, 1.0, 1.0 );
  }else if( level_num+1 == 9 ){
walky2(7.0,7.0,9.175858,-5.0);bouncy(16.0,7.0,4.8859615,-5.0);bouncy(23.0,6.0,1.0,-5.0);bouncy(24.0,4.0,1.0,-5.0);start_block(-14.0,10.0);solid_brick( -6.0, 10.0, 11.0, 1.0 );solid_brick( -6.5, 8.5, 4.0, 2.0 );solid_brick( -2.0, 7.5, 1.0, 4.0 );walky2(-4.0,9.0,0.3685955,-5.0);walky2(-3.0,9.0,0.15097673,-5.0);walky2(-3.0,9.0,0.46074435,-5.0);walky2(-3.0,8.0,0.55377924,-5.0);solid_brick( 8.5, 1.0, 8.0, 1.0 );coin( 9.0, -2.0 );coin( 10.0, -2.0 );coin( 11.0, -2.0 );coin( 10.0, -2.0 );coin( 7.0, -2.0 );coin( 7.0, -2.0 );coin( 8.0, -2.0 );coin( 8.0, -2.0 );coin( 6.0, -2.0 );coin( 12.0, -2.0 );coin( 12.0, -2.0 );coin( 12.0, -2.0 );coin( 12.0, -2.0 );coin( 12.0, -2.0 );coin( 12.0, -2.0 );coin( 11.0, -1.0 );coin( 10.0, -1.0 );coin( 9.0, -1.0 );coin( 8.0, -1.0 );coin( 7.0, -1.0 );coin( 6.0, -1.0 );coin( 12.0, -1.0 );coin( 12.0, -3.0 );coin( 10.0, -3.0 );coin( 8.0, -3.0 );coin( 6.0, -3.0 );coin( 9.0, -4.0 );coin( 9.0, -3.0 );solid_brick( 20.5, -3.0, 4.0, 1.0 );water( 25.0, -1.0, 5.0, 5.0 );solid_brick( 22.0, 0.0, 1.0, 5.0 );solid_brick( 25.5, 2.0, 6.0, 1.0 );solid_brick( 28.0, -1.0, 1.0, 5.0 );fish(24.0,0.0,1.0,2.0);fish(25.0,0.0,1.0,2.0);fish(26.0,0.0,1.0,2.0);fish(27.0,-1.0,1.0,2.0);fish(26.0,-1.0,0.692224,2.0);fish(24.0,-1.0,0.40960002,2.0);fish(23.0,0.0,0.40960002,2.0);fish(23.0,1.0,0.32768002,2.0);fish(24.0,1.0,0.512,2.0);fish(25.0,1.0,0.8,2.0);fish(26.0,1.0,0.40960002,2.0);fish(27.0,0.0,1.0,2.0);fish(27.0,0.0,0.40960002,2.0);invisible_brick( 17.0, 1.0, 9.0, 1.0 );invisible_brick( 13.0, 6.0, 1.0, 9.0 );invisible_brick( 33.0, 1.0, 9.0, 1.0 );invisible_brick( 37.0, 5.0, 1.0, 7.0 );solid_brick( 41.0, 9.0, 9.0, 1.0 );solid_brick( 51.5, 9.0, 8.0, 1.0 );coin( 48.0, 8.0 );coin( 45.0, 8.0 );coin( 36.0, 2.0 );coin( 35.0, 2.0 );coin( 34.0, 2.0 );coin( 33.0, 2.0 );coin( 32.0, 2.0 );coin( 31.0, 2.0 );coin( 30.0, 2.0 );coin( 29.0, 2.0 );coin( 29.0, 3.0 );coin( 30.0, 3.0 );coin( 31.0, 3.0 );coin( 32.0, 3.0 );coin( 33.0, 3.0 );coin( 34.0, 3.0 );coin( 35.0, 3.0 );coin( 36.0, 3.0 );coin( 36.0, 3.0 );coin( 36.0, 4.0 );coin( 35.0, 4.0 );coin( 34.0, 4.0 );coin( 32.0, 4.0 );coin( 32.0, 4.0 );coin( 33.0, 4.0 );coin( 31.0, 4.0 );coin( 31.0, 4.0 );coin( 30.0, 4.0 );coin( 30.0, 4.0 );coin( 29.0, 4.0 );coin( 29.0, 4.0 );coin( 29.0, 5.0 );coin( 29.0, 5.0 );coin( 30.0, 5.0 );coin( 30.0, 5.0 );coin( 31.0, 5.0 );coin( 31.0, 5.0 );coin( 32.0, 5.0 );coin( 32.0, 5.0 );coin( 33.0, 5.0 );coin( 34.0, 5.0 );coin( 34.0, 5.0 );coin( 35.0, 5.0 );coin( 35.0, 5.0 );coin( 36.0, 5.0 );coin( 36.0, 5.0 );coin( 36.0, 6.0 );coin( 36.0, 6.0 );coin( 35.0, 6.0 );coin( 34.0, 6.0 );coin( 34.0, 6.0 );coin( 34.0, 6.0 );coin( 33.0, 6.0 );coin( 33.0, 6.0 );coin( 32.0, 6.0 );coin( 32.0, 6.0 );coin( 31.0, 6.0 );coin( 30.0, 6.0 );coin( 29.0, 6.0 );solid_brick( 55.0, 10.0, 1.0, 1.0 );spike(55.0,8.0,0.60569596,0.8652799);solid_brick( 37.0, -8.0, 9.0, 1.0 );solid_brick( 45.0, -15.0, 1.0, 1.0 );solid_brick( 47.0, -15.0, 1.0, 1.0 );solid_brick( 49.0, -15.0, 1.0, 1.0 );solid_brick( 51.0, -15.0, 1.0, 1.0 );solid_brick( 50.0, -16.0, 1.0, 1.0 );solid_brick( 48.0, -16.0, 1.0, 1.0 );solid_brick( 46.0, -16.0, 1.0, 1.0 );solid_brick( 47.0, -17.0, 1.0, 1.0 );solid_brick( 49.0, -17.0, 1.0, 1.0 );solid_brick( 51.0, -17.0, 1.0, 1.0 );solid_brick( 45.0, -17.0, 1.0, 1.0 );solid_brick( 46.0, -18.0, 1.0, 1.0 );solid_brick( 48.0, -18.0, 1.0, 1.0 );solid_brick( 50.0, -18.0, 1.0, 1.0 );solid_brick( 51.0, -19.0, 1.0, 1.0 );solid_brick( 47.0, -19.0, 1.0, 1.0 );solid_brick( 45.0, -19.0, 1.0, 1.0 );solid_brick( 46.0, -20.0, 1.0, 1.0 );solid_brick( 48.0, -20.0, 1.0, 1.0 );solid_brick( 50.0, -20.0, 1.0, 1.0 );invisible_brick( 48.0, -21.0, 9.0, 1.0 );invisible_brick( 44.0, -17.5, 1.0, 6.0 );invisible_brick( 48.0, -14.0, 9.0, 1.0 );invisible_brick( 52.0, -17.5, 1.0, 6.0 );bouncy(51.0,-20.0,0.64,-5.0);bouncy(51.0,-18.0,0.64,-5.0);bouncy(51.0,-16.0,0.64,-5.0);bouncy(50.0,-15.0,0.6656,-5.0);bouncy(48.0,-15.0,0.64,-5.0);bouncy(46.0,-15.0,0.64,-5.0);bouncy(45.0,-16.0,0.64,-5.0);bouncy(47.0,-16.0,0.6656,-5.0);bouncy(49.0,-16.0,0.64,-5.0);spike(45.0,-20.0,0.44799998,0.64);spike(47.0,-20.0,0.44799998,0.64);solid_brick( 49.0, -19.0, 1.0, 1.0 );spike(49.0,-20.0,0.44799998,0.64);spike(49.0,-18.0,0.44799998,0.64);walky2(42.0,-12.0,0.64,-5.0);door(47.0, -24.0, 47.0, -22.0);keyed_button(0,0,255,45.0,-22.0);solid_brick( 48.5, -25.0, 4.0, 1.0 );solid_brick( 50.0, -23.0, 1.0, 3.0 );key(255,0,0,49.0,-22.0);key(0,0,255,27.0,1.0);key(0,0,255,27.0,1.0);key(0,0,255,27.0,1.0);key(0,0,255,27.0,1.0);key(0,0,255,27.0,1.0);key(0,0,255,27.0,1.0);key(0,0,255,27.0,1.0);key(0,0,255,27.0,1.0);key(0,0,255,27.0,1.0);key(0,0,255,27.0,1.0);key(0,0,255,27.0,1.0);key(0,0,255,27.0,1.0);key(0,0,255,27.0,1.0);key(0,0,255,27.0,1.0);coin( 47.0, -26.0 );coin( 48.0, -26.0 );coin( 49.0, -26.0 );coin( 50.0, -26.0 );coin( 50.0, -27.0 );coin( 49.0, -27.0 );coin( 48.0, -27.0 );coin( 47.0, -27.0 );coin( 48.0, -28.0 );coin( 49.0, -28.0 );solid_brick( 61.0, -21.0, 3.0, 1.0 );solid_brick( 66.0, -30.0, 3.0, 3.0 );solid_brick( 62.0, -24.0, 1.0, 5.0 );coin( 70.0, -35.0 );coin( 71.0, -35.0 );coin( 73.0, -35.0 );coin( 72.0, -35.0 );coin( 74.0, -35.0 );coin( 75.0, -35.0 );coin( 76.0, -35.0 );coin( 77.0, -35.0 );coin( 77.0, -35.0 );coin( 78.0, -35.0 );coin( 78.0, -35.0 );coin( 79.0, -35.0 );coin( 79.0, -35.0 );coin( 80.0, -35.0 );coin( 81.0, -35.0 );coin( 81.0, -35.0 );coin( 81.0, -35.0 );coin( 82.0, -35.0 );coin( 82.0, -35.0 );coin( 82.0, -36.0 );coin( 82.0, -36.0 );coin( 81.0, -36.0 );coin( 81.0, -36.0 );coin( 80.0, -36.0 );coin( 79.0, -36.0 );coin( 79.0, -36.0 );coin( 78.0, -36.0 );coin( 77.0, -36.0 );coin( 77.0, -36.0 );coin( 76.0, -36.0 );coin( 75.0, -36.0 );coin( 75.0, -36.0 );coin( 74.0, -36.0 );coin( 73.0, -36.0 );coin( 73.0, -36.0 );coin( 72.0, -36.0 );coin( 71.0, -36.0 );coin( 71.0, -36.0 );coin( 70.0, -36.0 );coin( 70.0, -37.0 );coin( 70.0, -37.0 );coin( 71.0, -37.0 );coin( 72.0, -37.0 );coin( 73.0, -37.0 );coin( 74.0, -37.0 );coin( 75.0, -37.0 );coin( 76.0, -37.0 );coin( 77.0, -37.0 );coin( 79.0, -37.0 );coin( 80.0, -37.0 );coin( 81.0, -37.0 );coin( 82.0, -37.0 );coin( 82.0, -37.0 );coin( 82.0, -38.0 );coin( 81.0, -38.0 );coin( 80.0, -38.0 );coin( 79.0, -38.0 );coin( 78.0, -38.0 );coin( 78.0, -37.0 );coin( 78.0, -38.0 );coin( 76.0, -38.0 );coin( 75.0, -38.0 );coin( 76.0, -38.0 );coin( 77.0, -38.0 );coin( 75.0, -38.0 );coin( 74.0, -38.0 );coin( 73.0, -38.0 );coin( 72.0, -38.0 );coin( 71.0, -38.0 );coin( 71.0, -38.0 );coin( 70.0, -38.0 );coin( 71.0, -39.0 );coin( 73.0, -39.0 );coin( 72.0, -39.0 );coin( 72.0, -40.0 );coin( 74.0, -37.0 );coin( 81.0, -37.0 );coin( 81.0, -39.0 );coin( 80.0, -39.0 );coin( 79.0, -39.0 );coin( 80.0, -40.0 );coin( 80.0, -39.0 );coin( 74.0, -39.0 );coin( 75.0, -39.0 );coin( 77.0, -39.0 );coin( 78.0, -39.0 );coin( 77.0, -40.0 );coin( 76.0, -40.0 );coin( 75.0, -40.0 );coin( 76.0, -41.0 );invisible_brick( 76.0, -34.0, 13.0, 1.0 );door(93.0, 10.0, 93.0, 3.0);keyed_button(255,0,0,76.0,-39.0);solid_brick( 98.5, 2.0, 12.0, 1.0 );solid_brick( 104.0, 6.5, 1.0, 8.0 );solid_brick( 100.0, 10.0, 1.0, 1.0 );
solid_brick( 101.5, 9.5, 2.0, 2.0 );solid_brick( 103.0, 8.0, 1.0, 5.0 );end_block(103.0,5.0);coin( 102.0, 8.0 );coin( 101.0, 8.0 );coin( 101.0, 8.0 );coin( 100.0, 9.0 );coin( 99.0, 10.0 );coin( 98.0, 10.0 );coin( 98.0, 10.0 );coin( 97.0, 10.0 );coin( 97.0, 10.0 );coin( 96.0, 10.0 );coin( 95.0, 10.0 );coin( 95.0, 10.0 );coin( 95.0, 10.0 );coin( 94.0, 10.0 );coin( 94.0, 9.0 );coin( 94.0, 9.0 );coin( 95.0, 9.0 );coin( 95.0, 9.0 );coin( 96.0, 9.0 );coin( 97.0, 9.0 );coin( 98.0, 9.0 );coin( 98.0, 9.0 );coin( 99.0, 9.0 );coin( 99.0, 8.0 );coin( 100.0, 8.0 );coin( 100.0, 8.0 );coin( 100.0, 7.0 );coin( 101.0, 7.0 );coin( 101.0, 7.0 );coin( 102.0, 7.0 );coin( 102.0, 6.0 );coin( 102.0, 6.0 );coin( 101.0, 6.0 );coin( 99.0, 6.0 );coin( 99.0, 6.0 );coin( 99.0, 7.0 );coin( 99.0, 6.0 );coin( 100.0, 6.0 );coin( 100.0, 6.0 );coin( 100.0, 5.0 );coin( 101.0, 5.0 );coin( 102.0, 5.0 );coin( 102.0, 4.0 );coin( 103.0, 4.0 );coin( 103.0, 4.0 );coin( 103.0, 3.0 );coin( 102.0, 3.0 );coin( 101.0, 3.0 );coin( 100.0, 3.0 );coin( 100.0, 4.0 );coin( 101.0, 4.0 );coin( 100.0, 4.0 );coin( 99.0, 4.0 );coin( 99.0, 5.0 );coin( 99.0, 4.0 );coin( 99.0, 3.0 );coin( 98.0, 4.0 );coin( 98.0, 5.0 );coin( 98.0, 6.0 );coin( 98.0, 8.0 );coin( 97.0, 8.0 );coin( 97.0, 8.0 );coin( 97.0, 7.0 );coin( 98.0, 7.0 );coin( 97.0, 7.0 );coin( 96.0, 8.0 );coin( 96.0, 8.0 );coin( 95.0, 8.0 );coin( 94.0, 8.0 );coin( 94.0, 7.0 );coin( 95.0, 7.0 );coin( 96.0, 7.0 );coin( 96.0, 6.0 );coin( 97.0, 6.0 );coin( 96.0, 6.0 );coin( 95.0, 6.0 );coin( 94.0, 6.0 );coin( 94.0, 5.0 );coin( 95.0, 5.0 );coin( 97.0, 5.0 );coin( 98.0, 5.0 );coin( 96.0, 5.0 );coin( 96.0, 5.0 );coin( 96.0, 4.0 );coin( 97.0, 4.0 );coin( 97.0, 4.0 );coin( 98.0, 3.0 );coin( 97.0, 3.0 );coin( 96.0, 3.0 );coin( 95.0, 3.0 );coin( 94.0, 3.0 );coin( 94.0, 3.0 );coin( 94.0, 4.0 );coin( 95.0, 4.0 );door(84.0, 4.0, 84.0, 10.0);keyed_button(0,255,0,75.0,10.0);solid_brick( 84.0, 2.0, 1.0, 3.0 );solid_brick( 94.5, 1.0, 20.0, 1.0 );key(0,255,0,9.0,-2.3841857E-9);bouncy(90.0,9.0,1.9010197,-5.0);
   }else if(level_num+1 == 10 ){
     start_block(-1.0,10.0);invisible_brick( -5.0, 9.0, 1.0, 3.0 );invisible_brick( -2.0, 8.0, 7.0, 1.0 );invisible_brick( 1.0, 9.0, 1.0, 3.0 );invisible_brick( -2.0, 11.0, 7.0, 1.0 );teleporter( -4.0, 10.0 );teleporter( -22.0, 10.0 );teleporter( -4.0, 10.0 );teleporter( -22.0, 10.0 );teleporter( -4.0, 9.0 );teleporter( -3.0, 9.0 );teleporter( -2.0, 9.0 );teleporter( -1.0, 9.0 );teleporter( 0.0, 9.0 );teleporter( 0.0, 10.0 );solid_brick( -26.5, 6.5, 2.0, 2.0 );solid_brick( -28.0, 5.0, 3.0, 3.0 );solid_brick( -31.0, 2.5, 5.0, 4.0 );invisible_brick( -24.25, -2.375, 2.5, 1.75 );invisible_brick( -48.5, -4.5, 20.0, 2.0 );invisible_brick( -39.5, 2.5, 2.0, 16.0 );bouncy(-48.285664,1.3236606,11.028675,5.0);bouncy(-220.46434,-136.83183,1.3,-5.0);invisible_brick( -48.5, 9.5, 18.0, 2.0 );bouncy(-233.24727,-5020.449,5.484367E-4,-5.0);bouncy(-379.27194,-2419.6755,2.8560998,-5.0);bouncy(-230.22293,-4199.8315,0.64,-5.0);bouncy(-231.93785,-4759.8267,1.7107109,-5.0);teleporter( -64.0, 10.0 );invisible_brick( -38.0, 5.0, 1.0, 1.0 );bouncy(-218.92918,-4893.758,7.058352,-5.0);invisible_brick( -58.0, 2.0, 1.0, 1.0 );
   }else if(level_num+1 == 11 ){
start_block(6.0,10.0);solid_brick( 8.0, 9.0, 5.0, 1.0 );loopy(9.379712,8.462392,1.1501552E-4,-0.2,0.7);loopy(9.07195,6.9433484,2.8560998,-0.2,0.7);invisible_brick( 11.0, 9.0, 1.0, 1.0 );invisible_brick( 11.0, 5.0, 1.0, 1.0 );invisible_brick( 11.0, 7.0, 1.0, 5.0 );solid_brick( 20.0, 10.0, 1.0, 1.0 );solid_brick( 15.0, 10.0, 1.0, 1.0 );walky2(18.25,10.0,1.0,5.0);solid_brick( 26.0, 5.0, 5.0, 1.0 );loopy(23.865572,7.4208746,1.0,-0.2,0.7);solid_brick( 29.0, 7.0, 1.0, 1.0 );solid_brick( 30.0, 9.0, 1.0, 1.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );coin( 25.0, 4.0 );end_block(25.0,4.0);coin( 7.0, 10.0 );coin( 8.0, 10.0 );coin( 9.0, 10.0 );coin( 10.0, 10.0 );coin( 11.0, 10.0 );coin( 12.0, 10.0 );coin( 13.0, 10.0 );coin( 14.0, 9.0 );coin( 15.0, 8.0 );coin( 16.0, 7.0 );coin( 17.0, 6.0 );coin( 18.0, 5.0 );coin( 19.0, 5.0 );coin( 20.0, 6.0 );coin( 21.0, 7.0 );coin( 22.0, 8.0 );coin( 23.0, 9.0 );coin( 24.0, 10.0 );coin( 25.0, 10.0 );coin( 26.0, 10.0 );coin( 27.0, 10.0 );coin( 28.0, 10.0 );coin( 29.0, 10.0 );coin( 30.0, 10.0 );coin( 31.0, 10.0 );coin( 31.0, 9.0 );coin( 31.0, 8.0 );coin( 30.0, 8.0 );coin( 30.0, 7.0 );coin( 31.0, 7.0 );coin( 31.0, 6.0 );coin( 30.0, 6.0 );coin( 29.0, 6.0 );coin( 29.0, 5.0 );coin( 30.0, 5.0 );coin( 31.0, 5.0 );coin( 29.0, 4.0 );coin( 29.0, 3.0 );coin( 29.0, 2.0 );coin( 29.0, 1.0 );coin( 28.0, 1.0 );coin( 27.0, 2.0 );coin( 26.0, 3.0 );coin( 16.0, 10.0 );coin( 17.0, 10.0 );walky2(17.0,10.0,1.0,-5.0);invisible_brick( 7.0, 0.0, 1.0, 9.0 );invisible_brick( -6.0, 0.5, 1.0, 10.0 );invisible_brick( 0.5, -4.0, 12.0, 1.0 );invisible_brick( 11.0, -2.0, 1.0, 13.0 );invisible_brick( 0.0, -8.0, 21.0, 1.0 );invisible_brick( -10.0, 1.0, 1.0, 17.0 );invisible_brick( -2.5, 9.0, 14.0, 1.0 );invisible_brick( 5.0, 9.5, 1.0, 2.0 );invisible_brick( 1.0, 5.0, 13.0, 1.0 );
   }else if(level_num+1 == 12 ){ //Hope's level
invisible_brick( 9.0, 10.0, 1.0, 1.0 );invisible_brick( 10.0, 9.0, 1.0, 1.0 );invisible_brick( 11.0, 8.0, 1.0, 1.0 );invisible_brick( 12.0, 7.0, 1.0, 1.0 );invisible_brick( 13.0, 6.0, 1.0, 1.0 );invisible_brick( 14.0, 6.0, 1.0, 1.0 );invisible_brick( 15.0, 6.0, 1.0, 1.0 );invisible_brick( 16.0, 6.0, 1.0, 1.0 );invisible_brick( 17.0, 6.0, 1.0, 1.0 );invisible_brick( 18.0, 7.0, 1.0, 1.0 );invisible_brick( 19.0, 8.0, 1.0, 1.0 );invisible_brick( 20.0, 9.0, 1.0, 1.0 );invisible_brick( 21.0, 10.0, 1.0, 1.0 );key(0,255,0,17.0,10.0);key(0,255,0,16.0,10.0);key(0,255,0,16.0,10.0);key(0,0,255,16.0,10.0);key(0,255,0,16.0,10.0);key(0,255,0,16.0,10.0);key(0,255,0,16.0,10.0);key(0,0,255,16.0,10.0);key(0,0,255,16.0,10.0);key(0,0,255,16.0,10.0);key(0,0,255,15.0,10.0);key(0,255,0,15.0,10.0);key(0,255,0,15.0,10.0);key(0,255,0,15.0,10.0);key(0,255,0,14.0,10.0);key(0,0,255,14.0,10.0);key(0,0,255,14.0,10.0);key(0,0,255,12.0,10.0);key(0,0,255,12.0,10.0);keyed_button(0,255,0,12.0,7.0);keyed_button(255,0,0,12.0,7.0);keyed_button(255,0,0,12.0,7.0);keyed_button(255,0,0,12.0,7.0);key(255,0,0,14.0,10.0);key(255,0,0,15.0,10.0);start_block(18.0,7.0);start_block(18.0,7.0);start_block(18.0,7.0);invisible_brick( 18.0, 7.0, 1.0, 1.0 );invisible_brick( 12.0, 7.0, 1.0, 1.0 );teleporter( 16.0, 7.0 );teleporter( 16.0, 7.0 );teleporter( 16.0, 7.0 );teleporter( 16.0, 7.0 );teleporter( 16.0, 7.0 );teleporter( 16.0, 7.0 );teleporter( 16.0, 7.0 );teleporter( 16.0, 7.0 );teleporter( 26.0, 7.0 );teleporter( 27.0, 7.0 );teleporter( 28.0, 7.0 );teleporter( 29.0, 7.0 );invisible_brick( 22.0, 10.0, 1.0, 1.0 );invisible_brick( 23.0, 9.0, 1.0, 1.0 );invisible_brick( 24.0, 8.0, 1.0, 1.0 );invisible_brick( 25.0, 7.0, 1.0, 1.0 );invisible_brick( 26.0, 6.0, 1.0, 1.0 );invisible_brick( 27.0, 6.0, 1.0, 1.0 );invisible_brick( 28.0, 6.0, 1.0, 1.0 );invisible_brick( 29.0, 6.0, 1.0, 1.0 );invisible_brick( 30.0, 6.0, 1.0, 1.0 );invisible_brick( 31.0, 7.0, 1.0, 1.0 );invisible_brick( 32.0, 8.0, 1.0, 1.0 );invisible_brick( 33.0, 9.0, 1.0, 1.0 );invisible_brick( 34.0, 10.0, 1.0, 1.0 );teleporter( 30.0, 7.0 );teleporter( 31.0, 8.0 );teleporter( 32.0, 9.0 );teleporter( 33.0, 10.0 );teleporter( 23.0, 10.0 );teleporter( 24.0, 9.0 );teleporter( 25.0, 8.0 );teleporter( 28.0, 4.0 );teleporter( 28.0, 8.0 );invisible_brick( 41.0, 6.0, 1.0, 1.0 );invisible_brick( 42.0, 6.0, 1.0, 1.0 );invisible_brick( 43.0, 6.0, 1.0, 1.0 );invisible_brick( 44.0, 6.0, 1.0, 1.0 );invisible_brick( 45.0, 6.0, 1.0, 1.0 );invisible_brick( 46.0, 6.0, 1.0, 1.0 );invisible_brick( 47.0, 6.0, 1.0, 1.0 );invisible_brick( 48.0, 6.0, 1.0, 1.0 );invisible_brick( 49.0, 6.0, 1.0, 1.0 );invisible_brick( 49.0, 5.0, 1.0, 1.0 );invisible_brick( 49.0, 4.0, 1.0, 1.0 );invisible_brick( 49.0, 3.0, 1.0, 1.0 );invisible_brick( 49.0, 2.0, 1.0, 1.0 );invisible_brick( 49.0, 1.0, 1.0, 1.0 );invisible_brick( 49.0, 0.0, 1.0, 1.0 );invisible_brick( 49.0, -1.0, 1.0, 1.0 );invisible_brick( 42.0, 5.0, 1.0, 1.0 );invisible_brick( 43.0, 4.0, 1.0, 1.0 );invisible_brick( 44.0, 3.0, 1.0, 1.0 );invisible_brick( 45.0, 2.0, 1.0, 1.0 );invisible_brick( 46.0, 1.0, 1.0, 1.0 );invisible_brick( 47.0, 0.0, 1.0, 1.0 );invisible_brick( 48.0, -1.0, 1.0, 1.0 );invisible_brick( 48.0, 0.0, 1.0, 1.0 );invisible_brick( 48.0, 1.0, 1.0, 1.0 );invisible_brick( 48.0, 2.0, 1.0, 1.0 );invisible_brick( 48.0, 3.0, 1.0, 1.0 );invisible_brick( 48.0, 5.0, 1.0, 1.0 );invisible_brick( 48.0, 4.0, 1.0, 1.0 );invisible_brick( 47.0, 5.0, 1.0, 1.0 );invisible_brick( 47.0, 4.0, 1.0, 1.0 );invisible_brick( 47.0, 3.0, 1.0, 1.0 );invisible_brick( 47.0, 2.0, 1.0, 1.0 );invisible_brick( 47.0, 1.0, 1.0, 1.0 );invisible_brick( 46.0, 2.0, 1.0, 1.0 );invisible_brick( 46.0, 2.0, 1.0, 1.0 );invisible_brick( 45.0, 3.0, 1.0, 1.0 );invisible_brick( 44.0, 4.0, 1.0, 1.0 );invisible_brick( 43.0, 5.0, 1.0, 1.0 );invisible_brick( 44.0, 5.0, 1.0, 1.0 );invisible_brick( 45.0, 5.0, 1.0, 1.0 );invisible_brick( 46.0, 5.0, 1.0, 1.0 );invisible_brick( 46.0, 4.0, 1.0, 1.0 );invisible_brick( 46.0, 3.0, 1.0, 1.0 );invisible_brick( 45.0, 4.0, 1.0, 1.0 );invisible_brick( 49.0, -2.0, 1.0, 1.0 );invisible_brick( 50.0, -3.0, 1.0, 1.0 );invisible_brick( 51.0, -4.0, 1.0, 1.0 );invisible_brick( 52.0, -5.0, 1.0, 1.0 );invisible_brick( 53.0, -6.0, 1.0, 1.0 );end_block(55.0,-9.0);door(54.0, -7.0, 55.0, -8.0);door(54.0, -7.0, 55.0, -8.0);start_block(6.0,6.0);
   }
}
//ideas
//teleporter which makes it so you skip a problem.
//Numbers in a jail so that they can't escape.
//math problems.
