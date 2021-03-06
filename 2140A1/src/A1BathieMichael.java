/*
A1BathieMichael

COMP 2140 SECTION A01
INSTRUCTOR HELEN CAMERON
ASSIGNMENT #1
Michael Bathie, 7835010
2018/9/11

PURPOSE: Testing sorting algorithms
*/

import java.lang.Math;

public class A1BathieMichael 
{
    private static int[] test = new int[10000];
    private static final int START = 0;
    private static final int END = test.length;
    private static final int RANDOM_SWAPS = 2500;
    
    public static long[] iSortTimings = new long[100]; //insertion sort timings
    public static long[] mSortTimings = new long[100]; // merge sort timings
    public static long[] qSortTimings = new long[100]; //quick sort timings
    public static long[] hqSortTimings = new long[100]; //hybrid quick sort timings
    
    //main
    public static void main( String[] args )
    {
        long start, stop; //start and stop the timer
        
        for( int i = 0; i < 100; i++ ) //test insertion sort
        {
            fill( test, RANDOM_SWAPS );
            start = System.nanoTime();
            insertionSort( test );
            stop = System.nanoTime();
            iSortTimings[i] = ( stop - start );
        }
        System.out.println();
        sorted( test, "Insertion Sort" ); //make sure it's sorted
        for( int i = 0; i < 100; i++ ) //test merge sort
        {
            fill( test, RANDOM_SWAPS );
            start = System.nanoTime();
            mergeSort( test );
            stop = System.nanoTime();
            mSortTimings[i] = ( stop - start );
        }
        System.out.println();
        sorted( test, "Merge Sort" ); //make sure it's sorted
        for( int i = 0; i < 100; i++ ) //test quick sort
        {
            fill( test, RANDOM_SWAPS );
            start = System.nanoTime();
            quickSort( test );
            stop = System.nanoTime();
            qSortTimings[i] = ( stop - start );
        }
        System.out.println();
        sorted(test, "Quick Sort" ); //make sure it's sorted
        for( int i = 0; i < 100; i++ ) //test the hybrid sort
        {
            fill( test, RANDOM_SWAPS );
            start = System.nanoTime();
            hybridQuickSort( test );
            stop = System.nanoTime();
            hqSortTimings[i] = ( stop - start );
        }
        System.out.println();
        sorted( test, "Hybrid Quick Sort" ); // make sure it's sorted
        
        double insertionSortMean = (Stats.mean( iSortTimings ));
        double insertionSortStdDev = Stats.standardDeviation( iSortTimings );
        
        double mergeSortMean = (Stats.mean( mSortTimings ));
        double mergeSortStdDev = Stats.standardDeviation( mSortTimings );
        
        double quickSortMean = (Stats.mean( qSortTimings ));
        double quickSortStdDev = Stats.standardDeviation( qSortTimings );
        
        double hybridQuickSortMean = (Stats.mean( hqSortTimings ));
        double hybridQuickSortStdDev = Stats.standardDeviation( hqSortTimings );
        
        double zStatim = Stats.zTest( iSortTimings, mSortTimings );
        double zStatiq = Stats.zTest( iSortTimings, qSortTimings );
        double zStatihq = Stats.zTest( iSortTimings, hqSortTimings );
        double zStatmq = Stats.zTest( mSortTimings, qSortTimings );
        double zStatmhq = Stats.zTest( mSortTimings, hqSortTimings );
        double zStatqhq = Stats.zTest( qSortTimings, hqSortTimings );
        System.out.println();
        System.out.println("MEAN STATISTICS:");
        System.out.println( "Insertion Sort: "+insertionSortMean+
                "\nMerge Sort: "+mergeSortMean+
                "\nQuick Sort: "+quickSortMean+
                "\nHybrid Quick Sort: "+hybridQuickSortMean );
        
        System.out.println();
        System.out.println("STANDARD DEVIATIONS:");
        System.out.println( "Insertion Sort: "+insertionSortStdDev+
                "\nMerge Sort: "+mergeSortStdDev+
                "\nQuick Sort: "+quickSortStdDev+
                "\nHybrid Quick Sort: "+hybridQuickSortStdDev );
        
        System.out.println();
        System.out.println("Z STATISTICS:");
        System.out.println( "Insertion Sort & Merge Sort: "+zStatim+
                "\nInsertion Sort & Quick Sort: "+zStatiq+
                "\nInsertion Sort & Hybrid Quick Sort: "+zStatihq+
                "\nMerge Sort & Quick Sort: "+zStatmq+
                "\nMerge Sort & Hybrid Quick Sort: "+zStatmhq+
                "\nQuick Sort & Hybrid Quick Sort: "+zStatqhq );       
        
    }
    
    //check if the array is sorted
    private static void sorted( int[] a, String name )
    {
        int check = 0; //used to check if the array is sorted
        int wrongOrder = 0; //tracks index of the first out of order number
        String error = ""; //message
        
        for( int i = 0; i < a.length - 1; i++ )
        {
            if( a[i] <= a[i+1] )
            {
                check++;
            }
            else
            {
                wrongOrder = i+1; //index of the offending value
                error  = a[i]+" is not smaller than "+ a[i+1] + ". ";
                break; //get outta that loop
            }
        }
        if( check == a.length - 1 ) //the array is sorted
        {
            System.out.println( "The array is sorted. "+name+" was successful." );
        }
        else //it's not sorted
        {
            System.out.println( "The array is not sorted. " + error + "The first item "
                    + "out of sorted order is in index " + wrongOrder + ". "+name+" failed." );
        }
    }
    
