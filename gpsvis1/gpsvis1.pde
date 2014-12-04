import java.sql.*;

/*
    Drawing GPS-like data from a database
    V1.0 colour by user
    configure this to draw data from multiple tables?
*/

gpsTalker DT;
float [] limits;
float  [] tlims;

float t;
int tinc = 30;
//seconds after midnight
int toffset = int(6.5*3600);

int ellipseSize = 10;
int ellipseAlpha = 10;
float pointSize = 3;

float opacity = 12;

boolean screenGrab = true;
boolean getLimits = false;
 
//set color for each track
boolean setC = false;
HashMap<String, PVector> trackCols = new HashMap<String, PVector>();


String []  dataTables = {"normals_clean", "couriers"};

//hsb
PVector bg = new PVector(0,0,0);
PVector fg = new PVector(0, 0, 255);


//int w = 1920;
//int h = 1080;

int w = 1280;
int h = 720;


PImage bgImage;

int fontSize = 50;

void setup()
{
    
    DT = new gpsTalker();
    if(getLimits) limits = DT.getLims("E", "N", dataTables[0]);
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
    
    bgImage = loadImage("BackgroundMap HD3.jpg");
    bgImage.resize(width,height);
    //actually just brighten this up a bit
    bgImage = contrast(bgImage);
    image(bgImage,0,0);
    bgImage = transparentise(bgImage, opacity, 1);
    
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

PImage transparentise(PImage p, float alpha, float brightenTheCorners)
{
    PImage pout = createImage(p.width, p.height, ARGB);
    pout.loadPixels();
  
    p.loadPixels();
    for(int i = 0; i<p.pixels.length; i++)
    {
        pout.pixels[i] = color(hue(p.pixels[i]), 0, brightenTheCorners*brightness(p.pixels[i]), alpha);
    }
    pout.updatePixels();
    return pout;
}

PImage contrast(PImage p)
{
    PImage pout = createImage(p.width, p.height, ARGB);
    pout.loadPixels();
  
    p.loadPixels();
    float mini = 255;
    float maxi = 0;
    for(int i = 0; i<p.pixels.length; i++)
    {
        if(mini>brightness(p.pixels[i])) mini = brightness(p.pixels[i]);
        if(maxi<brightness(p.pixels[i])) maxi = brightness(p.pixels[i]);
    }
    for(int i = 0; i<p.pixels.length; i++)
    {
        pout.pixels[i] = color(hue(p.pixels[i]), saturation(p.pixels[i]), map(brightness(p.pixels[i]), mini,maxi,0,255),255);
    }
    pout.updatePixels();
    return pout;
}

void draw()
{
//    fill(bg.x, bg.y, bg.z, opacity);
//    rect(0,0,width, height);
    image(bgImage,0,0);

    drawType();
    
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



void drawType()
{
    strokeWeight(pointSize);
    /*
        Draw all of the current cyclist types
        Assumes a comment format
    */
    
    for(int d =0; d<dataTables.length; d++)
    {
        ArrayList<PVector> points = DT.getArrayList("E", "N", dataTables[d], " WHERE TIME_TO_SEC(Timestamp) <= " + t + " AND " + (t-tinc) + " < TIME_TO_SEC(Timestamp)");
    
        //ArrayList<PVector> points = DT.getArrayList("E", "N", dataTable1, " WHERE TIME_TO_SEC(Timestamp) = " + t);
        ArrayList<String> ids = new ArrayList<String>();
        if(setC)
        {
            //ids = DT.getInfo("Track_ID", dataTable1, " WHERE TIME_TO_SEC(Timestamp) <= " + t + " AND " + (t-tinc) + " < TIME_TO_SEC(Timestamp)");
            ids = DT.getInfo("name", dataTables[d], " WHERE TIME_TO_SEC(Timestamp) <= " + t + " AND " + (t-tinc) + " < TIME_TO_SEC(Timestamp)");
        }
        //noStroke();
        
        
        

       PVector v = new PVector(255*d/dataTables.length,255,120);

        for(int i = 0; i<points.size(); i++)
        {
            PVector p = points.get(i);
            float x = map(p.x, limits[0], limits[1], 0, width);
            float y = map(p.y, limits[2], limits[3], height, 0);
            //println(x + " " + y);
            //
            
            //default color vector will be according to type
            
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
    }
}

void drawClock()
{
    int h = int(t)/3600;
    int m = int(t-(h*3600))/60;
    int s = int(t)%60;
    fill(bg.x, bg.y, bg.z);
    rectMode(CENTER);
    rect(width/2, height-(0.5*fontSize)-5, 6*fontSize, fontSize+10);
    fill(fg.x, fg.y, fg.z);
    textSize(fontSize);
    text(nf(h,2,0) + ":" + nf(m,2,0) + ":" + nf(s,2,0), (width/2) - (2.2*fontSize), height-10);
//    stroke(255,255,255);
//    strokeWeight(10);
//    point(width/2, height-(fontSize*0.5));
    
}
