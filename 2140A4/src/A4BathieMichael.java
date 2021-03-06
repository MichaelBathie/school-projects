/**
 * class A4BathieMichael
 * 
 * COMP 2140 SECTION A1
 * INSTRUCTOR   Helen Cameron
 * ASSIGNMENT   #4
 * @author      Michael Bathie, 7835010
 * @version     November 23rd, 2018
 * 
 * PURPOSE: Compute Lenert programs
 *
 **/

import java.io.FileReader;
import java.io.FileNotFoundException;
import java.util.Scanner;
import java.util.StringTokenizer;

public class A4BathieMichael 
{   
    public static void main(String[] args)
    {
        A4BathieMichael assignment = new A4BathieMichael();
        
        assignment.run();
    }
    /*
        just run the program
    */
    public void run()
    {
        Table t = new Table();
        print(t);
    }
    
    /*
        file opening, closing and printing
    */
    public void print(Table s)
    {
        //hold the error comments
        String error;
        //how many lenert programs
        int lenertCounter = 1;
        //count how many q's
        int qCounter = 0;
        //get file name input
        Scanner textFileName = new Scanner(System.in);
        String fileName;
        Scanner in = null;
            
        System.out.println("COMP 2140 Assignment 4: Executing Lenert Programs\n"
                + "----------------------------------------------------\n\n"
                + "Enter the input file name (.txt files only):");
        
        fileName = textFileName.next();
            
        try
        {
            in = new Scanner(new FileReader(fileName));
        }
        catch(FileNotFoundException e)
        {
            System.out.println(fileName+" was not found.");
            e.printStackTrace();
        }
        
        //how many lenert programs in total
        int size = in.nextInt();
        //skip a line
        String line = in.nextLine();
        line = in.nextLine();
        //while we haven't reached the last q
        while(qCounter < size)
        {
            error = "";
            System.out.println("\n\nLenert Program "+ lenertCounter +"\n"
                    + "-------------\n"
                    + "Error messages:");

            while(!line.equals("Q") && in.hasNextLine())
            {
                if(line.length() != 0)
                {
                    //add on the error messages
                    error += s.compute(line);
                   
                }
                line = in.nextLine();
            }
            //print everything
            System.out.println(error+"\n");
            System.out.println("Final values of the variables:\n");
            s.iT();
            System.out.println();
                
            //iterate the counters
            qCounter++;
            lenertCounter++;
            if(in.hasNextLine())
            {
                line = in.nextLine();
            }
            //reset the table
            s = new Table();
        }
        //close file
        in.close();
    }
    
    /*
        table class
    */
    class Table
    {
        private Node root;
        
        public Table()
        {
            root = null;
        }
        
        /*
            inorderTraveral driver method
        */
        public void iT()
        {
            if(root != null)
            {
                root.inorderTraversal();
            }
        }
       
        
        /*
            Search for a specific string in the tree.
        */
        public varRec search(String s)
        {
            varRec item = null;
            Node curr = root;
            boolean found = false;
            
            while(curr != null && !found)
            {
                if(s.compareTo(curr.record.name) == 0)
                {
                    found = true;
                    item = new varRec(curr.record.val,curr.record.name);
                }
                else if(s.compareTo(curr.record.name) < 0)
                {
                    curr = curr.left;
                }
                else
                {
                    curr = curr.right;
                }
            }
            
            return item;
        }
        
        /*
            Insert a node into the tree with a given
            value and name.
        */
        public void insert(int value, String key)
        {
            if(root == null)
            {
                root = new Node(value, key);
            }
            else
            {
                Node curr = root;
                Node prev = null;
                
                while(curr != null && !curr.record.name.equals(key))
                {
                    prev = curr;
                    if(key.compareTo(curr.record.name) < 0)
                    {
                        curr = curr.left;
                    }
                    else
                    {
                        curr = curr.right;
                    }
                }
                //if the name is found in the table change its value
                if(curr != null && curr.record.name.equals(key))
                {
                    curr.record.val = value;
                }
                
                else if(curr == null)
                {
                    if(key.compareTo(prev.record.name) < 0)
                    {
                        prev.left = new Node(value, key);
                    }
                    else
                    {
                        prev.right = new Node(value, key);
                    }
                }
            }
        }
        /*
            is this an integer
        */
        public boolean isInteger(String s)
        {
            boolean integer = false;
            
            //take in a string and try to parse it into an int
            try
            {
                //if it works then it's an int
                Integer.parseInt(s);
                integer = true;
            }
            //if not then it's not an int
            catch(NumberFormatException e)
            {

            }
            return integer;
        }
        
