import java.sql.*;

gpsTalker DT;
float [] limits;
float  [] tlims;

float t;
int tinc =1;
float toffset = 63531993600.0;

void setup()
{
    size(800, 800);
    DT = new gpsTalker();
    limits = DT.getLims("E", "N", "gps_test");
    tlims = DT.getLims("TO_SECONDS(Timestamp) - " + toffset, "gps_test");
    t = tlims[0];
    println(t);
    background(255);
}

void draw()
{
    //ArrayList<PVector> points = DT.getArrayList("E", "N", "gps_test", " WHERE (TO_SECONDS(Timestamp) - TO_SECONDS(" + startdate + ") <" + t + " AND TO_SECONDS(Timestamp) + " + tinc + ">" + t);
    
    ArrayList<PVector> points = DT.getArrayList("E", "N", "gps_test", " WHERE (TO_SECONDS(Timestamp) - " + toffset + ") =" + t);

    noStroke();
    
    fill(255,1);
    rect(0,0,width, height);
    
    fill(0);
    for(PVector p: points)
    {
        float x = map(p.x, limits[0], limits[1], 0, width);
        float y = map(p.y, limits[2], limits[3], height, 0);
        //println(x + " " + y);
        ellipse(x, y, 2, 2);
    }
    //println(t);
    t+=tinc;
    
    if(t>tlims[1]) println("zingo");
}
