/**
 * class A3BathieMichael
 * 
 * COMP 2140 SECTION A1
 * INSTRUCTOR   Helen Cameron
 * ASSIGNMENT   #3
 * @author      Michael Bathie, 7835010
 * @version     November 5th, 2018
 * 
 * PURPOSE: This program implements Stacks and Queues to create
 * the card game WAR.
 *
 */

public class A3BathieMichael 
{
    //two Queues for each player's hand
    private final Queue player1 = new Queue();
    private final Queue player2 = new Queue();
    
    private final Stack completedDeck = new Stack(); //the initial deck
    
    private final int DECK_SIZE = 52;
    private final int SWAP = 1000; //how many swaps to be performed
    
    private boolean war = false; //whether or not a war is going on
    
    private int howManyWars = 0; //how many war instances are open
    
    public static void main( String[] args )
    {
        A3BathieMichael game = new A3BathieMichael(); //start a new game    
        game.gameSetup(); 
        while( !game.gameIsDone() )
        {
            game.play();
        }
        
        String print = game.winner();
        System.out.println( print );
        
        System.out.println("\nProgram ends normally.");
    }
    
    /*
        gameSetup makes, fills, and randomizes a deck of cards, then puts
        half into each player's hand.
    */
    private void gameSetup()
    {
        System.out.println("Setting up the War card game...");
        
        fill( completedDeck.stack, SWAP );//fill it with numbers 0-51 and swap two random positions SWAP times
        
        for( int i = 0; i < DECK_SIZE/2; i++ )
        {
            //give each player half of the deck
            player1.enter(completedDeck.pop());
            player2.enter(completedDeck.pop());
        }
    }
    
    /*
        gameIsDone check if the game is over by checking if
        either of the player's hands is empty.
    */
    private boolean gameIsDone()
    {
        //is either hand empty
        return player1.isEmpty() || player2.isEmpty();
    }
    
    /*
        play begins the process of the actual game by taking two cards out of
        each player's hand and putting them in the pot. It also calls the compare
        method to compare the two cards.
    */
    private void play()
    {
        int p1Card = player1.leave();
        int p2Card = player2.leave();
        Stack pot = new Stack(); //keep track of the cards that have been played
        int rand = getRand( 1, 0 );
        //push them in in a random order
        if( rand == 1 )
        {
            pot.push(p1Card);
            pot.push(p2Card);
        }
        else
        {
            pot.push(p2Card);
            pot.push(p1Card);
        }
        compare( p1Card, p2Card, pot);
    }
    
    /*
        compare takes in two integer values to be compared and takes in
        a stack, which is the pot that will continue to be passed through 
        certain methods. If one card is greater than the other, compare will
        finish the process of the round, if not, the war method will be called.
    */
    private void compare( int p1, int p2, Stack pot )
    {   
        System.out.print("Player 1:    "+getCard(p1)+
                "   Player 2:    "+getCard(p2) );
        
        if( getCardNum( p1 ) == getCardNum( p2 ) )
        {
            howManyWars++; //you're opening a war instance
            war = true; //a war is going on
            war( pot );
        }
        else if( getCardNum( p1 ) < getCardNum( p2 ) )
        {
            howManyWars = 0; //reset war instances because they're about to be closed
            if( war )
            {
                System.out.println("\nPlayer 2 wins this battle and recieves the pot!");
            }
            else
            {
            System.out.println("        Player 2 recieves both cards!");
            }
            while( !pot.isEmpty() )
            {
                player2.enter(pot.pop());
            }
        }
        else if( getCardNum( p1 ) > getCardNum( p2 ) )
        {
            howManyWars = 0; //reset war instances because they're about to be closed
            if( war )
            {
                System.out.println("\nPlayer 1 wins this battle and recieves the pot!");
            }
            else
            {
            System.out.println("        Player 1 recieves both cards!");
            }
            while( !pot.isEmpty())
            {
                player1.enter(pot.pop());
            }
        }
        war = false; // you finished comparing the integers so you're not in a war anymore
    }
    
    /*
        war is called when the two cards pulled are equal in number, it also
        is passed the pot.war will pull two cards from each player's hand 
        to up the stakes,then pull another card from each hand to compare to 
        see who wins the pot. If the two cards are equal once again, then
        another instance of war will open. This process can continue until
        one card is larger or until one player runs out of cards.
    */
    private void war( Stack pot )
    {
        if( howManyWars > 1 )
        {
            System.out.println("\n   **   War continues...");
        }
        else
        {
            System.out.println("\n   **   It is War!");
        }
            
        //pull out the ante for each and the two cards to be compared
        int p1Ante1 = player1.leave();
        int p1Ante2 = player1.leave();
        int p2Ante1 = player2.leave();
        int p2Ante2 = player2.leave();
        int p1Card = player1.leave();
        int p2Card = player2.leave();
        
        System.out.println("Player 1 Ante: \n"+getCard(p1Ante1)+"\n"+getCard(p1Ante2));
        System.out.println("Player 2 Ante: \n"+getCard(p2Ante1)+"\n"+getCard(p2Ante2));
        
        //put all the cards in the pot
        pot.push(p1Ante1);
        pot.push(p1Ante2);
        pot.push(p2Ante1);
        pot.push(p2Ante2);
        pot.push(p1Card);
        pot.push(p2Card);
            
        //swap two random cards in the pot to avoid the chance of a tie
        swap(pot.stack, getRand(pot.top, 0 ), getRand( pot.top, 0 ) );
        
        //compare the two cards
        compare( p1Card, p2Card, pot );
    }
    