        /*
            puts together the entire tree and computer all of the mathematics.
            Note that we only ever deal with 3 or 5 token lines.
        */
        public String compute(String s)
        {
            //returns the error messages
            String message = "";
            //tokenize the strings
            StringTokenizer tok = new StringTokenizer(s);
            //how many tokens are we dealing with
            int size = tok.countTokens();
            //create an integer value for each spot in the array.
            int result = 0;
            int variable = 0;
            int equals = 1;
            int leftVal = 2;
            int operation = 3;
            int rightVal = 4;
            String[] line = null;
            
            if(size == 3)
            {
                //put each token in the array
                line = new String[size];
                for(int i = 0; i < size; i++)
                {
                    line[i] = tok.nextToken();
                }
                //check if computing half contains an integer
                if(isInteger(line[leftVal]))
                {
                    //it does so set it.
                    result = Integer.parseInt(line[leftVal]);
                }
                else
                {
                    //it doesnt so check if there's an error
                    if(search(line[leftVal]) == null)
                    {
                        message = "Invalid input line: variable "+line[leftVal]+" used before its declaration in \""+line[variable]+" "+line[equals]+" "+line[leftVal]+"\"\n";
                    }
                    else
                    {
                        //if not then get the val from your table
                        result = search(line[leftVal]).val;
                    }
                }
            }
            //same as before just with a few more steps
            else if(size == 5)
            {
                //you have to check for two computing values this time
                int op1 = 0;
                int op2 = 0;
                line = new String[size];
                for(int i = 0; i < size; i++)
                {
                    line[i] = tok.nextToken();
                }
                //first value
                if(isInteger(line[leftVal]))
                {
                    op1 = Integer.parseInt(line[leftVal]);
                }
                else
                {
                    if(search(line[leftVal]) == null)
                    {
                        message = "Invalid input line: variable "+line[leftVal]+" used before its declaration in \""+line[variable]+" "+line[equals]+" "+line[leftVal]+"\"\n";
                    }
                    else
                    {
                        op1 = search(line[leftVal]).val;
                    }
                }
                //second value
                if(isInteger(line[rightVal]))
                {
                    op2 = Integer.parseInt(line[rightVal]);
                }
                else
                {
                    if(search(line[rightVal]) == null)
                    {
                        message = "Invalid input line: variable "+line[rightVal]+" used before its declaration in \""+line[variable]+" "+line[equals]+" "+line[leftVal]+" "+line[operation]+" "+line[rightVal]+"\"\n";
                    }
                    else
                    {
                        op2 = search(line[rightVal]).val;
                    }
                }
                //check for the operation and compute accordingly
                switch(line[operation])
                {
                    case "+" :
                        result = op1 + op2;
                        break;
                    case "-" :
                        result = op1 - op2;
                        break;
                    case "*" :
                        result = op1 * op2;
                        break;
                    case "/" :
                        result = op1 / op2;
                        break;
                    default :
                }
            }
            //insert the resulting value with the name of the variable
            insert(result, line[variable]);
            //return the error message
            return message;
        }
        
        
        /*
            node class
        */
        private class Node
        {
            //contains a variable record
            public varRec record;
            public Node left;
            public Node right;
            
            public Node(int i, String s)
            {
                record = new varRec(i, s);
                left = null;
                right = null;
            }
            
            /*
                inorder traversal helper method
            */
            public void inorderTraversal()
            {
                if(left != null)
                {
                    left.inorderTraversal();
                }
                System.out.println(record.name + " = " + record.val);
                if(right != null)
                {
                    right.inorderTraversal();
                }
            }
            
        }
        
        /*
            variable record class, not much going on here
        */
        private class varRec
        {
            public int val;
            public String name;
            
            public varRec(int v, String s)
            {
                val = v;
                name = s;
            }
        }
    }
}