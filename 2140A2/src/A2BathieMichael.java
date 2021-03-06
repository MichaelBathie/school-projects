/*
    * A2BathieMichael
    
    * COMP 2140 SECTION A01
    * INSTRUCTOR: Helen Cameron
    * ASSIGNMENT #2
    * AUTHOR: Michael Bathie, 7835010
    * October 25th, 2018

    * PURPOSE: The purpose of this program is to read in a file,
      take its contents as input, and implement the instructions
      into a circular linked list (with a dummy node). The instructions
      can include: inserting and deleting nodes, taking the union and
      difference of sets, and printing the list.
*/


import java.io.FileReader;
import java.io.FileNotFoundException;
import java.util.Scanner;

public class A2BathieMichael 
{
    /*
        main
    */
    public static void main(String[] args)
    {
        Set.test();  
    }
    /*
        Creates a new set and performs operations
        on a set
    */
    static class Set
    {
        private Node top  = null;
        
        /*
            Create a new circular linked list
        */
        public Set()
        {
            //create a dummy node.
            top = new Node( Integer.MIN_VALUE, null );
            //set the dummy node to point back at top.
            top.setLink( top );
        }
        
        /*
            Insert each new node in ascending order.
            Don't insert the node if a pre existing
            node already has the same item.
        */
        public void orderedInsert( int newItem )
        {
            Node curr = top.link;
            Node prev = top;
            
            //while the correct spot hasn't been found and
            //we're not back at the start.
            while( curr.data < newItem && curr != top )
            {
                //iterate through
                prev = curr;
                curr = curr.link;
            }
            //if we don't already have that item
            if(curr.data != newItem )
            {
                //make a new node containing that item.
                Node tempNode = new Node( newItem, curr );
                prev.setLink(tempNode);
            }
        }
        
        /*
            Delete a node if the node you're 
            looking for actually exists.
        */
        public void delete( int key )
        {
            Node curr = top.link;
            Node prev = top;
            
            //while we haven't found the node and we're
            //not back at the start.
            while( curr.data != key && curr != top )
            {
                //iterate
                prev = curr;
                curr = curr.link;
            }
            //if we found node
            if( curr.data == key )
            {
                //have the links skip over it.
                prev.setLink( curr.link );
            }
        }
        
        /*
            Take the union of two sets and place
            the results in another set.
        */
        public void union( Set a, Set b )
        {
            Node currA = a.top.link;
            Node currB = b.top.link;
            Node last = top.link;
            //are we finished with both lists?
            boolean done = false;
            
            //while we're not done yet.
            while( !done )
            {
                //have both lists reached the end
                if( currA.data == Integer.MIN_VALUE && currB.data == Integer.MIN_VALUE )
                {
                    //then we're done.
                    done = true;
                }
                else
                {
                    //if we're pointing at two identical items.
                    if( currA.data == currB.data )
                    {
                        //have a new node point at top with the right data.
                        Node tempNode = new Node( currA.data, top );
                        //point our last node at the new one.
                        last.setLink(tempNode);
                        //iterate last one time to now be pointing at the last node.
                        last = last.link;
                        //iterate a and b.
                        currA = currA.link;
                        currB = currB.link;
                    }
                    //if a is smaller than b.
                    else if( currA.data < currB.data )
                    {   
                        //is a at the end?
                        if( currA.data == Integer.MIN_VALUE )
                        {
                            //it is. finish b instead
                            while( currB.data != Integer.MIN_VALUE )
                            {
                                //same as before but only iterate b
                                Node tempNode = new Node( currB.data, top );
                                last.setLink(tempNode);
                                last = last.link;
                                currB = currB.link;
                            }
                        }
                        else
                        {
                            //otherwise do a once and only iterate a.
                            Node tempNode = new Node( currA.data, top );
                            last.setLink(tempNode);
                            last = last.link;
                            currA = currA.link;
                        }
                    }
                    //b is smaller than a
                    else if( currB.data < currA.data )
                    {
                        //is be at the end?
                        if( currB.data == Integer.MIN_VALUE )
                        {
                            // it is, so finish a.
                            while( currA.data != Integer.MIN_VALUE )
                            {
                                //same old method, just only iterate a.
                                Node tempNode = new Node( currA.data, top );
                                last.setLink(tempNode);
                                last = last.link;
                                currA = currA.link;
                            }
                        }
                        else
                        {
                            //otherwise add the new node and iterate b once.
                            Node tempNode = new Node( currB.data, top );
                            last.setLink(tempNode);
                            last = last.link;
                            currB = currB.link;
                        }
                    }
                }
            }
        }
        
