// CLASS: List
//
// Author: Michael Bathie, 7835010
//
// REMARKS: The implementation of List
// Allows for the creation of a list, and
// defines the ways you can operate on it.
//
//-----------------------------------------

public class List {
    private Node top;
    private Node last;

    public Node start() {
        return top;
    }

    //------------------------------------------------------
    // add
    //
    // PURPOSE:    Add a ListItem to the list.
    // PARAMETERS:
    //     ListItem item: the item to add to the list.
    //------------------------------------------------------
    public void add(ListItem item) {

        //if the item is a value.
        if(item instanceof Value) {
            //cast it to that.
            Value v = (Value)item;
            //if the list is empty.
            if(top == null) {
                //set this item as the first node.
                top = new Node(v, null);
                last = top;
            }
            //if it's not the first item in the list.
            else {
                //set it to the last item in the list.
                last.setNext(new Node(v, null));
                last = last.getNext();
            }
        }
        //if item is a KeyValuePair
        else if(item instanceof KeyValuePair) {
            //cast it to that.
            KeyValuePair kvp = (KeyValuePair)item;
            //same process as the previous case.
            if(top == null) {
                top = new Node(kvp, null);
                last = top;
            }
            else {
                last.setNext(new Node(kvp, null));
                last = last.getNext();
            }
        }
    }

    //------------------------------------------------------
    // listString
    //
    // PURPOSE:    give a string representation of the list.
    // Returns: return the string representation of the current list.
    //------------------------------------------------------
    public String listString() {
        String message = "";
        Node curr = top;

        //while we're not at the end of the list.
        while(curr != null) {
            //if we're at the last item.
            if(curr.getNext() == null)
                message += curr.toString() + " ";
            //if we're not at the last item.
            else
                message += curr.toString() + " , ";
            //go to the next node.
            curr = curr.getNext();
        }

        return message;
    }

    //------------------------------------------------------
    // dupCheck
    //
    // PURPOSE:    checks if there is a duplicate in the list.
    // PARAMETERS:
    //     Value key: the key of the value we need to check for.
    // Returns: a pointer to the KeyValuePair of the duplicate.
    //------------------------------------------------------
    public KeyValuePair dupCheck(Value key) {
        Node curr = top;
        KeyValuePair kvp = null;
        boolean pairFound = false;

        //while we're not at the end of the list.
        while(curr != null) {
            //get the KeyValuePair of the current node.
            kvp = (KeyValuePair)curr.data();
            //if that key is equal to the key passed to this method.
            if(key.equals(kvp.key())) {
                //we found a pair.
                pairFound = true;
                //get out of the loop.
                break;
            }
            //go to the next node.
            curr = curr.getNext();
        }
        //if we didn't find a pair then it's null.
        if(!pairFound) {
            kvp = null;
        }

        return kvp;
    }

    //------------------------------------------------------
    // keySearch
    //
    // PURPOSE:    Look for a key.
    // PARAMETERS:
    //     Value k: the key we're looking for.
    // Returns: return a pointer to the value with the given key.
    //------------------------------------------------------
    public Value keySearch(Value k) {
        Node curr = top;
        KeyValuePair kvp = null;
        Value returnValue = null;

        //while we're not at the end of the list.
        while(curr != null) {
            //if the node we're pointing at holds a KeyValuePair.
            if(curr.data() instanceof KeyValuePair) {
                //if the key we passed and the key of the KeyValuePair have equal keys.
                if(((KeyValuePair) curr.data()).key().equals(k)) {
                    //grab the value of that KeyValuePair.
                    returnValue = ((KeyValuePair) curr.data()).getVal();
                    //get out of the loop.
                    break;
                }
            }
            //go to the next node.
            curr = curr.getNext();
        }

        //if we don't have a return value.
        if(returnValue == null)
            //just return an empty StringValue.
            returnValue = new StringValue("");

        return returnValue;
    }
}
