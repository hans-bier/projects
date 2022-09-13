import java.awt.EventQueue;
import java.awt.Graphics;
import java.awt.Graphics2D;
import javax.swing.JFrame;
import javax.swing.JPanel;
import java.awt.Color;
import java.io.File;
import java.util.Scanner;
import java.io.IOException;
import java.util.Random;


class Drawer extends JPanel {

    private static final long serialVersionUID = 1L;
    private JFrame window = new JFrame();
    
    private static String map = " "; // instantiating a variable for the file name
    private static int[][] grid;     // instantiating a variable for the matrix
    
    
    public Drawer() { 	
    	int row = retRow(map); // getting the row with retRow method
    	int col = retCol(map); // getting the column with retCol method
   
    	grid = MapDataDrawer(map, row, col); // using MapDataDrawer method to define the 'grid' variable
    	
        initUI();
    }

    
    private void initUI() {
        window.add(this);
        window.setTitle("Elevation");
        window.setSize(retCol(map),retRow(map)); // setting the window size to the size of the column and row
        window.setLocationRelativeTo(null);
        window.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        window.setVisible(true);
    }

    
    @Override
    public void paintComponent(Graphics g) {
        super.paintComponent(g);
        drawMap(g);
        
        int lowrow = 0; // variable for the lowest elev path row
        int change1 = drawLowestElevPath(g, 0); // first change to be compared
        int change2 = change1; // second change to be compared
         
        g.setColor(new Color(255,0,0)); // setting the color to red
        
        // for loop for drawing the paths, and finding the best path
        for(int z = 1; z < grid.length; z++) {
        	change1 = drawLowestElevPath(g, z);
        	if(change1 < change2) {
        		change2 = change1;
        		lowrow = z;
        	} // end if
        } // end for
       
        
        g.setColor(new Color(0, 255, 0)); // setting color to green
        drawLowestElevPath(g, lowrow); // drawing the best path in green
    }
   
    
    public static int retRow(String name) { // starting build of retRow method
    	
    	int ind1 = name.indexOf("x"); // getting first index   	
    	int ind2 = name.indexOf("."); // getting second index
    	
    	int row = Integer.valueOf(name.substring(ind1+1, ind2)); // using the indices to get the integer
    															 // value of the row
    	
    	return row; // returning the row value
    	
    }// end retRow method
    
    
    public static int retCol(String name) {	//starting build of retCol method
    	
    	int ind1 = name.indexOf("_"); // getting first index
    	int ind2 = name.indexOf("x"); // getting second index
    	
    	int col = Integer.valueOf(name.substring(ind1+1, ind2)); // using the indices to get the integer
    															 // value of the column
    	
    	return col; // returning the column value   	
    	
    }// end retCol method
    
    
    public static int[][] MapDataDrawer(String filename, int rows, int cols) { // starting build of MapDataDrawer method
    	
    	int[][] matrix = new int[rows][cols]; // creating an empty matrix
    	
    	try{
    		File data     = new File(filename); // referencing our file 
    		
    		Scanner sc    = new Scanner(data); // creating a scanner for file 

    		
    		int num = 0; // variable for holding the values of the data
    		
    		// nested for loops for filling our array in row major order
    		for(int i = 0; i < matrix.length; i++) {						
    			for(int j = 0; j < matrix[0].length; j++) {
    				num = sc.nextInt();
    				matrix[i][j] = num;
    				
    			} // end inner for loop
    			   			
    		} // end for outer loop
    		    		
    		sc.close(); // closing scanner
    	
    	} // end try
    	catch(IOException ioe) {
    		System.out.println(ioe.getMessage());
    		}// end catch
    	
    	return matrix; // returning the matrix
    	
    }// end MapDataDrawer method
    