    /*
        winner checks which player's hand is empty,
        as it's only called after the game is over. it will return
        an appropriate string depending on which player one the war.
    */
    private String winner()
    {
        String winner = "";
        
        if( player1.isEmpty() )
        {
            System.out.println("\n   **   Player 1 is out of cards!\n");
            winner +="Player 2 has won the war!";
        }
        else
        {
            System.out.println("\n   **   Player 2 is out of cards!\n");
            winner +="Player 1 has won the war!";
        }
        return winner;
    }
    
    /*
        getCardNum return the actual number of the card.
    */
    private int getCardNum( int n )
    {
        return 1 + ( n % 13 ); //get the cards number from 1-13
    }
    
    /*
        getCard is used to format how a card should be printed.
    */
    private String getCard( int n )
    {
        String card = "";
        //card symbol values
        final char SPADES = 9824;
        final char HEARTS = 9829;
        final char CLUBS = 9830;
        final char DIAMONDS = 9827;
        
        switch( getCardNum(n) )
        {
            case 1 :
                card += 'A';
                break;
            case 11 :
                card += 'J';
                break;
            case 12 :
                card += 'Q';
                break;
            case 13 :
                card += 'K';
                break;
            default :
                card += getCardNum(n);
        }
        
        switch( n/13 )
        {
            case 0 :
                card += SPADES;
                break;
            case 1 :
                card += DIAMONDS;
                break;
            case 2 :
                card += HEARTS;
                break;
            case 3 :
                card += CLUBS;
                break;
            default : 
                card = " No cards left! ";
        }
        
        return card;
    }
    
    /*
        fill takes in an array and an integer. The array is the 
        array you want to fill with numbers. The represents the number
        of times you want two random positions in the array to be swapped.
    */
    private void fill( int[] nums, int n )
    {
        for( int i = 0; i < nums.length; i++ ) //fill the array with numbers
        {
            completedDeck.push(i); //fill the array with numbers 0 to nums.length-1
        }
        for( int i = 0; i < n; i++ ) //swap the numbers around n times
        {
            //swap around two random values n times
            swap( nums, getRand( nums.length - 1, 0 ), getRand( nums.length - 1, 0 ) );
        }
    }
    
    /*
        getRand returns a random number from max to min inclusive.
        It contains the standard stack methods.
    */
    private static int getRand( int max, int min )
    {
        return ( int )( Math.random() * (( max - min) + 1 )) + min;
    }
    
    
    /*
        swap will swap the numbers in two spots in an array.
    */
    private static void swap( int[] a, int item1, int item2 )
    {
        int temp = a[item1];
        a[item1] = a[item2];
        a[item2] = temp;
    }
    
    /*
        The Stack class is an ADT implemented as an array.
    */
    class Stack
    {
        int top;
        int[] stack;
        
        public Stack()
        {
            top = -1;
            stack = new int[DECK_SIZE];
        }
        
        public void push( int n )
        {
            top++;
            stack[top] = n;
        }
        
        public int pop()
        {
            int val = stack[top];
            if( !isEmpty() )
            {
                top--;
            }
            return val;
        }
        
        public int top()
        {
            return stack[top];
        }
        
        public boolean isEmpty()
        {
            return top == -1;
        }
    }
    
    /*
        The Queue class is an ADT implemented as an array.
        It contains the standard queue methods
    */
    class Queue
    {
        int front;
        int end;
        int[] queue;
        int counter; //keep track of the size of the queue
        
        public Queue()
        {
            front = DECK_SIZE/2;
            end = DECK_SIZE/2;
            queue = new int[DECK_SIZE];
            counter = 0; // how many elements
            for( int i = 0; i < queue.length; i++ )
            {
                queue[i] = Integer.MIN_VALUE;
            }
        }
        
        public void enter( int n )
        {
            counter++;
            if( isEmpty() )
            {
                queue[front] = n;
            }
            else
            {
                end = ( end+1 ) % queue.length;
                queue[end] = n;
            }
        }
        
        public int leave()
        {
            int val = queue[( front+1 ) % queue.length];
            
            if( !isEmpty() )
            {
                counter--;
                front = ( front+1 ) % queue.length;
                return val;
            }
            return Integer.MIN_VALUE;
        }
        
        public int front()
        {
            return queue[front];
        }
        
        public boolean isEmpty()
        {
            return counter == 0;
        }
    }
    
}