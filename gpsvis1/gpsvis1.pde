import java.sql.*;

gpsTalker DT;
float [] limits;
float  [] tlims;

float t;
int tinc = 30;
//seconds after midnight
int toffset = int(4.5*3600);

int ellipseSize = 5;
int ellipseAlpha = 10;

boolean screenGrab = true;
boolean getLimits = false;

//set color for each track
boolean setC = true;
HashMap<String, PVector> trackCols = new HashMap<String, PVector>();

//String dataTable1 = "couriers";
String dataTable1 = "normals_clean";

//hsb
PVector bg = new PVector(0,0,255);
PVector fg = new PVector(0, 0, 0);

float opacity = 4;

int w = 1920;
int h = 1080;

void setup()
{
    
    DT = new gpsTalker();
    if(getLimits) limits = DT.getLims("E", "N", dataTable1);
    else setLimits();
    //println(limits);
    //tlims = DT.getLims("TO_SECONDS(Timestamp) - " + toffset, "gps_test");
    //t = tlims[0];
    t=toffset;
    println(t);
    
    colorMode(HSB);
    background(bg.x, bg.y, bg.z);
        
    size(w, h);
    smooth();
    frameRate(90);
    
    
}

void setLimits()
{
    limits = new float[4  ];
    limits[0] =  433634.318228391;
    limits[1] =  449812.843228392;
    limits[2] = 4470402.85;
    limits[3] = 4480833.11;
    
    //assumes bng and not latlon
    float dx = limits[1]-limits[0];
    float dy = limits[3]-limits[2];
    
    
    if((16*dy/9)>dx)
    {
        h = 1080;
        w = int(h*dx/dy);
    }
    else
    {
        w = 1920;
        h = int(w*dy/dx);
        
    }
    
}

void draw()
{
    //ArrayList<PVector> points = DT.getArrayList("E", "N", "gps_test", " WHERE (TO_SECONDS(Timestamp) - TO_SECONDS(" + startdate + ") <" + t + " AND TO_SECONDS(Timestamp) + " + tinc + ">" + t);
    //ArrayList<PVector> points = DT.getArrayList("E", "N", dataTable1, " WHERE TIME_TO_SEC(Timestamp) <= " + t + " AND " + (t-tinc) + " < TIME_TO_SEC(Timestamp)");
    ArrayList<PVector> points = DT.getArrayList("E", "N", dataTable1, " WHERE TIME_TO_SEC(Timestamp) <= " + t + " AND " + (t-tinc) + " < TIME_TO_SEC(Timestamp)");

    //ArrayList<PVector> points = DT.getArrayList("E", "N", dataTable1, " WHERE TIME_TO_SEC(Timestamp) = " + t);
    ArrayList<String> ids = new ArrayList<String>();
    if(setC)
    {
        //ids = DT.getInfo("Track_ID", dataTable1, " WHERE TIME_TO_SEC(Timestamp) <= " + t + " AND " + (t-tinc) + " < TIME_TO_SEC(Timestamp)");
        ids = DT.getInfo("name", dataTable1, " WHERE TIME_TO_SEC(Timestamp) <= " + t + " AND " + (t-tinc) + " < TIME_TO_SEC(Timestamp)");
    }
    //noStroke();
    
    fill(bg.x, bg.y, bg.z, opacity);
    rect(0,0,width, height);
    
//    stroke(0);
//    noFill();
    stroke(0);
    for(int i = 0; i<points.size(); i++)
    {
        PVector p = points.get(i);
        float x = map(p.x, limits[0], limits[1], 0, width);
        float y = map(p.y, limits[2], limits[3], height, 0);
        //println(x + " " + y);
        //
        
        PVector v = new PVector(0,0,0);
        
        if(setC)
        {
            String currentID = ids.get(i);
            if(trackCols.get(currentID)==null)
            {
                trackCols.put(currentID, new PVector(random(255), 255, 150));
            }
            
            v = trackCols.get(currentID).get();
        }
        
        
        
        noFill();
        stroke(v.x, v.y, v.z);
        point(x,y);
        
        noStroke();
        fill(v.x, v.y, v.z,ellipseAlpha);
        ellipse(x, y, ellipseSize, ellipseSize);
        fill(v.x, v.y, v.z,ellipseAlpha/4);
        ellipse(x, y, ellipseSize*2, ellipseSize*2);
        
    }
    
    //if(t%60==0) println(int(t)/3600 + ":" + int(t%3600)/60);
    
    
    drawClock();
    
    t+=tinc;
    if(t>24*3600)
    {
        println("break");
        noLoop();
    }
    else
    {
        if(screenGrab) saveFrame("images/####.jpg");
    }
    
}

void drawClock()
{
    int h = int(t)/3600;
    int m = int(t-(h*3600))/60;
    int s = int(t)%60;
    fill(bg.x, bg.y, bg.z);
    rect(0, height-20, width, 20);
    fill(fg.x, fg.y, fg.z);
    text(nf(h,2,0) + ":" + nf(m,2,0) + ":" + nf(s,2,0), width/2 - 50, height-10);
    
}