    public static int findMax(int[][] matrix) { // starting build of method findMax
		
		int max = matrix[0][0]; // defining the first number of our matrix to be 
								// compared and changed as needed in the loops below
		
		//outer and inner for loops for finding largest value
		for(int i = 0; i < matrix.length; i++) {
			for(int j = 0; j < matrix[i].length; j++) {
				
				if(matrix[i][j] > max) {
					max = matrix[i][j];
				} // end if statement
				
			} // end inner for loop
		} // end outer for loop
		
		
		return max; // returning the maximum number
		
	} // end findMax method

	
	public static int findMin(int[][] matrix) { // starting build of method findMin
		
		int min = matrix[0][0]; // defining the first number of our matrix to be
								// compared and changed as needed in the loops below
		
		// outer and inner for loops for finding smallest value
		for(int i = 0; i < matrix.length; i++) {
			for(int j = 0; j < matrix[i].length; j++) {
				
				if(matrix[i][j] < min) {
					min = matrix[i][j];
				} // end if statement
				
			} // end inner for loop		
		} // end outer for loop
		
		
		return min; // returning minimum number
		
	} // end findMin method
	
	
	public static int drawLowestElevPath(Graphics g, int row) { // starting build of drawLowestElevPath
			
		Graphics2D g2d = (Graphics2D) g;
		
		int change = 0; // defining a variable to hold the value of the elevation change
		int one; // <--- defining variables to hold the change in elev value 
		int two; // 	 to determine where we should take a "step" in our
		int three; // <-- path
		
		int ran = 0; // a variable to hold our random values in the case elev change values are equal
		Random r = new Random();  // a variable of random type to define the variable above
		
		// for loop for drawing the path
		for(int i = 0; i < grid[0].length-1; i++) {	
			
			if(row == 479) {
				two = Math.abs(grid[row][i] - grid[row][i+1]);     // two is a step fwd
				
				three = Math.abs(grid[row][i] - grid[row-1][i+1]); // three is a step fwd and up
				
				if(three < two) {
					g.fillRect(i+1, row-1, 1, 1);	
					change = change + three;
					row = row - 1;
				} // end if
				
				else if(two < three) {
					g.fillRect(i+1, row, 1, 1);
					change = change +two;
				} // end else if
				
				else if(three == two) {
					g.fillRect(i+1, row, 1, 1);
				} // end else if	
			} // end if
			
			else if(row >=1) {
				one = Math.abs(grid[row][i] - grid[row+1][i+1]); // one is a step fwd and down
				
				two = Math.abs(grid[row][i] - grid[row][i+1]); // two is a step fwd
			
				three = Math.abs(grid[row][i] - grid[row-1][i+1]); // three is a step fwd and up
				
				
				if(one < two && one < three) {
					g.fillRect(i+1, row+1, 1, 1);
					change = change + one;
					row = row + 1;
				} // end if
		
				else if(two < one && two < three) {
					g.fillRect(i+1, row, 1, 1);
					change = change + two;
				} // end else if
			
				else if(three < one && three < two) {
					g.fillRect(i+1,row-1, 1, 1);
					change = change + three;
					row = row - 1;
				} // end else if
				
				else if(three==two) {
					g.fillRect(i+1, row, 1, 1);
				} // end else 
				else if(two==one){
					g.fillRect(i+1, row, 1, 1);
				} // end else if

				else if(one==three){
					ran = r.nextInt(2);
					if(ran == 0) {
						g.fillRect(i+1, row, 1, 1);
					}// end if
					
					else {
						g.fillRect(i+1, row-1, 1, 1);
						row = row - 1;
					} // end else
				} // end else if
						
			} // end else if
						
			else {
				one = Math.abs(grid[row][i] - grid[row+1][i+1]);
				
				two = Math.abs(grid[row][i] - grid[row][i+1]);
				
				if(one < two) {
					g.fillRect(i+1, row+1, 1, 1);
					change = change + one;
					row = row + 1;
				} // end if
				
				if(two < one) {
					g.fillRect(i+1, row, 1, 1);
					change = change + two;
				} // end if
				
				if(one == two) {
					g.fillRect(i+1, row, 1, 1);
				} // end if
			} // end else
		} // end for loop

		
		return change; // returning the change
		
		
	} // end drawLowestElevPath method
    
    private void drawMap(Graphics g) {

        /*
            RGB Colors:
            ================================================
            Black       => (0, 0, 0)        => low elevation
            Mid Grey    => (128, 128, 128)  => mid elevation
            White       => (255, 255, 255)  => high elevation

            Grey Scale colors are scaled in matching set of 3 numeric values
        */

        Graphics2D g2d = (Graphics2D) g;
        
        int max = findMax(grid); // getting the max value with findMax method
    	int min = findMin(grid); // getting the min value with findMin method
        
        int c = 0; // defining a variable to hold the color value
   
        // nested for loops for drawing our map
        for(int i = 0; i < grid.length; i++) {
        	for(int j = 0; j < grid[0].length; j++) {
        		
        		c = ((grid[i][j]-min)*255/(max-min)); // determining the grey scale value
        		
        		g.setColor(new Color(c, c, c)); // setting the color to the grey scale value 
        										// determined above
        		g.fillRect(j, i, 1, 1); // filling the rectangle for the interval
        		
        	}// end inner for
        }// end outer for
        
    }// end drawMap
    
    
    public static void main(String[] args) {
    	// retrieving our files name, and an if else in the case the user doesn't enter anything
    	if(args.length != 1) {
    		System.out.println("Error, please enter valid file name as a cmd line arg.");
    	} // end if
    	else {
    		map = args[0]; // defining our 'map' variable as the user input 
   		}// end else

        EventQueue.invokeLater(new Runnable() {
            @Override
            public void run() {
                Drawer ex = new Drawer();
                ex.setVisible(true);
            }
        });
    } // end main
} // end class
