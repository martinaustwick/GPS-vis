String source = "start_casa_id";
String dest = "end_casa_id";
//duration in seconds
String dur = "duration_s";

float lonStart;
float lonEnd;
float latStart;
float latEnd;



public class dataTalker {

  String placeString = "nyc";
  
  String database = "Gustavo";
  String table;
  String server = "jdbc:mysql://localhost:3306/";
  String username = "reader";
  String password = "reader";
  
  //table containing the locations of stands
  String locations = "bikeflow_" + placeString + "_namelocation";
  //table containing routes
  String routes = "bikeflow_" + placeString + "_routing";
  //edges table
  String edges = "bikeflow_" + placeString;

  private java.sql.Connection con;
  private java.sql.Statement stmt;
  
  int zero = 0;
  int last;

  public dataTalker(String s) {
    server = s;
    checkConnect();
  }

  public dataTalker() {
    checkConnect();
  }

  public void checkConnect() {
    try {
      //Register the JDBC driver for MySQL.
      Class.forName("com.mysql.jdbc.Driver");
      con = DriverManager.getConnection(server + database, username, password);
      stmt = con.createStatement();
      con.close();
    }
      catch( Exception e ) {
      e.printStackTrace();
    }//en
  }

  public void connect() {
      try {
        con = DriverManager.getConnection(server + database , username, password);
        stmt = con.createStatement();
      }
      catch( Exception e ) {
        e.printStackTrace();
        println("Failed to connect");
      }
  }
  
  public void close(){
      try {
        con.close();
      }
      catch( Exception e ) {
        e.printStackTrace();
        System.out.println("Could not close");
      }
  
  }
  
  public ResultSet sendCommand(String command){
      ResultSet rs;
      try{
            rs = stmt.executeQuery(command);
            return rs;
      }
      catch( Exception e ) {
          //e.printStackTrace();
          System.out.println("Statement failed in SENDCOMMAND: " + command);
          return null;
      }

  }
  
  public ResultSet connectAndSend(String command){
        connect();
        ResultSet rs = sendCommand(command);
        //close();
        return rs;
  }

   
   public float[] getLims(String x, String table)
   {
       locations  = table;
       connect();
       float lims[] = new float[2];
       String s = "SELECT min(" + x  + "), max(" + x + ") from " + locations;
       ResultSet rs = sendCommand(s);
       try
        {
            while(rs.next())
            {
                  lims[0] = rs.getFloat(1);
                  lims[1] = rs.getFloat(2);

            }
            
            float lonMid = 0.5*(lims[0] + lims[1]);
            float lonhw = 0.5*(lims[1] - lims[0]);

            
            lonStart = lonMid - 1.25*lonhw;
            lonEnd = lonMid + 1.25*lonhw;
            
            println(lims);
        }
        catch( Exception e )
        {
            System.out.println("Statement failed in getLims:");
            println(s);
        }
       
       
       return lims;
       
   }
   
   public float[] getLims(String x, String y, String table)
   {
       locations  = table;
       connect();
       float lims[] = new float[4];
       String s = "SELECT min(" + x  + "), max(" + x + "), min(" + y + "), max(" + y + ") from " + locations;
       ResultSet rs = sendCommand(s);
       try
        {
            while(rs.next())
            {
                  lims[0] = rs.getFloat(1);
                  lims[1] = rs.getFloat(2);
                  lims[2] = rs.getFloat(3);
                  lims[3] = rs.getFloat(4);
            }
            
            float lonMid = 0.5*(lims[0] + lims[1]);
            float lonhw = 0.5*(lims[1] - lims[0]);
            
            float latMid = 0.5*(lims[3] + lims[2]);
            float lathw = 0.5*(lims[3] - lims[2]);
            
            lonStart = lonMid - 1.25*lonhw;
            lonEnd = lonMid + 1.25*lonhw;
            latStart = latMid - 1.25*lathw;
            latEnd = latMid + 1.25*lathw;
            
            
            println(lims);
        }
        catch( Exception e )
        {
            System.out.println("Statement failed in getLims:");
            println(s);
        }
       
       
       return lims;
       
   }
  

}
