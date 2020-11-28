import java.util.LinkedList;

color blue = color( 0,0,255 );
color red = color( 255, 0, 0 );

String[] level_codes = { "", "56736", "12123" };

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
void show_start_menu(){
  menu = new StartMenu(); 
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
    
    float menu_width = 500;
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

abstract class PickupAble extends Thing{
  Thing carried_by = null;
  
  public void draw(){
    if( carried_by == null ){
        loc = loc.plus( speed );
        
        float bottom = loc.y+.5*size.y;
        
        
        if( bottom < floor ){
          speed = speed.plus( gravity );
        }else{
          loc.y = floor - .5*size.y;
          if( speed.y > 0 ) speed.y = 0;
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
   //last_last_brick = last_brick;
   //last_brick = new_brick;
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
}

class Person extends Thing{
  boolean maker_mode = false;
  boolean dead = false;
  Loc desired_direction = new Loc();
  public Person(){
     loc.x = 640/2;
  }
  public void draw(){
    if( !maker_mode ){
      if( !dead ){
        float bottom = loc.y+.5*size.y;
        
        float go_speed = walk_speed;
        if( in_water ) go_speed *= .5;
        
        speed.x = desired_direction.x*go_speed;
        
        if( person.in_water ){
          speed.y = desired_direction.y*go_speed;
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
    if( desired_direction.y < 0 && push.y < 0 ) jump();
    loc = loc.plus(push);
  }
  public void jump(){
    if( abs(person.speed.y) < .4 ){
      person.speed.y = -jump_speed;
    }
  }
  public void set_in_water(){
    in_water = true;
  }
  public void take_hit( int hurt_amount ){
      dead=true;
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

void keyPressed() {
  //println( keyCode );
  if( menu != null ){
    menu.keyPressed();
  }else if( !person.maker_mode ){
    if( key == 'm' ){
      person.maker_mode = !person.maker_mode;
    }else if( keyCode == SHIFT ){
      person.figure_shift_action(); 
    }else if( key == 'r' ){
      person.loc = the_start_block.loc.copy();
      person.dead = false;
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
       walky( person.loc.x/block_size.x, person.loc.y/block_size.y, -5 );
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
    }else if( key == '1' ){
      start_block(  person.loc.x/block_size.x, person.loc.y/block_size.y );
    }else if( key == 'e' ){
      end_block(  person.loc.x/block_size.x, person.loc.y/block_size.y );
    
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
          this.activated = true;
          show_message_menu( "You finished level " + (current_level_number+1) + ".", new DoSomething(){ public void do_it(){
            if( current_level_number + 1 == level_codes.length ){
              println( "option 1" );
              show_message_menu( "You finished all the levels!!", new DoSomething(){ public void do_it(){ show_start_menu(); } });
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
  boolean unlocked = true;
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
            if( door != null )door.is_open = !door.is_open;
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
    if( !person.maker_mode ){
    
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
      
      if( !in_water ){
        things_to_remove.add(this);
      }else{
        if( speed.y > -bubble_float_speed ) speed.y -= 1;
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
  
  public void take_hit( int hurt_amount ){
    things_to_remove.add(this);
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
    return "   walky2(" + (loc.x/block_size.x) + "," + (loc.y/block_size.y) + "," + (size.x/block_size.x) + "," + this.speed.x + ");";
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
  //level1();
  show_start_menu();
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
  
  if( menu != null ) menu.draw();
} 

abstract class Menu{
  abstract void draw();
  abstract void keyPressed();
}

Menu menu = null;

int current_level_number = 0;
//Define level
void start_level( int level_num ){
  current_level_number = level_num;
  remove_things();
  
  if( -1 == level_num ){
    //this is a blank level for making new levels
  }else if( level_num+1 == 1 ){
solid_brick( 6.0, 4.0, 10.0, 1.0 );coin( 8.0, 3.0 );solid_brick( -3.0, 10.0, 1.0, 1.0 );solid_brick( 14.0, 10.0, 1.0, 1.0 );coin( 3.0, 1.0 );coin( 6.0, 1.0 );coin( 7.0, 1.0 );coin( 8.0, 1.0 );coin( 9.0, 1.0 );solid_brick( 1.0, 3.0, 1.0, 1.0 );solid_brick( 11.0, 3.0, 1.0, 1.0 );coin( 5.0, 1.0 );coin( 4.0, 1.0 );coin( 3.0, 0.0 );coin( 4.0, 0.0 );coin( 5.0, 0.0 );coin( 6.0, 0.0 );coin( 7.0, 0.0 );coin( 8.0, 0.0 );coin( 9.0, 0.0 );coin( 3.0, 2.0 );coin( 4.0, 2.0 );coin( 5.0, 2.0 );coin( 7.0, 2.0 );coin( 8.0, 2.0 );coin( 9.0, 2.0 );coin( 10.0, 2.0 );coin( 11.0, 2.0 );coin( 11.0, 1.0 );coin( 11.0, 0.0 );coin( 10.0, -1.0 );coin( 9.0, -1.0 );coin( 8.0, -1.0 );coin( 7.0, -1.0 );coin( 6.0, -1.0 );coin( 5.0, -1.0 );coin( 4.0, -1.0 );coin( 3.0, -1.0 );coin( 2.0, 2.0 );coin( 2.0, 4.0 );coin( 2.0, 5.0 );coin( 11.0, 5.0 );coin( 11.0, 4.0 );coin( 11.0, 3.0 );coin( 2.0, 6.0 );solid_brick( -8.0, 10.0, 1.0, 1.0 );solid_brick( -8.0, 9.0, 1.0, 1.0 );solid_brick( -9.0, 10.0, 1.0, 1.0 );solid_brick( -16.0, 10.0, 1.0, 1.0 );solid_brick( -17.0, 10.0, 1.0, 1.0 );solid_brick( -18.0, 10.0, 1.0, 1.0 );solid_brick( -19.0, 10.0, 1.0, 1.0 );solid_brick( -19.0, 9.0, 1.0, 1.0 );solid_brick( -19.0, 8.0, 1.0, 1.0 );solid_brick( -19.0, 7.0, 1.0, 1.0 );solid_brick( -19.0, 6.0, 1.0, 1.0 );solid_brick( -19.0, 5.0, 1.0, 1.0 );solid_brick( -19.0, 4.0, 1.0, 1.0 );solid_brick( -19.0, 3.0, 1.0, 1.0 );solid_brick( -19.0, 2.0, 1.0, 1.0 );solid_brick( -19.0, 1.0, 1.0, 1.0 );solid_brick( -19.0, 0.0, 1.0, 1.0 );solid_brick( -19.0, -1.0, 1.0, 1.0 );solid_brick( -19.0, -2.0, 1.0, 1.0 );solid_brick( -19.0, -3.0, 1.0, 1.0 );solid_brick( -19.0, -4.0, 1.0, 1.0 );solid_brick( -19.0, -5.0, 1.0, 1.0 );solid_brick( -19.0, -6.0, 1.0, 1.0 );solid_brick( -19.0, -7.0, 1.0, 1.0 );solid_brick( -19.0, -8.0, 1.0, 1.0 );solid_brick( -19.0, -9.0, 1.0, 1.0 );solid_brick( -19.0, -10.0, 1.0, 1.0 );solid_brick( -19.0, -12.0, 1.0, 1.0 );solid_brick( -19.0, -11.0, 1.0, 1.0 );solid_brick( -18.0, -12.0, 1.0, 1.0 );solid_brick( -17.0, -12.0, 1.0, 1.0 );solid_brick( -16.0, -12.0, 1.0, 1.0 );solid_brick( -15.0, -12.0, 1.0, 1.0 );solid_brick( -14.0, -12.0, 1.0, 1.0 );solid_brick( -13.0, -12.0, 1.0, 1.0 );solid_brick( -9.0, -12.0, 1.0, 1.0 );coin( -16.0, 9.0 );coin( -17.0, 9.0 );coin( -17.0, 8.0 );coin( -18.0, 8.0 );coin( -17.0, 8.0 );coin( -16.0, 8.0 );coin( -15.0, 7.0 );coin( -16.0, 7.0 );coin( -17.0, 7.0 );coin( -18.0, 7.0 );coin( -18.0, 6.0 );coin( -17.0, 6.0 );coin( -16.0, 6.0 );coin( -15.0, 6.0 );solid_brick( -14.0, 10.0, 1.0, 1.0 );solid_brick( -15.0, 10.0, 1.0, 1.0 );solid_brick( -14.0, 9.0, 1.0, 1.0 );solid_brick( -18.0, 5.0, 1.0, 1.0 );solid_brick( -17.0, 5.0, 1.0, 1.0 );solid_brick( -16.0, 5.0, 1.0, 1.0 );solid_brick( -14.0, 5.0, 1.0, 1.0 );solid_brick( -14.0, 4.0, 1.0, 1.0 );coin( -15.0, 4.0 );coin( -16.0, 4.0 );coin( -17.0, 4.0 );solid_brick( -17.0, 1.0, 1.0, 1.0 );solid_brick( -16.0, 1.0, 1.0, 1.0 );solid_brick( -15.0, 1.0, 1.0, 1.0 );solid_brick( -14.0, 1.0, 1.0, 1.0 );solid_brick( -14.0, 0.0, 1.0, 1.0 );coin( -17.0, 0.0 );coin( -16.0, 0.0 );coin( -15.0, 0.0 );solid_brick( -18.0, -3.0, 1.0, 1.0 );solid_brick( -17.0, -3.0, 1.0, 1.0 );solid_brick( -16.0, -3.0, 1.0, 1.0 );solid_brick( -14.0, -3.0, 1.0, 1.0 );solid_brick( -14.0, -4.0, 1.0, 1.0 );coin( -18.0, -4.0 );coin( -16.0, -4.0 );coin( -15.0, -4.0 );solid_brick( -17.0, -7.0, 1.0, 1.0 );solid_brick( -16.0, -7.0, 1.0, 1.0 );solid_brick( -15.0, -7.0, 1.0, 1.0 );solid_brick( -14.0, -7.0, 1.0, 1.0 );coin( -17.0, -8.0 );coin( -16.0, -8.0 );coin( -15.0, -8.0 );coin( -15.0, -9.0 );coin( -16.0, -9.0 );coin( -17.0, -9.0 );coin( -18.0, -9.0 );coin( -18.0, -10.0 );coin( -17.0, -10.0 );coin( -16.0, -10.0 );coin( -15.0, -10.0 );coin( -15.0, -11.0 );coin( -16.0, -11.0 );coin( -17.0, -11.0 );coin( -18.0, -11.0 );coin( -14.0, -11.0 );solid_brick( -13.0, 10.0, 1.0, 1.0 );solid_brick( -1.0, -5.0, 1.0, 1.0 );solid_brick( -4.0, -10.0, 1.0, 1.0 );coin( -15.0, 8.0 );solid_brick( -11.0, 10.0, 1.0, 1.0 );solid_brick( -10.0, 10.0, 1.0, 1.0 );solid_brick( -12.0, 10.0, 1.0, 1.0 );coin( -13.0, 1.0 );coin( -12.0, 1.0 );coin( -11.0, 1.0 );coin( -12.0, -3.0 );coin( -11.0, -3.0 );coin( -13.0, -7.0 );coin( -12.0, -7.0 );coin( -11.0, -7.0 );walky2(304.8,10.0,1.0,10.0);solid_brick( 308.0, 10.0, 1.0, 1.0 );solid_brick( 308.0, 6.0, 1.0, 1.0 );solid_brick( 307.0, 6.0, 1.0, 1.0 );solid_brick( 306.0, 6.0, 1.0, 1.0 );solid_brick( 305.0, 6.0, 1.0, 1.0 );solid_brick( 304.0, 6.0, 1.0, 1.0 );solid_brick( 303.0, 6.0, 1.0, 1.0 );solid_brick( 302.0, 6.0, 1.0, 1.0 );solid_brick( 301.0, 6.0, 1.0, 1.0 );solid_brick( 301.0, 7.0, 1.0, 1.0 );solid_brick( 301.0, 8.0, 1.0, 1.0 );solid_brick( 301.0, 9.0, 1.0, 1.0 );solid_brick( 301.0, 10.0, 1.0, 1.0 );solid_brick( 302.0, 9.0, 1.0, 1.0 );solid_brick( 303.0, 9.0, 1.0, 1.0 );solid_brick( 304.0, 9.0, 1.0, 1.0 );solid_brick( 305.0, 9.0, 1.0, 1.0 );solid_brick( 308.0, 9.0, 1.0, 1.0 );solid_brick( 308.0, 8.0, 1.0, 1.0 );solid_brick( 308.0, 7.0, 1.0, 1.0 );solid_brick( 305.0, 8.0, 1.0, 1.0 );walky2(302.8,8.006,1.0,-10.0);coin( 12.0, 1.0 );coin( 12.0, 2.0 );coin( 12.0, 3.0 );coin( 12.0, 4.0 );solid_brick( 17.0, -3.0, 1.0, 1.0 );solid_brick( 16.0, -2.0, 1.0, 1.0 );solid_brick( 15.0, -2.0, 1.0, 1.0 );solid_brick( 14.0, -2.0, 1.0, 1.0 );solid_brick( 13.0, -3.0, 1.0, 1.0 );coin( 17.0, -2.0 );coin( 18.0, -3.0 );coin( 18.0, -4.0 );coin( 17.0, -4.0 );coin( 17.0, -5.0 );coin( 15.0, -6.0 );coin( 13.0, -6.0 );coin( 13.0, -5.0 );coin( 18.0, -5.0 );coin( 12.0, -5.0 );coin( 12.0, -4.0 );coin( 12.0, -3.0 );coin( 13.0, -2.0 );coin( 14.0, -1.0 );coin( 15.0, -1.0 );coin( 16.0, -1.0 );coin( 15.0, -3.0 );coin( 16.0, -3.0 );coin( 16.0, -4.0 );coin( 15.0, -4.0 );coin( 15.0, -5.0 );coin( 14.0, -4.0 );coin( 13.0, -4.0 );coin( 14.0, -3.0 );solid_brick( 1.0, 12.0, 1.0, 1.0 );solid_brick( 2.0, 12.0, 1.0, 1.0 );solid_brick( 3.0, 13.0, 1.0, 1.0 );solid_brick( 3.0, 14.0, 1.0, 1.0 );solid_brick( 2.0, 15.0, 1.0, 1.0 );solid_brick( 1.0, 15.0, 1.0, 1.0 );solid_brick( 0.0, 15.0, 1.0, 1.0 );solid_brick( 0.0, 13.0, 1.0, 1.0 );solid_brick( 0.0, 12.0, 1.0, 1.0 );solid_brick( 0.0, 14.0, 1.0, 1.0 );solid_brick( 0.0, 16.0, 1.0, 1.0 );solid_brick( 0.0, 17.0, 1.0, 1.0 );solid_brick( 0.0, 18.0, 1.0, 1.0 );solid_brick( 7.0, 18.0, 1.0, 1.0 );solid_brick( 7.0, 17.0, 1.0, 1.0 );solid_brick( 7.0, 16.0, 1.0, 1.0 );solid_brick( 0.0, 19.0, 1.0, 1.0 );solid_brick( 7.0, 19.0, 1.0, 1.0 );solid_brick( 7.0, 15.0, 1.0, 1.0 );solid_brick( 6.0, 16.0, 1.0, 1.0 );solid_brick( 5.0, 15.0, 1.0, 1.0 );solid_brick( 4.0, 16.0, 1.0, 1.0 );solid_brick( 4.0, 18.0, 1.0, 1.0 );solid_brick( 5.0, 19.0, 1.0, 1.0 );solid_brick( 6.0, 18.0, 1.0, 1.0 );solid_brick( 4.0, 17.0, 1.0, 1.0 );solid_brick( 9.0, 15.0, 1.0, 1.0 );solid_brick( 9.0, 16.0, 1.0, 1.0 );solid_brick( 9.0, 17.0, 1.0, 1.0 );solid_brick( 9.0, 18.0, 1.0, 1.0 );solid_brick( 9.0, 19.0, 1.0, 1.0 );solid_brick( 9.0, 20.0, 1.0, 1.0 );solid_brick( 9.0, 21.0, 1.0, 1.0 );solid_brick( 9.0, 22.0, 1.0, 1.0 );solid_brick( 9.0, 23.0, 1.0, 1.0 );coin( 3.0, 5.0 );coin( 4.0, 5.0 );coin( 5.0, 5.0 );coin( 6.0, 5.0 );coin( 7.0, 5.0 );
coin( 8.0, 5.0 );coin( 9.0, 5.0 );coin( 10.0, 5.0 );coin( 10.0, 6.0 );coin( 9.0, 6.0 );coin( 8.0, 6.0 );coin( 7.0, 6.0 );coin( 6.0, 6.0 );coin( 5.0, 6.0 );coin( 4.0, 6.0 );coin( 3.0, 6.0 );solid_brick( 10.0, 15.0, 1.0, 1.0 );solid_brick( 11.0, 15.0, 1.0, 1.0 );solid_brick( 12.0, 16.0, 1.0, 1.0 );solid_brick( 12.0, 17.0, 1.0, 1.0 );solid_brick( 11.0, 18.0, 1.0, 1.0 );solid_brick( 10.0, 18.0, 1.0, 1.0 );solid_brick( 14.0, 16.0, 1.0, 1.0 );solid_brick( 14.0, 17.0, 1.0, 1.0 );solid_brick( 14.0, 18.0, 1.0, 1.0 );solid_brick( 15.0, 15.0, 1.0, 1.0 );solid_brick( 15.0, 19.0, 1.0, 1.0 );solid_brick( 16.0, 18.0, 1.0, 1.0 );solid_brick( 17.0, 18.0, 1.0, 1.0 );solid_brick( 17.0, 19.0, 1.0, 1.0 );solid_brick( 17.0, 17.0, 1.0, 1.0 );solid_brick( 17.0, 16.0, 1.0, 1.0 );solid_brick( 17.0, 15.0, 1.0, 1.0 );solid_brick( 16.0, 16.0, 1.0, 1.0 );solid_brick( 22.0, 15.0, 1.0, 1.0 );solid_brick( 21.0, 14.0, 1.0, 1.0 );solid_brick( 21.0, 13.0, 1.0, 1.0 );solid_brick( 22.0, 12.0, 1.0, 1.0 );solid_brick( 23.0, 13.0, 1.0, 1.0 );solid_brick( 23.0, 14.0, 1.0, 1.0 );solid_brick( 21.0, 16.0, 1.0, 1.0 );solid_brick( 20.0, 17.0, 1.0, 1.0 );solid_brick( 20.0, 18.0, 1.0, 1.0 );solid_brick( 21.0, 19.0, 1.0, 1.0 );solid_brick( 22.0, 19.0, 1.0, 1.0 );solid_brick( 23.0, 19.0, 1.0, 1.0 );solid_brick( 24.0, 18.0, 1.0, 1.0 );solid_brick( 25.0, 17.0, 1.0, 1.0 );solid_brick( 25.0, 19.0, 1.0, 1.0 );solid_brick( 23.0, 17.0, 1.0, 1.0 );solid_brick( 22.0, 16.0, 1.0, 1.0 );solid_brick( 34.0, 13.0, 1.0, 1.0 );solid_brick( 33.0, 12.0, 1.0, 1.0 );solid_brick( 32.0, 12.0, 1.0, 1.0 );solid_brick( 30.0, 14.0, 1.0, 1.0 );solid_brick( 34.0, 17.0, 1.0, 1.0 );solid_brick( 34.0, 18.0, 1.0, 1.0 );solid_brick( 33.0, 19.0, 1.0, 1.0 );solid_brick( 31.0, 19.0, 1.0, 1.0 );solid_brick( 32.0, 19.0, 1.0, 1.0 );solid_brick( 30.0, 18.0, 1.0, 1.0 );solid_brick( 30.0, 13.0, 1.0, 1.0 );solid_brick( 31.0, 12.0, 1.0, 1.0 );solid_brick( 31.0, 15.0, 1.0, 1.0 );solid_brick( 32.0, 15.0, 1.0, 1.0 );solid_brick( 33.0, 15.0, 1.0, 1.0 );solid_brick( 34.0, 16.0, 1.0, 1.0 );solid_brick( 37.0, 15.0, 1.0, 1.0 );solid_brick( 39.0, 15.0, 1.0, 1.0 );solid_brick( 39.0, 16.0, 1.0, 1.0 );solid_brick( 39.0, 17.0, 1.0, 1.0 );solid_brick( 39.0, 19.0, 1.0, 1.0 );solid_brick( 39.0, 18.0, 1.0, 1.0 );solid_brick( 38.0, 16.0, 1.0, 1.0 );solid_brick( 36.0, 16.0, 1.0, 1.0 );solid_brick( 36.0, 17.0, 1.0, 1.0 );solid_brick( 36.0, 18.0, 1.0, 1.0 );solid_brick( 38.0, 18.0, 1.0, 1.0 );solid_brick( 37.0, 19.0, 1.0, 1.0 );solid_brick( 41.0, 15.0, 1.0, 1.0 );solid_brick( 41.0, 16.0, 1.0, 1.0 );solid_brick( 41.0, 17.0, 1.0, 1.0 );solid_brick( 41.0, 18.0, 1.0, 1.0 );solid_brick( 41.0, 19.0, 1.0, 1.0 );solid_brick( 42.0, 16.0, 1.0, 1.0 );solid_brick( 43.0, 15.0, 1.0, 1.0 );solid_brick( 44.0, 15.0, 1.0, 1.0 );solid_brick( 47.0, 16.0, 1.0, 1.0 );solid_brick( 47.0, 17.0, 1.0, 1.0 );solid_brick( 47.0, 18.0, 1.0, 1.0 );solid_brick( 48.0, 19.0, 1.0, 1.0 );solid_brick( 50.0, 18.0, 1.0, 1.0 );solid_brick( 49.0, 18.0, 1.0, 1.0 );solid_brick( 50.0, 19.0, 1.0, 1.0 );solid_brick( 50.0, 17.0, 1.0, 1.0 );solid_brick( 50.0, 16.0, 1.0, 1.0 );solid_brick( 50.0, 15.0, 1.0, 1.0 );solid_brick( 49.0, 16.0, 1.0, 1.0 );solid_brick( 48.0, 15.0, 1.0, 1.0 );solid_brick( 52.0, 12.0, 1.0, 1.0 );solid_brick( 52.0, 13.0, 1.0, 1.0 );solid_brick( 52.0, 14.0, 1.0, 1.0 );solid_brick( 52.0, 15.0, 1.0, 1.0 );solid_brick( 52.0, 16.0, 1.0, 1.0 );solid_brick( 52.0, 17.0, 1.0, 1.0 );solid_brick( 52.0, 18.0, 1.0, 1.0 );solid_brick( 52.0, 19.0, 1.0, 1.0 );solid_brick( 53.0, 16.0, 1.0, 1.0 );solid_brick( 54.0, 15.0, 1.0, 1.0 );solid_brick( 55.0, 16.0, 1.0, 1.0 );solid_brick( 55.0, 17.0, 1.0, 1.0 );solid_brick( 55.0, 18.0, 1.0, 1.0 );solid_brick( 55.0, 19.0, 1.0, 1.0 );solid_brick( 45.0, 16.0, 1.0, 1.0 );solid_brick( 63.0, 13.0, 1.0, 1.0 );solid_brick( 64.0, 12.0, 1.0, 1.0 );solid_brick( 65.0, 12.0, 1.0, 1.0 );solid_brick( 66.0, 13.0, 1.0, 1.0 );solid_brick( 66.0, 14.0, 1.0, 1.0 );solid_brick( 66.0, 15.0, 1.0, 1.0 );solid_brick( 65.0, 16.0, 1.0, 1.0 );solid_brick( 64.0, 17.0, 1.0, 1.0 );solid_brick( 63.0, 18.0, 1.0, 1.0 );solid_brick( 62.0, 19.0, 1.0, 1.0 );solid_brick( 61.0, 18.0, 1.0, 1.0 );solid_brick( 60.0, 17.0, 1.0, 1.0 );solid_brick( 59.0, 16.0, 1.0, 1.0 );solid_brick( 58.0, 15.0, 1.0, 1.0 );solid_brick( 58.0, 14.0, 1.0, 1.0 );solid_brick( 58.0, 13.0, 1.0, 1.0 );solid_brick( 59.0, 12.0, 1.0, 1.0 );solid_brick( 60.0, 12.0, 1.0, 1.0 );solid_brick( 61.0, 13.0, 1.0, 1.0 );solid_brick( 62.0, 14.0, 1.0, 1.0 );coin( 1.0, 5.0 );coin( 1.0, 4.0 );coin( 0.0, 4.0 );coin( 0.0, 3.0 );coin( 0.0, 2.0 );coin( 0.0, 1.0 );coin( 1.0, 1.0 );coin( 1.0, 0.0 );coin( 1.0, 2.0 );coin( 2.0, -1.0 );solid_brick( 15.0, 0.0, 1.0, 1.0 );solid_brick( 14.0, 1.0, 1.0, 1.0 );solid_brick( 15.0, 2.0, 1.0, 1.0 );solid_brick( 16.0, 3.0, 1.0, 1.0 );solid_brick( 15.0, 4.0, 1.0, 1.0 );solid_brick( 14.0, 5.0, 1.0, 1.0 );solid_brick( 6.0, 7.0, 1.0, 1.0 );solid_brick( 7.0, 8.0, 1.0, 1.0 );solid_brick( 6.0, 9.0, 1.0, 1.0 );solid_brick( 5.0, 10.0, 1.0, 1.0 );solid_brick( 6.0, 10.0, 1.0, 1.0 );solid_brick( 7.0, 10.0, 1.0, 1.0 );solid_brick( 14.0, 6.0, 1.0, 1.0 );solid_brick( 15.0, 7.0, 1.0, 1.0 );solid_brick( 16.0, 8.0, 1.0, 1.0 );solid_brick( 15.0, 9.0, 1.0, 1.0 );solid_brick( 15.0, 10.0, 1.0, 1.0 );solid_brick( 16.0, 10.0, 1.0, 1.0 );teleporter( 13.0, 10.0 );teleporter( 15.0, -4.0 );solid_brick( 0.0, 2.0, 1.0, 1.0 );coin( 6.0, 2.0 );coin( 5.0, 3.0 );coin( 6.0, 3.0 );coin( 7.0, 3.0 );coin( 9.0, 3.0 );coin( 10.0, 3.0 );coin( 4.0, 3.0 );coin( 2.0, 3.0 );coin( 3.0, 3.0 );coin( 2.0, 1.0 );solid_brick( 2.0, 0.0, 1.0, 1.0 );coin( 10.0, 1.0 );solid_brick( 10.0, 0.0, 1.0, 1.0 );teleporter( 6.0, 1.0 );teleporter( 17.0, 10.0 );coin( -17.0, -4.0 );coin( -18.0, 0.0 );coin( -18.0, 4.0 );coin( -18.0, 9.0 );coin( -18.0, -8.0 );solid_brick( -7.0, 9.0, 1.0, 1.0 );coin( -13.0, 9.006 );coin( -14.0, 8.0 );coin( -14.0, 7.0 );coin( -13.0, 8.0 );coin( -13.0, 7.0 );coin( -13.0, 6.0 );coin( -13.0, 5.0 );coin( -13.0, 4.0 );coin( -13.0, 3.0 );coin( -14.0, 3.0 );coin( -15.0, 3.0 );coin( -16.0, 3.0 );coin( -17.0, 3.0 );coin( -18.0, 3.0 );coin( -18.0, 2.0 );coin( -17.0, 2.0 );coin( -16.0, 2.0 );coin( -15.0, 2.0 );coin( -14.0, 2.0 );coin( -13.0, 2.0 );coin( -13.0, 0.0 );coin( -13.0, -1.0 );coin( -14.0, -1.0 );coin( -15.0, -1.0 );coin( -16.0, -1.0 );coin( -17.0, -1.0 );coin( -18.0, -1.0 );coin( -18.0, -2.0 );coin( -17.0, -2.0 );coin( -16.0, -2.0 );coin( -15.0, -2.0 );coin( -14.0, -2.0 );coin( -13.0, -2.0 );coin( -13.0, -4.0 );coin( -13.0, -4.0 );coin( -13.0, -5.0 );coin( -14.0, -5.0 );coin( -15.0, -5.0 );coin( -15.0, -5.0 );coin( -16.0, -5.0 );coin( -17.0, -5.0 );coin( -17.0, -5.0 );coin( -18.0, -5.0 );coin( -18.0, -5.0 );coin( -18.0, -5.0 );coin( -18.0, -6.0 );coin( -18.0, -6.0 );coin( -17.0, -6.0 );coin( -16.0, -6.0 );coin( -16.0, -6.0 );coin( -16.0, -6.0 );coin( -16.0, -6.0 );coin( -15.0, -6.0 );coin( -14.0, -6.0 );coin( -13.0, -6.0 );coin( -12.0, -6.0 );coin( -12.0, -5.0 );coin( -12.0, -4.0 );coin( -11.0, -4.0 );coin( -11.0, -5.0 );coin( -11.0, -6.0 );coin( -10.0, -6.0 );coin( -10.0, -5.0 );coin( -10.0, -4.0 );
coin( -10.0, -3.0 );coin( -9.0, -3.0 );coin( -9.0, -4.0 );coin( -9.0, -5.0 );coin( -9.0, -6.0 );coin( -9.0, -8.0 );coin( -9.0, -9.0 );coin( -9.0, -10.0 );coin( -10.0, -8.0 );coin( -10.0, -7.0 );coin( -10.0, -9.0 );coin( -10.0, -10.0 );coin( -10.0, -11.0 );coin( -11.0, -11.0 );coin( -11.0, -10.0 );coin( -11.0, -9.0 );coin( -11.0, -8.0 );coin( -12.0, -8.0 );coin( -12.0, -9.0 );coin( -12.0, -10.0 );coin( -12.0, -11.0 );coin( -13.0, -8.0 );coin( -13.0, -9.0 );coin( -13.0, -10.0 );coin( -13.0, -11.0 );coin( -12.0, -2.0 );coin( -12.0, -1.0 );coin( -12.0, 0.0 );coin( -11.0, -1.0 );coin( -11.0, -2.0 );coin( -11.0, 0.0 );coin( -10.0, -2.0 );coin( -9.0, -2.0 );coin( -11.0, 2.0 );coin( -11.0, 3.0 );coin( -11.0, 4.0 );coin( -11.0, 5.0 );coin( -11.0, 6.0 );coin( -11.0, 6.0 );coin( -11.0, 7.0 );coin( -11.0, 7.0 );coin( -11.0, 7.0 );coin( -12.0, 7.0 );coin( -12.0, 6.0 );coin( -12.0, 5.0 );coin( -12.0, 3.0 );coin( -12.0, 2.0 );coin( -13.0, 3.0 );coin( -13.0, 3.0 );coin( -16.0, 3.0 );coin( -15.0, 3.0 );coin( -15.0, 3.0 );coin( -14.0, 3.0 );coin( -12.0, 3.0 );coin( -11.0, 3.0 );coin( -13.0, 9.006 );coin( -12.0, 9.006 );coin( -12.0, 8.0 );coin( -11.0, 8.0 );coin( -11.0, 9.0 );coin( -10.0, 9.0 );coin( -10.0, 8.0 );coin( -10.0, 7.0 );coin( -10.0, 6.0 );coin( -10.0, 5.0 );coin( -10.0, 4.0 );coin( -10.0, 3.0 );coin( -10.0, 2.0 );coin( -10.0, 1.0 );coin( -10.0, 0.0 );coin( -10.0, -1.0 );coin( -9.0, -1.0 );coin( -9.0, 0.0 );coin( -9.0, 1.0 );coin( -9.0, 2.0 );coin( -9.0, 3.0 );coin( -9.0, 4.0 );coin( -9.0, 5.0 );coin( -9.0, 6.0 );coin( -9.0, 7.0 );coin( -9.0, 8.0 );solid_brick( -8.0, -4.5, 1.0, 16.0 );door(-8.0, 4.0, -8.0, 8.0);button( -9.0, 9.0 );teleporter( -7.0, 10.0 );solid_brick( -14.0, -11.0, 1.0, 1.0 );solid_brick( -14.0, -10.0, 1.0, 1.0 );solid_brick( -14.0, -9.0, 1.0, 1.0 );solid_brick( -14.0, 3.0, 1.0, 1.0 );solid_brick( -14.0, 1.0, 1.0, 1.0 );solid_brick( -14.0, 2.0, 1.0, 1.0 );solid_brick( -14.0, -1.0, 1.0, 1.0 );solid_brick( -14.0, -2.0, 1.0, 1.0 );solid_brick( -14.0, -5.0, 1.0, 1.0 );solid_brick( -14.0, -6.0, 1.0, 1.0 );coin( -18.0, -7.0 );coin( -15.0, -3.0 );coin( -18.0, 0.0 );coin( -18.0, 1.0 );invisible_brick( -13.0, -7.0, 1.0, 1.0 );invisible_brick( -12.0, -7.0, 1.0, 1.0 );invisible_brick( -11.0, -7.0, 1.0, 1.0 );invisible_brick( -10.0, -7.0, 1.0, 1.0 );invisible_brick( -12.0, -3.0, 1.0, 1.0 );invisible_brick( -11.0, -3.0, 1.0, 1.0 );invisible_brick( -10.0, -3.0, 1.0, 1.0 );invisible_brick( -9.0, -3.0, 1.0, 1.0 );teleporter( -17.0, -11.0 );coin( -13.0, -3.0 );invisible_brick( -13.0, 1.0, 1.0, 1.0 );invisible_brick( -12.0, 1.0, 1.0, 1.0 );invisible_brick( -11.0, 1.0, 1.0, 1.0 );invisible_brick( -10.0, 1.0, 1.0, 1.0 );invisible_brick( -9.0, 5.0, 1.0, 1.0 );invisible_brick( -10.0, 5.0, 1.0, 1.0 );invisible_brick( -11.0, 5.0, 1.0, 1.0 );invisible_brick( -12.0, 5.0, 1.0, 1.0 );invisible_brick( -14.0, 8.0, 1.0, 1.0 );invisible_brick( -14.0, 7.0, 1.0, 1.0 );invisible_brick( -14.0, -8.0, 1.0, 1.0 );solid_brick( -12.0, -7.0, 1.0, 1.0 );solid_brick( -10.0, -7.0, 1.0, 1.0 );solid_brick( -12.0, -3.0, 1.0, 1.0 );solid_brick( -10.0, -3.0, 1.0, 1.0 );solid_brick( -12.0, 1.0, 1.0, 1.0 );solid_brick( -10.0, 1.0, 1.0, 1.0 );solid_brick( -12.0, 5.0, 1.0, 1.0 );solid_brick( -10.0, 5.0, 1.0, 1.0 );coin( -11.0, 5.0 );coin( -9.0, 5.0 );coin( -11.0, 1.0 );coin( -13.0, 1.0 );coin( -11.0, -3.0 );coin( -9.0, -3.0 );coin( -11.0, -6.0 );coin( -11.0, -7.0 );coin( -13.0, -7.0 );coin( -14.0, -8.0 );coin( -14.0, 8.0 );coin( -14.0, 7.0 );coin( 14.0, -5.0 );coin( 16.0, -5.0 );solid_brick( 16.0, -6.0, 1.0, 1.0 );solid_brick( 14.0, -6.0, 1.0, 1.0 );coin( 12.0, -6.0 );coin( 13.0, -7.0 );coin( 14.0, -7.0 );coin( 15.0, -7.0 );coin( 16.0, -7.0 );coin( 17.0, -6.0 );coin( 17.0, -7.0 );coin( 18.0, -6.0 );coin( -14.0, 6.0 );solid_brick( 39.0, 10.0, 1.0, 1.0 );solid_brick( 40.0, 9.0, 1.0, 1.0 );solid_brick( 41.0, 8.0, 1.0, 1.0 );solid_brick( 41.0, 9.0, 1.0, 1.0 );solid_brick( 40.0, 10.0, 1.0, 1.0 );solid_brick( 41.0, 10.0, 1.0, 1.0 );solid_brick( 44.5, 6.5, 8.0, 2.0 );solid_brick( 48.5, 4.0, 10.0, 3.0 );solid_brick( 55.0, 10.0, 1.0, 1.0 );walky2(43.0,10.0,1.0,-10.0);walky2(163.8952,10.2952,0.40960002,-10.0);solid_brick( 203.0, 10.0, 1.0, 1.0 );walky2(136.42795,7.106561,6.7868776,10.0);walky2(119.134514,10.0,1.0,-10.0);solid_brick( 62.0, 2.0, 1.0, 1.0 );solid_brick( 62.0, 1.0, 1.0, 1.0 );solid_brick( 62.0, 0.0, 1.0, 1.0 );solid_brick( 62.0, -1.0, 1.0, 1.0 );solid_brick( 63.0, -2.0, 1.0, 1.0 );solid_brick( 64.0, -2.0, 1.0, 1.0 );solid_brick( 65.0, -1.0, 1.0, 1.0 );solid_brick( 65.0, 0.0, 1.0, 1.0 );solid_brick( 65.0, 1.0, 1.0, 1.0 );solid_brick( 65.0, 2.0, 1.0, 1.0 );solid_brick( 65.0, 3.0, 1.0, 1.0 );solid_brick( 64.0, 4.0, 1.0, 1.0 );solid_brick( 63.0, 4.0, 1.0, 1.0 );solid_brick( 62.0, 3.0, 1.0, 1.0 );solid_brick( 63.0, 1.0, 1.0, 1.0 );solid_brick( 64.0, 1.0, 1.0, 1.0 );solid_brick( 64.0, 2.0, 1.0, 1.0 );solid_brick( 63.0, 2.0, 1.0, 1.0 );solid_brick( 61.0, 0.0, 1.0, 1.0 );solid_brick( 60.0, -1.0, 1.0, 1.0 );solid_brick( 61.0, -2.0, 1.0, 1.0 );solid_brick( 60.0, -3.0, 1.0, 1.0 );solid_brick( 66.0, 7.0, 1.0, 1.0 );solid_brick( 67.0, 7.0, 1.0, 1.0 );solid_brick( 68.0, 7.0, 1.0, 1.0 );solid_brick( 69.0, 6.0, 1.0, 1.0 );solid_brick( 70.0, 1.0, 1.0, 1.0 );solid_brick( 71.0, 0.0, 1.0, 1.0 );solid_brick( 72.0, 0.0, 1.0, 1.0 );solid_brick( 73.0, 0.0, 1.0, 1.0 );solid_brick( 74.0, 1.0, 1.0, 1.0 );solid_brick( 75.0, 0.0, 1.0, 1.0 );solid_brick( 76.0, -1.0, 1.0, 1.0 );start_block(-7.0,8.0);end_block(70.0,5.0);solid_brick( -27.0, 7.5, 1.0, 6.0 );water( -26.0, 5.0, 1.0, 1.0 );water( -25.0, 5.0, 1.0, 1.0 );water( -24.0, 5.0, 1.0, 1.0 );water( -23.0, 5.0, 1.0, 1.0 );water( -22.0, 5.0, 1.0, 1.0 );water( -21.0, 5.0, 1.0, 1.0 );water( -20.0, 5.0, 1.0, 1.0 );water( -20.0, 6.0, 1.0, 1.0 );water( -21.0, 6.0, 1.0, 1.0 );water( -22.0, 6.0, 1.0, 1.0 );water( -23.0, 6.0, 1.0, 1.0 );water( -24.0, 6.0, 1.0, 1.0 );water( -25.0, 6.0, 1.0, 1.0 );water( -26.0, 6.0, 1.0, 1.0 );water( -26.0, 7.0, 1.0, 1.0 );water( -25.0, 7.0, 1.0, 1.0 );water( -24.0, 7.0, 1.0, 1.0 );water( -23.0, 7.0, 1.0, 1.0 );water( -22.0, 7.0, 1.0, 1.0 );water( -21.0, 7.0, 1.0, 1.0 );water( -20.0, 7.0, 1.0, 1.0 );water( -20.0, 8.0, 1.0, 1.0 );water( -21.0, 8.0, 1.0, 1.0 );water( -22.0, 8.0, 1.0, 1.0 );water( -23.0, 8.0, 1.0, 1.0 );water( -24.0, 8.0, 1.0, 1.0 );water( -25.0, 8.0, 1.0, 1.0 );water( -26.0, 8.0, 1.0, 1.0 );water( -26.0, 9.0, 1.0, 1.0 );water( -25.0, 9.0, 1.0, 1.0 );water( -24.0, 9.0, 1.0, 1.0 );water( -23.0, 9.0, 1.0, 1.0 );water( -22.0, 9.0, 1.0, 1.0 );water( -21.0, 9.0, 1.0, 1.0 );water( -20.0, 9.0, 1.0, 1.0 );water( -20.0, 10.0, 1.0, 1.0 );water( -21.0, 10.0, 1.0, 1.0 );water( -22.0, 10.0, 1.0, 1.0 );water( -23.0, 10.0, 1.0, 1.0 );water( -24.0, 10.0, 1.0, 1.0 );water( -25.0, 10.0, 1.0, 1.0 );water( -26.0, 10.0, 1.0, 1.0 );fish(-25.0,6.0,1.0,2);
  }else if( level_num+1 == 2 ){
    start_block(-3.0,7.0);solid_brick( -16.5, -2.5, 20.0, 26.0 );solid_brick( 12.0, 6.0, 11.0, 1.0 );solid_brick( 17.0, 5.0, 1.0, 1.0 );walky2( 16.0, 5.0, 1.0, -5.0 );coin( 9.0, 3.0 );coin( 12.0, 3.0 );coin( 15.0, 3.0 );coin( 1.0, 3.0 );solid_brick( 21.5, 1.0, 10.0, 1.0 );walky2( 26.0, 0.0, 1.0, -5.0 );solid_brick( 30.5, 6.0, 4.0, 9.0 );walky2( 21.0, 7.8896623, 5.220675, -5.6E-45 );coin( -25.0, -18.0 );coin( -23.0, -18.0 );coin( -20.0, -18.0 );coin( -22.0, -18.0 );coin( -18.0, -18.0 );coin( -15.0, -18.0 );coin( -13.0, -18.0 );coin( -10.0, -18.0 );coin( -8.0, -18.0 );coin( -9.0, -20.0 );coin( -12.0, -20.0 );coin( -15.0, -20.0 );coin( -18.0, -20.0 );coin( -21.0, -20.0 );coin( -23.0, -20.0 );solid_brick( -26.0, -16.0, 1.0, 1.0 );solid_brick( -7.0, -16.0, 1.0, 1.0 );walky2( -22.0, -16.15, 0.42598403, -5.0 );teleporter( -16.0, -19.0 );teleporter( 65.0, 10.0 );coin( 18.0, -2.0 );coin( 21.0, -2.0 );coin( 25.0, -2.0 );coin( 35.0, 7.0 );coin( 39.0, 7.0 );coin( 44.0, 7.0 );solid_brick( 56.0, 3.0, 1.0, 15.0 );solid_brick( 76.0, 3.0, 1.0, 15.0 );solid_brick( 60.0, 5.0, 1.0, 1.0 );solid_brick( 67.5, 6.0, 16.0, 1.0 );solid_brick( 73.0, 1.0, 1.0, 1.0 );solid_brick( 65.0, 2.0, 17.0, 1.0 );teleporter( 55.0, 10.0 );teleporter( 56.0, -5.0 );walky2( 57.0, 1.0, 1.0, -5.0 );walky2( 62.0, 5.0, 1.0, -5.0 );walky2( 66.0, 5.0, 1.0, -5.0 );coin( 60.0, 8.0 );coin( 63.0, 8.0 );coin( 66.0, 8.0 );coin( 69.0, 8.0 );coin( 72.0, 8.0 );coin( 74.0, 8.0 );walky2( 67.0, -1.0, 3.089157, -5.0 );solid_brick( 67.0, -4.0, 17.0, 1.0 );key(255,0,0,75.0,10.0);teleporter( 82.0, 7.0 );teleporter( 90.0, 7.0 );teleporter( 86.0, 7.0 );teleporter( 98.0, 7.0 );teleporter( 94.0, 7.0 );teleporter( 75.0, -5.0 );walky2( 84.0, 10.0, 1.0, -5.0 );door(105.0, 10.0, 105.0, 3.0);button( 66.0, -5.0 );solid_brick( 105.0, -1.0, 1.0, 7.0 );solid_brick( 116.0, -4.0, 21.0, 1.0 );solid_brick( 126.0, 2.0, 1.0, 11.0 );solid_brick( 115.5, 6.0, 12.0, 1.0 );solid_brick( 115.5, 2.0, 6.0, 1.0 );coin( 110.0, 3.0 );coin( 113.0, -1.0 );coin( 115.0, -1.0 );coin( 118.0, -1.0 );coin( 121.0, 4.0 );solid_brick( 122.0, 0.0, 1.0, 1.0 );solid_brick( 123.5, 1.0, 4.0, 1.0 );walky2( 124.0, 0.0, 1.0, -5.0 );walky2( 114.0, -0.43072328, 3.8614466, -5.0 );door(125.0, 2.0, 125.0, 10.0);button( 115.0, 5.0 );teleporter( 115.0, 10.0 );teleporter( 115.0, -5.0 );coin( 107.0, -7.0 );coin( 110.0, -7.0 );coin( 113.0, -7.0 );coin( 117.0, -7.0 );coin( 120.0, -7.0 );coin( 123.0, -7.0 );coin( 126.0, -7.0 );coin( 104.0, -4.0 );coin( 104.0, -3.0 );coin( 104.0, -2.0 );coin( 104.0, -1.0 );coin( 104.0, 0.0 );coin( 104.0, 1.0 );coin( 104.0, 2.0 );coin( 104.0, 3.0 );coin( 104.0, 4.0 );coin( 104.0, 5.0 );coin( 103.0, 5.0 );coin( 103.0, 4.0 );coin( 103.0, 3.0 );coin( 103.0, 2.0 );coin( 103.0, 1.0 );coin( 103.0, 0.0 );coin( 103.0, -1.0 );coin( 103.0, -2.0 );coin( 103.0, -3.0 );coin( 103.0, -4.0 );coin( 127.0, -4.0 );coin( 127.0, -3.0 );coin( 127.0, -2.0 );coin( 127.0, -1.0 );coin( 127.0, 0.0 );coin( 127.0, 1.0 );coin( 127.0, 2.0 );coin( 127.0, 3.0 );coin( 127.0, 4.0 );coin( 128.0, 4.0 );coin( 128.0, 3.0 );coin( 128.0, 2.0 );coin( 128.0, 1.0 );coin( 128.0, 0.0 );coin( 128.0, -1.0 );coin( 128.0, -2.0 );coin( 128.0, -3.0 );coin( 128.0, -4.0 );door(140.0, 10.0, 140.0, 3.0);keyed_button(255,0,0,138.0,10.0);solid_brick( 140.0, -1.5, 1.0, 8.0 );solid_brick( 149.0, -5.0, 17.0, 1.0 );solid_brick( 157.0, 3.0, 1.0, 15.0 );solid_brick( 149.0, 3.5, 9.0, 6.0 );solid_brick( 144.0, 7.0, 1.0, 1.0 );solid_brick( 142.0, 3.0, 1.0, 1.0 );coin( 146.0, -2.0 );coin( 148.0, -2.0 );coin( 151.0, -2.0 );coin( 153.0, -2.0 );solid_brick( 149.0, -10.0, 1.0, 1.0 );teleporter( 153.0, 0.0 );teleporter( 153.0, -6.0 );teleporter( 140.0, -6.0 );teleporter( 13.0, -17.0 );solid_brick( 169.0, 7.0, 1.0, 1.0 );solid_brick( 170.0, 8.0, 1.0, 1.0 );solid_brick( 171.0, 7.0, 1.0, 1.0 );solid_brick( 169.0, 6.0, 1.0, 1.0 );solid_brick( 171.0, 6.0, 1.0, 1.0 );solid_brick( 172.0, 8.0, 1.0, 1.0 );solid_brick( 173.0, 7.0, 1.0, 1.0 );solid_brick( 173.0, 6.0, 1.0, 1.0 );solid_brick( 175.0, 6.0, 1.0, 1.0 );solid_brick( 175.0, 7.0, 1.0, 1.0 );solid_brick( 175.0, 8.0, 1.0, 1.0 );solid_brick( 177.0, 8.0, 1.0, 1.0 );solid_brick( 177.0, 7.0, 1.0, 1.0 );solid_brick( 177.0, 6.0, 1.0, 1.0 );solid_brick( 178.0, 6.0, 1.0, 1.0 );solid_brick( 179.0, 7.0, 1.0, 1.0 );solid_brick( 179.0, 8.0, 1.0, 1.0 );solid_brick( 260.5, -2.0, 28.0, 25.0 );door(157.0, -6.0, 155.0, -20.0);keyed_button(0,255,0,151.0,-6.0);solid_brick( 134.0, 0.0, 1.0, 1.0 );key(0,255,0,134.0,-1.0);water( 4.0, 5.0, 1.0, 1.0 );water( 4.0, 6.0, 1.0, 1.0 );water( 4.0, 7.0, 1.0, 1.0 );water( 4.0, 8.0, 1.0, 1.0 );water( 4.0, 9.0, 1.0, 1.0 );water( 4.0, 10.0, 1.0, 1.0 );water( 3.0, 10.0, 1.0, 1.0 );water( 3.0, 9.0, 1.0, 1.0 );water( 3.0, 8.0, 1.0, 1.0 );water( 3.0, 7.0, 1.0, 1.0 );water( 3.0, 6.0, 1.0, 1.0 );water( 3.0, 5.0, 1.0, 1.0 );water( 2.0, 5.0, 1.0, 1.0 );water( 2.0, 6.0, 1.0, 1.0 );water( 2.0, 7.0, 1.0, 1.0 );water( 2.0, 8.0, 1.0, 1.0 );water( 2.0, 9.0, 1.0, 1.0 );water( 2.0, 10.0, 1.0, 1.0 );water( 1.0, 10.0, 1.0, 1.0 );water( 1.0, 9.0, 1.0, 1.0 );water( 1.0, 8.0, 1.0, 1.0 );water( 1.0, 7.0, 1.0, 1.0 );water( 1.0, 6.0, 1.0, 1.0 );water( 1.0, 5.0, 1.0, 1.0 );water( 28.0, 10.0, 1.0, 1.0 );water( 27.0, 10.0, 1.0, 1.0 );water( 26.0, 10.0, 1.0, 1.0 );water( 25.0, 10.0, 1.0, 1.0 );water( 24.0, 10.0, 1.0, 1.0 );water( 23.0, 10.0, 1.0, 1.0 );water( 22.0, 10.0, 1.0, 1.0 );water( 21.0, 10.0, 1.0, 1.0 );water( 20.0, 10.0, 1.0, 1.0 );water( 19.0, 10.0, 1.0, 1.0 );water( 19.0, 9.0, 1.0, 1.0 );water( 19.0, 8.0, 1.0, 1.0 );water( 19.0, 7.0, 1.0, 1.0 );water( 19.0, 6.0, 1.0, 1.0 );water( 18.0, 5.0, 1.0, 1.0 );water( 18.0, 6.0, 1.0, 1.0 );water( 18.0, 7.0, 1.0, 1.0 );water( 18.0, 8.0, 1.0, 1.0 );water( 18.0, 9.0, 1.0, 1.0 );water( 18.0, 10.0, 1.0, 1.0 );water( 19.0, 5.0, 1.0, 1.0 );water( 20.0, 5.0, 1.0, 1.0 );water( 21.0, 5.0, 1.0, 1.0 );water( 22.0, 5.0, 1.0, 1.0 );water( 23.0, 5.0, 1.0, 1.0 );water( 24.0, 5.0, 1.0, 1.0 );water( 25.0, 5.0, 1.0, 1.0 );water( 26.0, 5.0, 1.0, 1.0 );water( 27.0, 5.0, 1.0, 1.0 );water( 28.0, 5.0, 1.0, 1.0 );water( 28.0, 6.0, 1.0, 1.0 );water( 28.0, 7.0, 1.0, 1.0 );water( 28.0, 8.0, 1.0, 1.0 );water( 28.0, 9.0, 1.0, 1.0 );water( 27.0, 9.0, 1.0, 1.0 );water( 27.0, 8.0, 1.0, 1.0 );water( 27.0, 7.0, 1.0, 1.0 );water( 27.0, 6.0, 1.0, 1.0 );water( 26.0, 6.0, 1.0, 1.0 );water( 26.0, 7.0, 1.0, 1.0 );water( 26.0, 8.0, 1.0, 1.0 );water( 26.0, 9.0, 1.0, 1.0 );water( 25.0, 9.0, 1.0, 1.0 );water( 25.0, 8.0, 1.0, 1.0 );water( 25.0, 7.0, 1.0, 1.0 );water( 25.0, 6.0, 1.0, 1.0 );water( 24.0, 6.0, 1.0, 1.0 );water( 24.0, 7.0, 1.0, 1.0 );water( 24.0, 8.0, 1.0, 1.0 );water( 24.0, 9.0, 1.0, 1.0 );water( 23.0, 9.0, 1.0, 1.0 );water( 23.0, 8.0, 1.0, 1.0 );water( 23.0, 7.0, 1.0, 1.0 );water( 23.0, 6.0, 1.0, 1.0 );water( 22.0, 6.0, 1.0, 1.0 );water( 22.0, 7.0, 1.0, 1.0 );water( 22.0, 8.0, 1.0, 1.0 );water( 22.0, 9.0, 1.0, 1.0 );water( 21.0, 9.0, 1.0, 1.0 );water( 21.0, 8.0, 1.0, 1.0 );water( 21.0, 7.0, 1.0, 1.0 );water( 21.0, 6.0, 1.0, 1.0 );water( 20.0, 6.0, 1.0, 1.0 );water( 20.0, 7.0, 1.0, 1.0 );
water( 20.0, 8.0, 1.0, 1.0 );water( 20.0, 9.0, 1.0, 1.0 );solid_brick( 17.0, 10.0, 1.0, 1.0 );solid_brick( 17.0, 9.0, 1.0, 1.0 );solid_brick( 17.0, 8.0, 1.0, 1.0 );solid_brick( 17.0, 7.0, 1.0, 1.0 );solid_brick( 5.0, 10.0, 1.0, 1.0 );solid_brick( 5.0, 9.0, 1.0, 1.0 );solid_brick( 5.0, 8.0, 1.0, 1.0 );solid_brick( 5.0, 7.0, 1.0, 1.0 );solid_brick( 5.0, 6.0, 1.0, 1.0 );solid_brick( 5.0, 5.0, 1.0, 1.0 );solid_brick( 0.0, 5.0, 1.0, 1.0 );solid_brick( 0.0, 6.0, 1.0, 1.0 );solid_brick( 0.0, 7.0, 1.0, 1.0 );solid_brick( 0.0, 8.0, 1.0, 1.0 );solid_brick( 0.0, 9.0, 1.0, 1.0 );solid_brick( 0.0, 10.0, 1.0, 1.0 );end_block(175.0,4.0);
  }else if( level_num+1 == 3 ){
solid_brick( 23.0, 10.006, 41.0, 1.0 );solid_brick( 13.0, 7.0, 1.0, 5.0 );solid_brick( 33.0, 7.0, 1.0, 5.0 );solid_brick( 30.0, 5.0, 5.0, 1.0 );solid_brick( 13.0, 0.0, 21.0, 1.0 );solid_brick( 23.0, 0.0, 1.0, 11.0 );solid_brick( 25.0, 2.0, 3.0, 1.0 );solid_brick( 36.0, 0.0, 15.0, 1.0 );solid_brick( 33.0, 1.5, 1.0, 2.0 );solid_brick( 43.0, -10.5, 1.0, 40.0 );solid_brick( 38.0, -7.5, 1.0, 6.0 );solid_brick( 33.0, -10.0, 21.0, 1.0 );solid_brick( 3.0, -15.0, 1.0, 31.0 );solid_brick( 33.0, -7.0, 1.0, 5.0 );solid_brick( 13.0, -8.0, 1.0, 15.0 );solid_brick( 8.0, -10.0, 9.0, 1.0 );water( 4.0, -7.0, 1.0, 1.0 );water( 5.0, -7.0, 1.0, 1.0 );water( 6.0, -7.0, 1.0, 1.0 );water( 7.0, -7.0, 1.0, 1.0 );water( 8.0, -7.0, 1.0, 1.0 );water( 9.0, -7.0, 1.0, 1.0 );water( 10.0, -7.0, 1.0, 1.0 );water( 11.0, -7.0, 1.0, 1.0 );water( 12.0, -7.0, 1.0, 1.0 );water( 12.0, -6.0, 1.0, 1.0 );water( 11.0, -6.0, 1.0, 1.0 );water( 10.0, -6.0, 1.0, 1.0 );water( 9.0, -6.0, 1.0, 1.0 );water( 8.0, -6.0, 1.0, 1.0 );water( 7.0, -6.0, 1.0, 1.0 );water( 6.0, -6.0, 1.0, 1.0 );water( 5.0, -6.0, 1.0, 1.0 );water( 4.0, -6.0, 1.0, 1.0 );water( 4.0, -5.0, 1.0, 1.0 );water( 5.0, -5.0, 1.0, 1.0 );water( 6.0, -5.0, 1.0, 1.0 );water( 7.0, -5.0, 1.0, 1.0 );water( 8.0, -5.0, 1.0, 1.0 );water( 9.0, -5.0, 1.0, 1.0 );water( 10.0, -5.0, 1.0, 1.0 );water( 11.0, -5.0, 1.0, 1.0 );water( 12.0, -5.0, 1.0, 1.0 );water( 12.0, -4.0, 1.0, 1.0 );water( 11.0, -4.0, 1.0, 1.0 );water( 10.0, -4.0, 1.0, 1.0 );water( 9.0, -4.0, 1.0, 1.0 );water( 8.0, -4.0, 1.0, 1.0 );water( 7.0, -4.0, 1.0, 1.0 );water( 6.0, -4.0, 1.0, 1.0 );water( 5.0, -4.0, 1.0, 1.0 );water( 4.0, -4.0, 1.0, 1.0 );water( 4.0, -3.0, 1.0, 1.0 );water( 5.0, -3.0, 1.0, 1.0 );water( 6.0, -3.0, 1.0, 1.0 );water( 7.0, -3.0, 1.0, 1.0 );water( 8.0, -3.0, 1.0, 1.0 );water( 9.0, -3.0, 1.0, 1.0 );water( 10.0, -3.0, 1.0, 1.0 );water( 11.0, -3.0, 1.0, 1.0 );water( 12.0, -3.0, 1.0, 1.0 );water( 12.0, -2.0, 1.0, 1.0 );water( 11.0, -2.0, 1.0, 1.0 );water( 10.0, -2.0, 1.0, 1.0 );water( 9.0, -2.0, 1.0, 1.0 );water( 8.0, -2.0, 1.0, 1.0 );water( 7.0, -2.0, 1.0, 1.0 );water( 6.0, -2.0, 1.0, 1.0 );water( 5.0, -2.0, 1.0, 1.0 );water( 4.0, -2.0, 1.0, 1.0 );water( 5.0, -1.0, 1.0, 1.0 );water( 4.0, -1.0, 1.0, 1.0 );water( 6.0, -1.0, 1.0, 1.0 );water( 7.0, -1.0, 1.0, 1.0 );water( 8.0, -1.0, 1.0, 1.0 );water( 9.0, -1.0, 1.0, 1.0 );water( 10.0, -1.0, 1.0, 1.0 );water( 11.0, -1.0, 1.0, 1.0 );water( 12.0, -1.0, 1.0, 1.0 );fish(7.070426,-7.4294024,1.0,1.8953298);walky2(14.7,-0.994,1.0,5.0);walky2(18.8,-3.00394,5.0198803,5.0);solid_brick( 6.0, -15.0, 5.0, 1.0 );solid_brick( 25.0, -20.0, 35.0, 1.0 );solid_brick( 23.0, -13.0, 1.0, 5.0 );solid_brick( 33.0, -13.0, 1.0, 5.0 );water( 24.0, -14.0, 1.0, 1.0 );water( 24.0, -13.0, 1.0, 1.0 );water( 24.0, -12.0, 1.0, 1.0 );water( 24.0, -11.0, 1.0, 1.0 );water( 25.0, -11.0, 1.0, 1.0 );water( 25.0, -12.0, 1.0, 1.0 );water( 25.0, -13.0, 1.0, 1.0 );water( 25.0, -14.0, 1.0, 1.0 );water( 26.0, -14.0, 1.0, 1.0 );water( 26.0, -13.0, 1.0, 1.0 );water( 26.0, -12.0, 1.0, 1.0 );water( 26.0, -11.0, 1.0, 1.0 );water( 27.0, -11.0, 1.0, 1.0 );water( 27.0, -12.0, 1.0, 1.0 );water( 27.0, -13.0, 1.0, 1.0 );water( 27.0, -14.0, 1.0, 1.0 );water( 28.0, -14.0, 1.0, 1.0 );water( 28.0, -13.0, 1.0, 1.0 );water( 28.0, -12.0, 1.0, 1.0 );water( 29.0, -11.0, 1.0, 1.0 );water( 29.0, -12.0, 1.0, 1.0 );water( 29.0, -13.0, 1.0, 1.0 );water( 29.0, -14.0, 1.0, 1.0 );water( 30.0, -14.0, 1.0, 1.0 );water( 30.0, -13.0, 1.0, 1.0 );water( 30.0, -12.0, 1.0, 1.0 );water( 30.0, -11.0, 1.0, 1.0 );water( 31.0, -11.0, 1.0, 1.0 );water( 31.0, -12.0, 1.0, 1.0 );water( 31.0, -13.0, 1.0, 1.0 );water( 31.0, -14.0, 1.0, 1.0 );water( 32.0, -14.0, 1.0, 1.0 );water( 32.0, -13.0, 1.0, 1.0 );water( 32.0, -12.0, 1.0, 1.0 );water( 28.0, -11.0, 1.0, 1.0 );water( 32.0, -11.0, 1.0, 1.0 );fish(27.76,-11.0,1.0,-2.0);fish(24.673756,-11.0,1.0,0.0);solid_brick( 23.0, -23.0, 1.0, 5.0 );solid_brick( 20.0, -25.0, 5.0, 1.0 );solid_brick( 40.0, -25.0, 5.0, 1.0 );solid_brick( 38.0, -28.0, 1.0, 5.0 );solid_brick( 23.0, -30.0, 41.0, 1.0 );water( 39.0, -27.0, 1.0, 1.0 );water( 40.0, -27.0, 1.0, 1.0 );water( 41.0, -27.0, 1.0, 1.0 );water( 42.0, -27.0, 1.0, 1.0 );water( 41.0, -26.0, 1.0, 1.0 );water( 40.0, -26.0, 1.0, 1.0 );water( 39.0, -26.0, 1.0, 1.0 );door(3.0, 1.0, 3.0, 9.0);button( 0.0, 10.0 );door(4.0, 9.0, 4.0, 1.0);button( -3.0, 10.0 );walky2(18.0,9.011999,1.0,-5.0);teleporter( 34.0, -25.0 );teleporter( 43.0, -31.0 );water( 42.0, -26.0, 1.0, 1.0 );teleporter( 42.0, -29.0 );teleporter( 34.0, -21.0 );teleporter( 34.0, -29.0 );teleporter( 12.0, -9.0 );teleporter( 45.0, 10.0 );teleporter( -9.0, -8.0 );door(13.0, -10.0, 23.0, -10.0);button( 42.0, -1.0 );door(13.0, -21.0, 13.0, -29.0);button( 39.0, -5.0 );key(0,255,0,18.0,-11.0);invisible_brick( 3.0, -31.0, 1.0, 1.0 );end_block(37.0,-31.0);walky2(24.536255,-38.563744,16.127487,5.0);start_block(-6.0,2.0);invisible_brick( 33.0, -31.0, 1.0, 1.0 );coin( 4.0, -1.0 );coin( 4.0, -2.0 );coin( 5.0, -2.0 );coin( 5.0, -1.0 );coin( 4.0, -7.0 );coin( 7.0, -5.0 );coin( 10.0, -7.0 );coin( 11.0, -4.0 );coin( 8.0, -2.0 );coin( 5.0, -4.0 );coin( -9.0, -7.0 );coin( -9.0, -6.0 );coin( -9.0, -5.0 );coin( -9.0, -4.0 );coin( -9.0, -3.0 );coin( -9.0, -2.0 );coin( -9.0, -1.0 );coin( -9.0, 0.0 );coin( -9.0, 1.0 );coin( -9.0, 2.0 );coin( -9.0, 3.0 );coin( -9.0, 4.0 );coin( -9.0, 4.0 );coin( -9.0, 5.0 );coin( -9.0, 6.0 );coin( -9.0, 7.0 );coin( -9.0, 8.0 );coin( -9.0, 9.0 );coin( -9.0, 10.0 );coin( 12.0, 6.0 );coin( 7.0, 5.0 );coin( 16.0, 3.0 );coin( 17.0, 3.0 );coin( 18.0, 3.0 );coin( 19.0, 3.0 );coin( 28.0, 6.0 );coin( 28.0, 7.0 );coin( 29.0, 7.0 );coin( 29.0, 6.0 );coin( 39.0, 8.0 );coin( 39.0, 3.0 );coin( 35.0, 3.0 );coin( 35.0, 8.0 );coin( 37.0, 6.0 );coin( 37.0, -9.0 );coin( 36.0, -9.0 );coin( 35.0, -9.0 );coin( 34.0, -9.0 );coin( 34.0, -8.0 );coin( 35.0, -8.0 );coin( 36.0, -8.0 );coin( 37.0, -8.0 );coin( 37.0, -7.0 );coin( 36.0, -7.0 );coin( 35.0, -7.0 );coin( 34.0, -7.0 );coin( 34.0, -6.0 );coin( 35.0, -6.0 );coin( 36.0, -6.0 );coin( 37.0, -6.0 );coin( 37.0, -5.0 );coin( 36.0, -5.0 );coin( 35.0, -5.0 );coin( 34.0, -5.0 );invisible_brick( 36.0, -5.0, 1.0, 1.0 );invisible_brick( 37.0, -5.0, 1.0, 1.0 );coin( 24.0, -3.0 );coin( 24.0, -5.0 );coin( 22.0, -1.0 );coin( 21.0, -1.0 );coin( 20.0, -1.0 );coin( 19.0, -1.0 );coin( 18.0, -1.0 );coin( 17.0, -1.0 );coin( 16.0, -1.0 );coin( 15.0, -1.0 );coin( 14.0, -1.0 );coin( 8.0, -14.0 );coin( 8.0, -13.0 );coin( 8.0, -12.0 );coin( 8.0, -11.0 );coin( 7.0, -11.0 );coin( 7.0, -12.0 );coin( 7.0, -13.0 );coin( 7.0, -14.0 );coin( 4.0, -14.0 );coin( 25.0, -14.0 );coin( 32.0, -11.0 );coin( 30.0, -13.0 );coin( 40.0, -13.0 );coin( 41.0, -14.0 );coin( 42.0, -17.0 );coin( 38.0, -17.0 );coin( 37.0, -14.0 );door(33.0, -30.0, 33.0, -20.0);keyed_button(0,255,0,42.0,-11.0);solid_brick( 84.0, 5.0, 11.0, 11.0 );solid_brick( 47.0, 8.0, 1.0, 5.0 );walky2(66.41714,0.01713501,20.96573,-5.0);fish(8.456921,-3.9530745,0.719913,1.6161432);fish(8.573414,-0.613414,0.24533713,2.0);coin( 28.0, -26.0 );coin( 25.0, -26.0 );
coin( 24.0, -24.0 );coin( 25.0, -23.0 );coin( 26.0, -22.0 );coin( 27.0, -22.0 );coin( 28.0, -23.0 );coin( 29.0, -24.0 );coin( 27.0, -25.0 );coin( 8.0, -26.0 );coin( 9.0, -27.0 );coin( 10.0, -27.0 );coin( 11.0, -26.0 );coin( 11.0, -25.0 );coin( 10.0, -24.0 );coin( 9.0, -23.0 );coin( 8.0, -22.0 );coin( 7.0, -23.0 );coin( 6.0, -24.0 );coin( 5.0, -25.0 );coin( 5.0, -26.0 );coin( 6.0, -27.0 );coin( 7.0, -27.0 );coin( 8.0, -31.0 );coin( 8.0, -32.0 );coin( 8.0, -33.0 );coin( 8.0, -34.0 );coin( 8.0, -35.0 );coin( 8.0, -36.0 );coin( 8.0, -37.0 );coin( 8.0, -38.0 );coin( 8.0, -39.0 );coin( 7.0, -39.0 );coin( 7.0, -38.0 );coin( 7.0, -36.0 );coin( 7.0, -37.0 );coin( 7.0, -34.0 );coin( 7.0, -35.0 );coin( 7.0, -33.0 );coin( 7.0, -32.0 );coin( 7.0, -31.0 );coin( 6.0, -31.0 );coin( 6.0, -32.0 );coin( 6.0, -33.0 );coin( 6.0, -34.0 );coin( 6.0, -35.0 );coin( 6.0, -36.0 );coin( 6.0, -37.0 );coin( 6.0, -38.0 );coin( 6.0, -39.0 );coin( 5.0, -39.0 );coin( 5.0, -38.0 );coin( 5.0, -37.0 );coin( 5.0, -36.0 );coin( 5.0, -35.0 );coin( 5.0, -34.0 );coin( 5.0, -33.0 );coin( 5.0, -32.0 );coin( 5.0, -31.0 );coin( 4.0, -31.0 );coin( 4.0, -32.0 );coin( 4.0, -33.0 );coin( 4.0, -34.0 );coin( 4.0, -35.0 );coin( 4.0, -36.0 );coin( 4.0, -37.0 );coin( 4.0, -38.0 );coin( 4.0, -39.0 );coin( 3.0, -39.0 );coin( 3.0, -38.0 );coin( 3.0, -37.0 );coin( 3.0, -36.0 );coin( 3.0, -35.0 );coin( 3.0, -34.0 );coin( 3.0, -33.0 );coin( 3.0, -32.0 );coin( 3.0, -31.0 );teleporter( 44.0, -20.0 );teleporter( 23.0, -51.0 );teleporter( 15.0, -22.0 );teleporter( 41.0, 8.0 );key(255,0,0,20.0,-11.0);door(14.0, -15.0, 14.0, -20.0);keyed_button(255,0,0,12.0,-14.0);walky2(10.0,9.0,0.4430234,-5.0);walky2(9.0,9.0,0.36859542,-5.0);
  }
}


//ideas
//teleporter which makes it so you skip a problem.
//Numbers in a jail so that they can't escape.
//math problems.  