        /*
            Take the difference of two sets and place
            the result in a new set. Largely the same
            process as union with a few small changes.
        */
        public void difference( Set a, Set b )
        {
            Node currA = a.top.link;
            Node currB = b.top.link;
            Node last = top.link;
            boolean done = false;
            
            while( !done )
            {
                if( currA.data == Integer.MIN_VALUE )
                {
                    done = true;
                }
                else
                {
                    if( currA.data == currB.data )
                    {
                        currA = currA.link;
                        currB = currB.link;
                    }
                    else if( currA.data < currB.data )
                    {
                        if( currA.data != Integer.MIN_VALUE )
                        {
                            Node tempNode = new Node( currA.data, top );
                            last.setLink(tempNode);
                            last = last.link;
                            currA = currA.link;
                        }
                    }
                    //if b is ever smaller, just skip over it.
                    else if( currB.data < currA.data )
                    {
                        if( currB.data != Integer.MIN_VALUE )
                        {
                        currB = currB.link; 
                        }
                        else
                        {
                            while( currA.data != Integer.MIN_VALUE )
                            {
                                Node tempNode = new Node( currA.data, top );
                                last.setLink(tempNode);
                                last = last.link;
                                currA = currA.link;
                            }
                        }
                    }
                }
            }
        }
        
        /*
            print the given list in the format
            {_, _, _,......}.
        */
        public static void printList( Set s )
        {
            //most items on one line.
            int listMax = 10;
            
            System.out.print("{");
            //if there are no nodes in the list close the brace right away.
            if( s.top.link.data == Integer.MIN_VALUE )
            {
            System.out.print("}");
            }
            //count how many nodes we have.
            int counter = 1;
            //check if we're back at the start.
            for( Node curr  = s.top.link; curr != s.top; curr = curr.link )
            {
                //if we have 10 nodes.
                if( counter == listMax )
                {
                    //print the last node with a closing brace.
                    System.out.println(curr.data+"}");
                    //reset counter.
                    counter = 1; 
                    //open another brace for the next line if we have more.
                    if( curr.link != s.top )
                    {
                    System.out.print("{");
                    }
                } 
                //if we're right before the max nodes.
                else if( counter == listMax - 1 )
                {
                    //is the next node top?
                    if( curr.link == s.top )
                    {
                        //close the brace.
                        System.out.print(curr.data+"}");
                    }
                    //otherwise
                    else
                    {
                        //continue normally.
                        System.out.print(curr.data+", ");
                        counter++;
                    }
                }
                //no more nodes
                else if( curr.link == s.top )
                {
                    //close the brace
                    System.out.print(curr.data+"}");
                    counter++; 
                }
                //nothing special is happening.
                else
                {
                    System.out.print(curr.data+", ");
                    counter++;
                }
            }
        }
        
        /*
            take our intructions from a file
        */
        public static void test()
        {
            //our array of sets.
            Set[] sets;
            //our scanner.
            Scanner in = null;
            
            //try to open the file.
            try
            {
                //open the file.
                in = new Scanner( new FileReader( "a2data.txt" ) );
            }
            //if we counln't fine the file.
            catch( FileNotFoundException e )
            {
                //print the stack trace.
                e.printStackTrace();
            }
            
            //get the first number in the file ( the size of the array ).
            int size = in.nextInt();
            //initialize the array.
            sets = new Set[size];
            //place a new set in every spot of the array.
            for( int i = 0; i < size; i++ )
            {
                sets[i] = new Set();
            }
            //next line
            in.nextLine();
            
            //if we have another token.
            while( in.hasNext() )
            {
                //grab the next char.
                String type = in.next();
                
                //if P then print.
                if( type.equals( "P" ) )
                {
                    //print lines only have one int
                    int setNumber = in.nextInt();
                    System.out.println("Set "+setNumber);
                    printList(sets[setNumber]);
                    System.out.println();
                }
                //if I then insert
                else if( type.equals( "I" ) )
                {
                    //insert line take two ints. the first for the 
                    //set number, second for the nodes data.
                    sets[in.nextInt()].orderedInsert(in.nextInt());
                }
                //if D then delete
                else if( type.equals( "D" ) )
                {
                    //delete takes two ints. first for the set
                    //number, second for the nodes data.
                    sets[in.nextInt()].delete(in.nextInt());
                }
                //if U then union.
                else if( type.equals( "U" ) )
                {
                    //union takes three ints
                    //first and second for the sets to union,
                    //third for the set you want the union in.
                    int set1 = in.nextInt();
                    int set2 = in.nextInt();
                    int resultSet = in.nextInt();
                    
                    //make a new set for the union.
                    sets[resultSet] = new Set();
                    sets[resultSet].union(sets[set1], sets[set2]);
                }
                //if \ then difference
                else if( type.equals( "\\" ) )
                {
                    //difference takes three ints.
                    //first and second for the sets to differentiate
                    //third for the set you want the difference in.
                    int set1 = in.nextInt();
                    int set2 = in.nextInt();
                    int resultSet = in.nextInt();
                    
                    //make a new set for the difference.
                    sets[resultSet] = new Set();
                    sets[resultSet].difference( sets[set1], sets[set2] );
                }
            }
            //close the file.
            in.close();
        }
    }
    
    /*
        Node class. Allows you to create a new Node
        and set what it is linked to.
    */
    static class Node
    {
        private int data;
        private Node link;
        
        //make a new node with given data and link.
        public Node( int origData, Node origLink )
        {
            data = origData;
            link = origLink;
        }
        
        //set the nodes link.
        public void setLink( Node n )
        {
            link = n;
        }
    }    
}