    //fill and randomize the array
    private static void fill( int[] nums, int n )
    {
        for( int i = 0; i < nums.length; i++ ) //fill the array with numbers
        {
            nums[i] = i; //fill the array with numbers 0 to nums.length-1
        }
        for( int i = 0; i < n; i++ ) //swap the numbers around n times
        {
            //swap around two random values n times
            swap( nums, getRand( -1, nums.length - 1 ), getRand( -1, nums.length - 1 ) );
        }
    }
    
    //get a random number
    private static int getRand( int max, int min )
    {
        return ( int )( Math.random() * ( max - min) ) + min;
    }
    
    //Insertion Sort
    /*===================================================================*/
    
    //insertion sort
    private static void insertionSort( int[] nums, int start, int end )
    {
        int shift; //The item currently being shifted around
        int a; //the position in the array being compared to the shifting value
        
        for( int i = start+1; i < end; i++ )//get shift values
        {
            shift = nums[i];
            a = i-1;
            while( a>= start && nums[a] > shift )//compare shift values
            {
                nums[a+1] = nums[a];
                a--;
            }
            nums[a+1] = shift;//put shift in the right spot
        }
    }
    
    //public getter insertion sort
    public static void insertionSort( int[] nums )
    {
        insertionSort( nums, START, END );
    }
    
    //Merge Sort
    /*=====================================================================*/
    
    //public getting merge sort
    public static void mergeSort( int[] a)
    {
        int[] temp = new int[a.length];
        
        mergeSort( a, START, END, temp );
    }
    
    //merge sort
    private static void mergeSort( int[] a, int start, int end, int[] temp )
    {
        int mid;
        
        if( 1 < end - start )
        {
            mid = start + ( end - start )/2; //get the mid
            mergeSort( a, start, mid, temp ); //merge the first half
            mergeSort( a, mid, end, temp ); //merge the second half
            merge( a, start, mid, end, temp ); //merge the two halves together
        }
    }
    
    //merge the two sorted halves
    public static void merge( int[] a, int start, int mid, int end, int[] temp )
    {
        int currL = start; //current index on left half
        int currR = mid; //current index on right half
        int currT; //index of temp array
        
        for( currT = start; currT < end; currT++ )
        {
            if( currL < mid && ( currR >= end || a[currL] < a[currR] ) ) //should currL be added to currT
            {
                temp[currT] = a[currL];
                currL++;
            }
            else //add currR to currT
            {
                temp[currT] = a[currR];
                currR++;
            }
        }
        for( currT = start; currT < end; currT++ ) // copy over the array
        {
            a[currT] = temp[currT]; 
        }
    }
    
    //QuickSort
    /*======================================================================*/
    
    //public getter quick sort
    public static void quickSort( int[] a )
    {
        quickSort( a, START, END );
    }
    
    //quick sort
    private static void quickSort( int[] a, int start, int end )
    {
        int pivotPosn;
        
        if( 1 < end - start )
        {
            choosePivot( a, start, end ); //choose a good pivot
            pivotPosn = partition( a, start, end ); //situate the bigs and smalls around the pivot
            quickSort( a, start, pivotPosn ); //quick sort smalls
            quickSort( a, pivotPosn + 1, end ); //quick sort bigs
        }   
    }
    
    //swap method to swap two values in a given array
    private static void swap( int[] a, int item1, int item2 )
    {
        int temp = a[item1];
        a[item1] = a[item2];
        a[item2] = temp;
    }
    
    //partition the two halfs of the list on either side of the pivot
    private static int partition( int[] a, int start, int end )
    {
        int bigStart = start + 1;
        int pivot = a[start];
        
        for( int curr = start + 1; curr < end; curr++ )
        {
            if( a[curr] < pivot) //should be in smalls
            {
                swap( a, bigStart, curr );
                bigStart++;
            }
            //if it should be in bigs don't do anything
        }
        swap( a, start, bigStart - 1 ); //move the pivot to the correct spot
        return bigStart - 1; //return the pivots position
    }
    
    //choose a pivot using the median of three and move it to the front of the array
    private static void choosePivot( int[] a, int start, int end )
    {
        int mid = ( end - start )/2;
        
        if( a[start] < a[mid] && a[mid] < a[end - 1] || a[start] > a[mid] && a[mid] > a[end - 1] ) //checks if a[mid] is the middle number
        {
            swap( a, mid, start); //move a[mid] to the beginning of the array
        }
        else if( a[start] < a[end - 1] && a[end - 1] < a[mid] || a[start] > a[end - 1] && a[end - 1] > a[mid] ) //checks if a[end] is the middle number
        {
            swap( a, end - 1, start); //move a[end] to the beginng of the array
        }
        //if neither of the previous two cases are true then the first item
        //is the pivot so it doesn't have to move
    }
    
    //hybrid sort
    /*=========================================================================*/
    
    //public getter hybrid sort
    public static void hybridQuickSort( int[] a )
    {
        hybridQuickSort( a, START, END );
    }
    
    //hybrid sort
    private static void hybridQuickSort( int[] nums, int start, int end )
    {
        int pivotPosn;
        final int BREAKPOINT = 50;
        
        if( 1 < end - start )
        {
            if( ( end - start ) < BREAKPOINT ) //check to see if the part we're looking at is < BREAKPOINT
            {
                insertionSort( nums, start, end ); //if so then insertion sort
            }
            else if( nums.length > BREAKPOINT) //otherwise do a quick sort
            {
                choosePivot( nums, start, end );            //do
                pivotPosn = partition( nums, start, end );  //a
                hybridQuickSort( nums, start, pivotPosn );  //quick
                hybridQuickSort( nums, pivotPosn + 1, end );//sort
            }
        }
    }
}   
