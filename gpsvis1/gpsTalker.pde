public class gpsTalker extends dataTalker
{
    ArrayList<PVector> getArrayList(String x, String y, String tabler, String condition)
    {
        ArrayList<PVector> al = new ArrayList<PVector>();
      
        String s = "Select "  + x + "," + y +  " from " + tabler + " " + condition;
        println(s);
        connect();
        ResultSet rs = sendCommand(s);
        
        try
        {
            while(rs.next())
            {
                float sx = rs.getFloat(x);
                float sy = rs.getFloat(y);
                al.add(new PVector(sx,sy));
            }
            
        }
        catch( Exception e ){println("Statement failed in getArrayList: " + s);}
        close();
        return al;
    }
    
    ArrayList<String> getInfo (String infoCol, String tabler, String condition)
    {
        ArrayList<String> sal = new ArrayList<String>();
      
        String s = "Select "  + infoCol +  " from " + tabler + " " + condition;
        //println(s);
        connect();
        ResultSet rs = sendCommand(s);
        
        try
        {
            while(rs.next())
            {
                String sout = rs.getString(infoCol);
                sal.add(sout);
            }
            
        }
        catch( Exception e ){println("Statement failed in getArrayList: " + s);}
        close();
        return sal;
    }
}
