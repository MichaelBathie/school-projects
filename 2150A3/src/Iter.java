// CLASS: Iter
//
// Author: Michael Bathie, 7835010
//
// REMARKS: The implementation of Iter.
// An iterator that allows anyone to iterate
// over an ObjectValue or ArrayValue without
// knowing the Values.
//
//-----------------------------------------

public class Iter implements JSONIter {
    private List list;
    private Node curr;
    //checks if the iterator has looked at the first item.
    private int num = 0;

    //constructor.
    public Iter(List l) {
        curr = l.start();
    }

    //------------------------------------------------------
    // hasNext
    //
    // PURPOSE:    checks if the iterator has another item.
    // Returns: returns a boolean indicating if the iterator
    // has another item in it.
    //------------------------------------------------------
    public boolean hasNext() {
        boolean next;
        //if the iterator isnt empty and it hasnt looked at the first item.
        if(curr != null && num == 0) {
            next = true;
        }
        //otherwise just check the next item.
        else {
            next = curr.nextCheck();
        }
        return next;
    }

    //------------------------------------------------------
    // getNext
    //
    // PURPOSE:    get the next item in the list.
    // Returns: return the next item in the list if it exists.
    //------------------------------------------------------
    public Value getNext() {
        ListItem item;
        Value v = null;
        //if the iterator isnt empty and we haven't looked at the first item.
        if(num == 0 && curr != null) {
            //grab the item.
            item = curr.data();
            //say we've looked at the first item.
            num = 1;

            //if that item is a KeyValuePair.
            if(item instanceof KeyValuePair)
                //cast it to that
                v = ((KeyValuePair)item).key();
            //otherwise if its a Value
            else if(item instanceof Value)
                //cast it to that.
                v = (Value)item;
        }
        //if we're not looking that the first item
        //and the iterator has another item in it.
        else if(curr.getNext() != null) {
            //iterate and grab the item.
            curr = curr.getNext();
            item = curr.data();
            //do the same thing as in the previous case.
            if(item instanceof KeyValuePair)
                v = ((KeyValuePair)item).key();
            else if(item instanceof Value)
                v = (Value)item;
        }
        return v;
    }
}
